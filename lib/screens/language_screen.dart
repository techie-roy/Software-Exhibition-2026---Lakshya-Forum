import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/constants.dart';
import '../app/localizations.dart';
import '../app/routes.dart';
import '../models/language.dart';
import '../providers/language_provider.dart';
import '../widgets/app_logo.dart';
import '../widgets/primary_button.dart';

class LanguageScreen extends StatefulWidget {
  final bool isSettingsMode;

  const LanguageScreen({super.key, this.isSettingsMode = false});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late String _selectedCode;

  @override
  void initState() {
    super.initState();
    final current = context.read<LanguageProvider>().currentLanguage;
    _selectedCode = current.code;
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final s = S.of(context);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: widget.isSettingsMode
          ? AppBar(
              title: Text(s.chooseLanguage),
              backgroundColor: Colors.white,
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!widget.isSettingsMode) ...[
                const SizedBox(height: 24),
                const Center(child: AppLogo(size: 72)),
                const SizedBox(height: 16),
                Text(
                  s.appTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryGreen,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  s.appSubtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  s.chooseLanguage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
              ] else
                const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: AppLanguage.supportedLanguages.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final lang = AppLanguage.supportedLanguages[index];
                    final isSelected = lang.code == _selectedCode;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedCode = lang.code;
                        });
                      },
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.surfacePaleGreen : Colors.white,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                          border: Border.all(
                            color: isSelected ? AppColors.primaryGreen : AppColors.borderSubtle,
                            width: isSelected ? 2.0 : 1.0,
                          ),
                          boxShadow: isSelected ? AppShadows.softCard : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : AppColors.surfaceSoftMint,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  lang.nativeName.characters.take(1).toString(),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? AppColors.primaryGreen : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lang.nativeName,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                      color: isSelected ? AppColors.primaryGreen : AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    lang.englishName,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? AppColors.primaryGreen : Colors.transparent,
                                border: Border.all(
                                  color: isSelected ? AppColors.primaryGreen : AppColors.borderSubtle,
                                  width: 2.0,
                                ),
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      size: 16,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                text: widget.isSettingsMode ? s.saveLanguage : s.continueText,
                icon: Icons.arrow_forward_rounded,
                onPressed: () async {
                  final chosen = AppLanguage.supportedLanguages.firstWhere(
                    (l) => l.code == _selectedCode,
                    orElse: () => AppLanguage.supportedLanguages.first,
                  );
                  await languageProvider.setLanguage(chosen);

                  if (!context.mounted) return;

                  if (widget.isSettingsMode) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacementNamed(context, AppRoutes.login);
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
