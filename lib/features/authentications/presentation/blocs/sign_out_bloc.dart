import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mona_coffee/features/authentications/data/repositories/authentication_repository.dart';
import 'package:mona_coffee/features/authentications/presentation/blocs/auth_bloc.dart';

abstract class SignOutEvent extends Equatable {
  const SignOutEvent();

  @override
  List<Object> get props => [];
}

class SignOutRequested extends SignOutEvent {}

abstract class SignOutState extends Equatable {
  const SignOutState();

  @override
  List<Object> get props => [];
}

class SignOutInitial extends SignOutState {}

class SignOutInProgress extends SignOutState {}

class SignOutSuccess extends SignOutState {}

class SignOutFailure extends SignOutState {
  final String error;

  const SignOutFailure(this.error);

  @override
  List<Object> get props => [error];
}

class SignOutBloc extends Bloc<SignOutEvent, SignOutState> {
  final AuthenticationRepository _authenticationRepository;
  final AuthBloc _authBloc;

  SignOutBloc(this._authenticationRepository, this._authBloc) : super(SignOutInitial()) {
    on<SignOutRequested>(_onSignOutRequested);
  }

  void _onSignOutRequested(SignOutRequested event, Emitter<SignOutState> emit) async {
    emit(SignOutInProgress());
    try {
      await _authenticationRepository.signOut();
      _authBloc.add(AuthLoggedOut());
      emit(SignOutSuccess());
    } catch (error) {
      emit(SignOutFailure(error.toString()));
    }
  }
}