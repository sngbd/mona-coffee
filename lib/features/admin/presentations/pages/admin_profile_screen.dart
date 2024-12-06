import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mona_coffee/core/utils/common.dart';
import 'package:mona_coffee/core/utils/sizer.dart';
import 'package:mona_coffee/core/widgets/activity_indicator.dart';
import 'package:mona_coffee/features/authentications/presentation/blocs/profile_bloc.dart';
import 'package:mona_coffee/features/authentications/presentation/blocs/sign_out_bloc.dart';
import 'package:go_router/go_router.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Sizer().init(context);

    return Scaffold(
      backgroundColor: mLightOrange,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'My Profile',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: mDarkBrown,
                  ),
                ),
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'Admin',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: mDarkBrown,
                    ),
                  ),
                ),
              ),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: BlocListener<SignOutBloc, SignOutState>(
                    listener: (context, state) {
                      if (state is SignOutInProgress) {
                        Scaffold(
                          appBar: null,
                          body: SizedBox(
                            height: Sizer.screenHeight,
                            child: const Center(
                              child: ActivityIndicator(),
                            ),
                          ),
                        );
                      }

                      if (state is SignOutSuccess) {
                        context.goNamed('login', extra: {'clearStack': true});
                      }
                    },
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<SignOutBloc>().add(SignOutRequested());
                        context.read<ProfileBloc>().add(ResetProfileForm());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mBrown,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
