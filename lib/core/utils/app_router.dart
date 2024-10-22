import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mona_coffee/features/authentications/presentation/pages/login_screen.dart';
import 'package:mona_coffee/features/home/presentation/pages/landing_screen.dart';

class AppRouter {
  GoRouter get router => _goRouter;
  late final GoRouter _goRouter = GoRouter(
    initialLocation: '/',
    routes: configRouter,
  );
}

final List<GoRoute> configRouter = [
  GoRoute(
    path: '/',
    name: 'intro',
    builder: (BuildContext context, GoRouterState state) {
      return const LandingScreen();
    },
  ),
  GoRoute(
    path: '/login',
    name: 'login',
    builder: (BuildContext context, GoRouterState state) {
      return const LoginScreen();
    },
  ),
];
