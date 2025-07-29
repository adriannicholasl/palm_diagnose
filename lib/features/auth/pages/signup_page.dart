import 'package:flutter/material.dart';
import 'package:palm_diagnose/features/auth/controllers/auth_controller.dart';
import 'package:palm_diagnose/features/auth/pages/auth_gate.dart';
import 'package:palm_diagnose/features/auth/pages/signin_page.dart'
    hide GradientText;
import 'package:palm_diagnose/features/auth/widgets/auth_input_field.dart';
// import 'package:palm_diagnose/features/auth/widgets/auth_back_button.dart';
import 'package:flutter/services.dart'; //
import 'package:palm_diagnose/features/auth/widgets/auth_gradient_text.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  final isPasswordVisible = ValueNotifier(false);
  final isConfirmVisible = ValueNotifier(false);
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    isPasswordVisible.dispose();
    isConfirmVisible.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (passwordController.text != confirmController.text) {
      setState(() => errorMessage = 'Password dan konfirmasi tidak cocok.');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final auth = AuthController();
    final result = await auth.signUpWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      username: usernameController.text.trim(),
      phone: phoneController.text.trim().replaceAll(RegExp(r'\D'), ''),
    );

    setState(() {
      isLoading = false;
      errorMessage = result;
    });

    if (result == null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AuthGate()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD1F7C4),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE1F9C6), Color(0xFFE4FFEB), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    const Text(
                      "Logoipsum",
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // const AuthBackButton(),
                          const SizedBox(height: 16),
                          const GradientText(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF49F68B),
                                Color(0xFFF5B575),
                                Color(0xFFFBACB7),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                errorMessage!,
                                style: const TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Already have an account? "),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SignInScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Sign In",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          AuthInputField(
                            label: "Username",
                            hintText: " ",
                            controller: usernameController,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Username wajib diisi'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          AuthInputField(
                            hintText: "example@gmai.com",
                            label: "Email",
                            controller: emailController,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Email wajib diisi'
                                : null,
                          ),
                          AuthInputField(
                            label: "Phone Number",
                            controller: phoneController,
                            hintText: "Masukan Nomor Telpon",
                            validator: (value) => value == null || value.isEmpty
                                ? 'Nomor telepon wajib diisi'
                                : null,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                          const SizedBox(height: 16),
                          ValueListenableBuilder(
                            valueListenable: isPasswordVisible,
                            builder: (_, visible, __) {
                              return AuthInputField(
                                label: "Password",
                                hintText: "*******",
                                controller: passwordController,
                                isPassword: true,
                                obscureText: !visible,
                                toggleVisibility: () =>
                                    isPasswordVisible.value = !visible,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password wajib diisi';
                                  } else if (value.length < 6) {
                                    return 'Password minimal 6 karakter';
                                  }
                                  return null;
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          ValueListenableBuilder(
                            valueListenable: isConfirmVisible,
                            builder: (_, visible, __) {
                              return AuthInputField(
                                label: "Confirm Password",
                                hintText: "*******",
                                controller: confirmController,
                                isPassword: true,
                                obscureText: !visible,
                                toggleVisibility: () =>
                                    isConfirmVisible.value = !visible,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Konfirmasi password wajib diisi';
                                  } else if (value != passwordController.text) {
                                    return 'Konfirmasi tidak cocok';
                                  }
                                  return null;
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: const Color(0xFF3366FF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    "Register",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
