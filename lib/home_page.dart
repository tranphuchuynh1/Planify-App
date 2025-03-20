import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hoctapflutter/router.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
              body: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        router.go(
                            '/detail',
                          extra: {
                              'id' : '1',
                              'tag': 'hero-image-1',
                              'imagePath' : "assets/images/dev.png",
                              'description' : "this is senior developer",
                          },
                        );
                        setState(() {

                        });
                      },
                      child: Hero(
                          tag: 'hero-image-1',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.asset(
                                "assets/images/dev.png",
                                width: 100,
                                height: 100,
                              fit: BoxFit.cover,
                            ),
                          )
                      ),
                    ),

                 const SizedBox(height: 20),
                 GestureDetector(
                  onTap: () {
                    router.go(
                      '/detail',
                      extra: {
                        'id' : '2',
                        'tag': 'hero-image-2',
                        'imagePath' : "assets/images/TMA-logo.png",
                        'description' : "this is TMA logo",
                      },
                    );
                    setState(() {

                    });
                  },
                  child: Hero(
                      tag: 'hero-image-2',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          "assets/images/TMA-logo.png",
                            height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      )
                  ),
                ),
                ],
              )
              ),
    );
  }
}