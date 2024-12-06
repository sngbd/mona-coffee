import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:mona_coffee/core/utils/common.dart';
import 'package:mona_coffee/core/utils/sizer.dart';
import 'package:mona_coffee/core/widgets/activity_indicator.dart';
import 'package:mona_coffee/core/widgets/flasher.dart';
import 'package:mona_coffee/features/authentications/presentation/blocs/sign_in_bloc.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Sizer().init(context);

    return BlocConsumer<SignInBloc, SignInState>(
      listener: (context, state) {
        if (state.status == FormStatusSignIn.failure) {
          Flasher.showSnackBar(
            context,
            'Error',
            state.errorMessage ?? '-',
            Icons.error_outline,
            Colors.red,
          );
        }

        if (state.status == FormStatusSignIn.success) {
          context.read<SignInBloc>().add(ResetFormSignIn());
          context.goNamed('home');
        }
      },
      builder: (context, state) {
        if (state.status == FormStatusSignIn.submitting) {
          return Scaffold(
            appBar: null,
            body: SizedBox(
              height: Sizer.screenHeight,
              child: const Center(
                child: ActivityIndicator(),
              ),
            ),
          );
        } else {
          return Scaffold(
            backgroundColor: mLightPink,
            appBar: AppBar(
              backgroundColor: mLightPink,
              leading: Padding(
                padding: const EdgeInsets.only(
                  top: 20,
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              title: const Padding(
                padding: EdgeInsets.only(
                  top: 25,
                ),
                child: Text(
                  'Log In',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    const Text(
                      'Log in to get\nyour perfect cup.',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: mDarkBrown,
                        height: 1.2,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        context.goNamed('login-form');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mBrown,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () {
                        context.read<SignInBloc>().add(GoogleSignInSubmitted());
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            'assets/icons/Google.svg',
                            fit: BoxFit.fill,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Continue with Google',
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: mBrown,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            context.goNamed('sign-up');
                          },
                          child: const Text(
                            'Sign up',
                            style: TextStyle(
                              color: mDarkBrown,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
