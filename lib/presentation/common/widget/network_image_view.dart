import 'package:flutter/material.dart';
import 'package:hello_flutter/presentation/values/dimens.dart';

class NetworkImageView extends StatelessWidget {
  final String url;
  final Widget? placeholder;
  final double height;
  final double width;
  final BoxFit? fit;
  final BorderRadiusGeometry borderRadius;

  const NetworkImageView({
    required this.url,
    this.placeholder,
    this.height = double.infinity,
    this.width = double.infinity,
    this.fit,
    this.borderRadius = BorderRadius.zero,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.network(url, fit: fit, height: height, width: width,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        return frame == null ? placeholder ?? _placeholder() : child;
      }, errorBuilder: (context, error, stackTrace) {
        return placeholder ?? _errorPlaceholder();
      }),
    );
  }

  Widget _placeholder() {
    return Container(
      height: height,
      width: width,
      padding: EdgeInsets.all(Dimens.dimen_8),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _errorPlaceholder() {
    return Container(
      height: height,
      width: width,
      padding: EdgeInsets.all(Dimens.dimen_8),
      child: const Icon(Icons.error),
    );
  }
}
