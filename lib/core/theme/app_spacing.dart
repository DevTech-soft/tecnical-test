import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  // Base spacing unit (8dp)
  static const double baseUnit = 8.0;

  // Spacing scale
  static const double xs = baseUnit * 0.5; // 4
  static const double sm = baseUnit; // 8
  static const double md = baseUnit * 2; // 16
  static const double lg = baseUnit * 3; // 24
  static const double xl = baseUnit * 4; // 32
  static const double xxl = baseUnit * 6; // 48
  static const double xxxl = baseUnit * 8; // 64

  // Padding presets
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);
  static const EdgeInsets paddingXXL = EdgeInsets.all(xxl);

  // Horizontal padding
  static const EdgeInsets paddingHorizontalXS = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets paddingHorizontalSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets paddingHorizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingHorizontalLG = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHorizontalXL = EdgeInsets.symmetric(horizontal: xl);

  // Vertical padding
  static const EdgeInsets paddingVerticalXS = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets paddingVerticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets paddingVerticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingVerticalLG = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets paddingVerticalXL = EdgeInsets.symmetric(vertical: xl);

  // Common padding combinations
  static const EdgeInsets paddingPageHorizontal = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingPageVertical = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingPage = EdgeInsets.all(md);
  static const EdgeInsets paddingCard = EdgeInsets.all(md);
  static const EdgeInsets paddingButton = EdgeInsets.symmetric(horizontal: lg, vertical: md);

  // Border radius
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusFull = 999.0;

  // Border radius presets
  static BorderRadius get borderRadiusXS => BorderRadius.circular(radiusXS);
  static BorderRadius get borderRadiusSM => BorderRadius.circular(radiusSM);
  static BorderRadius get borderRadiusMD => BorderRadius.circular(radiusMD);
  static BorderRadius get borderRadiusLG => BorderRadius.circular(radiusLG);
  static BorderRadius get borderRadiusXL => BorderRadius.circular(radiusXL);
  static BorderRadius get borderRadiusXXL => BorderRadius.circular(radiusXXL);
  static BorderRadius get borderRadiusFull => BorderRadius.circular(radiusFull);

  // Elevation levels
  static const double elevation0 = 0;
  static const double elevation1 = 2;
  static const double elevation2 = 4;
  static const double elevation3 = 8;
  static const double elevation4 = 16;
  static const double elevation5 = 24;

  // Icon sizes
  static const double iconXS = 16.0;
  static const double iconSM = 20.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 48.0;
  static const double iconXXL = 64.0;

  // Avatar sizes
  static const double avatarSM = 32.0;
  static const double avatarMD = 48.0;
  static const double avatarLG = 64.0;
  static const double avatarXL = 96.0;

  // Button heights
  static const double buttonHeightSM = 36.0;
  static const double buttonHeightMD = 48.0;
  static const double buttonHeightLG = 56.0;

  // Common widget sizes
  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 64.0;
  static const double cardMinHeight = 80.0;
  static const double fabSize = 56.0;
  static const double fabSizeLarge = 64.0;

  // Divider
  static const double dividerThickness = 1.0;
  static const double dividerIndent = md;

  // Breakpoints for responsive design
  static const double breakpointMobile = 600;
  static const double breakpointTablet = 1024;
  static const double breakpointDesktop = 1440;

  // Max content widths
  static const double maxContentWidthMobile = 600;
  static const double maxContentWidthTablet = 1024;
  static const double maxContentWidthDesktop = 1440;

  // Grid spacing
  static const double gridSpacing = md;
  static const double listSpacing = sm;

  // Helper methods
  static EdgeInsets only({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) {
    return EdgeInsets.only(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    );
  }

  static SizedBox verticalSpace(double height) => SizedBox(height: height);
  static SizedBox horizontalSpace(double width) => SizedBox(width: width);

  // Common spacers
  static Widget get verticalSpaceXS => verticalSpace(xs);
  static Widget get verticalSpaceSM => verticalSpace(sm);
  static Widget get verticalSpaceMD => verticalSpace(md);
  static Widget get verticalSpaceLG => verticalSpace(lg);
  static Widget get verticalSpaceXL => verticalSpace(xl);

  static Widget get horizontalSpaceXS => horizontalSpace(xs);
  static Widget get horizontalSpaceSM => horizontalSpace(sm);
  static Widget get horizontalSpaceMD => horizontalSpace(md);
  static Widget get horizontalSpaceLG => horizontalSpace(lg);
  static Widget get horizontalSpaceXL => horizontalSpace(xl);
}
