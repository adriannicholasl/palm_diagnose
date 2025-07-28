import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:palm_diagnose/features/auth/controllers/auth_controller.dart';
import 'package:palm_diagnose/features/auth/pages/auth_gate.dart';
import 'package:palm_diagnose/features/auth/pages/register_page.dart';
import 'package:palm_diagnose/features/auth/widgets/auth_input_field.dart';
import 'package:palm_diagnose/core/constants/svg_assets.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Gradient gradient;
  final TextAlign? textAlign;

  const GradientText(
    this.text, {
    super.key,
    required this.gradient,
    required this.style,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return gradient.createShader(
          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
        );
      },
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
      ),
    );
  }
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ValueNotifier<bool> isPasswordVisible = ValueNotifier(false);
  final ValueNotifier<bool> rememberMe = ValueNotifier(false);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    isPasswordVisible.dispose();
    rememberMe.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD1F7C4),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE1F9C6),
              Color(0xFFE4FFEB),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                        horizontal: 20, vertical: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.black.withOpacity(0.05),
                      //     blurRadius: 15,
                      //     offset: const Offset(0, 2),
                      //   ),
                      // ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const GradientText(
                          "Get Started now",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF49F68B),
                              Color(0xFFF5B575),
                              Color(0xFFFBACB7),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Create an account or log in to explore our app",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final auth = AuthController();
                                final error = await auth.signInWithGoogle();
                                if (!context.mounted) return;
                                if (error != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error)),
                                  );
                                } else {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const AuthGate()),
                                  );
                                }
                              },
                              icon: SvgPicture.string(googleIcon, height: 20),
                              label: const Text(
                                "Sign in with Google",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color.fromARGB(137, 16, 16, 16),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF444444),
                                side:
                                    const BorderSide(color: Color(0xFFE0E0E0)),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16, horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text("Or"),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AuthInputField(
                          label: "Email",
                          hintText: "exmaple@gmail.com",
                          controller: emailController,
                        ),
                        const SizedBox(height: 16),
                        ValueListenableBuilder<bool>(
                          valueListenable: isPasswordVisible,
                          builder: (context, isVisible, _) {
                            return AuthInputField(
                              label: "Password",
                              hintText: "********",
                              controller: passwordController,
                              isPassword: true,
                              obscureText: !isVisible,
                              toggleVisibility: () {
                                isPasswordVisible.value = !isVisible;
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              // Ganti Flexible jadi Expanded
                              child: ValueListenableBuilder<bool>(
                                valueListenable: rememberMe,
                                builder: (context, value, _) {
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Checkbox(
                                        value: value,
                                        onChanged: (val) =>
                                            rememberMe.value = val ?? false,
                                        materialTapTargetSize: MaterialTapTargetSize
                                            .shrinkWrap, // memperkecil area klik
                                        visualDensity: VisualDensity
                                            .compact, // lebih rapat
                                      ),
                                      const SizedBox(width: 4),
                                      const Expanded(
                                        child: Text(
                                          "Remember me",
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontSize:
                                                  12), // tambahkan ukuran kecil
                                          softWrap: false,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     ValueListenableBuilder<bool>(
                        //       valueListenable: rememberMe,
                        //       builder: (context, value, _) {
                        //         return Row(
                        //           children: [
                        //             Checkbox(
                        //               value: value,
                        //               onChanged: (val) =>
                        //                   rememberMe.value = val ?? false,
                        //             ),
                        //             const Text("Remember me"),
                        //           ],
                        //         );
                        //       },
                        //     ),
                        //     TextButton(
                        //       onPressed: () {},
                        //       child: const Text(
                        //         "Forgot Password?",
                        //         style: TextStyle(
                        //           color: Colors.blue,
                        //           fontWeight: FontWeight.w500,
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10), // padding luar kiri-kanan
                          child: SizedBox(
                            width: double.infinity, // tombol selebar parent
                            child: ElevatedButton(
                              onPressed: () async {
                                final email = emailController.text.trim();
                                final password = passwordController.text.trim();
                                final auth = AuthController();
                                final error =
                                    await auth.loginWithEmailAndPassword(
                                  email: email,
                                  password: password,
                                );
                                if (!context.mounted) return;
                                if (error != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(error)),
                                  );
                                } else {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const AuthGate()),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: const Color(0xFF3366FF),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16), // tinggi tombol
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      8), // lebih elegan dari 5
                                ),
                              ),
                              child: const Text(
                                "Log In",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don’t have an account? "),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const SignUpScreen()),
                                );
                              },
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
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
    );
  }
}
