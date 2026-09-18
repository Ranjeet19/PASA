import 'package:flutter/material.dart';
import 'package:my_assist/services/user_profile.dart';
import 'package:my_assist/utils/colors.dart';

class ProfileAvatar extends StatelessWidget {
  final double radius;

  const ProfileAvatar({
    super.key,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final photo = UserProfile.photoBytes;

    final placeholder = Icon(
      Icons.person,
      color: primaryColor,
      size: radius,
    );

    return ClipOval(
      child: SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: ColoredBox(
          color: Colors.grey.shade900,
          child: photo == null
              ? Center(child: placeholder)
              : Image.memory(
                  photo,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(child: placeholder);
                  },
                ),
        ),
      ),
    );
  }
}