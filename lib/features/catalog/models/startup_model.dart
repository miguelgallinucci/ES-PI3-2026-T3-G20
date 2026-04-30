class StartupModel {
  final String name;
  final String sector;
  final String stage;
  final String description;
  final String capital;
  final String tokens;

  const StartupModel({
    required this.name,
    required this.sector,
    required this.stage,
    required this.description,
    required this.capital,
    required this.tokens,
  });

  factory StartupModel.fromFirestore(Map<String, dynamic> data) {
    final capitalRaised = _toDouble(data['capitalRaised']);
    final totalTokens = _toInt(data['totalTokens']);

    return StartupModel(
      name: data['name']?.toString() ?? 'Startup sem nome',
      sector: data['sector']?.toString() ?? 'Setor não informado',
      stage: data['stage']?.toString() ?? 'Estágio não informado',
      description: data['description']?.toString() ?? 'Descrição não informada',
      capital: _formatCurrency(capitalRaised),
      tokens: _formatNumber(totalTokens),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return 0;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    return 0;
  }

  static String _formatCurrency(double value) {
    if (value >= 1000000) {
      final millions = value / 1000000;
      return 'R\$ ${millions.toStringAsFixed(1).replaceAll('.', ',')} mi';
    }

    if (value >= 1000) {
      final thousands = value / 1000;
      return 'R\$ ${thousands.toStringAsFixed(0)} mil';
    }

    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  static String _formatNumber(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }
}
