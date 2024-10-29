import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mona_coffee/core/utils/common.dart';
import 'package:mona_coffee/core/widgets/activity_indicator.dart';
import 'package:mona_coffee/features/accounts/presentations/widgets/skeleton_account_card.dart';
import 'package:mona_coffee/features/authentications/presentation/blocs/auth_bloc.dart';
import 'package:mona_coffee/features/authentications/presentation/blocs/sign_out_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AuthBloc>().add(AuthStarted());
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
              ' My Profile',
              style: TextStyle(
                color: mDarkBrown,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                final user = state.user;
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 60),
                        const Center(
                          child: CircleAvatar(
                            radius: 100,
                            backgroundImage: NetworkImage(
                              'https://via.placeholder.com/150',
                            ),
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
                          controller: TextEditingController(text: user.displayName),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(0),
                            filled: true,
                            fillColor: Colors.transparent,
                            hintStyle: TextStyle(
                              color: Colors.black.withValues(alpha: 0.4),
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
                          controller: TextEditingController(text: user.email),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(0),
                            filled: true,
                            fillColor: Colors.transparent,
                            hintStyle: TextStyle(
                              color: Colors.black.withValues(alpha: 0.4),
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
                          controller: TextEditingController(text: user.phoneNumber),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(0),
                            filled: true,
                            fillColor: Colors.transparent,
                            hintStyle: TextStyle(
                              color: Colors.black.withValues(alpha: 0.4),
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
                                // Add logic to save changes
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
              } else if (state is AuthUnauthenticated) {
                return const Center(child: Text('User is not authenticated'));
              }
              return const SkeletonAccountCard();
            },
          ),
        ),
      ),
    );
  }
}
