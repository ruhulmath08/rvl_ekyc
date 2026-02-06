import 'package:flutter/material.dart';
import 'package:hello_flutter/presentation/base/adaptive_util/platform_utils.dart';

class AdaptiveScreenBuilder extends StatelessWidget {
  final ContentBuilder mobilePortraitContentBuilder;
  late final ContentBuilder mobileLandscapeContentBuilder;
  late final ContentBuilder tabPortraitContentBuilder;
  late final ContentBuilder tabLandscapeContentBuilder;
  late final ContentBuilder largeScreenPortraitContentBuilder;
  late final ContentBuilder largeScreenLandscapeContentBuilder;

  AdaptiveScreenBuilder({
    required this.mobilePortraitContentBuilder,
    ContentBuilder? mobileLandscapeContentBuilder,
    ContentBuilder? tabPortraitContentBuilder,
    ContentBuilder? tabLandscapeContentBuilder,
    ContentBuilder? largeScreenPortraitContentBuilder,
    ContentBuilder? largeScreenLandscapeContentBuilder,
    Key? key,
  }) : super(key: key) {
    this.mobileLandscapeContentBuilder =
        mobileLandscapeContentBuilder ?? mobilePortraitContentBuilder;
    this.tabPortraitContentBuilder =
        tabPortraitContentBuilder ?? mobilePortraitContentBuilder;
    this.tabLandscapeContentBuilder =
        tabLandscapeContentBuilder ?? mobilePortraitContentBuilder;
    this.largeScreenPortraitContentBuilder =
        largeScreenPortraitContentBuilder ?? mobilePortraitContentBuilder;
    this.largeScreenLandscapeContentBuilder =
        largeScreenLandscapeContentBuilder ?? mobilePortraitContentBuilder;
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        MediaQueryData mediaQueryData = MediaQuery.of(context);
        PlatformUtils platformUtils = PlatformUtils(mediaQueryData);
        if (platformUtils.screenType == AdaptiveScreenType.mobile &&
            platformUtils.screenOrientation == ScreenOrientation.landscape) {
          return mobileLandscapeContentBuilder(context);
        } else if (platformUtils.screenType == AdaptiveScreenType.tablet &&
            platformUtils.screenOrientation == ScreenOrientation.landscape &&
            platformUtils.screenWidth > 500) {
          return tabLandscapeContentBuilder(context);
        } else if (platformUtils.screenType == AdaptiveScreenType.tablet &&
            platformUtils.screenOrientation == ScreenOrientation.portrait &&
            platformUtils.screenWidth > 500) {
          return tabPortraitContentBuilder(context);
        } else if (platformUtils.screenType == AdaptiveScreenType.large &&
            platformUtils.screenOrientation == ScreenOrientation.landscape &&
            platformUtils.screenWidth > 500) {
          return tabLandscapeContentBuilder(context);
        } else if (platformUtils.screenType == AdaptiveScreenType.large &&
            platformUtils.screenOrientation == ScreenOrientation.portrait &&
            platformUtils.screenWidth > 500) {
          return tabPortraitContentBuilder(context);
        } else {
          return mobilePortraitContentBuilder(context);
        }
      },
    );
  }
}

typedef ContentBuilder = Widget Function(
  BuildContext context,
);
