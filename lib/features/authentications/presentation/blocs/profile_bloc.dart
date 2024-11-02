import 'dart:io';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mona_coffee/core/event/bloc_event.dart';
import 'package:mona_coffee/features/authentications/data/repositories/authentication_repository.dart';

class NameProfileChanged extends FormEvent {
  final String name;

  const NameProfileChanged(this.name);

  @override
  List<Object> get props => [name];
}

class EmailProfileChanged extends FormEvent {
  final String email;

  const EmailProfileChanged(this.email);

  @override
  List<Object> get props => [email];
}

class PhoneProfileChanged extends FormEvent {
  final String phone;

  const PhoneProfileChanged(this.phone);

  @override
  List<Object> get props => [phone];
}

class InitializeProfileState extends FormEvent {}

class OpenCameraProfileAction extends FormEvent {}

class OpenGalleryProfileAction extends FormEvent {}

class RemoveImageProfileAction extends FormEvent {}

class FormProfileSubmitted extends FormEvent {}

enum FormStatusProfile {
  initial,
  invalid,
  submitting,
  success,
  failure,
  unauthenticated
}

enum AvatarStatusProfile {
  initial,
  update,
  remove,
}

class ProfileState extends Equatable {
  final FormStatusProfile status;
  final AvatarStatusProfile avatarStatus;
  final String? name;
  final String? email;
  final String? phone;
  final File? avatar;
  final String? avatarError;
  final String? errorMessage;

  const ProfileState({
    this.status = FormStatusProfile.initial,
    this.avatarStatus = AvatarStatusProfile.initial,
    this.name,
    this.email,
    this.phone,
    this.avatar,
    this.avatarError,
    this.errorMessage,
  });

  ProfileState copyWith({
    FormStatusProfile? status,
    AvatarStatusProfile? avatarStatus,
    String? name,
    String? email,
    String? phone,
    File? avatar,
    String? avatarError,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      avatarStatus: avatarStatus ?? this.avatarStatus,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      avatarError: avatarError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        avatarStatus,
        name,
        email,
        phone,
        avatar,
        avatarError,
        errorMessage,
      ];
}

class ProfileBloc extends Bloc<FormEvent, ProfileState> {
  final AuthenticationRepository _authenticationRepository;

  ProfileBloc(this._authenticationRepository) : super(const ProfileState()) {
    on<InitializeProfileState>((event, emit) async {
      emit(state.copyWith(status: FormStatusProfile.submitting));

      try {
        final user = _authenticationRepository.currentUser;
        final avatar =
            await _authenticationRepository.getUserAvatar(uid: user!.uid);

        final fileAvatar = File((await getTemporaryDirectory()).path);
        if (avatar != null) {
          final bytes = base64Decode(avatar);
          await fileAvatar.writeAsBytes(bytes);
        }

        emit(state.copyWith(
          name: user.displayName,
          email: user.email,
          phone: user.phoneNumber,
          avatar: avatar == null ? null : fileAvatar,
          status: FormStatusProfile.success,
        ));
      } catch (error) {
        emit(state.copyWith(
          status: FormStatusProfile.failure,
          errorMessage: error.toString(),
        ));
      }
    });

    on<NameProfileChanged>((event, emit) {
      emit(state.copyWith(
        name: event.name,
      ));
    });

    on<EmailProfileChanged>((event, emit) {
      emit(state.copyWith(
        email: event.email,
      ));
    });

    on<PhoneProfileChanged>((event, emit) {
      emit(state.copyWith(
        phone: event.phone,
      ));
    });

    on<FormProfileSubmitted>((event, emit) async {
      final avatarError = _validateAvatar(state.avatar);
      if (avatarError == null) {
        emit(state.copyWith(status: FormStatusProfile.submitting));

        try {
          await _authenticationRepository.updateProfile(
            displayName: state.name,
            email: state.email,
            phoneNumber: state.phone,
          );

          final user = _authenticationRepository.currentUser;

          if (state.avatar != null) {
            if (state.avatarStatus == AvatarStatusProfile.update) {
              final fileAvatar = File(
                  '${(await getTemporaryDirectory()).path}/temp_avatar.png');
              final bytes = await fileAvatar.readAsBytes();

              var avatarString = base64Encode(bytes);
              await _authenticationRepository.updateUserAvatar(
                uid: user!.uid,
                avatar: avatarString,
              );

              emit(state.copyWith(
                avatarStatus: AvatarStatusProfile.initial,
              ));
            } else if (state.avatarStatus == AvatarStatusProfile.remove) {
              await _authenticationRepository.updateUserAvatar(
                uid: user!.uid,
                avatar: "",
              );

              emit(state.copyWith(
                avatarStatus: AvatarStatusProfile.initial,
              ));
            }
          }

          emit(state.copyWith(
            status: FormStatusProfile.success,
          ));
        } catch (error) {
          emit(state.copyWith(
            status: FormStatusProfile.failure,
            errorMessage: error.toString(),
          ));

          emit(state.copyWith(
            status: FormStatusProfile.invalid,
          ));
        }
      } else {
        emit(state.copyWith(
          status: FormStatusProfile.invalid,
          avatarError: avatarError,
        ));
      }
    });

    on<OpenCameraProfileAction>((event, emit) async {
      final image = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
      );
      if (image == null) return;
      final imageTemp = File(image.path);

      emit(state.copyWith(
        avatar: imageTemp,
        avatarStatus: AvatarStatusProfile.update,
      ));
    });

    on<OpenGalleryProfileAction>((event, emit) async {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
      if (image == null) return;
      final imageTemp = File(image.path);

      emit(state.copyWith(
        avatar: imageTemp,
        avatarStatus: AvatarStatusProfile.update,
      ));
    });

    on<RemoveImageProfileAction>((event, emit) async {
      emit(state.copyWith(
        avatar: null,
        avatarStatus: AvatarStatusProfile.remove,
      ));
    });
  }

  String? _validateAvatar(File? avatar) {
    if (avatar != null) {
      final int fileSize = avatar.lengthSync();
      if (fileSize >= 1048576) {
        return 'File size must be less than 1MB';
      }
    }

    return null;
  }
}
