import 'package:flutter/material.dart';
import 'package:hoctapflutter/ui/profile/profile_page.dart';
import 'add_task_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  List<Widget> _pages = [];
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();

    _pages = [
      const IndexPage(), // Home page
      Container(
        color: Colors.green,
        child: const Center(
          child: Text(
            'Calendar Page',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      ),
      Container(), // Empty for FAB
      Container(
        color: Colors.yellow,
        child: const Center(
          child: Text(
            'Focus Page',
            style: TextStyle(color: Colors.black, fontSize: 24),
          ),
        ),
      ),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: _pages.elementAt(_currentPage),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF363636),
        unselectedItemColor: Colors.white,
        selectedItemColor: const Color(0xFF8687E7),
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentPage,
        onTap: (index) {
          if (index == 2) {
            return;
          }
          setState(() {
            _currentPage = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Image.asset("assets/images/home.png",
            width: 24, height: 24, fit: BoxFit.fill,
          ) ,
              activeIcon: Image.asset("assets/images/home.png",
                width: 24, height: 24, fit: BoxFit.fill,color: const Color(0xFF8687E7),
              ),
              label: "Home", backgroundColor: Colors.transparent
          ),
          BottomNavigationBarItem(icon: Image.asset("assets/images/calendar.png",
            width: 24, height: 24, fit: BoxFit.fill,
          ) ,
              activeIcon: Image.asset("assets/images/calendar.png",
                width: 24, height: 24, fit: BoxFit.fill,color: const Color(0xFF8687E7),
              ),
              label: "Calendar", backgroundColor: Colors.transparent
          ),
          BottomNavigationBarItem(icon: Container(),
              label: "", backgroundColor: Colors.transparent
          ),
          BottomNavigationBarItem(icon: Image.asset("assets/images/clock.png",
            width: 24, height: 24, fit: BoxFit.fill,
          ) ,
              activeIcon: Image.asset("assets/images/clock.png",
                width: 24, height: 24, fit: BoxFit.fill,color: const Color(0xFF8687E7),
              ),
              label: "Focuse", backgroundColor: Colors.transparent
          ),
          BottomNavigationBarItem(icon: Image.asset("assets/images/user.png",
            width: 24, height: 24, fit: BoxFit.fill,
          ) ,
              activeIcon: Image.asset("assets/images/user.png",
                width: 24, height: 24, fit: BoxFit.fill,color: const Color(0xFF8687E7),
              ),
              label: "Profile", backgroundColor: Colors.transparent
          ),
        ],
      ),
      floatingActionButton: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: const Color(0xFF8687E7),
          borderRadius: BorderRadius.circular(32),
        ),
        child: IconButton(
            onPressed: _navigateToAddTask,
            icon: const Icon(
              Icons.add,
              size: 30,
              color: Colors.white,
            )
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _navigateToAddTask() async {
    // Navigate to AddTaskPage
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTaskPage(),
      ),
    );

    if (result != null) {
      // Handle the returned task data
      print('Task created: $result');
      // You can add the task to a list, save to database, etc.
    }
  }
}

// Index Page Widget - Same as before
class IndexPage extends StatelessWidget {
  const IndexPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.sort,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () {
            // Open drawer or menu
          },
        ),
        title: const Text(
          'Index',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[800],
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background papers
                  Positioned(
                    left: 20,
                    top: 30,
                    child: Container(
                      width: 120,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 40,
                    top: 20,
                    child: Container(
                      width: 120,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Checkboxes
                            Row(
                              children: [
                                Icon(Icons.check_box,
                                    color: Colors.grey[400], size: 16),
                                const SizedBox(width: 6),
                                Container(
                                  width: 60,
                                  height: 2,
                                  color: Colors.grey[300],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.check_box,
                                    color: Colors.grey[400], size: 16),
                                const SizedBox(width: 6),
                                Container(
                                  width: 50,
                                  height: 2,
                                  color: Colors.grey[300],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.check_box_outline_blank,
                                    color: Colors.grey[400], size: 16),
                                const SizedBox(width: 6),
                                Container(
                                  width: 45,
                                  height: 2,
                                  color: Colors.grey[300],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.check_box_outline_blank,
                                    color: Colors.grey[400], size: 16),
                                const SizedBox(width: 6),
                                Container(
                                  width: 55,
                                  height: 2,
                                  color: Colors.grey[300],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Character
                  Positioned(
                    right: 10,
                    bottom: 20,
                    child: Container(
                      width: 80,
                      height: 100,
                      child: Stack(
                        children: [
                          // Character body
                          Positioned(
                            left: 20,
                            bottom: 0,
                            child: Container(
                              width: 40,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                          // Character head
                          Positioned(
                            left: 25,
                            top: 10,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: Color(0xFF8687E7),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Main text
            const Text(
              'What do you want to do today?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Subtitle
            Text(
              'Tap + to add your tasks',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}