// import 'package:boom_solutions_invoice/final/controller/auth_controller.dart';
// import 'package:boom_solutions_invoice/final/controller/themeController.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/get.dart';
// import 'package:flutter/animation.dart';

// class AuthScreen extends StatefulWidget {
//   const AuthScreen({super.key});

//   @override
//   State<AuthScreen> createState() => _AuthScreenState();
// }

// class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1000),
//     );

//     _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     );

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.1),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: Curves.fastOutSlowIn,
//     ));

//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Animated Background
//           Positioned.fill(
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 500),
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: Get.find<ThemeController>().isDarkMode
//                       ? [const Color.fromARGB(255, 0, 33, 60), ]
//                       : [const Color.fromARGB(255, 0, 33, 60), Colors.black],
//                 ),
//               ),
//             ),
//           ),

//           SingleChildScrollView(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               children: [
//                 const SizedBox(height: 80),
//                 // Animated Logo
//                 FadeTransition(
//                   opacity: _fadeAnimation,
//                   child: SlideTransition(
//                   position: _slideAnimation,
//                   child: CircleAvatar(
//                     radius: 55,
//                     backgroundColor: Colors.transparent,
//                     child: ClipOval(
//                     child: SvgPicture.asset(
//                       "lib/assets/boomLogo.svg",
//                       fit: BoxFit.cover,
//                       width: 110,
//                       height: 110,
//                     ),
//                     ),
//                   ),
//                   ),
//                 ),

//                 const SizedBox(height: 40),
//                 AnimatedAuthCard(),

//                 const SizedBox(height: 30),
//                 // Social Login
//                 FadeTransition(
//                   opacity: _fadeAnimation,
//                   child: const SocialLoginRow(),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class AnimatedAuthCard extends StatelessWidget {
//   final AuthController authController = Get.find();

//   AnimatedAuthCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Obx(() => AnimatedContainer(
//             duration: const Duration(milliseconds: 400),
//             curve: Curves.easeInOut,
//             height: authController.isLogin.value ? 480 : 520,
//             child: _DashboardCard(
//               child: Form(
//                 key: authController.formKey,
//                 child: Column(
//                   children: [
//                     AnimatedSwitcher(
//                       duration: const Duration(milliseconds: 300),
//                       child: Text(
//                         authController.isLogin.value ? 'Welcome Back!' : 'Create Account',
//                         key: ValueKey(authController.isLogin.value),
//                         style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                               fontWeight: FontWeight.w800,
//                               letterSpacing: -0.5,
//                             ),
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                     if (!authController.isLogin.value)
//                       AnimatedTextField(
//                         controller: authController.nameController,
//                         label: 'Full Name',
//                         icon: Icons.person_outline,
//                         validator: (value) =>
//                             value!.isEmpty ? 'Enter your name' : null,
//                       ),
//                     AnimatedTextField(
//                       controller: authController.emailController,
//                       label: 'Email Address',
//                       icon: Icons.email_outlined,
//                       validator: (value) =>
//                           GetUtils.isEmail(value!) ? null : 'Invalid email',
//                     ),
//                     const SizedBox(height: 20),
//                     AnimatedTextField(
//                       controller: authController.passwordController,
//                       label: 'Password',
//                       icon: Icons.lock_outline,
//                       obscureText: true,
//                       validator: (value) => value!.length >= 6
//                           ? null
//                           : 'Minimum 6 characters required',
//                     ),
//                     const SizedBox(height: 30),
//                     AnimatedAuthButton(),
//                     const SizedBox(height: 20),
//                     AnimatedAuthSwitch(),
//                   ],
//                 ),
//               ),
//             ),
//           )),
//     );
//   }
// }

// class AnimatedTextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String label;
//   final IconData icon;
//   final bool obscureText;
//   final String? Function(String?)? validator;

//   const AnimatedTextField({
//     super.key,
//     required this.controller,
//     required this.label,
//     required this.icon,
//     this.obscureText = false,
//     this.validator,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: TextFormField(
//         controller: controller,
//         obscureText: obscureText,
//         validator: validator,
//         style: Theme.of(context).textTheme.bodyLarge,
//         decoration: InputDecoration(
//           labelText: label,
//           prefixIcon: Icon(icon, size: 22),
//           border: const UnderlineInputBorder(),
//           floatingLabelBehavior: FloatingLabelBehavior.auto,
//           labelStyle: TextStyle(
//             color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class AnimatedAuthButton extends StatelessWidget {
//   final AuthController authController = Get.find();

//   AnimatedAuthButton({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Obx(() => AnimatedContainer(
//             duration: const Duration(milliseconds: 300),
//             width: authController.isLoading.value ? 60 : double.infinity,
//             height: 50,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(authController.isLoading.value ? 30 : 8),
//               color: Theme.of(context).primaryColor,
//             ),
//             child: Material(
//               color: Colors.transparent,
//               child: InkWell(
//                 borderRadius: BorderRadius.circular(8),
//                 onTap: authController.isLoading.value
//                     ? null
//                     : () => authController.isLogin.value
//                         ? authController.signIn()
//                         : authController.signUp(),
//                 child: AnimatedSwitcher(
//                   duration: const Duration(milliseconds: 300),
//                   child: authController.isLoading.value
//                       ? const Padding(
//                           padding: EdgeInsets.all(12),
//                           child: CircularProgressIndicator(color: Colors.white),
//                         )
//                       : Center(
//                           child: Text(
//                             authController.isLogin.value ? 'Sign In' : 'Register',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                 ),
//               ),
//             ),
//           )),
//     );
//   }
// }

// class AnimatedAuthSwitch extends StatelessWidget {
//   final AuthController authController = Get.find();

//   AnimatedAuthSwitch({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             authController.isLogin.value ? 'New here? ' : 'Have an account? ',
//             style: TextStyle(color: Theme.of(context).hintColor),
//           ),
//           GestureDetector(
//             onTap: () => authController.toggleAuthMode(),
//             child: Container(
//               decoration: BoxDecoration(
//                 border: Border(
//                   bottom: BorderSide(
//                     color: Theme.of(context).hintColor,
//                     width: 1.5,
//                   ),
//                 ),
//               ),
//               child: Text(
//                 authController.isLogin.value ? 'Create Account' : 'Sign In',
//                 style: TextStyle(
//                   color: Colors.purple,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// class _DashboardCard extends StatelessWidget {
//   final Widget child;
//   const _DashboardCard({required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           )
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: child,
//       ),
//     );
//   }
// }




  
// }

// // Reuse the existing _DashboardCard widget from previous implementations// auth_screen.dart
import 'package:boom_solutions_invoice/final/controller/auth_controller.dart';
import 'package:boom_solutions_invoice/final/controller/themeController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter/animation.dart';
class SocialLoginRow extends StatelessWidget {
  const SocialLoginRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Text('Or continue with'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SocialLoginButton(icon: Icons.g_mobiledata, provider: 'Google'),
            SizedBox(width: 20),
            SocialLoginButton(icon: Icons.apple, provider: 'Apple'),
            SizedBox(width: 20),
            SocialLoginButton(icon: Icons.facebook, provider: 'Facebook'),
          ],
        ),
      ],
    );
  }
}
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
         Positioned.fill(
  child: AnimatedContainer(
    
    duration: const Duration(milliseconds: 500),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: Get.find<ThemeController>().isDarkMode
            ? [
                const Color.fromARGB(255, 0, 33, 60),
                const Color.fromARGB(255, 0, 33, 60), // Add second color
              ]
            : [
                const Color.fromARGB(255, 0, 33, 60),
                Colors.black
              ],
      ),
    ),
  ),
),

          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 80),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.transparent,
                      child: ClipOval(
                        child: SvgPicture.asset(
                          "lib/assets/boomLogo.svg",
                          fit: BoxFit.cover,
                          width: 110,
                          height: 110,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
                _AuthForm(),
                const SizedBox(height: 30),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child:  SocialLoginRow(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthForm extends StatelessWidget {
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
       width: MediaQuery.of(context).size.width,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      height: 400,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: authController.formKey,
            child: Column(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    'Welcome Back!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                  ),
                ),
                const SizedBox(height: 30),
                _AnimatedTextField(
                  controller: authController.emailController,
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                  validator: (value) =>
                      GetUtils.isEmail(value!) ? null : 'Invalid email',
                ),
                const SizedBox(height: 20),
                _AnimatedTextField(
                  controller: authController.apiTokenController,
                  label: 'API Token',
                  icon: Icons.vpn_key_outlined,
                  obscureText: false,
                  validator: (value) =>
                      value!.isEmpty ? 'Enter API token' : null,
                ),
                const SizedBox(height: 30),
                _AuthButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final String? Function(String?)? validator;

  const _AnimatedTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 22),
          border: const UnderlineInputBorder(),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  final AuthController authController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() =>AnimatedContainer(
      duration: const Duration(milliseconds: 300),
        width: authController.isLoading.value  ? 200.0 : 100.0, 
      height: 50,
      
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          authController.isLoading.value ? 30 : 8,
        ),
        color: Theme.of(context).primaryColor,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          
          borderRadius: BorderRadius.circular(8),
          onTap: authController.isLoading.value 
              ? null 
              : authController.signIn,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 3000),
            child: authController.isLoading.value
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  )
                : const Center(
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
        ),
      ),
    ));
  
  }
  
}
class SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final String provider;

  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Sign in with $provider',
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, size: 28),
          ),
        ),
      ),
    );
  }}
// Keep other UI components (SocialLoginRow, etc.) as provided