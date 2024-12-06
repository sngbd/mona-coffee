import 'dart:io';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:mona_coffee/features/authentications/data/entities/user_profile.dart';
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

class ToggleVerifyEmail extends FormEvent {
  final bool verifyEmail;

  const ToggleVerifyEmail(this.verifyEmail);

  @override
  List<Object> get props => [verifyEmail];
}

class InitializeProfileState extends FormEvent {}

class OpenCameraProfileAction extends FormEvent {}

class OpenGalleryProfileAction extends FormEvent {}

class RemoveImageProfileAction extends FormEvent {}

class FormProfileSubmitted extends FormEvent {}

class ResetProfileForm extends FormEvent {}

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

enum AuthMethodProfile {
  isGoogle,
  isEmail,
}

class ProfileState extends Equatable {
  final FormStatusProfile status;
  final AvatarStatusProfile avatarStatus;
  final AuthMethodProfile authMethod;
  final String? name;
  final String? email;
  final bool? verifyEmail;
  final String? phone;
  final File? avatar;
  final String? errorMessage;

  const ProfileState({
    this.status = FormStatusProfile.initial,
    this.avatarStatus = AvatarStatusProfile.initial,
    this.authMethod = AuthMethodProfile.isEmail,
    this.name,
    this.email,
    this.verifyEmail,
    this.phone,
    this.avatar,
    this.errorMessage,
  });

  ProfileState copyWith({
    FormStatusProfile? status,
    AvatarStatusProfile? avatarStatus,
    AuthMethodProfile? authMethod,
    String? name,
    String? email,
    bool? verifyEmail,
    String? phone,
    File? avatar,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      avatarStatus: avatarStatus ?? this.avatarStatus,
      authMethod: authMethod ?? this.authMethod,
      name: name ?? this.name,
      email: email ?? this.email,
      verifyEmail: verifyEmail ?? this.verifyEmail,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        avatarStatus,
        authMethod,
        name,
        email,
        verifyEmail,
        phone,
        avatar,
        errorMessage,
      ];
}

class ProfileBloc extends Bloc<FormEvent, ProfileState> {
  final AuthenticationRepository _authenticationRepository;

  ProfileBloc(this._authenticationRepository) : super(const ProfileState()) {
    on<InitializeProfileState>((event, emit) async {
      emit(state.copyWith(status: FormStatusProfile.submitting));

      try {
        final isGoogle =
            await _authenticationRepository.isUserLoggedInWithGoogle();

        final user = await _authenticationRepository.getProfileData();

        final tempDir = await getTemporaryDirectory();
        File fileAvatar = File('${tempDir.path}/${user.email}.png');

        if (user.avatar != null) {
          final bytes = base64Decode(user.avatar!);
          await fileAvatar.writeAsBytes(bytes);
        } else {
          final byteData = await rootBundle.load('assets/images/blank.png');
          fileAvatar = File('${tempDir.path}/temp_asset.png');
          await fileAvatar.writeAsBytes(byteData.buffer.asUint8List());
        }

        emit(state.copyWith(
          name: user.name,
          email: user.email,
          phone: user.phone,
          avatar: user.avatar == null ? null : fileAvatar,
          authMethod:
              isGoogle ? AuthMethodProfile.isGoogle : AuthMethodProfile.isEmail,
          status: FormStatusProfile.initial,
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
          UserProfile userProfile;
          userProfile = UserProfile(
            name: state.name,
            email: state.email,
            phone: state.phone,
          );

          if (state.avatar != null) {
            if (state.avatarStatus == AvatarStatusProfile.update) {
              final bytes = await state.avatar!.readAsBytes();

              var avatarString = base64Encode(bytes);
              userProfile.avatar = avatarString;

              emit(state.copyWith(
                avatarStatus: AvatarStatusProfile.initial,
              ));
            } else if (state.avatarStatus == AvatarStatusProfile.remove) {
              userProfile.avatar = null;

              emit(state.copyWith(
                avatarStatus: AvatarStatusProfile.initial,
              ));
            }
          }

          final currentUser = _authenticationRepository.currentUser;
          if (state.email != currentUser!.email) {
            emit(state.copyWith(
              verifyEmail: true,
            ));
          }

          await _authenticationRepository.updateProfileData(userProfile);

          emit(state.copyWith(
            status: FormStatusProfile.success,
          ));

          emit(state.copyWith(
            status: FormStatusProfile.initial,
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
          errorMessage: avatarError,
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
      final byteData = await rootBundle.load('assets/images/blank.png');
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/temp_asset.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      emit(state.copyWith(
        avatar: file,
        avatarStatus: AvatarStatusProfile.remove,
      ));
    });

    on<ToggleVerifyEmail>((event, emit) {
      emit(state.copyWith(
        verifyEmail: event.verifyEmail,
      ));
    });

    on<ResetProfileForm>((event, emit) {
      emit(const ProfileState());
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
