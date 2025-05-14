import 'package:boom_solutions_invoice/final/controller/auth_controller.dart';
import 'package:boom_solutions_invoice/final/controller/themeController.dart';
import 'package:boom_solutions_invoice/final/view/auth_Getx.dart';
import 'package:boom_solutions_invoice/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> logout() async {
    try {
      // Show loading indicator
      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      // Get SharedPreferences instance
      final prefs = await SharedPreferences.getInstance();

      // Clear ALL stored data
      final success = await prefs.clear();

      // Verify everything was cleared
      if (!success) {
        throw Exception("Failed to clear SharedPreferences");
      }

      // Verify clearing worked by checking keys
      final keys = prefs.getKeys();
      if (keys.isNotEmpty) {
        throw Exception("Some preferences weren't cleared: ${keys.join(', ')}");
      }

      // Reset user state
      final authController = Get.find<AuthController>();
      authController.logout();

      // Navigate to login screen
      Get.offAllNamed('/login');

      // Show success message
      Get.back(); // Close loading dialog
      Get.snackbar(
        S.of(Get.context!).logoutSuccessTitle,
        S.of(Get.context!).logoutSuccessMessage,
        duration: Duration(seconds: 2),
      );
    } catch (e) {
      // Log the error and show message
      debugPrint("Logout error: ${e.toString()}");
      Get.back(); // Close loading dialog
      Get.snackbar(
        S.of(Get.context!).logoutErrorTitle,
        S.of(Get.context!).logoutErrorMessage + ': ${e.toString()}',
        duration: Duration(seconds: 3),
      );
    } finally {
      // Ensure loading dialog is closed if still open
      if (Get.isDialogOpen ?? false) Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final authController = Get.put<AuthController>(AuthController());
    final l10n = S.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card with real user data
            Obx(() => _buildProfileCard(authController.currentUser.value, l10n)),

            SizedBox(height: 16),

            // Theme Settings Card
            _buildThemeSettingsCard(themeController, l10n),

            SizedBox(height: 16),

            // Account Settings Card
            _buildAccountSettingsCard(l10n),

            SizedBox(height: 16),

            // Notifications Card with proper logout
            _buildNotificationsCard(authController, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(User? user, S l10n) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue,
              child: Text(
                user?.name.substring(0, 1) ?? l10n.defaultUserInitial,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? l10n.defaultUserName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?.email ?? l10n.defaultUserEmail,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  if (user?.storeName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        user!.storeName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSettingsCard(ThemeController themeController, S l10n) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.darkModeTitle,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Obx(
              () => Switch(
                value: themeController.isDarkMode,
                onChanged: (value) => themeController.toggleTheme(),
                activeColor: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSettingsCard(S l10n) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSettingsItem(
            icon: Icons.person_outline,
            title: l10n.editProfileTitle,
            onTap: () {
              Get.to(() => ProfileScreen());
            },
          ),
          Divider(height: 1),
          _buildSettingsItem(
            icon: Icons.security,
            title: l10n.securityTitle,
            onTap: () {
              // Implement security settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsCard(AuthController authController, S l10n) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSettingsItem(
            icon: Icons.notifications_outlined,
            title: l10n.notificationsTitle,
            onTap: () {
              // Implement notifications
            },
          ),
          Divider(height: 1),
          _buildSettingsItem(
            icon: Icons.logout,
            title: l10n.logoutTitle,
            onTap: () {
              _showLogoutDialog(authController, l10n);
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(AuthController authController, S l10n) {
    Get.dialog(
      AlertDialog(
        title: Text(l10n.logoutDialogTitle),
        content: Text(l10n.logoutDialogMessage),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(l10n.cancelButton),
          ),
          TextButton(
            onPressed: () {
              logout();
              Get.to(AuthScreen());
              authController.logout();
            },
            child: Text(
              l10n.logoutButton,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class ProfileScreen extends StatelessWidget {
  final AuthController authController = Get.find();

  ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profileTitle),
      ),
      body: Obx(() {
        final user = authController.currentUser.value;
        return user == null
            ? Center(child: Text(l10n.noUserData))
            : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildProfileHeader(user, l10n),
                    SizedBox(height: 24),
                    _buildProfileDetails(user, l10n),
                  ],
                ),
              );
      }),
    );
  }

  Widget _buildProfileHeader(User user, S l10n) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.blue,
          child: Text(
            user.name.substring(0, 1),
            style: TextStyle(
              fontSize: 36,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 16),
        Text(
          user.name,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          user.email,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileDetails(User user, S l10n) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDetailItem(l10n.emailLabel, user.email),
            Divider(),
            _buildDetailItem(l10n.loginLabel, user.login),
            Divider(),
            _buildDetailItem(l10n.storeLabel, user.storeName ?? ''),
            Divider(),
            _buildDetailItem(l10n.storeIdLabel, user.storeId.toString()),
            Divider(),
            _buildDetailItem(l10n.partnerIdLabel, user.partnerId.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}