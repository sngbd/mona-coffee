import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mona_coffee/core/utils/router_bloc_listenable.dart';
import 'package:mona_coffee/core/utils/transition.dart';
import 'package:mona_coffee/features/accounts/presentations/pages/cart_screen.dart';
import 'package:mona_coffee/features/accounts/presentations/pages/checkout_screen.dart';
import 'package:mona_coffee/features/accounts/presentations/pages/delivery_payment_success_screen.dart';
import 'package:mona_coffee/features/accounts/presentations/pages/dinein_seat_receive_screen.dart';
import 'package:mona_coffee/features/accounts/presentations/pages/favorites_screen.dart';
import 'package:mona_coffee/features/accounts/presentations/pages/order_status_detail_screen.dart';
import 'package:mona_coffee/features/accounts/presentations/pages/order_tracking_screen.dart';
import 'package:mona_coffee/features/accounts/presentations/pages/select_address_screen.dart';
import 'package:mona_coffee/features/accounts/presentations/pages/update_order_screen.dart';
import 'package:mona_coffee/features/admin/presentations/pages/admin_home_screen.dart';
import 'package:mona_coffee/features/admin/presentations/pages/admin_orders_screen.dart';
import 'package:mona_coffee/features/admin/presentations/pages/admin_past_orders_detail_screen.dart';
import 'package:mona_coffee/features/admin/presentations/pages/admin_profile_screen.dart';
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
        context.read<ProfileBloc>().add(InitializeProfileState());
        final email = authState.user.email;
        if (email == 'admin@coffee.mona') {
          return '/admin-home';
        }
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
              routes: [
                GoRoute(
                  path: '/login-form-forgot-password',
                  name: 'login-form-forgot-password',
                  pageBuilder: (BuildContext context, GoRouterState state) {
                    return slideFromRight(state, const ForgotPasswordScreen());
                  },
                ),
              ]),
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
    path: '/admin-home',
    name: 'admin-home',
    pageBuilder: (BuildContext context, GoRouterState state) {
      return slideFromRight(state, const AdminHomeScreen());
    },
  ),
  GoRoute(
    path: '/favorites',
    name: 'favorites',
    builder: (BuildContext context, GoRouterState state) {
      return const FavoritesScreen();
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
  // GoRoute(
  //   path: '/item-detail',
  //   name: 'item-detail',
  //   builder: (BuildContext context, GoRouterState state) {
  //     return const ItemDetailScreen();
  //   },
  // ),
  GoRoute(
    path: '/profile',
    name: 'profile',
    builder: (BuildContext context, GoRouterState state) {
      return const ProfileScreen();
    },
  ),
  GoRoute(
    path: '/new-password',
    name: 'new-password',
    builder: (BuildContext context, GoRouterState state) {
      return const NewPasswordScreen();
    },
  ),
  GoRoute(
    path: '/update-order',
    name: 'update-order',
    builder: (BuildContext context, GoRouterState state) {
      return const UpdateOrderScreen();
    },
  ),
  GoRoute(
    path: '/delivery-payment-success',
    name: 'delivery-payment-success',
    builder: (BuildContext context, GoRouterState state) {
      return const DeliveryPaymentSuccessScreen();
    },
  ),
  GoRoute(
    path: '/dinein-seat-receive',
    name: 'dinein-seat-receive',
    builder: (BuildContext context, GoRouterState state) {
      return const DineInSeatReceiveScreen();
    },
  ),
  GoRoute(
    path: '/order-status',
    name: 'order-status',
    builder: (BuildContext context, GoRouterState state) {
      return const OrderStatusDetailScreen();
    },
  ),
  // GoRoute(
  //   path: '/admin-item-detail',
  //   name: 'admin-item-detail',
  //   builder: (BuildContext context, GoRouterState state) {
  //     return const AdminItemDetail(menuItem: menuitem);
  //   },
  // ),
  // GoRoute(
  //   path: '/admin-edit-menu',
  //   name: 'admin-edit-menu',
  //   builder: (BuildContext context, GoRouterState state) {
  //     return const AdminEditMenu();
  //   },
  // ),
  GoRoute(
    path: '/admin-orders',
    name: 'admin-orders',
    builder: (BuildContext context, GoRouterState state) {
      return const AdminOrdersScreen();
    },
  ),
  GoRoute(
    path: '/admin-profile',
    name: 'admin-profile',
    builder: (BuildContext context, GoRouterState state) {
      return const AdminProfileScreen();
    },
  ),
  // GoRoute(
  //   path: '/admin-delivery-detail-screen',
  //   name: 'admin-delivery-detail-screen',
  //   builder: (BuildContext context, GoRouterState state) {
  //     return const AdminOrderDetailScreen();
  //   },
  // ),
  // GoRoute(
  //   path: '/admin-dinein-detail-screen',
  //   name: 'admin-dinein-detail-screen',
  //   builder: (BuildContext context, GoRouterState state) {
  //     return const AdminDineInOrderDetailScreen();
  //   },
  // ),
  GoRoute(
    path: '/admin-past-order-detail-screen',
    name: 'admin-past-order-detail-screen',
    builder: (BuildContext context, GoRouterState state) {
      return const AdminPastOrderDetailScreen();
    },
  ),
  GoRoute(
    path: '/order-tracking',
    name: 'order-tracking',
    builder: (BuildContext context, GoRouterState state) {
      return const OrderTrackingScreen();
    },
  ),
  GoRoute(
    path: '/select-address',
    name: 'select-address',
    builder: (BuildContext context, GoRouterState state) {
      return const SelectAddressScreen();
    },
  ),
];
