import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../startup/models/startup_model.dart';
import '../widgets/catalog_market_offer_card.dart';
import '../widgets/catalog_user_position_card.dart';

class CatalogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  Stream<List<StartupModel>> watchStartups() {
    return _firestore.collection('startups').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        return StartupModel.fromMap({
          ...data,
          'id': doc.id,
        });
      }).toList();
    });
  }

  /// desenvolvido por Miguel Gallinucci - lista ofertas abertas do balcao para compra.
  Stream<List<AvailableOffer>> watchOpenOffers() {
    final uid = currentUserId;

    return _firestore
        .collection('marketOffers')
        .where('status', isEqualTo: 'open')
        .snapshots()
        .asyncMap((snapshot) async {
      final startupPrices = await _fetchStartupPrices();
      final offers = <AvailableOffer>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['source'] != 'balcao') continue;
        if (uid != null && data['sellerId'] == uid) continue;

        final quantity = _toInt(data['remainingQuantity'] ?? data['quantity']);
        final unitPrice = _toDouble(data['unitPrice']);
        if (quantity <= 0 || unitPrice <= 0) continue;

        final startupId = data['startupId']?.toString() ?? '';
        final currentPrice = startupPrices[startupId] ?? 0;
        final variation = _formatOfferVariation(unitPrice, currentPrice);

        offers.add(
          AvailableOffer(
            id: doc.id,
            startupId: startupId,
            sellerId: data['sellerId']?.toString() ?? '',
            startup: data['startupName']?.toString() ?? 'Startup',
            sector: data['sector']?.toString() ?? '',
            stage: data['stage']?.toString() ?? '',
            quantity: quantity,
            unitPrice: unitPrice,
            variation: variation,
            createdAtMillis: _toMillis(data['createdAt']),
          ),
        );
      }

      offers.sort((a, b) {
        final priceCompare = a.unitPrice.compareTo(b.unitPrice);
        if (priceCompare != 0) return priceCompare;

        return b.createdAtMillis.compareTo(a.createdAtMillis);
      });
      return offers;
    });
  }

  /// desenvolvido por Miguel Gallinucci - lista ofertas abertas criadas pelo usuario logado.
  Stream<List<AvailableOffer>> watchCurrentUserOpenOffers() {
    final uid = currentUserId;

    if (uid == null) {
      throw Exception('Usuario nao autenticado.');
    }

    return _firestore
        .collection('marketOffers')
        .where('status', isEqualTo: 'open')
        .snapshots()
        .asyncMap((snapshot) async {
      final startupPrices = await _fetchStartupPrices();
      final offers = <AvailableOffer>[];

      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['source'] != 'balcao') continue;
        if (data['sellerId'] != uid) continue;

        final quantity = _toInt(data['remainingQuantity'] ?? data['quantity']);
        final unitPrice = _toDouble(data['unitPrice']);
        if (quantity <= 0 || unitPrice <= 0) continue;
        final startupId = data['startupId']?.toString() ?? '';
        final currentPrice = startupPrices[startupId] ?? 0;

        offers.add(
          AvailableOffer(
            id: doc.id,
            startupId: startupId,
            sellerId: data['sellerId']?.toString() ?? '',
            startup: data['startupName']?.toString() ?? 'Startup',
            sector: data['sector']?.toString() ?? '',
            stage: data['stage']?.toString() ?? '',
            quantity: quantity,
            unitPrice: unitPrice,
            variation: _formatOfferVariation(unitPrice, currentPrice),
            createdAtMillis: _toMillis(data['createdAt']),
          ),
        );
      }

      offers.sort((a, b) {
        final dateCompare = b.createdAtMillis.compareTo(a.createdAtMillis);
        if (dateCompare != 0) return dateCompare;

        return a.startup.compareTo(b.startup);
      });
      return offers;
    });
  }

  /// desenvolvido por Miguel Gallinucci - monta a carteira atual a partir do historico de transacoes.
  Stream<List<UserTokenPosition>> watchCurrentUserPositions() {
    final uid = currentUserId;

    if (uid == null) {
      throw Exception('Usuario nao autenticado.');
    }

    return _firestore
        .collection('transactions')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      final positions = <String, _PositionAccumulator>{};
      final orderedDocs = [...snapshot.docs]
        ..sort((a, b) {
          final aDate = _toMillis(a.data()['createdAt']);
          final bDate = _toMillis(b.data()['createdAt']);

          return aDate.compareTo(bDate);
        });

      for (final doc in orderedDocs) {
        final data = doc.data();
        final type = (data['type'] ?? data['tipo'] ?? '')
            .toString()
            .toLowerCase();
        final isPurchase = type == 'compra' || type == 'compra_balcao';
        final isReservedForSale = type == 'oferta_venda';
        final isCanceledOffer = type == 'cancelamento_oferta';

        if (!isPurchase && !isReservedForSale && !isCanceledOffer) {
          continue;
        }

        final startupName = (data['startupName'] ??
                data['nomeStartup'] ??
                data['startup'] ??
                'Startup')
            .toString();
        final startupId = (data['startupId'] ?? startupName).toString();
        final quantity = _toInt(data['quantity']);
        final tokenPrice = _toDouble(data['tokenPrice']);
        final totalValue = _toDouble(
          data['totalValue'] ?? data['valorTotal'] ?? data['amount'],
        );
        final reservedCost = _toDouble(data['reservedCost']);

        if (quantity <= 0) {
          continue;
        }

        final current = positions[startupId] ??
            _PositionAccumulator(
              startupId: startupId,
              startup: startupName,
              sector: data['sector']?.toString() ?? '',
            );

        if (isPurchase) {
          current.quantity += quantity;
          current.totalValue += totalValue.abs();
          if (tokenPrice > 0) {
            current.currentPrice = tokenPrice;
          }
        } else if (isReservedForSale) {
          final costToReserve = reservedCost > 0
              ? reservedCost
              : current.averagePrice * quantity;
          current.quantity -= quantity;
          current.totalValue = current.totalValue - costToReserve;
          if (current.totalValue < 0) {
            current.totalValue = 0;
          }
        } else if (isCanceledOffer) {
          current.quantity += quantity;
          current.totalValue += reservedCost;
        }

        if (current.sector.isEmpty) {
          current.sector = data['sector']?.toString() ?? '';
        }

        positions[startupId] = current;
      }

      final result = positions.values
          .where((position) => position.quantity > 0)
          .map(
            (position) => UserTokenPosition(
              startupId: position.startupId,
              startup: position.startup,
              sector: position.sector,
              tokensOwned: position.quantity,
              currentPrice: position.currentPrice > 0
                  ? position.currentPrice
                  : position.averagePrice,
              averagePrice: position.averagePrice,
              variation: '+0.0%',
            ),
          )
          .toList()
        ..sort(
          (a, b) => a.startup.compareTo(b.startup),
        );

      return result;
    });
  }

  Stream<double> watchCurrentUserBalance() {
    final uid = currentUserId;

    if (uid == null) {
      throw Exception('Usuario nao autenticado.');
    }

    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      return _toDouble(doc.data()?['saldoFicticio']);
    });
  }

  /// desenvolvido por Miguel Gallinucci - envia para o backend a criacao de oferta de venda.
  Future<void> createSellOffer({
    required String startupId,
    required int quantity,
    required double unitPrice,
  }) async {
    final callable = _functions.httpsCallable('createSellOffer');
    await callable.call({
      'startupId': startupId,
      'quantity': quantity,
      'unitPrice': unitPrice,
    });
  }

  /// desenvolvido por Miguel Gallinucci - compra uma oferta completa do balcao.
  Future<void> buyMarketOffer({required String offerId}) async {
    final callable = _functions.httpsCallable('buyMarketOffer');
    await callable.call({
      'offerId': offerId,
    });
  }

  /// desenvolvido por Miguel Gallinucci - compra uma quantidade parcial de uma oferta do balcao.
  Future<void> buyMarketOfferQuantity({
    required String offerId,
    required int quantity,
  }) async {
    final callable = _functions.httpsCallable('buyMarketOffer');
    await callable.call({
      'offerId': offerId,
      'quantity': quantity,
    });
  }

  /// desenvolvido por Miguel Gallinucci - cancela uma oferta de venda do usuario.
  Future<void> cancelSellOffer({required String offerId}) async {
    final callable = _functions.httpsCallable('cancelSellOffer');
    await callable.call({
      'offerId': offerId,
    });
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.')) ?? 0;
    }
    return 0;
  }

  /// desenvolvido por Miguel Gallinucci - calcula variacao da oferta contra o preco atual do token.
  String _formatOfferVariation(double offerPrice, double currentPrice) {
    if (offerPrice <= 0 || currentPrice <= 0) return '+0.0%';

    final variation = ((offerPrice - currentPrice) / currentPrice) * 100;
    final signal = variation >= 0 ? '+' : '';

    return '$signal${variation.toStringAsFixed(1)}%';
  }

  Future<Map<String, double>> _fetchStartupPrices() async {
    final snapshot = await _firestore.collection('startups').get();

    return {
      for (final doc in snapshot.docs) doc.id: _toDouble(doc.data()['tokenPrice'])
    };
  }

  int _toMillis(dynamic value) {
    if (value is Timestamp) return value.millisecondsSinceEpoch;
    return 0;
  }
}

class _PositionAccumulator {
  final String startupId;
  final String startup;
  String sector;
  int quantity = 0;
  double totalValue = 0;
  double currentPrice = 0;

  _PositionAccumulator({
    required this.startupId,
    required this.startup,
    required this.sector,
  });

  double get averagePrice {
    if (quantity <= 0) return 0;

    return totalValue / quantity;
  }
}
