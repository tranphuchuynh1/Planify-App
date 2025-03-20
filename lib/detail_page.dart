
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  // khai bao du lieu input
  final TextEditingController _commentController = TextEditingController(); // Controller get content input
  var TextOutput = "";

  @override
  Widget build(BuildContext context) {
    //nhận dữ liệu từ homepage qua extra
    final extra = GoRouterState.of(context).extra as Map<String, String>?;

    final id = extra?['id'] ?? ""; // get id form extra
    final tag = extra?['tag'] ?? ""; // get tag
    final imagePath = extra?['imagePath'] ?? ""; // get location img
    final description = extra?['description'] ?? ""; // get description

    return Scaffold(
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Hero(
                  tag: tag,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      imagePath,
                      width: 550,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                  )
              ),
            ),
           ),
          const SizedBox(height: 15,),
          Text(
              "Bài viết số $id",
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.blue
            ),
          ),
          const Divider(
            color: Colors.blue,
            thickness: 2,
            indent: 50,
            endIndent: 50,
          ),
          Text(
              "Mô tả: $description",
            style: const TextStyle(
              fontSize: 18,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
            child: TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: "Nhap noi dung...",
                labelText: "Comments",
                contentPadding: EdgeInsets.all(5),
              ),
            ),
          ),
          SizedBox(height: 20,),
          TextButton(
              onPressed: () {
                  setState(() {
                      TextOutput = _commentController.text;
                  });
              },
              child: const Text(
                  "Comment",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
          ),
           SizedBox(height: 30),
          Text(
              "Comments: $TextOutput",
            style: const TextStyle(
              fontSize: 18,
            ),
          )
        ],
      ),
    );
  }
}
