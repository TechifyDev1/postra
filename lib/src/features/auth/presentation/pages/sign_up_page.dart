import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:postra/src/features/auth/data/models/register_request.dart';
import 'package:postra/src/features/auth/presentation/pages/sign_in_page.dart';
import 'package:postra/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:postra/src/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:postra/src/features/main_tabs.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CupertinoTheme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authenticationProvider = ref.watch(authProvider);
    bool isRegistering = authenticationProvider.isRegistering;

    void handleSignUp() async {
      final fullName = _fullNameController.text;
      final username = _usernameController.text;
      final email = _emailController.text;
      final password = _passwordController.text;

      if (isRegistering) return;

      if (fullName.isEmpty ||
          username.isEmpty ||
          email.isEmpty ||
          password.isEmpty) {
        return;
      }

      final request = RegisterRequest(
        fullName: fullName,
        username: username,
        email: email,
        password: password,
      );

      await authenticationProvider.register(request);

      if (authenticationProvider.registerError != null) {
        if (context.mounted) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text(
                'Error',
                style: TextStyle(color: CupertinoColors.systemRed),
              ),
              content: Text(authenticationProvider.registerError!),
              actions: [
                CupertinoDialogAction(
                  child: const Text(
                    'OK',
                    style: TextStyle(color: CupertinoColors.systemRed),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          );
        }
        return;
      }

      if (authenticationProvider.currentUser != null) {
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
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => Navigator.pop(context),
                    child: Icon(
                      CupertinoIcons.chevron_left,
                      color: isDark
                          ? CupertinoColors.white
                          : CupertinoColors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Header
                Text(
                  'Create Account',
                  style: theme.textTheme.textStyle.merge(
                    const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join the minimalist movement.',
                  style: theme.textTheme.textStyle.merge(
                    TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? CupertinoColors.systemGrey2
                          : CupertinoColors.systemGrey,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
                const SizedBox(height: 64),

                // Form
                AuthTextField(
                  label: 'Full Name',
                  placeholder: 'What should we call you?',
                  controller: _fullNameController,
                ),
                const SizedBox(height: 48),
                AuthTextField(
                  label: 'Username',
                  placeholder: 'Choose a handle',
                  controller: _usernameController,
                ),
                const SizedBox(height: 48),
                AuthTextField(
                  label: 'Email Address',
                  placeholder: 'name@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 48),
                AuthTextField(
                  label: 'Password',
                  placeholder: 'Create a password',
                  controller: _passwordController,
                  obscureText: true,
                ),
                const SizedBox(height: 32),

                // Terms Notice
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 12,
                      color: CupertinoColors.systemGrey,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: 'By signing up, you agree to our '),
                      TextSpan(
                        text: 'Terms',
                        style: TextStyle(
                          color: isDark
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: isDark
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Primary Action
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    color: isDark
                        ? CupertinoColors.white
                        : CupertinoColors.black,
                    borderRadius: BorderRadius.circular(16),
                    onPressed: () {
                      handleSignUp();
                    },
                    child: isRegistering
                        ? CupertinoActivityIndicator(
                            color: isDark
                                ? CupertinoColors.black
                                : CupertinoColors.white,
                          )
                        : Text(
                            'Create Account',
                            style: TextStyle(
                              color: isDark
                                  ? CupertinoColors.black
                                  : CupertinoColors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // secondary Action
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?',
                        style: theme.textTheme.textStyle.merge(
                          TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? CupertinoColors.systemGrey2
                                : CupertinoColors.systemGrey,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.only(left: 4),
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            CupertinoPageRoute(
                              builder: (context) => const SignInPage(),
                            ),
                          );
                        }, // Redirect to login
                        child: Text(
                          'Log In',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? CupertinoColors.white
                                : CupertinoColors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
