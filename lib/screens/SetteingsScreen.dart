import 'package:boom_solutions_invoice/final/controller/auth_controller.dart';
import 'package:boom_solutions_invoice/final/controller/themeController.dart';
import 'package:boom_solutions_invoice/final/view/auth_Getx.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);
Future<void> logout() async {
    try {
      // Show loading indicator
      
      // Get SharedPreferences instance
      final prefs = await SharedPreferences.getInstance();
      
      // Verify we have the instance
      if (prefs == null) {
        throw Exception("Failed to access SharedPreferences");
      }
      
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
 
      
      // Navigate to login screen
      Get.offAllNamed('/login');
      
      // Show success message
      Get.snackbar(
        'Logged Out', 
        'You have been successfully logged out',
        duration: Duration(seconds: 2),
      );
      
    } catch (e) {
      // Log the error and show message
      debugPrint("Logout error: ${e.toString()}");
      Get.snackbar(
        'Logout Error', 
        'Failed to complete logout: ${e.toString()}',
        duration: Duration(seconds: 3),
      );
    } finally {
    
    }
  }
  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final authController = Get.put<AuthController>(AuthController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card with real user data
            Obx(() => _buildProfileCard(authController.currentUser.value)),
            
            SizedBox(height: 16),

            // Theme Settings Card
            _buildThemeSettingsCard(themeController),
            
            SizedBox(height: 16),

            // Account Settings Card
            _buildAccountSettingsCard(),
            
            SizedBox(height: 16),

            // Notifications Card with proper logout
            _buildNotificationsCard(authController),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(User? user) {
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
                user?.name.substring(0, 1) ?? 'U',
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
                    user?.name ?? 'User',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?.email ?? 'No email',
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

  Widget _buildThemeSettingsCard(ThemeController themeController) {
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
              'Dark Mode',
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

  Widget _buildAccountSettingsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSettingsItem(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () {
              Get.to(() => ProfileScreen());
            },
          ),
          Divider(height: 1),
          _buildSettingsItem(
            icon: Icons.security,
            title: 'Security',
            onTap: () {
              // Implement security settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsCard(AuthController authController) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSettingsItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {
              // Implement notifications
            },
          ),
          Divider(height: 1),
          _buildSettingsItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () {
              _showLogoutDialog(authController);
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(AuthController authController) {
    Get.dialog(
      AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              logout();
              Get.to(AuthScreen());
              authController.logout();
            },
            child: Text(
              'Logout',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Obx(() {
        final user = authController.currentUser.value;
        return user == null
            ? Center(child: Text('No user data available'))
            : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildProfileHeader(user),
                    SizedBox(height: 24),
                    _buildProfileDetails(user),
                  ],
                ),
              );
      }),
    );
  }

  Widget _buildProfileHeader(User user) {
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

  Widget _buildProfileDetails(User user) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDetailItem('Email', user.email),
            Divider(),
            _buildDetailItem('Login', user.login),
            Divider(),
            _buildDetailItem('Store', user.storeName),
            Divider(),
            _buildDetailItem('Store ID', user.storeId.toString()),
            Divider(),
            _buildDetailItem('Partner ID', user.partnerId.toString()),
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