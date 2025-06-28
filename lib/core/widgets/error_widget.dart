import 'package:flutter/material.dart';
import '../utils/screen_size_util.dart';
import '../constants/app_strings.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const CustomErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    ScreenSizeUtil().init(context);
    
    return Center(
      child: Padding(
        padding: ScreenSizeUtil.getResponsivePadding(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: ScreenSizeUtil.getProportionateScreenWidth(64),
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.oops,
              style: TextStyle(
                fontSize: ScreenSizeUtil.getResponsiveFontSize(24),
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: ScreenSizeUtil.getResponsiveFontSize(16),
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text(AppStrings.retry),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 