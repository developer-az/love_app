class Memory {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime date;
  final String location;
  final bool isFavorite;

  Memory({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.date,
    required this.location,
    this.isFavorite = false,
  });

  bool matchesQuery(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return title.toLowerCase().contains(q) ||
        description.toLowerCase().contains(q) ||
        location.toLowerCase().contains(q);
  }

  Memory copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    DateTime? date,
    String? location,
    bool? isFavorite,
  }) {
    return Memory(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      date: date ?? this.date,
      location: location ?? this.location,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  factory Memory.fromJson(Map<String, dynamic> json) {
    final dateValue = json['date'];
    DateTime parsedDate;
    if (dateValue is String && dateValue.isNotEmpty) {
      parsedDate = DateTime.tryParse(dateValue) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return Memory(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      date: parsedDate,
      location: json['location']?.toString() ?? '',
      isFavorite: json['isFavorite'] == true,
    );
  }

  static Memory? tryFromJson(dynamic json) {
    Map<String, dynamic>? map;
    if (json is Map<String, dynamic>) {
      map = json;
    } else if (json is Map) {
      map = Map<String, dynamic>.from(json);
    }
    if (map == null) return null;

    try {
      final memory = Memory.fromJson(map);
      if (memory.id.isEmpty) return null;
      return memory;
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'date': date.toIso8601String(),
      'location': location,
      'isFavorite': isFavorite,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Memory && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
