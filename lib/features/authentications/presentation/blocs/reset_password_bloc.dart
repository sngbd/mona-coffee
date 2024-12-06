import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mona_coffee/core/event/bloc_event.dart';
import 'package:mona_coffee/features/authentications/data/repositories/authentication_repository.dart';

class EmailResetPasswordChanged extends FormEvent {
  final String email;

  const EmailResetPasswordChanged(this.email);

  @override
  List<Object> get props => [email];
}

class ResetPasswordSubmitted extends FormEvent {}

enum FormStatusResetPassword {
  initial,
  invalid,
  submitting,
  success,
  failure,
}

class ResetFormResetPassword extends FormEvent {}

class ResetPasswordState extends Equatable {
  final FormStatusResetPassword status;
  final String? email;
  final String? errorMessage;
  final GlobalKey<FormState> formKey;

  ResetPasswordState({
    this.status = FormStatusResetPassword.initial,
    this.email,
    this.errorMessage,
    GlobalKey<FormState>? formKey,
  }) : formKey = formKey ?? GlobalKey<FormState>();

  ResetPasswordState copyWith({
    FormStatusResetPassword? status,
    String? email,
    String? errorMessage,
    GlobalKey<FormState>? formKey,
  }) {
    return ResetPasswordState(
      status: status ?? this.status,
      email: email ?? this.email,
      errorMessage: errorMessage ?? this.errorMessage,
      formKey: formKey ?? this.formKey,
    );
  }

  @override
  List<Object?> get props => [
        status,
        email,
        errorMessage,
        formKey,
      ];
}

class ResetPasswordBloc extends Bloc<FormEvent, ResetPasswordState> {
  final AuthenticationRepository _authenticationRepository;

  ResetPasswordBloc(this._authenticationRepository)
      : super(ResetPasswordState()) {
    on<EmailResetPasswordChanged>((event, emit) {
      emit(state.copyWith(
        email: event.email,
      ));
    });

    on<ResetPasswordSubmitted>((event, emit) async {
      if (state.email == null) {
        emit(state.copyWith(
          status: FormStatusResetPassword.failure,
        ));
      } else {
        emit(state.copyWith(
          status: FormStatusResetPassword.submitting,
        ));

        await _authenticationRepository.sendResetPassword(state.email!);

        emit(state.copyWith(
          status: FormStatusResetPassword.success,
        ));
      }
    });

    on<ResetFormResetPassword>((event, emit) {
      emit(ResetPasswordState());
    });
  }
}
