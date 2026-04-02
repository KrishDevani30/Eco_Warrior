import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/auth/login_page.dart';

final appRouter = GoRouter(
  initialLocation: '/login', // Start at login for Auth testing
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
  ],
);
