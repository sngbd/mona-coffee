import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mona_coffee/features/authentications/presentation/pages/forgot_password.dart';
import 'package:mona_coffee/features/authentications/presentation/pages/login_screen.dart';
import 'package:mona_coffee/features/authentications/presentation/pages/new_password.dart';
import 'package:mona_coffee/features/home/presentation/pages/home_screen.dart';
import 'package:mona_coffee/features/home/presentation/pages/landing_screen.dart';

class AppRouter {
  GoRouter get router => _goRouter;
  late final GoRouter _goRouter = GoRouter(
    initialLocation: '/login',
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
  GoRoute(
    path: '/forgot_password',
    name: 'forgot_password',
    builder: (BuildContext context, GoRouterState state) {
      return const ForgotPasswordPage();
    }
  ),
  GoRoute(
    path: '/new_password',
    name: 'new_password',
    builder: (BuildContext context, GoRouterState state) {
      return const NewPasswordPage();
    }
  ),
  GoRoute(
    path: '/home',
    name: 'home',
    builder: (BuildContext context, GoRouterState state) {
      return const HomeScreen();
    },
  ),
];
