import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:mona_coffee/features/authentications/presentation/blocs/auth_bloc.dart';

class RouterBlocListenable extends ChangeNotifier {
  final AuthBloc _authBloc;
  late final StreamSubscription _subscription;

  RouterBlocListenable(this._authBloc) {
    _subscription = _authBloc.stream.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}