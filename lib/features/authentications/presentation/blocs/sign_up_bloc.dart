import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mona_coffee/core/event/bloc_event.dart';

class EmailSignUpChanged extends FormEvent {
  final String email;
  const EmailSignUpChanged(this.email);

  @override
  List<Object> get props => [email];
}

class PasswordSignUpChanged extends FormEvent {
  final String password;
  const PasswordSignUpChanged(this.password);

  @override
  List<Object> get props => [password];
}

class ConfirmPasswordSignUpChanged extends FormEvent {
  final String confirmPassword;
  const ConfirmPasswordSignUpChanged(this.confirmPassword);

  @override
  List<Object> get props => [confirmPassword];
}

class PasswordSignUpToggleChanged extends FormEvent {
  final bool passwordToggleStatus;
  const PasswordSignUpToggleChanged(this.passwordToggleStatus);

  @override
  List<Object> get props => [passwordToggleStatus];
}

class ConfirmPasswordSignUpToggleChanged extends FormEvent {
  final bool confirmPasswordToggleStatus;
  const ConfirmPasswordSignUpToggleChanged(this.confirmPasswordToggleStatus);

  @override
  List<Object> get props => [confirmPasswordToggleStatus];
}

enum FormStatusSignUp { initial, invalid, submitting, success, failure }

class FormSignUpSubmitted extends FormEvent {}

class SignUpState extends Equatable {
  final String email;
  final String password;
  final String confirmPassword;
  final FormStatusSignUp status;
  final bool passwordToggleStatus;
  final bool confirmPasswordToggleStatus;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final String? errorMessage;

  const SignUpState({
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.status = FormStatusSignUp.initial,
    this.passwordToggleStatus = true,
    this.confirmPasswordToggleStatus = true,
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
    this.errorMessage,
  });

  SignUpState copyWith({
    String? email,
    String? password,
    String? confirmPassword,
    FormStatusSignUp? status,
    bool? passwordToggleStatus,
    bool? confirmPasswordToggleStatus,
    String? emailError,
    String? passwordError,
    String? confirmPasswordError,
    String? errorMessage,
  }) {
    return SignUpState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      status: status ?? this.status,
      passwordToggleStatus: passwordToggleStatus ?? this.passwordToggleStatus,
      confirmPasswordToggleStatus:
          confirmPasswordToggleStatus ?? this.confirmPasswordToggleStatus,
      emailError: emailError,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        email,
        password,
        confirmPassword,
        status,
        passwordToggleStatus,
        confirmPasswordToggleStatus,
        emailError,
        passwordError,
        confirmPasswordError,
        errorMessage,
      ];
}

class SignUpBloc extends Bloc<FormEvent, SignUpState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  SignUpBloc() : super(const SignUpState()) {
    on<EmailSignUpChanged>((event, emit) {
      emit(state.copyWith(
        email: event.email,
        emailError: _validateEmail(event.email),
      ));
    });

    on<PasswordSignUpChanged>((event, emit) {
      emit(state.copyWith(
        password: event.password,
        passwordError: _validatePassword(event.password),
      ));
    });

    on<ConfirmPasswordSignUpChanged>((event, emit) {
      emit(state.copyWith(
        confirmPassword: event.confirmPassword,
        confirmPasswordError:
            _validateConfirmPassword(event.confirmPassword, state.password),
      ));
    });

    on<PasswordSignUpToggleChanged>((event, emit) {
      emit(state.copyWith(
        passwordToggleStatus: event.passwordToggleStatus,
      ));
    });

    on<ConfirmPasswordSignUpToggleChanged>((event, emit) {
      emit(state.copyWith(
        confirmPasswordToggleStatus: event.confirmPasswordToggleStatus,
      ));
    });

    on<FormSignUpSubmitted>((event, emit) async {
      final emailError = _validateEmail(state.email);
      final passwordError = _validatePassword(state.password);
      final confirmPasswordError =
          _validateConfirmPassword(state.confirmPassword, state.password);
      if (emailError == null &&
          passwordError == null &&
          confirmPasswordError == null) {
        emit(state.copyWith(status: FormStatusSignUp.submitting));

        try {
          await _auth.createUserWithEmailAndPassword(
            email: state.email,
            password: state.password,
          );

          emit(state.copyWith(
            status: FormStatusSignUp.success,
          ));
        } on FirebaseAuthException catch (error) {
          emit(state.copyWith(
            status: FormStatusSignUp.failure,
            errorMessage: error.message,
          ));

          emit(state.copyWith(
            status: FormStatusSignUp.invalid,
          ));
        }
      } else {
        emit(state.copyWith(
          status: FormStatusSignUp.invalid,
          emailError: emailError,
          passwordError: passwordError,
          confirmPasswordError: confirmPasswordError,
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

  String? _validateConfirmPassword(String confirmPassword, String password) {
    if (confirmPassword.isEmpty) {
      return 'Please fill in password confirmation';
    } else if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (confirmPassword != password) {
      return 'Password confirmation does not match';
    }

    return null;
  }
}
