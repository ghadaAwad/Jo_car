import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/validators.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../widgets/logo_widget.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const LogoWidget(),
                  Transform.translate(
                    offset: const Offset(0, -100),
                    child: Column(
                      children: [
                        Text(
                          'Welcome Back',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Please Log in to your account',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 50),

                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: Validators.email,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                            suffixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFFFDD853),
                                width: 2.0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          validator: Validators.password,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            floatingLabelBehavior: FloatingLabelBehavior.auto,
                            suffixIcon: const Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xFFFDD853),
                                width: 2.0,
                              ),
                            ),
                          ),
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => context.push('/forget-password'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                            child: const Text(
                              'Forgot Password?',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),

                        const SizedBox(height: 50),

                        SizedBox(
                          height: 50,
                          width: 300,
                          child: ElevatedButton(
                            onPressed: auth.loading
                                ? null
                                : () async {
                                    if (_formKey.currentState!.validate()) {
                                      await auth.login(
                                        _emailController.text.trim(),
                                        _passwordController.text.trim(),
                                      );

                                      if (auth.isAuthenticated &&
                                          context.mounted) {
                                        context.go('/home');
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Invalid email or password',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFDD853),
                              foregroundColor: Colors.black,
                              elevation: 0,
                            ),
                            child: auth.loading
                                ? const CircularProgressIndicator()
                                : const Text(
                                    'Log In',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        const SizedBox(height: 20),
                        /*       SizedBox(
                          height: 50,
                          width: 300,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final auth = context.read<AuthProvider>();

                              try {
                                await auth.signInWithGoogle();

                                if (auth.isAuthenticated) {
                                  context.go('/home');
                                }
                              } catch (e) {
                                if (e.toString().contains("NO_ACCOUNT")) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "هذا الحساب غير مسجل. يرجى إنشاء حساب أولاً.",
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "فشل تسجيل الدخول عبر Google.",
                                      ),
                                    ),
                                  );
                                }
                              }
                            },

                            icon: Image.asset(
                              'assets/images/google_logo.png',
                              height: 24,
                              width: 24,
                            ),
                           label: const Text(
                              'Sign in with Google',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
*/
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Don’t have an account?'),
                            TextButton(
                              onPressed: () => context.push('/register'),
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Color(0xFFFDD853),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
