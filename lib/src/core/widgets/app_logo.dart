import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showBorder;
  
  const AppLogo({
    this.size = 80, 
    this.showBorder = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      // Reduced padding from 0.2 to 0.1 to make the logo look bigger
      padding: EdgeInsets.all(size * 0.1),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: showBorder ? Border.all(color: Colors.green.shade100, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/app_logo.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Icon(
              Icons.eco_rounded,
              size: size * 0.6,
              color: const Color(0xFF2E7D32),
            );
          },
        ),
      ),
    );
  }
}
