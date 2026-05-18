// Utilitários globais de formatação usados no aplicativo.
//
// Centraliza formatação de moeda, valores compactos e datas para evitar
// duplicação de métodos privados nas telas.
import 'package:cloud_firestore/cloud_firestore.dart';

class AppFormatters {
  /// Formata um valor numérico para o padrão de moeda brasileira (R$)
  /// Exemplo: 1000.50 -> R$ 1000,50
  static String currency(double value) {
    return 'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Formata um valor numérico para moeda negativa
  /// Exemplo: 50.0 -> -R$ 50,00
  static String negativeCurrency(double value) {
    final positiveValue = value.abs();
    return '-R\$ ${positiveValue.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  /// Formata um valor de forma compacta (ex: 1.5k)
  static String compactCurrency(double value) {
    if (value.abs() >= 1000) {
      final compact = value / 1000;
      return '${compact.toStringAsFixed(1).replaceAll('.', ',')}k';
    }
    return value.toStringAsFixed(0);
  }

  /// Formata uma data para o padrão brasileiro (DD/MM/YYYY)
  static String date(DateTime? date) {
    if (date == null) return 'Agora';
    
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    
    return '$day/$month/$year';
  }

  /// Formata um Timestamp do Firestore para data brasileira
  static String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'Agora';
    return date(timestamp.toDate());
  }
}
