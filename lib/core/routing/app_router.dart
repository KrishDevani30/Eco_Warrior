import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/profile_page.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
    ),
  ],
);
