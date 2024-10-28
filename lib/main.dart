import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mona_coffee/core/utils/app_router.dart';
import 'package:mona_coffee/core/utils/router_bloc_listenable.dart';
import 'package:mona_coffee/core/utils/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mona_coffee/features/authentications/data/repositories/authentication_repository.dart';
import 'package:mona_coffee/features/authentications/presentation/blocs/auth_bloc.dart';
import 'package:mona_coffee/features/authentications/presentation/blocs/sign_in_bloc.dart';
import 'package:mona_coffee/features/authentications/presentation/blocs/sign_out_bloc.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MonaCoffeeApp());
}

class MonaCoffeeApp extends StatelessWidget {
  const MonaCoffeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = AuthBloc(FirebaseAuth.instance);
    final authenticationRepository =
        AuthenticationRepository(FirebaseAuth.instance);

    final routerBlocListenable = RouterBlocListenable(authBloc);
    authBloc.add(AuthStarted());

    final appRouter = AppRouter(routerBlocListenable: routerBlocListenable);

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              AuthBloc(FirebaseAuth.instance)..add(AuthStarted()),
        ),
        BlocProvider(
          create: (context) => SignInBloc(authenticationRepository),
        ),
        BlocProvider(
          create: (context) =>
              SignOutBloc(authenticationRepository, context.read<AuthBloc>()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Mona Coffee App',
        theme: AppTheme.monaCoffeeTheme(context),
        routerDelegate: appRouter.router.routerDelegate,
        routeInformationParser: appRouter.router.routeInformationParser,
        routeInformationProvider: appRouter.router.routeInformationProvider,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
