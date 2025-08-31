import 'package:json_annotation/json_annotation.dart';

part 'collection.g.dart';

@JsonSerializable()
class Collection {
  final String id;
  final String name;
  final String type;
  final String? language;
  final DateTime timestamp;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const Collection({
    required this.id,
    required this.name,
    required this.type,
    this.language,
    required this.timestamp,
    required this.createdAt,
  });

  factory Collection.fromJson(Map<String, dynamic> json) => _$CollectionFromJson(json);
  Map<String, dynamic> toJson() => _$CollectionToJson(this);

  // Get collection type display name
  String get typeDisplay {
    switch (type) {
      case 'trending':
        return 'Trending';
      case 'fastest_growing':
        return 'Fast Growing';
      case 'newly_published':
        return 'New Projects';
      default:
        return type;
    }
  }
  
  // Get language display
  String get languageDisplay => language ?? 'All Languages';
  
  // Get display name combining type and language
  String get displayName {
    if (language != null) {
      return '$typeDisplay ($language)';
    }
    return typeDisplay;
  }
}

// Enum for collection types
enum CollectionType {
  trending,
  @JsonValue('fastest_growing')
  fastestGrowing,
  @JsonValue('newly_published')
  newlyPublished;

  String get displayName {
    switch (this) {
      case CollectionType.trending:
        return 'Trending';
      case CollectionType.fastestGrowing:
        return 'Fast Growing';
      case CollectionType.newlyPublished:
        return 'New Projects';
    }
  }
}