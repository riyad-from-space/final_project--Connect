import 'package:connect/core/widgets/buttons/submit_button.dart';
import 'package:connect/features/auth/view/screens/verification_code_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/text_style.dart';
import '../../../../../core/widgets/buttons/back_button.dart';
import '../../../view_model/auth_viewmodel.dart';
import '../../../widgets/headline.dart';
import '../sign_screens/signup_screen.dart';

final isFormValidProvider = StateProvider<bool>((ref) => false);

class LoginScreen extends ConsumerWidget {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the isFormValidProvider
    final isFormValid = ref.watch(isFormValidProvider);

    // Function to check if both fields are filled
    void _updateFormValidity() {
      final emailFilled = _emailController.text.isNotEmpty;
      final passwordFilled = _passwordController.text.isNotEmpty;
      ref.read(isFormValidProvider.notifier).state = emailFilled && passwordFilled;
    }

    // Add listeners to the controllers
    _emailController.addListener(_updateFormValidity);
    _passwordController.addListener(_updateFormValidity);

    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: const CustomBackButton(),
        ),
        actions: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VerificationCodeScreen(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(

                'Forgotten Password?',
                style: KTextStyle.subtitle1.copyWith(
                  fontFamily: GoogleFonts.openSans().fontFamily,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: const Color(0xffA76FFF),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/Ellipse 1.png',
                      height: 60,
                      width: 60,
                      alignment: Alignment.center,
                    ),
                  ],
                ),
                SizedBox(
                  height: 100,
                ),
                Headline(
                  headline: 'Welcome Back',
                  sub_headline: 'Enter your email address and password',
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    prefixIcon: const Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required.';
                    }
                    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid Gmail address.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required.';
                    }
                    final passwordRegex = RegExp(
                      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{6,}$',
                    );
                    if (!passwordRegex.hasMatch(value)) {
                      return 'Password must include:\n'
                          '- At least 6 characters\n'
                          '- Uppercase, lowercase, number, and special character.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Column(
                  children: [
                    SubmitButton(
                      isEnabled: isFormValid,
                      onSubmit: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            await ref.read(authViewModelProvider).login(
                                  _emailController.text.trim(),
                                  _passwordController.text.trim(),
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Sign Up Successful!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            Navigator.pushNamed(context, '/notes');
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: ${e.toString()}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please fix the errors in the form.'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text(
                          'Don\'t have an account? ',
                          style: TextStyle(fontSize: 16),
                        ),
                        TextButton(
                          onPressed: () {
                            // Navigate to Sign Up page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignupScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'Signup',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xffA76FFF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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
}
