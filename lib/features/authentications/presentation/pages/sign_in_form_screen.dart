import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:mona_coffee/core/utils/common.dart';
import 'package:mona_coffee/core/utils/sizer.dart';
import 'package:mona_coffee/core/widgets/activity_indicator.dart';
import 'package:mona_coffee/core/widgets/custom_input_field.dart';
import 'package:mona_coffee/core/widgets/error_text.dart';
import 'package:mona_coffee/core/widgets/flasher.dart';
import 'package:mona_coffee/features/authentications/data/repositories/authentication_repository.dart';
import 'package:mona_coffee/features/authentications/presentation/blocs/sign_in_bloc.dart';

class LoginFormScreen extends StatelessWidget {
  const LoginFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Sizer().init(context);

    
    final AuthenticationRepository authenticationRepository =
        AuthenticationRepository(FirebaseAuth.instance);

    return BlocProvider(
      create: (context) =>
          SignInBloc(authenticationRepository),
      child: BlocConsumer<SignInBloc, SignInState>(
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
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),
                      Text(
                        'Log in to get\nyour perfect cup.',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown[900],
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 48),
                      CustomInputField(
                        paddingOuterTop: 15,
                        paddingOuterBottom: 0,
                        label: 'Email*',
                        hint: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        initialValue: state.email,
                        onChange: (value) => context
                            .read<SignInBloc>()
                            .add(EmailSignInChanged(value)),
                      ),
                      state.emailError != null
                          ? ErrorText(
                              text: state.emailError!,
                            )
                          : const SizedBox.shrink(),
                      const SizedBox(height: 20),
                      CustomInputField(
                        paddingOuterTop: 15,
                        paddingOuterBottom: 0,
                        label: 'Password*',
                        hint: 'Password',
                        initialValue: state.password,
                        obscureText: state.passwordToggleStatus,
                        suffixIcon: state.passwordToggleStatus
                            ? FontAwesomeIcons.eyeSlash
                            : FontAwesomeIcons.eye,
                        onPressedSuffix: () => {
                          context.read<SignInBloc>().add(
                              PasswordSignInToggleChanged(
                                  !state.passwordToggleStatus)),
                        },
                        onChange: (value) => {
                          context.read<SignInBloc>().add(
                                PasswordSignInChanged(value),
                              ),
                        },
                      ),
                      state.passwordError != null
                          ? ErrorText(
                              text: state.passwordError!,
                            )
                          : const SizedBox.shrink(),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            context
                                .read<SignInBloc>()
                                .add(FormSignInSubmitted());
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
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            context.goNamed('forgot-password');
                          },
                          child: Text(
                            'Forgot password?',
                            style: TextStyle(
                              color: Colors.brown[900],
                              fontSize: 14,
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
        },
      ),
    );
  }
}
