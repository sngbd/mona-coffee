import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mona_coffee/features/accounts/presentations/pages/favorites_screen.dart';
import 'package:mona_coffee/features/authentications/presentation/pages/login_form_screen.dart';
import 'package:mona_coffee/features/authentications/presentation/pages/login_screen.dart';
import 'package:mona_coffee/features/authentications/presentation/pages/sign_up_screen.dart';
import 'package:mona_coffee/features/home/presentation/pages/home_screen.dart';
import 'package:mona_coffee/features/home/presentation/pages/landing_screen.dart';

class AppRouter {
  GoRouter get router => _goRouter;
  late final GoRouter _goRouter = GoRouter(
    initialLocation: '/home',
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
    path: '/home',
    name: 'home',
    builder: (BuildContext context, GoRouterState state) {
      return const HomeScreen();
    },
  ),
  GoRoute(
    path: '/login-form',
    name: 'login-form',
    builder: (BuildContext context, GoRouterState state) {
      return const LoginFormScreen();
    },
  ),
  GoRoute(
    path: '/sign-up',
    name: 'sign-up',
    builder: (BuildContext context, GoRouterState state) {
      return const SignUpScreen();
    },
  ),
  GoRoute(
    path: '/favorites',
    name: 'favorites',
    builder: (BuildContext context, GoRouterState state) {
      return FavoritesScreen();
    },
  ),
];
