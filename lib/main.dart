import 'package:flutter/material.dart';
import 'package:mona_coffee/core/utils/app_router.dart';
import 'package:mona_coffee/core/utils/theme.dart';

void main() {
  runApp(const MonaCoffeeApp());
}

class MonaCoffeeApp extends StatelessWidget {
  const MonaCoffeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter();

    return MaterialApp.router(
      title: 'Mona Coffee App',
      theme: AppTheme.monaCoffeeTheme(context),
      routerDelegate: appRouter.router.routerDelegate,
      routeInformationParser: appRouter.router.routeInformationParser,
      routeInformationProvider: appRouter.router.routeInformationProvider,
      debugShowCheckedModeBanner: false,
    );
  }
}

