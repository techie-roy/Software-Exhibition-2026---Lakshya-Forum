import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/constants.dart';
import '../app/localizations.dart';
import '../app/routes.dart';
import '../models/farmer.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/info_card.dart';
import 'language_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    final s = S.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        ),
        title: Text(
          s.logoutTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Text(
          s.logoutDesc,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(s.cancel, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusAlert,
              foregroundColor: Colors.white,
            ),
            child: Text(s.logoutLabel),
          ),
        ],
      ),
    );
  }

  void _showPersonalInfoDialog(BuildContext context, Farmer farmer) {
    final s = S.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXLarge)),
      ),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.personalInformation,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 12),
              _ProfileDetailRow(label: s.fullName, val: farmer.name),
              _ProfileDetailRow(label: s.mobileNumber, val: farmer.mobile),
              _ProfileDetailRow(label: s.farmerId, val: farmer.id),
              _ProfileDetailRow(label: s.landSize, val: '${farmer.landSizeAcres} ${s.acres}'),
              _ProfileDetailRow(label: s.village, val: farmer.village),
              _ProfileDetailRow(label: s.district, val: farmer.district),
              _ProfileDetailRow(label: s.state, val: farmer.state),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showDocumentsDialog(BuildContext context, Farmer farmer) {
    final s = S.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXLarge)),
      ),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.myDocuments,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 12),
              _DocumentItem(
                title: s.kccDocument,
                number: farmer.kisanCreditCard,
                icon: Icons.credit_card,
              ),
              const SizedBox(height: 10),
              _DocumentItem(
                title: s.aadhaarDocument,
                number: farmer.aadhaarMasked,
                icon: Icons.fingerprint,
              ),
              const SizedBox(height: 10),
              _DocumentItem(
                title: '${s.bankAccount} (${farmer.bankName})',
                number: farmer.bankAccountMasked,
                icon: Icons.account_balance,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpSupportDialog(BuildContext context) {
    final s = S.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXLarge)),
      ),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.helpSupport,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfacePaleGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.phone_in_talk, color: AppColors.primaryGreen, size: 28),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.tollFree,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s.helplineHours,
                          style: const TextStyle(fontSize: 13, color: AppColors.primaryGreen, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '${s.faq}:',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('• ${s.faq1}'),
              const SizedBox(height: 4),
              Text('• ${s.faq2}'),
              const SizedBox(height: 4),
              Text('• ${s.faq3}'),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final languageProvider = context.watch<LanguageProvider>();
    final s = S.of(context);
    final farmer = authProvider.currentFarmer ??
        const Farmer(
          id: 'FID-UP-78219',
          name: 'Rajesh Kumar',
          mobile: '+91 9876543210',
          mandiId: 'MND-LKO-01',
          mandiName: 'Lucknow Central Mandi',
          mandiAddress: 'Transport Nagar, Lucknow, UP',
          landSizeAcres: 6.5,
          village: 'Malihabad',
          district: 'Lucknow',
          state: 'Uttar Pradesh',
          kisanCreditCard: 'KCC-8821-4412-9901',
          aadhaarMasked: 'XXXX-XXXX-4819',
          bankAccountMasked: 'SBI ••••••••3912',
          bankName: 'State Bank of India',
          avatarInitials: 'RK',
        );

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(s.farmerProfile),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMedium, vertical: 12),
          child: Column(
            children: [
              InfoCard(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.surfacePaleGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryGreen, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          farmer.avatarInitials,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            farmer.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            farmer.mobile,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfacePaleGreen,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${s.farmerId}: ${farmer.id}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              InfoCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _ProfileTile(
                      icon: Icons.person_outline,
                      title: s.personalInformation,
                      subtitle: '${farmer.village}, ${farmer.district}',
                      onTap: () => _showPersonalInfoDialog(context, farmer),
                    ),
                    const Divider(height: 1, indent: 56, color: AppColors.borderSubtle),
                    _ProfileTile(
                      icon: Icons.storefront_outlined,
                      title: s.myMandi,
                      subtitle: farmer.mandiName,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${s.selectedMandiLabel}: ${farmer.mandiName}'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 56, color: AppColors.borderSubtle),
                    _ProfileTile(
                      icon: Icons.folder_shared_outlined,
                      title: s.myDocuments,
                      subtitle: s.kccAadhaarBank,
                      onTap: () => _showDocumentsDialog(context, farmer),
                    ),
                    const Divider(height: 1, indent: 56, color: AppColors.borderSubtle),
                    _ProfileTile(
                      icon: Icons.translate_rounded,
                      title: s.languageLabel,
                      subtitle: languageProvider.currentLanguage.nativeName,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LanguageScreen(isSettingsMode: true),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 56, color: AppColors.borderSubtle),
                    _ProfileTile(
                      icon: Icons.notifications_none_rounded,
                      title: s.notificationsAlerts,
                      subtitle: s.smsMandiReminders,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(s.notificationsEnabled),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 56, color: AppColors.borderSubtle),
                    _ProfileTile(
                      icon: Icons.help_outline_rounded,
                      title: s.helpSupport,
                      subtitle: s.tollFree,
                      onTap: () => _showHelpSupportDialog(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              InfoCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.statusAlertBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.logout_rounded, color: AppColors.statusAlert, size: 20),
                  ),
                  title: Text(
                    s.logoutLabel,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.statusAlert,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.statusAlert),
                  onTap: () => _showLogoutDialog(context),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surfaceSoftMint,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primaryGreen, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}

class _ProfileDetailRow extends StatelessWidget {
  final String label;
  final String val;

  const _ProfileDetailRow({required this.label, required this.val});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              val,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentItem extends StatelessWidget {
  final String title;
  final String number;
  final IconData icon;

  const _DocumentItem({
    required this.title,
    required this.number,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 2),
                Text(number, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 18),
        ],
      ),
    );
  }
}
