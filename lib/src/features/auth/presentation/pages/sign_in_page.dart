import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:postra/src/features/auth/data/models/login_request.dart';
import 'package:postra/src/features/auth/presentation/pages/sign_up_page.dart';
import 'package:postra/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:postra/src/features/auth/presentation/widgets/auth_input_box.dart';
import 'package:postra/src/features/main_tabs.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    bool isLoggingIn = authState.isLoggingIn;

    void handleSignIn() async {
      final identifier = _identifierController.text;
      final password = _passwordController.text;
      if (isLoggingIn) {
        return;
      }
      if (identifier.isEmpty || password.isEmpty) {
        return;
      }
      final loginRequest = LoginRequest(
        usernameOrEmail: identifier,
        password: password,
      );
      await authState.login(loginRequest);
      if (authState.loginError != null) {
        if (context.mounted) {
          showCupertinoDialog(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: const Text(
                  'Error',
                  style: TextStyle(color: CupertinoColors.systemRed),
                ),
                content: Text(authState.loginError!),
                actions: [
                  CupertinoDialogAction(
                    child: const Text(
                      'OK',
                      style: TextStyle(color: CupertinoColors.systemRed),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        }
      } else {
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(builder: (context) => const MainTabs()),
          );
        }
      }
    }

    return CupertinoPageScaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Stack(
        children: [
          // Background Decorative Elements
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                child: Container(color: CupertinoColors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                height:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 64),

                    // Branding
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: isDark
                            ? CupertinoColors.white
                            : CupertinoColors.black,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: CupertinoColors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        CupertinoIcons.person,
                        size: 32,
                        color: isDark
                            ? CupertinoColors.black
                            : CupertinoColors.white,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Header
                    Text(
                      'Welcome back',
                      style: theme.textTheme.textStyle.merge(
                        const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please enter your details to sign in.',
                      style: theme.textTheme.textStyle.merge(
                        TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? CupertinoColors.systemGrey
                              : CupertinoColors.systemGrey2,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Form
                    AuthInputBox(
                      label: 'Email or Username',
                      placeholder: 'alex@example.com',
                      controller: _identifierController,
                    ),
                    const SizedBox(height: 24),
                    AuthInputBox(
                      label: 'Password',
                      placeholder: '••••••••',
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      suffix: CupertinoButton(
                        padding: const EdgeInsets.only(right: 12),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        child: Icon(
                          _isPasswordVisible
                              ? CupertinoIcons.eye_slash
                              : CupertinoIcons.eye,
                          size: 20,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {},
                        child: Text(
                          'Forgot password?',
                          style: theme.textTheme.textStyle.merge(
                            TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? CupertinoColors.systemGrey
                                  : CupertinoColors.systemGrey2,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        color: isDark
                            ? CupertinoColors.white
                            : CupertinoColors.black,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        borderRadius: BorderRadius.circular(100),
                        onPressed: () {
                          handleSignIn();
                        },
                        child: isLoggingIn
                            ? CupertinoActivityIndicator(
                                color: isDark
                                    ? CupertinoColors.black
                                    : CupertinoColors.white,
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Log In',
                                    style: theme.textTheme.textStyle.merge(
                                      TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? CupertinoColors.black
                                            : CupertinoColors.white,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    CupertinoIcons.arrow_right,
                                    size: 18,
                                    color: isDark
                                        ? CupertinoColors.black
                                        : CupertinoColors.white,
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sign Up Link
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: theme.textTheme.textStyle.merge(
                              TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? CupertinoColors.systemGrey
                                    : CupertinoColors.systemGrey2,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                          CupertinoButton(
                            padding: const EdgeInsets.only(left: 4),
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                CupertinoPageRoute(
                                  builder: (context) => const SignUpPage(),
                                ),
                              );
                            },
                            child: Text(
                              'Sign Up',
                              style: theme.textTheme.textStyle.merge(
                                TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? CupertinoColors.white
                                      : CupertinoColors.black,
                                  decoration: TextDecoration.none,
                                ),
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
        ],
      ),
    );
  }
}
