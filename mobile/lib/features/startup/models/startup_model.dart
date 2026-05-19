class StartupModel {
  final String id;
  final String name;
  final String sector;
  final List<String> categories;
  final String stage;
  final String description;

  final num? capitalRaised;
  final num? totalTokens;
  final num? availableTokens;
  final num? tokenPrice;
  final num? variationPercent;

  final String equityStructure;
  final String executiveSummary;
  final String mentorsBoard;
  final String partners;
  final String businessPlanUrl;
  final String demoVideoUrl;
  final String logoUrl;
  final String status;
  final String emailPrivado;

  const StartupModel({
    this.id = '',
    required this.name,
    this.sector = '',
    this.categories = const [],
    required this.stage,
    required this.description,
    this.capitalRaised,
    this.totalTokens,
    this.availableTokens,
    this.tokenPrice,
    this.variationPercent,
    this.equityStructure = '',
    this.executiveSummary = '',
    this.mentorsBoard = '',
    this.partners = '',
    this.businessPlanUrl = '',
    this.demoVideoUrl = '',
    this.logoUrl = '',
    this.status = '',
    this.emailPrivado = '',
  });

  factory StartupModel.fromMap(Map<String, dynamic> data) {
    final List<String> firebaseCategories = data['categorias'] is List
        ? List<String>.from(data['categorias'])
        : [];

    final String fallbackSector = data['sector']?.toString() ?? '';

    final List<String> finalCategories = firebaseCategories.isNotEmpty
        ? firebaseCategories
        : fallbackSector.isNotEmpty
        ? [fallbackSector]
        : [];

    return StartupModel(
      id: data['id']?.toString() ?? data['idStartup']?.toString() ?? '',
      name: data['name']?.toString() ?? '',
      sector: finalCategories.isNotEmpty ? finalCategories.first : '',
      categories: finalCategories,
      stage: data['stage']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      capitalRaised: _toNum(data['capitalRaised']),
      totalTokens: _toNum(data['totalTokens']),
      availableTokens: _toNum(data['availableTokens']),
      tokenPrice: _toNum(data['tokenPrice']),
      variationPercent: _toNum(data['variationPercent']),
      equityStructure: data['equityStructure']?.toString() ?? '',
      executiveSummary: data['executiveSummary']?.toString() ?? '',
      mentorsBoard: data['mentorsBoard']?.toString() ?? '',
      partners: data['partners']?.toString() ?? '',
      businessPlanUrl: data['businessPlanUrl']?.toString() ?? '',
      demoVideoUrl: data['demoVideoUrl']?.toString() ?? '',
      logoUrl: data['logoUrl']?.toString() ?? '',
      status: data['status']?.toString() ?? '',
      emailPrivado: data['emailPrivado']?.toString() ?? '',
    );
  }

  factory StartupModel.fromFirestore(Map<String, dynamic> data) {
    return StartupModel.fromMap(data);
  }

  static num? _toNum(dynamic value) {
    if (value == null) return null;

    if (value is num) return value;

    if (value is String) {
      return num.tryParse(value.replaceAll(',', '.'));
    }

    return null;
  }

  String get displaySector {
    if (categories.isNotEmpty) {
      return categories.join(' / ');
    }

    return sector;
  }

  String get capital {
    if (capitalRaised == null) return '-';

    return 'R\$ ${_formatNumber(capitalRaised!)}';
  }

  String get tokens {
    if (totalTokens == null) return '-';

    return _formatNumber(totalTokens!, decimalPlaces: 0);
  }

  String get availableTokensText {
    if (availableTokens == null) return '-';

    return _formatNumber(availableTokens!, decimalPlaces: 0);
  }

  String get tokenPriceText {
    if (tokenPrice == null) return '-';

    return 'R\$ ${_formatNumber(tokenPrice!, decimalPlaces: 2)}';
  }

  String get variationText {
    if (variationPercent == null) return '0.0%';

    final value = variationPercent!;
    final signal = value >= 0 ? '+' : '';

    return '$signal${value.toStringAsFixed(1)}%';
  }

  String get aboutText {
    if (executiveSummary.trim().isNotEmpty) {
      return executiveSummary;
    }

    if (description.trim().isNotEmpty) {
      return description;
    }

    return 'Informações sobre o projeto ainda não cadastradas.';
  }

  List<String> get partnersList {
    return _splitTextList(partners);
  }

  List<String> get mentorsList {
    return _splitTextList(mentorsBoard);
  }

  List<String> get equityList {
    return _splitTextList(equityStructure);
  }

  static List<String> _splitTextList(String value) {
    if (value.trim().isEmpty) return [];

    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static String _formatNumber(
      num value, {
        int decimalPlaces = 2,
      }) {
    final fixed = value.toStringAsFixed(decimalPlaces);
    final parts = fixed.split('.');

    String integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';

    final buffer = StringBuffer();

    for (int i = 0; i < integerPart.length; i++) {
      final positionFromEnd = integerPart.length - i;

      buffer.write(integerPart[i]);

      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }

    if (decimalPlaces == 0) {
      return buffer.toString();
    }

    return '${buffer.toString()},$decimalPart';
  }
}