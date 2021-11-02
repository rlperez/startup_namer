class NameSuggestion {
  final int id;
  final String name;
  final bool isFavorite;

  NameSuggestion({
    required this.id,
    required this.name,
    required this.isFavorite
  });

  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isFavorite': isFavorite,
    };
  }

  @override
  String toString() {
    return 'NameSuggestion{id: $id, name: $name, isFavorite: $isFavorite}';
  }
}