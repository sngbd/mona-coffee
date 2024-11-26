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
import 'package:mona_coffee/features/authentications/presentation/blocs/sign_up_bloc.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Sizer().init(context);

    return BlocProvider(
      create: (context) => SignUpBloc(),
      child: BlocConsumer<SignUpBloc, SignUpState>(
        listener: (context, state) {
          if (state.status == FormStatusSignUp.failure) {
            Flasher.showSnackBar(
              context,
              'Error',
              state.errorMessage ?? '-',
              Icons.error_outline,
              Colors.red,
            );
          }

          if (state.status == FormStatusSignUp.success) {
            context.read<SignUpBloc>().add(ResetFormSignUp());
            context.goNamed('sign-up-login-form');
          }
        },
        builder: (context, state) {
          if (state.status == FormStatusSignUp.submitting) {
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
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: state.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 60),
                        Text(
                          'Join us and start\nyour coffee journey.',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.brown[900],
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 40),
                        CustomInputField(
                          paddingOuterTop: 15,
                          paddingOuterBottom: 0,
                          label: 'Email*',
                          hint: 'Email',
                          keyboardType: TextInputType.emailAddress,
                          initialValue: state.email,
                          onChange: (value) => context
                              .read<SignUpBloc>()
                              .add(EmailSignUpChanged(value)),
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
                            context.read<SignUpBloc>().add(
                                PasswordSignUpToggleChanged(
                                    !state.passwordToggleStatus)),
                          },
                          onChange: (value) => {
                            context.read<SignUpBloc>().add(
                                  PasswordSignUpChanged(value),
                                ),
                          },
                        ),
                        state.passwordError != null
                            ? ErrorText(
                                text: state.passwordError!,
                              )
                            : const SizedBox.shrink(),
                        const SizedBox(height: 20),
                        CustomInputField(
                          paddingOuterTop: 15,
                          paddingOuterBottom: 0,
                          label: 'Password Confirmation*',
                          hint: 'Confirm Password',
                          initialValue: state.confirmPassword,
                          obscureText: state.confirmPasswordToggleStatus,
                          suffixIcon: state.confirmPasswordToggleStatus
                              ? FontAwesomeIcons.eyeSlash
                              : FontAwesomeIcons.eye,
                          onPressedSuffix: () => {
                            context.read<SignUpBloc>().add(
                                ConfirmPasswordSignUpToggleChanged(
                                    !state.confirmPasswordToggleStatus)),
                          },
                          onChange: (value) => {
                            context.read<SignUpBloc>().add(
                                  ConfirmPasswordSignUpChanged(value),
                                ),
                          },
                        ),
                        state.confirmPasswordError != null
                            ? ErrorText(
                                text: state.confirmPasswordError!,
                              )
                            : const SizedBox.shrink(),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              context
                                  .read<SignUpBloc>()
                                  .add(FormSignUpSubmitted());
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
                              'Sign Up',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Already have an account?',
                              style: TextStyle(color: Colors.brown[900]),
                            ),
                            TextButton(
                              onPressed: () {
                                context.goNamed('sign-up-login-form');
                              },
                              child: const Text(
                                'Log in',
                                style: TextStyle(
                                  color: Colors.brown,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
