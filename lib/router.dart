

import 'package:go_router/go_router.dart';
import 'package:hoctapflutter/detail_page.dart';
import 'package:hoctapflutter/home_page.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
        path: "/",
      builder: (context, state) =>  HomePage(),
    ),
    GoRoute(
      path: "/detail",
      builder: (context, state) =>  const DetailPage(),
    )
  ]
);