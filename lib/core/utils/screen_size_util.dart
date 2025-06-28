import 'package:flutter/material.dart';

class ScreenSizeUtil {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double defaultSize;
  static late Orientation orientation;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;
    
    // Default size is based on screen width
    defaultSize = orientation == Orientation.landscape 
        ? screenHeight * 0.024 
        : screenWidth * 0.024;
  }

  // Get the proportionate height as per screen size
  static double getProportionateScreenHeight(double inputHeight) {
    double screenHeight = _mediaQueryData.size.height;
    return (inputHeight / 812.0) * screenHeight;
  }

  // Get the proportionate width as per screen size
  static double getProportionateScreenWidth(double inputWidth) {
    double screenWidth = _mediaQueryData.size.width;
    return (inputWidth / 375.0) * screenWidth;
  }

  // Check if device is tablet
  static bool isTablet() {
    return screenWidth > 600;
  }

  // Check if device is phone
  static bool isPhone() {
    return screenWidth <= 600;
  }

  // Get responsive font size
  static double getResponsiveFontSize(double baseSize) {
    if (isTablet()) {
      return baseSize * 1.2;
    }
    return baseSize;
  }

  // Get responsive padding
  static EdgeInsets getResponsivePadding({
    double horizontal = 16.0,
    double vertical = 16.0,
  }) {
    if (isTablet()) {
      return EdgeInsets.symmetric(
        horizontal: horizontal * 1.5,
        vertical: vertical * 1.5,
      );
    }
    return EdgeInsets.symmetric(
      horizontal: horizontal,
      vertical: vertical,
    );
  }
} 