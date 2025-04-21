import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:boom_solutions_invoice/final/controller/themeController.dart';
import '../controller/auth_controller.dart';

/// Helper function that returns the current route's animation or a fallback.
Animation<double> getAnimation(BuildContext context) {
  final route = ModalRoute.of(context);
  return route?.animation ?? kAlwaysCompleteAnimation;
}

class AuthScreen extends StatelessWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Make sure both ThemeController and AuthController are available via GetX.
    Get.find<ThemeController>();
    Get.put(AuthController()); // Ensures the AuthController is created

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with scale animation
                AnimatedScale(
                  scale: 1.0,
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  child: Hero(
                    tag: 'logo',
                    child: SvgPicture.asset(
                      "lib/assets/boomLogo.svg",
                      width: 120,
                      height: 120,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Auth form with slide up animation
                SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: getAnimation(context),
                      curve: Curves.easeOutQuart,
                    ),
                  ),
                  child: const _ProfessionalAuthForm(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Converted _ProfessionalAuthForm to a StatefulWidget to create a local GlobalKey.
class _ProfessionalAuthForm extends StatefulWidget {
  const _ProfessionalAuthForm({Key? key}) : super(key: key);

  @override
  State<_ProfessionalAuthForm> createState() => _ProfessionalAuthFormState();
}

class _ProfessionalAuthFormState extends State<_ProfessionalAuthForm> {
  @override
  Widget build(BuildContext context) {
    // Retrieve the controllers using Get.find
    final authController = Get.find<AuthController>();
    final isDarkMode = Get.find<ThemeController>().isDarkMode;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      // Use the controller's form key for validation.
      child: Form(
        key: authController.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title with fade animation
            FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: getAnimation(context),
                  curve: const Interval(0.3, 0.6, curve: Curves.easeIn),
                ),
              ),
              child: Text(
                'Welcome Back',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: isDarkMode ? Colors.white : Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Email field with slide animation
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-0.5, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: getAnimation(context),
                  curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
                ),
              ),
              child: _ProfessionalEmailField(
                controller: authController.emailController,
                isDarkMode: isDarkMode,
              ),
            ),
            const SizedBox(height: 20),
            // Token field with slide animation
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.5, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(
                  parent: getAnimation(context),
                  curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
                ),
              ),
              child: _ProfessionalTokenField(
                controller: authController.apiTokenController,
                isDarkMode: isDarkMode,
              ),
            ),
            const SizedBox(height: 40),
            // Sign in button with loading animation
            _ProfessionalSignInButton(),
            const SizedBox(height: 20),
            // Forgot token link with fade animation
            FadeTransition(
              opacity: Tween<double>(begin: 0, end: 1).animate(
                CurvedAnimation(
                  parent: getAnimation(context),
                  curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
                ),
              ),
              child: _ForgotTokenLink(isDarkMode: isDarkMode),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfessionalEmailField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDarkMode;

  const _ProfessionalEmailField({
    Key? key,
    required this.controller,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      // validator: (value) => GetUtils.isEmail(value!) ? null : 'Invalid email',
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black87,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: 'Enter your email',
        hintStyle: TextStyle(
          color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
        ),
        prefixIcon: Icon(
          Icons.email_outlined,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
        filled: true,
        fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        errorStyle: TextStyle(
          color: Colors.red[300],
        ),
      ),
    );
  }
}

class _ProfessionalTokenField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDarkMode;

  const _ProfessionalTokenField({
    Key? key,
    required this.controller,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: (value) => value!.isEmpty ? 'Enter API token' : null,
      obscureText: true,
      style: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black87,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: 'API Token',
        hintStyle: TextStyle(
          color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
        ),
        prefixIcon: Icon(
          Icons.vpn_key_outlined,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
        filled: true,
        fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        errorStyle: TextStyle(
          color: Colors.red[300],
        ),
      ),
    );
  }
}

class _ProfessionalSignInButton extends StatelessWidget {
  const _ProfessionalSignInButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final isDarkMode = Get.find<ThemeController>().isDarkMode;

    return Obx(() => AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: authController.isLoading.value
            ? null
            : LinearGradient(
          colors: [
            isDarkMode ? Colors.blueAccent : Colors.blue,
            isDarkMode ? Colors.lightBlueAccent : Colors.lightBlue,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        color: authController.isLoading.value
            ? (isDarkMode ? Colors.grey[800] : Colors.grey[300])
            : null,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (!authController.isLoading.value)
            BoxShadow(
              color: Colors.blue.withOpacity(isDarkMode ? 0.3 : 0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: authController.isLoading.value ? null : authController.signIn,
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.transparent,
          child: Center(
            child: authController.isLoading.value
                ? SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: isDarkMode ? Colors.white : Colors.blue,
              ),
            )
                : const Text(
              'Sign In',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    ));
  }
}

class _ForgotTokenLink extends StatelessWidget {
  final bool isDarkMode;

  const _ForgotTokenLink({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Contact your system administrator for a new API token.',
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.all(12),
      ),
      child: Text(
        'Forgot your API Token?',
        style: TextStyle(
          color: isDarkMode ? Colors.blue[200] : Colors.blue[600],
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
