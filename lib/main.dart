import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/web.dart';
import 'package:mona_coffee/core/utils/app_router.dart';
import 'package:mona_coffee/core/utils/router_bloc_listenable.dart';
import 'package:mona_coffee/core/utils/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mona_coffee/features/accounts/data/repositories/cart_repository.dart';
import 'package:mona_coffee/features/accounts/data/repositories/checkout_repository.dart';
import 'package:mona_coffee/features/accounts/presentations/blocs/cart_bloc.dart';
import 'package:mona_coffee/features/accounts/presentations/blocs/checkout_bloc.dart';
import 'package:mona_coffee/features/authentications/data/repositories/authentication_repository.dart';
import 'package:mona_coffee/features/authentications/presentation/blocs/auth_bloc.dart';
import 'package:mona_coffee/features/authentications/presentation/blocs/profile_bloc.dart';
import 'package:mona_coffee/features/authentications/presentation/blocs/reset_password_bloc.dart';
import 'package:mona_coffee/features/authentications/presentation/blocs/sign_in_bloc.dart';
import 'package:mona_coffee/features/authentications/presentation/blocs/sign_out_bloc.dart';
import 'package:mona_coffee/features/authentications/presentation/blocs/sign_up_bloc.dart';
import 'package:mona_coffee/features/home/data/repositories/favorite_repository.dart';
import 'package:mona_coffee/features/home/data/repositories/menu_repository.dart';
import 'package:mona_coffee/features/home/presentation/blocs/favorite_bloc.dart';
import 'package:mona_coffee/features/home/presentation/blocs/menu_bloc.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MonaCoffeeApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  Logger().i("Handling a background message: ${message.messageId}");
}

class MonaCoffeeApp extends StatelessWidget {
  const MonaCoffeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticationRepository =
        AuthenticationRepository(FirebaseAuth.instance);

    final authBloc = AuthBloc(FirebaseAuth.instance);
    final signInBloc = SignInBloc(authenticationRepository);
    final signUpBloc = SignUpBloc();
    authBloc.add(AuthStarted());
    final signOutBloc = SignOutBloc(authenticationRepository, authBloc);
    final profileBloc = ProfileBloc(authenticationRepository);
    final resetPasswordBloc = ResetPasswordBloc(authenticationRepository);
    final favoriteRepository = FavoriteRepository(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    );
    final menuRepository = MenuRepository();
    final cartRepository = CartRepository(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    );

    final checkoutRepository = CheckoutRepository(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    );

    final favoriteBloc = FavoriteBloc(repository: favoriteRepository);
    final menuBloc = MenuBloc(menuRepository);
    final cartBloc = CartBloc(cartRepository);
    cartBloc.add(LoadCart());
    favoriteBloc.add(LoadFavorites());

    final checkoutBloc = CheckoutBloc(repository: checkoutRepository);

    final RouterBlocListenable routerBlocListenable =
        RouterBlocListenable(authBloc);
    final appRouter = AppRouter(routerBlocListenable: routerBlocListenable);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => authenticationRepository),
        RepositoryProvider(create: (context) => favoriteRepository),
        RepositoryProvider(create: (context) => menuRepository),
        RepositoryProvider(create: (context) => cartRepository),
        RepositoryProvider(create: (context) => checkoutRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => authBloc),
          BlocProvider(create: (context) => signInBloc),
          BlocProvider(create: (context) => signUpBloc),
          BlocProvider(create: (context) => signOutBloc),
          BlocProvider(create: (context) => profileBloc),
          BlocProvider(create: (context) => resetPasswordBloc),
          BlocProvider(create: (context) => favoriteBloc),
          BlocProvider(create: (context) => menuBloc),
          BlocProvider(create: (context) => cartBloc),
          BlocProvider(create: (context) => checkoutBloc),
        ],
        child: MaterialApp.router(
          title: 'Mona Coffee App',
          theme: AppTheme.monaCoffeeTheme(context),
          routerDelegate: appRouter.router.routerDelegate,
          routeInformationParser: appRouter.router.routeInformationParser,
          routeInformationProvider: appRouter.router.routeInformationProvider,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
