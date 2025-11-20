import 'package:flutter/widgets.dart';

class ResponsiveLayout {
  ResponsiveLayout(this.width);

  factory ResponsiveLayout.of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return ResponsiveLayout(size.width);
  }

  final double width;

  bool get isCompact => width < 420;
  bool get isMedium => width >= 420 && width < 900;
  bool get isExpanded => width >= 900;

  double get horizontalPadding =>
      isCompact ? 16 : isMedium ? 24 : 40;

  double get sectionPadding => isCompact ? 16 : 24;

  double get maxContentWidth => isExpanded ? 1100 : double.infinity;
}
