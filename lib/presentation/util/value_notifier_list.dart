import 'package:flutter/foundation.dart';

class ValueNotifierList<T> extends ValueNotifier<List<T>> {
  ValueNotifierList(List<T> value) : super(value);

  void add(T item) {
    value = List.from(value)..add(item);
  }

  void addAll(List<T> items) {
    value = List.from(value)..addAll(items);
  }

  void remove(T item) {
    value = List.from(value)..remove(item);
  }

  void removeAt(int index) {
    value = List.from(value)..removeAt(index);
  }

  void clear() {
    value = [];
  }

  void updateAt(int index, T item) {
    value = List.from(value)..[index] = item;
  }

  void updateAll(List<T> items) {
    value = List.from(items);
  }

  void updateWhere(bool Function(T) test, T item) {
    value = List.from(value)..[value.indexWhere(test)] = item;
  }

  void updateItem(T oldItem, T newItem) {
    value = List.from(value)..[value.indexOf(oldItem)] = newItem;
  }
}
