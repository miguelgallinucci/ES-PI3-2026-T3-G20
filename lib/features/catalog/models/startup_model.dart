class StartupModel {
  final String id;
  final String name;
  final String sector;
  final List<String> categories;
  final String stage;
  final String description;
  final String capital;
  final String tokens;

  const StartupModel({
    this.id = '',
    required this.name,
    this.sector = '',
    this.categories = const [],
    required this.stage,
    required this.description,
    required this.capital,
    required this.tokens,
  });

  factory StartupModel.fromMap(Map<String, dynamic> data) {
    final List<String> firebaseCategories = data['categorias'] is List
        ? List<String>.from(data['categorias'])
        : [];

    final String fallbackSector = data['sector'] ?? '';

    final List<String> finalCategories = firebaseCategories.isNotEmpty
        ? firebaseCategories
        : fallbackSector.isNotEmpty
        ? [fallbackSector]
        : [];

    return StartupModel(
      id: data['id']?.toString() ?? data['idStartup']?.toString() ?? '',
      name: data['name'] ?? '',
      sector: finalCategories.isNotEmpty ? finalCategories.first : '',
      categories: finalCategories,
      stage: data['stage'] ?? '',
      description: data['description'] ?? '',
      capital: data['capitalRaised'] != null
          ? 'R\$ ${data['capitalRaised']}'
          : data['capital'] ?? '',
      tokens: data['totalTokens'] != null
          ? '${data['totalTokens']}'
          : data['tokens'] ?? '',
    );
  }

  factory StartupModel.fromFirestore(Map<String, dynamic> data) {
    return StartupModel.fromMap(data);
  }
}