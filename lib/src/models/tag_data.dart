import 'package:flutter/widgets.dart';

class TagData {
  const TagData({
    required this.key,
    required this.id,
    required this.name,
  });
  final GlobalKey key;
  final String id;
  final String name;

  @override
  String toString() {
    return 'TagData(key: $key, id: $id, name: $name)';
  }
}
