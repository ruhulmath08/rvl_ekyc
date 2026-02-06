import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

abstract class BaseUiState<W extends StatefulWidget> extends State<W> {
  Widget valueListenableBuilder<T>({
    required ValueListenable<T> listenable,
    required Widget Function(BuildContext context, T value) builder,
  }) {
    return ValueListenableBuilder(
      valueListenable: listenable,
      builder: (context, value, child) {
        return builder(context, value);
      },
    );
  }
}
