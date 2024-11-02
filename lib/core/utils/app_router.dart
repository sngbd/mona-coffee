import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mona_coffee/core/utils/router_bloc_listenable.dart';
import 'package:mona_coffee/core/utils/transition.dart';
import 'package:mona_coffee/features/accounts/presentations/pages/cart_screen.dart';
import 'package:mona_coffee/features/accounts/presentations/pages/checkout_screen.dart';
import 'package:mona_coffee/features/accounts/presentations/pages/favorites_screen.dart';
import 'package:mona_coffee/features/authentications/presentation/blocs/auth_bloc.dart';
import 'package:mona_coffee/features/accounts/presentations/pages/profile_screen.dart';
import 'package:mona_coffee/features/authentications/presentation/blocs/profile_bloc.dart';
import 'package:mona_coffee/features/authentications/presentation/pages/forgot_password.dart';
import 'package:mona_coffee/features/authentications/presentation/pages/sign_in_form_screen.dart';
import 'package:mona_coffee/features/authentications/presentation/pages/sign_in_screen.dart';
import 'package:mona_coffee/features/authentications/presentation/pages/new_password.dart';
import 'package:mona_coffee/features/authentications/presentation/pages/sign_up_screen.dart';
import 'package:mona_coffee/features/home/presentation/pages/home_screen.dart';
import 'package:mona_coffee/features/home/presentation/pages/landing_screen.dart';

class AppRouter {
  final RouterBlocListenable routerBlocListenable;

  AppRouter({required this.routerBlocListenable});

  GoRouter get router => _goRouter;
  late final GoRouter _goRouter = GoRouter(
    refreshListenable: routerBlocListenable,
    initialLocation: '/checkout',
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
        context.read<ProfileBloc>().add(InitializeProfileState());
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
  GoRoute(
    path: '/cart',
    name: 'cart',
    builder: (BuildContext context, GoRouterState state) {
      return const CartScreen();
    },
  ),
  GoRoute(
    path: '/checkout',
    name: 'checkout',
    builder: (BuildContext context, GoRouterState state) {
      return const CheckoutScreen();
    },
  ),
  GoRoute(
    path: '/profile',
    name: 'profile',
    builder: (BuildContext context, GoRouterState state) {
      return const ProfileScreen();
    },
  ),
  GoRoute(
    path: '/forgot_password',
    name: 'forgot_password',
    builder: (BuildContext context, GoRouterState state) {
      return const ForgotPasswordScreen();
    },
  ),
  GoRoute(
    path: '/new_password',
    name: 'new_password',
    builder: (BuildContext context, GoRouterState state) {
      return const NewPasswordScreen();
    },
  ),
];
