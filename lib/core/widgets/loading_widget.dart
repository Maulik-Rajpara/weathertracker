import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/screen_size_util.dart';
import '../constants/app_strings.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    ScreenSizeUtil().init(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              width: ScreenSizeUtil.getProportionateScreenWidth(80),
              height: ScreenSizeUtil.getProportionateScreenWidth(80),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (message != null)
            Text(
              message!,
              style: TextStyle(
                fontSize: ScreenSizeUtil.getResponsiveFontSize(16),
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
} 