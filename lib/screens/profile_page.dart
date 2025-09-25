import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../theme/app_components.dart';
import 'edit_profile_screen.dart';
import 'info_pages.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // MODIFIED: Header Row with Title and Sign Out Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile',
                    style: AppTextStyles.h1,
                  ),
                  // Sign Out Button (Moved to top right)
                  IconButton(
                    icon: Icon(
                      Icons.logout,
                      size: AppSizes.iconLarge,
                      color: AppColors.errorColor,
                    ),
                    onPressed: () => _showSignOutDialog(context, authProvider),
                    // Removed extra padding/background to keep it clean like a standard action icon
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Profile Info Card
              Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: AppBorderRadius.card,
                    boxShadow: AppShadows.card,
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.backgroundColor,
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (user?.email != null)
                        Text(
                          user!.email!,
                          style: AppTextStyles.h3,
                        ),
                      const SizedBox(height: 8),
                      Text(
                        'IMAGEPICK User',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      AppComponents.primaryButton(
                        text: 'Edit Profile',
                        onPressed: () => _navigateToEditProfile(context),
                        width: null,
                        padding: const EdgeInsets.symmetric(horizontal: AppSizes.xl, vertical: AppSizes.md),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Options List
              Expanded(
                child: ListView(
                  children: [
                    _buildProfileOption(
                      context,
                      'Welcome to Imagepick',
                      Icons.waving_hand,
                      // Assuming WelcomeScreen is accessible from info_pages.dart or defined elsewhere
                          () => _navigateToPage(context, const WelcomeScreen()),
                    ),
                    _buildProfileOption(
                      context,
                      'About Paramount',
                      Icons.info,
                          () => _navigateToPage(context, const AboutParamountScreen()),
                    ),
                    _buildProfileOption(
                      context,
                      'Visit Paramount Site',
                      Icons.public,
                          () => _navigateToPage(context, const VisitSiteScreen()),
                    ),
                    _buildProfileOption(
                      context,
                      'Terms & Conditions',
                      Icons.description,
                          () => _navigateToPage(context, const TermsConditionsScreen()),
                    ),
                    _buildProfileOption(
                      context,
                      'Privacy Policy',
                      Icons.privacy_tip,
                          () => _navigateToPage(context, const PrivacyPolicyScreen()),
                    ),
                    _buildProfileOption(
                      context,
                      'Upgrade Firmware',
                      Icons.upgrade,
                          () => _navigateToPage(context, const UpgradeFirmwareScreen()),
                    ),
                    const SizedBox(height: 32),
                    // REMOVED: The old Sign Out button was here. Keeping this space for padding if necessary.
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption(
      BuildContext context,
      String title,
      IconData icon,
      VoidCallback onTap,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.md),
      padding: const EdgeInsets.all(AppSizes.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: AppBorderRadius.card,
        boxShadow: AppShadows.card,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primaryText, size: AppSizes.iconLarge),
              const SizedBox(width: AppSizes.lg),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: AppSizes.iconSmall,
                color: AppColors.tertiaryText,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _navigateToEditProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EditProfileScreen(),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Assuming authProvider.signOut() handles navigation away from the page
              authProvider.signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}