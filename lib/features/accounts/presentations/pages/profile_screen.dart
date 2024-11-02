import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mona_coffee/core/utils/common.dart';
import 'package:mona_coffee/core/widgets/activity_indicator.dart';
import 'package:mona_coffee/features/accounts/presentations/widgets/skeleton_account_card.dart';
import 'package:mona_coffee/features/authentications/presentation/blocs/profile_bloc.dart';
import 'package:mona_coffee/features/authentications/presentation/blocs/sign_out_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProfileBloc>().add(InitializeProfileState());
      },
      child: BlocListener<SignOutBloc, SignOutState>(
        listener: (context, state) {
          if (state is SignOutInProgress) {
            const ActivityIndicator();
          }

          if (state is SignOutSuccess) {
            context.goNamed('intro');
          }
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.logout,
                  color: mDarkBrown,
                ),
                onPressed: () {
                  context.read<SignOutBloc>().add(SignOutRequested());
                },
              ),
            ],
            title: const Text(
              'My Profile',
              style: TextStyle(
                color: mDarkBrown,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state.status == FormStatusProfile.success) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 60),
                        Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: 100,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: state.avatar != null
                                          ? FileImage(state.avatar!)
                                          : const NetworkImage(
                                              'https://via.placeholder.com/150'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 15,
                                child: GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text(
                                                  'Choose image source',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                ListTile(
                                                  title: const Text('Gallery'),
                                                  onTap: () {
                                                    context.read<ProfileBloc>().add(
                                                        OpenGalleryProfileAction());
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                ListTile(
                                                  title: const Text('Camera'),
                                                  onTap: () {
                                                    context.read<ProfileBloc>().add(
                                                        OpenCameraProfileAction());
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                                context
                                                            .read<ProfileBloc>()
                                                            .state
                                                            .avatar ==
                                                        null
                                                    ? const SizedBox.shrink()
                                                    : ListTile(
                                                        title: const Text(
                                                            'Remove'),
                                                        onTap: () {
                                                          context
                                                              .read<
                                                                  ProfileBloc>()
                                                              .add(
                                                                  RemoveImageProfileAction());
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: mBrown,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 25,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Name',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: mDarkBrown,
                          ),
                        ),
                        TextField(
                          onChanged: (name) {
                            context
                                .read<ProfileBloc>()
                                .add(NameProfileChanged(name));
                          },
                          decoration: InputDecoration(
                            labelText: state.name,
                            contentPadding: const EdgeInsets.all(0),
                            filled: true,
                            fillColor: Colors.transparent,
                            hintStyle: TextStyle(
                              color: Colors.black.withOpacity(0.4),
                              fontSize: 14,
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 58, 58, 58)),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: mBrown),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Email',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: mDarkBrown,
                          ),
                        ),
                        TextField(
                          onChanged: (email) {
                            context
                                .read<ProfileBloc>()
                                .add(EmailProfileChanged(email));
                          },
                          decoration: InputDecoration(
                            labelText: state.email,
                            contentPadding: const EdgeInsets.all(0),
                            filled: true,
                            fillColor: Colors.transparent,
                            hintStyle: TextStyle(
                              color: Colors.black.withOpacity(0.4),
                              fontSize: 14,
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 58, 58, 58)),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: mBrown),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Phone Number',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: mDarkBrown,
                          ),
                        ),
                        TextField(
                          onChanged: (phone) {
                            context
                                .read<ProfileBloc>()
                                .add(PhoneProfileChanged(phone));
                          },
                          decoration: InputDecoration(
                            labelText: state.phone,
                            contentPadding: const EdgeInsets.all(0),
                            filled: true,
                            fillColor: Colors.transparent,
                            hintStyle: TextStyle(
                              color: Colors.black.withOpacity(0.4),
                              fontSize: 14,
                            ),
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromARGB(255, 58, 58, 58)),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: mBrown),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        Center(
                          child: SizedBox(
                            width: 180,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                context
                                    .read<ProfileBloc>()
                                    .add(FormProfileSubmitted());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: mBrown,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Save',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (state.status == FormStatusProfile.unauthenticated) {
                return Center(child: Text(state.errorMessage!));
              } else if (state.status == FormStatusProfile.failure) {
                return Center(child: Text(state.errorMessage!));
              }
              return const SkeletonAccountCard();
            },
          ),
        ),
      ),
    );
  }
}
