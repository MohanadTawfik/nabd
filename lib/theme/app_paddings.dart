import 'package:flutter/material.dart';

class AppPaddings {
  static const EdgeInsets allExtraSmall = EdgeInsets.all(4.0);
  static const EdgeInsets tiny = EdgeInsets.all(4.0);
  static const EdgeInsets allSmall = EdgeInsets.all(8.0);
  static const EdgeInsets allMedium = EdgeInsets.all(16.0);
  static const EdgeInsets allLarge = EdgeInsets.all(24.0);

  static const EdgeInsets horizontalSmall = EdgeInsets.symmetric(horizontal: 8.0);
  static const EdgeInsets horizontalMedium = EdgeInsets.symmetric(horizontal: 16.0);
  static const EdgeInsets horizontalLarge = EdgeInsets.symmetric(horizontal: 24.0);

  static const EdgeInsets verticalSmall = EdgeInsets.symmetric(vertical: 8.0);
  static const EdgeInsets verticalMedium = EdgeInsets.symmetric(vertical: 16.0);
  static const EdgeInsets verticalLarge = EdgeInsets.symmetric(vertical: 24.0);
  static const BorderRadius verticalTop20 = BorderRadius.vertical(top: Radius.circular(20.0));
  static const EdgeInsets fromLTRB = EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 0);

  static const SizedBox extraSmallHeight = SizedBox(height: 4.0);
  static const SizedBox smallHeight = SizedBox(height: 8.0);
  static const SizedBox mediumHeight = SizedBox(height: 16.0);
  static const SizedBox largeHeight = SizedBox(height: 24.0);

  static const SizedBox smallWidth = SizedBox(width: 8.0);
  static const SizedBox mediumWidth = SizedBox(width: 16.0);
  static const SizedBox largeWidth = SizedBox(width: 24.0);

  static const double mediumRadius = 12.0;
  static const double largeIconSize = 48.0;
}