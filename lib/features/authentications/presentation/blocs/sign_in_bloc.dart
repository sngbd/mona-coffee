import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mona_coffee/core/event/bloc_event.dart';
import 'package:mona_coffee/features/authentications/data/repositories/authentication_repository.dart';

class EmailSignInChanged extends FormEvent {
  final String email;
  const EmailSignInChanged(this.email);

  @override
  List<Object> get props => [email];
}

class PasswordSignInChanged extends FormEvent {
  final String password;
  const PasswordSignInChanged(this.password);

  @override
  List<Object> get props => [password];
}

class PasswordSignInToggleChanged extends FormEvent {
  final bool passwordToggleStatus;
  const PasswordSignInToggleChanged(this.passwordToggleStatus);

  @override
  List<Object> get props => [passwordToggleStatus];
}

enum FormStatusSignIn { initial, invalid, submitting, success, failure }

class FormSignInSubmitted extends FormEvent {}

class GoogleSignInSubmitted extends FormEvent {}

class GoogleSignOutSubmitted extends FormEvent {}

class SignInState extends Equatable {
  final String email;
  final String password;
  final FormStatusSignIn status;
  final bool passwordToggleStatus;
  final String? emailError;
  final String? passwordError;
  final String? errorMessage;

  const SignInState({
    this.email = '',
    this.password = '',
    this.status = FormStatusSignIn.initial,
    this.passwordToggleStatus = true,
    this.emailError,
    this.passwordError,
    this.errorMessage,
  });

  SignInState copyWith({
    String? email,
    String? password,
    FormStatusSignIn? status,
    bool? passwordToggleStatus,
    bool? confirmPasswordToggleStatus,
    String? emailError,
    String? passwordError,
    String? confirmPasswordError,
    String? errorMessage,
  }) {
    return SignInState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      passwordToggleStatus: passwordToggleStatus ?? this.passwordToggleStatus,
      emailError: emailError,
      passwordError: passwordError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        email,
        password,
        status,
        passwordToggleStatus,
        emailError,
        passwordError,
        errorMessage,
      ];
}

class SignInBloc extends Bloc<FormEvent, SignInState> {
  final AuthenticationRepository _authenticationRepository;

  SignInBloc(this._authenticationRepository) : super(const SignInState()) {
    on<EmailSignInChanged>((event, emit) {
      emit(state.copyWith(
        email: event.email,
        emailError: _validateEmail(event.email),
      ));
    });

    on<PasswordSignInChanged>((event, emit) {
      emit(state.copyWith(
        password: event.password,
        passwordError: _validatePassword(event.password),
      ));
    });

    on<PasswordSignInToggleChanged>((event, emit) {
      emit(state.copyWith(
        passwordToggleStatus: event.passwordToggleStatus,
      ));
    });

    on<FormSignInSubmitted>((event, emit) async {
      final emailError = _validateEmail(state.email);
      final passwordError = _validatePassword(state.password);
      if (emailError == null && passwordError == null) {
        emit(state.copyWith(status: FormStatusSignIn.submitting));

        try {
          await _authenticationRepository.signInWithEmailAndPassword(
            email: state.email,
            password: state.password,
          );

          emit(state.copyWith(
            status: FormStatusSignIn.success,
          ));
        } catch (error) {
          emit(state.copyWith(
            status: FormStatusSignIn.failure,
            errorMessage: error.toString(),
          ));

          emit(state.copyWith(
            status: FormStatusSignIn.invalid,
          ));
        }
      } else {
        emit(state.copyWith(
          status: FormStatusSignIn.invalid,
          emailError: emailError,
          passwordError: passwordError,
        ));
      }
    });

    on<GoogleSignInSubmitted>((event, emit) async {
      try {
        await _authenticationRepository.signInWithGoogle();

        emit(state.copyWith(
          status: FormStatusSignIn.success,
        ));
      } catch (error) {
        emit(state.copyWith(
          status: FormStatusSignIn.failure,
          errorMessage: error.toString(),
        ));

        emit(state.copyWith(
          status: FormStatusSignIn.invalid,
        ));
      }
    });

    on<GoogleSignOutSubmitted>((event, emit) async {
      try {
        await _authenticationRepository.signOutGoogle();

        emit(state.copyWith(
          status: FormStatusSignIn.success,
        ));
      } catch (error) {
        emit(state.copyWith(
          status: FormStatusSignIn.failure,
          errorMessage: error.toString(),
        ));

        emit(state.copyWith(
          status: FormStatusSignIn.invalid,
        ));
      }
    });
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) {
      return 'Please fill in email';
    }

    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) {
      return 'Please fill in password';
    } else if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }

    return null;
  }
}
