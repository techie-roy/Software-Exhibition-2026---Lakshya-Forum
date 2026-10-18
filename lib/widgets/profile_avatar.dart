import 'package:flutter/material.dart';

import '../app/constants.dart';
import '../models/farmer.dart';

/// Circular profile avatar: the farmer's profile-photo URL (Google sign-in
/// profile photo) when present, otherwise the initials fallback. A failed
/// network load falls back to initials instead of showing a broken image.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.farmer,
    required this.size,
    required this.fontSize,
    required this.fontWeight,
    required this.borderWidth,
    required this.borderColor,
  });

  final Farmer farmer;
  final double size;
  final double fontSize;
  final FontWeight fontWeight;
  final double borderWidth;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    final photoUrl = farmer.photoUrl;
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surfacePaleGreen,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: photoUrl == null || photoUrl.isEmpty
          ? Center(child: _initials())
          : Image.network(
              photoUrl,
              fit: BoxFit.cover,
              width: size,
              height: size,
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
              errorBuilder: (context, error, stackTrace) =>
                  Center(child: _initials()),
            ),
    );
  }

  Widget _initials() => Text(
    farmer.avatarInitials,
    style: TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: AppColors.primaryGreen,
    ),
  );
}
