import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mona_coffee/core/utils/router_bloc_listenable.dart';
import 'package:mona_coffee/core/utils/transition.dart';
import 'package:mona_coffee/features/accounts/presentations/pages/favorites_screen.dart';
import 'package:mona_coffee/features/authentications/presentation/blocs/auth_bloc.dart';
import 'package:mona_coffee/features/authentications/presentation/pages/sign_in_form_screen.dart';
import 'package:mona_coffee/features/authentications/presentation/pages/sign_in_screen.dart';
import 'package:mona_coffee/features/authentications/presentation/pages/sign_up_screen.dart';
import 'package:mona_coffee/features/home/presentation/pages/home_screen.dart';
import 'package:mona_coffee/features/home/presentation/pages/landing_screen.dart';

class AppRouter {
  final RouterBlocListenable routerBlocListenable;

  AppRouter({required this.routerBlocListenable});

  GoRouter get router => _goRouter;
  late final GoRouter _goRouter = GoRouter(
    refreshListenable: routerBlocListenable,
    initialLocation: '/',
    routes: configRouter,
    errorBuilder: (context, state) => const Center(
      child: Text(
        'Failed to access screen, Please check router',
        style: TextStyle(fontSize: 12),
        textAlign: TextAlign.center,
      ),
    ),
    redirect: (context, GoRouterState state) async {
      final authState = context.read<AuthBloc>().state;

      if (authState is AuthAuthenticated) {
        return '/home';
      } else if (state is AuthUnauthenticated) {
        return '/';
      }

      return null;
    },
  );
}

final List<GoRoute> configRouter = [
  // Stack 1 - Landing Screen
  GoRoute(
    path: '/',
    name: 'intro',
    pageBuilder: (BuildContext context, GoRouterState state) {
      return slideFromRight(state, const LandingScreen());
    },
    routes: <RouteBase>[
      // Stack 2 - Login Screen
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return slideFromRight(state, const LoginScreen());
        },
        routes: <RouteBase>[
          // Stack 3 - Login Form Screen
          GoRoute(
            path: '/login-form',
            name: 'login-form',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return slideFromRight(state, const LoginFormScreen());
            },
          ),
          GoRoute(
            path: '/sign-up',
            name: 'sign-up',
            pageBuilder: (BuildContext context, GoRouterState state) {
              return slideFromRight(state, const SignUpScreen());
            },
            routes: <RouteBase>[
              GoRoute(
                path: '/sign-up-login-form',
                name: 'sign-up-login-form',
                pageBuilder: (BuildContext context, GoRouterState state) {
                  return slideFromRight(state, const LoginFormScreen());
                },
              ),
            ],
          ),
        ],
      ),
    ],
  ),
  GoRoute(
    path: '/home',
    name: 'home',
    pageBuilder: (BuildContext context, GoRouterState state) {
      return slideFromRight(state, const HomeScreen());
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
