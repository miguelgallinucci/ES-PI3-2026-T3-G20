import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { db } from '../../shared/firebase';

const MARKET_CURRENT_PRICE_WEIGHT = 0.7;
const MARKET_AVERAGE_PRICE_WEIGHT = 0.3;

function roundTokenPrice(value: number): number {
    return Number(value.toFixed(4));
}

/// desenvolvido por Miguel Gallinucci - ajusta o preco oficial usando media recente do balcao.
function calculateMarketAdjustedPrice(currentPrice: number, marketAveragePrice: number): number {
    if (currentPrice <= 0) {
        return roundTokenPrice(marketAveragePrice);
    }

    if (marketAveragePrice <= 0) {
        return currentPrice;
    }

    return roundTokenPrice(
        (currentPrice * MARKET_CURRENT_PRICE_WEIGHT) +
        (marketAveragePrice * MARKET_AVERAGE_PRICE_WEIGHT)
    );
}

/// desenvolvido por Miguel Gallinucci - processa compra no balcao entre investidor comprador e vendedor.
export const buyMarketOffer = functions.https.onCall(async (data, context) => {
    if (!context.auth || !context.auth.uid) {
        throw new functions.https.HttpsError(
            'unauthenticated',
            'Usuario nao autenticado.'
        );
    }

    const buyerId = context.auth.uid;
    const { offerId, quantity: requestedQuantity } = data;

    if (!offerId || typeof offerId !== 'string' || offerId.trim() === '') {
        throw new functions.https.HttpsError(
            'invalid-argument',
            'O campo offerId e obrigatorio e deve ser uma string valida.'
        );
    }

    if (
        requestedQuantity !== undefined &&
        (typeof requestedQuantity !== 'number' || requestedQuantity <= 0 || !Number.isInteger(requestedQuantity))
    ) {
        throw new functions.https.HttpsError(
            'invalid-argument',
            'A quantidade deve ser um numero inteiro maior que zero.'
        );
    }

    const normalizedOfferId = offerId.trim();
    const offerRef = db.collection('marketOffers').doc(normalizedOfferId);
    const buyerRef = db.collection('users').doc(buyerId);
    const buyerTransactionRef = db.collection('transactions').doc();
    const sellerTransactionRef = db.collection('transactions').doc();

    try {
        await db.runTransaction(async (transaction) => {
            const offerSnapshot = await transaction.get(offerRef);

            if (!offerSnapshot.exists) {
                throw new functions.https.HttpsError('not-found', 'Oferta nao encontrada.');
            }

            const offerData = offerSnapshot.data() || {};
            const sellerId = typeof offerData.sellerId === 'string' ? offerData.sellerId : '';
            const startupId = typeof offerData.startupId === 'string' ? offerData.startupId : '';
            const status = typeof offerData.status === 'string' ? offerData.status : '';
            const remainingQuantity = typeof offerData.remainingQuantity === 'number'
                ? offerData.remainingQuantity
                : (typeof offerData.quantity === 'number' ? offerData.quantity : 0);
            const quantity = requestedQuantity === undefined ? remainingQuantity : requestedQuantity;
            const unitPrice = typeof offerData.unitPrice === 'number' ? offerData.unitPrice : 0;

            if (status !== 'open' || remainingQuantity <= 0) {
                throw new functions.https.HttpsError('failed-precondition', 'Oferta indisponivel.');
            }

            if (quantity <= 0 || quantity > remainingQuantity) {
                throw new functions.https.HttpsError(
                    'failed-precondition',
                    'Quantidade indisponivel nesta oferta.'
                );
            }

            if (!sellerId || !startupId) {
                throw new functions.https.HttpsError('failed-precondition', 'Oferta invalida.');
            }

            if (sellerId === buyerId) {
                throw new functions.https.HttpsError(
                    'failed-precondition',
                    'Voce nao pode comprar a propria oferta.'
                );
            }

            if (unitPrice <= 0) {
                throw new functions.https.HttpsError('failed-precondition', 'Preco da oferta invalido.');
            }

            const sellerRef = db.collection('users').doc(sellerId);
            const buyerPositionRef = buyerRef.collection('positions').doc(startupId);
            const startupRef = db.collection('startups').doc(startupId);
            const last24Hours = admin.firestore.Timestamp.fromMillis(Date.now() - (24 * 60 * 60 * 1000));
            const recentMarketTransactionsQuery = db.collection('transactions').where('startupId', '==', startupId);

            const [buyerSnapshot, sellerSnapshot, buyerPositionSnapshot, startupSnapshot, recentMarketTransactionsSnapshot] = await Promise.all([
                transaction.get(buyerRef),
                transaction.get(sellerRef),
                transaction.get(buyerPositionRef),
                transaction.get(startupRef),
                transaction.get(recentMarketTransactionsQuery),
            ]);

            if (!buyerSnapshot.exists) {
                throw new functions.https.HttpsError('not-found', 'Comprador nao encontrado.');
            }

            if (!sellerSnapshot.exists) {
                throw new functions.https.HttpsError('not-found', 'Vendedor nao encontrado.');
            }

            const buyerData = buyerSnapshot.data() || {};
            const sellerData = sellerSnapshot.data() || {};
            const buyerPositionData = buyerPositionSnapshot.data() || {};
            const startupData = startupSnapshot.data() || {};
            const totalValue = quantity * unitPrice;
            const buyerBalance = typeof buyerData.saldoFicticio === 'number' ? buyerData.saldoFicticio : 0;
            const sellerBalance = typeof sellerData.saldoFicticio === 'number' ? sellerData.saldoFicticio : 0;
            const currentStartupPrice = typeof startupData.tokenPrice === 'number' ? startupData.tokenPrice : unitPrice;

            if (buyerBalance < totalValue) {
                throw new functions.https.HttpsError('failed-precondition', 'saldo_insuficiente');
            }

            const currentBuyerQuantity = typeof buyerPositionData.quantity === 'number' ? buyerPositionData.quantity : 0;
            const currentBuyerTotalInvested = typeof buyerPositionData.totalInvested === 'number' ? buyerPositionData.totalInvested : 0;
            const newBuyerQuantity = currentBuyerQuantity + quantity;
            const newBuyerTotalInvested = currentBuyerTotalInvested + totalValue;
            const now = admin.firestore.FieldValue.serverTimestamp();
            let marketTokens24h = quantity;
            let marketValue24h = totalValue;

            recentMarketTransactionsSnapshot.docs.forEach((doc) => {
                const transactionData = doc.data() || {};
                const type = String(transactionData.type || transactionData.tipo || '').toLowerCase();
                const createdAt = transactionData.createdAt;

                if (type !== 'compra_balcao') {
                    return;
                }

                if (!createdAt || typeof createdAt.toMillis !== 'function' || createdAt.toMillis() < last24Hours.toMillis()) {
                    return;
                }

                const transactionQuantity = typeof transactionData.quantity === 'number' ? transactionData.quantity : 0;
                const transactionTotalValue = typeof transactionData.totalValue === 'number'
                    ? transactionData.totalValue
                    : (typeof transactionData.valorTotal === 'number'
                        ? transactionData.valorTotal
                        : (typeof transactionData.amount === 'number' ? Math.abs(transactionData.amount) : 0));

                if (transactionQuantity <= 0 || transactionTotalValue <= 0) {
                    return;
                }

                marketTokens24h += transactionQuantity;
                marketValue24h += transactionTotalValue;
            });

            const marketAveragePrice24h = marketTokens24h > 0 ? marketValue24h / marketTokens24h : unitPrice;
            const newStartupPrice = calculateMarketAdjustedPrice(currentStartupPrice, marketAveragePrice24h);
            const variationPercent = currentStartupPrice > 0
                ? ((newStartupPrice - currentStartupPrice) / currentStartupPrice) * 100
                : 0;

            transaction.update(buyerRef, {
                saldoFicticio: buyerBalance - totalValue,
            });

            transaction.update(sellerRef, {
                saldoFicticio: sellerBalance + totalValue,
            });

            transaction.set(buyerPositionRef, {
                startupId,
                startupName: offerData.startupName || "",
                sector: offerData.sector || "",
                quantity: newBuyerQuantity,
                tokenPrice: unitPrice,
                totalInvested: newBuyerTotalInvested,
                averagePrice: newBuyerTotalInvested / newBuyerQuantity,
                updatedAt: now,
                ...(buyerPositionSnapshot.exists ? {} : { createdAt: now }),
            }, { merge: true });

            const newRemainingQuantity = remainingQuantity - quantity;

            transaction.update(offerRef, {
                remainingQuantity: newRemainingQuantity,
                status: newRemainingQuantity > 0 ? 'open' : 'closed',
                buyerId,
                soldAt: newRemainingQuantity > 0 ? offerData.soldAt || null : now,
                lastBuyerId: buyerId,
                updatedAt: now,
            });

            transaction.update(startupRef, {
                tokenPrice: newStartupPrice,
                variationPercent,
                lastPriceUpdateAt: now,
            });

            transaction.set(startupRef.collection('priceHistory').doc(), {
                price: newStartupPrice,
                previousPrice: currentStartupPrice,
                variationPercent,
                source: 'balcao',
                marketAveragePrice24h,
                quantity,
                totalValue,
                offerId: normalizedOfferId,
                createdAt: now,
            });

            transaction.set(buyerTransactionRef, {
                userId: buyerId,
                type: 'compra_balcao',
                title: 'Compra no balcao',
                description: 'Compra de tokens de outro investidor',
                startupId,
                startupName: offerData.startupName || "",
                sector: offerData.sector || "",
                quantity,
                tokenPrice: unitPrice,
                totalValue,
                amount: -totalValue,
                offerId: normalizedOfferId,
                createdAt: now,
            });

            transaction.set(sellerTransactionRef, {
                userId: sellerId,
                type: 'venda',
                title: 'Venda de tokens',
                description: 'Venda de tokens no balcao',
                startupId,
                startupName: offerData.startupName || "",
                sector: offerData.sector || "",
                quantity,
                tokenPrice: unitPrice,
                totalValue,
                amount: totalValue,
                offerId: normalizedOfferId,
                createdAt: now,
            });
        });

        return { success: true };
    } catch (error) {
        console.error('Erro ao comprar oferta do balcao:', error);
        if (error instanceof functions.https.HttpsError) {
            throw error;
        }
        throw new functions.https.HttpsError('internal', 'Erro interno ao comprar oferta do balcao.');
    }
});
