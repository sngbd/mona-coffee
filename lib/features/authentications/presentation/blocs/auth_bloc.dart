import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:equatable/equatable.dart';
import 'package:mona_coffee/core/event/bloc_event.dart';

class AuthStarted extends AuthEvent {}

class AuthLoggedIn extends AuthEvent {
  final User user;

  const AuthLoggedIn(this.user);

  @override
  List<Object> get props => [user];
}

class AuthLoggedOut extends AuthEvent {}

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth;

  AuthBloc(this._firebaseAuth) : super(AuthInitial()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthLoggedIn>(_onAuthLoggedIn);
    on<AuthLoggedOut>(_onAuthLoggedOut);

    _firebaseAuth.authStateChanges().listen((user) {
      if (user != null) {
        add(AuthLoggedIn(user));
      } else {
        add(AuthLoggedOut());
      }
    });
  }

  void _onAuthStarted(AuthStarted event, Emitter<AuthState> emit) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  void _onAuthLoggedIn(AuthLoggedIn event, Emitter<AuthState> emit) {
    emit(AuthAuthenticated(event.user));
  }

  void _onAuthLoggedOut(AuthLoggedOut event, Emitter<AuthState> emit) {
    emit(AuthUnauthenticated());
  }
}