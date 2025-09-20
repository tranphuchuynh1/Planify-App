import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class FocusPage extends StatefulWidget {
  const FocusPage({Key? key}) : super(key: key);

  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> with TickerProviderStateMixin {
  Timer? _timer;
  int _totalSeconds = 0;
  int _currentSeconds = 0;
  bool _isRunning = false;
  late AnimationController _circleController;
  late AnimationController _pulseController;

  // Focus session durations (in minutes)
  final List<int> _durations = [15, 25, 30, 45, 60];
  int _selectedDuration = 25; // Default 25 minutes

  // Weekly stats (mock data for now)
  String _selectedPeriod = 'This Week';
  final List<String> _periods = ['This Week', 'Last Week', 'This Month'];

  // Mock weekly data (hours per day)
  final Map<String, List<double>> _weeklyData = {
    'This Week': [2.5, 3.5, 5.0, 3.0, 4.0, 4.5, 2.0],
    'Last Week': [2.0, 3.0, 4.5, 2.5, 3.5, 4.0, 1.5],
    'This Month': [2.8, 3.2, 4.8, 3.2, 4.2, 4.2, 2.2],
  };

  final List<String> _weekDays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
  final int _todayIndex = DateTime.now().weekday % 7; // Current day

  // Mock app usage data
  final List<Map<String, dynamic>> _appUsage = [
    {
      'name': 'Instagram',
      'icon': '📷',
      'color': Colors.purple,
      'time': 240, // minutes
    },
    {
      'name': 'Twitter',
      'icon': '🐦',
      'color': Colors.blue,
      'time': 180,
    },
    {
      'name': 'Facebook',
      'icon': '📘',
      'color': Colors.blue[800],
      'time': 60,
    },
    {
      'name': 'Telegram',
      'icon': '✈️',
      'color': Colors.lightBlue,
      'time': 30,
    },
    {
      'name': 'Gmail',
      'icon': '📧',
      'color': Colors.red,
      'time': 45,
    },
  ];

  @override
  void initState() {
    super.initState();
    _circleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _totalSeconds = _selectedDuration * 60;
    _currentSeconds = _totalSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _circleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (_currentSeconds <= 0) {
      _currentSeconds = _totalSeconds;
    }

    setState(() {
      _isRunning = true;
    });

    _pulseController.repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_currentSeconds > 0) {
          _currentSeconds--;
        } else {
          _stopTimer();
          _onSessionComplete();
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _pulseController.stop();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _currentSeconds = _totalSeconds;
    });
  }

  void _onSessionComplete() {
    // Show completion dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF363636),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Session Complete!',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
        ),
        content: Text(
          'Great job! You focused for ${_selectedDuration} minutes.',
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetTimer();
            },
            child: const Text('New Session', style: TextStyle(color: Color(0xFF8687E7))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetTimer();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8687E7),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDurationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF363636),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Focus Duration',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              ..._durations.map((duration) => ListTile(
                title: Text(
                  '$duration minutes',
                  style: TextStyle(
                    color: _selectedDuration == duration ? const Color(0xFF8687E7) : Colors.white,
                    fontWeight: _selectedDuration == duration ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
                trailing: _selectedDuration == duration
                    ? const Icon(Icons.check, color: Color(0xFF8687E7))
                    : null,
                onTap: () {
                  setState(() {
                    _selectedDuration = duration;
                    _totalSeconds = duration * 60;
                    if (!_isRunning) {
                      _currentSeconds = _totalSeconds;
                    }
                  });
                  Navigator.pop(context);
                },
              )),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatAppTime(int minutes) {
    if (minutes >= 60) {
      int hours = minutes ~/ 60;
      int remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '${hours}h';
      }
      return '${hours}h ${remainingMinutes}m';
    }
    return '${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalSeconds > 0 ? (_totalSeconds - _currentSeconds) / _totalSeconds : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: const Text(
          'Focus Mode',
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showDurationPicker,
            icon: const Icon(Icons.timer, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Timer Circle
            GestureDetector(
              onTap: _showDurationPicker,
              child: Container(
                width: 280,
                height: 280,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background circle
                    CustomPaint(
                      size: const Size(280, 280),
                      painter: CircleProgressPainter(
                        progress: progress,
                        isRunning: _isRunning,
                        pulseAnimation: _pulseController,
                      ),
                    ),
                    // Time display
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(_currentSeconds),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        if (!_isRunning && _currentSeconds == _totalSeconds)
                          Text(
                            'Tap timer to change duration',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Description text
            Text(
              'While your focus mode is on, all of your\nnotifications will be off',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 40),

            // Control button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isRunning ? _stopTimer : _startTimer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8687E7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  _isRunning ? 'Stop Focusing' : 'Start Focusing',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 60),

            // Overview Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: const Color(0xFF363636),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (context) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'Select Period',
                                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 20),
                              ..._periods.map((period) => ListTile(
                                title: Text(
                                  period,
                                  style: TextStyle(
                                    color: _selectedPeriod == period ? const Color(0xFF8687E7) : Colors.white,
                                    fontWeight: _selectedPeriod == period ? FontWeight.w500 : FontWeight.normal,
                                  ),
                                ),
                                trailing: _selectedPeriod == period
                                    ? const Icon(Icons.check, color: Color(0xFF8687E7))
                                    : null,
                                onTap: () {
                                  setState(() {
                                    _selectedPeriod = period;
                                  });
                                  Navigator.pop(context);
                                },
                              )),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF363636),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedPeriod,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Chart
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              child: CustomPaint(
                size: Size(MediaQuery.of(context).size.width - 80, 200),
                painter: BarChartPainter(
                  data: _weeklyData[_selectedPeriod]!,
                  labels: _weekDays,
                  todayIndex: _todayIndex,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Applications Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Applications',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // App usage list
            ..._appUsage.map((app) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF363636),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: app['color'],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        app['icon'],
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'You spent ${_formatAppTime(app['time'])} on ${app['name']} today',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.access_time,
                    color: Colors.white54,
                    size: 20,
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class CircleProgressPainter extends CustomPainter {
  final double progress;
  final bool isRunning;
  final Animation<double> pulseAnimation;

  CircleProgressPainter({
    required this.progress,
    required this.isRunning,
    required this.pulseAnimation,
  }) : super(repaint: pulseAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey[800]!
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress circle
    final progressPaint = Paint()
      ..color = const Color(0xFF8687E7)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    if (isRunning) {
      // Add pulse effect
      final pulseValue = pulseAnimation.value;
      progressPaint.strokeWidth = 8 + (pulseValue * 2);
    }

    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class BarChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> labels;
  final int todayIndex;

  BarChartPainter({
    required this.data,
    required this.labels,
    required this.todayIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final barWidth = (size.width - 40) / data.length;
    final maxValue = data.reduce((a, b) => a > b ? a : b);

    for (int i = 0; i < data.length; i++) {
      final barHeight = (data[i] / maxValue) * (size.height - 60);
      final x = 20 + i * barWidth + barWidth * 0.2;
      final barWidthActual = barWidth * 0.6;

      // Bar color
      paint.color = i == todayIndex ? const Color(0xFF8687E7) : Colors.grey[600]!;

      // Draw bar
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x,
            size.height - 40 - barHeight,
            barWidthActual,
            barHeight,
          ),
          const Radius.circular(4),
        ),
        paint,
      );

      // Draw value label
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${data[i].toStringAsFixed(data[i] % 1 == 0 ? 0 : 1)}h',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          x + barWidthActual / 2 - textPainter.width / 2,
          size.height - 35 - barHeight - textPainter.height,
        ),
      );

      // Draw day label
      final dayTextPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            color: i == todayIndex ? const Color(0xFF8687E7) : Colors.white.withOpacity(0.7),
            fontSize: 12,
            fontWeight: i == todayIndex ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      dayTextPainter.layout();
      dayTextPainter.paint(
        canvas,
        Offset(
          x + barWidthActual / 2 - dayTextPainter.width / 2,
          size.height - 20,
        ),
      );
    }

    // Draw Y-axis labels
    for (int i = 1; i <= 6; i++) {
      final y = size.height - 40 - (i / 6) * (size.height - 60);
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i}h',
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}