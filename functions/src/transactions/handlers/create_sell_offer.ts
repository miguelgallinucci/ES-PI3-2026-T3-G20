import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { db } from '../../shared/firebase';

/// desenvolvido por Miguel Gallinucci - cria oferta de venda reservando tokens da carteira.
export const createSellOffer = functions.https.onCall(async (data, context) => {
    if (!context.auth || !context.auth.uid) {
        throw new functions.https.HttpsError(
            'unauthenticated',
            'Usuario nao autenticado.'
        );
    }

    const uid = context.auth.uid;
    const { startupId, quantity, unitPrice } = data;

    if (!startupId || typeof startupId !== 'string' || startupId.trim() === '') {
        throw new functions.https.HttpsError(
            'invalid-argument',
            'O campo startupId e obrigatorio e deve ser uma string valida.'
        );
    }

    if (typeof quantity !== 'number' || quantity <= 0 || !Number.isInteger(quantity)) {
        throw new functions.https.HttpsError(
            'invalid-argument',
            'A quantidade deve ser um numero inteiro maior que zero.'
        );
    }

    if (typeof unitPrice !== 'number' || unitPrice <= 0) {
        throw new functions.https.HttpsError(
            'invalid-argument',
            'O preco por token deve ser maior que zero.'
        );
    }

    const normalizedStartupId = startupId.trim();
    const startupRef = db.collection('startups').doc(normalizedStartupId);
    const positionRef = db.collection('users').doc(uid).collection('positions').doc(normalizedStartupId);
    const userTransactionsQuery = db.collection('transactions').where('userId', '==', uid);
    const offerRef = db.collection('marketOffers').doc();
    const transactionRef = db.collection('transactions').doc();

    try {
        await db.runTransaction(async (transaction) => {
            const [startupSnapshot, positionSnapshot, userTransactionsSnapshot] = await Promise.all([
                transaction.get(startupRef),
                transaction.get(positionRef),
                transaction.get(userTransactionsQuery),
            ]);

            if (!startupSnapshot.exists) {
                throw new functions.https.HttpsError('not-found', 'Startup nao encontrada.');
            }

            const startupData = startupSnapshot.data() || {};
            const positionData = positionSnapshot.data() || {};
            const positionQuantity = typeof positionData.quantity === 'number' ? positionData.quantity : 0;
            const positionTotalInvested = typeof positionData.totalInvested === 'number' ? positionData.totalInvested : 0;
            let ledgerQuantity = 0;
            let ledgerTotalInvested = 0;
            let ledgerTokenPrice = 0;

            /// desenvolvido por Miguel Gallinucci - reconstroi a posicao por transacoes antes de vender.
            const orderedTransactionDocs = [...userTransactionsSnapshot.docs].sort((a, b) => {
                const aCreatedAt = a.data().createdAt;
                const bCreatedAt = b.data().createdAt;
                const aTime = aCreatedAt && typeof aCreatedAt.toMillis === 'function' ? aCreatedAt.toMillis() : 0;
                const bTime = bCreatedAt && typeof bCreatedAt.toMillis === 'function' ? bCreatedAt.toMillis() : 0;

                return aTime - bTime;
            });

            orderedTransactionDocs.forEach((doc) => {
                const transactionData = doc.data() || {};
                const transactionStartupId = typeof transactionData.startupId === 'string' ? transactionData.startupId : "";

                if (transactionStartupId !== normalizedStartupId) {
                    return;
                }

                const type = String(transactionData.type || transactionData.tipo || "").toLowerCase();
                const transactionQuantity = typeof transactionData.quantity === 'number' ? transactionData.quantity : 0;

                if (transactionQuantity <= 0) {
                    return;
                }

                const transactionTokenPrice = typeof transactionData.tokenPrice === 'number' ? transactionData.tokenPrice : 0;
                const transactionTotalValue = typeof transactionData.totalValue === 'number'
                    ? transactionData.totalValue
                    : (typeof transactionData.valorTotal === 'number'
                        ? transactionData.valorTotal
                        : (typeof transactionData.amount === 'number' ? Math.abs(transactionData.amount) : 0));
                const reservedCost = typeof transactionData.reservedCost === 'number'
                    ? transactionData.reservedCost
                    : transactionTotalValue;

                if (type === 'compra' || type === 'compra_balcao') {
                    ledgerQuantity += transactionQuantity;
                    ledgerTotalInvested += Math.abs(transactionTotalValue);
                    if (transactionTokenPrice > 0) {
                        ledgerTokenPrice = transactionTokenPrice;
                    }
                }

                if (type === 'oferta_venda') {
                    const averagePrice = ledgerQuantity > 0 ? ledgerTotalInvested / ledgerQuantity : 0;
                    ledgerQuantity -= transactionQuantity;
                    ledgerTotalInvested = Math.max(0, ledgerTotalInvested - (reservedCost || (averagePrice * transactionQuantity)));
                }

                if (type === 'cancelamento_oferta') {
                    ledgerQuantity += transactionQuantity;
                    ledgerTotalInvested += Math.abs(reservedCost);
                }
            });

            const currentQuantity = ledgerQuantity > 0 ? ledgerQuantity : positionQuantity;
            const totalInvested = currentQuantity === positionQuantity && ledgerQuantity <= 0 && positionTotalInvested > 0
                ? positionTotalInvested
                : ledgerTotalInvested;

            if (currentQuantity < quantity) {
                throw new functions.https.HttpsError(
                    'failed-precondition',
                    'Tokens insuficientes na carteira para criar a oferta.'
                );
            }

            const averagePrice = currentQuantity > 0 ? totalInvested / currentQuantity : 0;
            const reservedCost = averagePrice * quantity;
            const newQuantity = currentQuantity - quantity;
            const newTotalInvested = Math.max(0, totalInvested - reservedCost);
            const startupSector = startupData.sector || (startupData.categorias && startupData.categorias.length > 0 ? startupData.categorias[0] : "");
            const now = admin.firestore.FieldValue.serverTimestamp();
            const totalValue = quantity * unitPrice;

            transaction.set(positionRef, {
                startupId: normalizedStartupId,
                startupName: startupData.name || positionData.startupName || "",
                sector: startupSector || positionData.sector || "",
                quantity: newQuantity,
                tokenPrice: ledgerTokenPrice > 0 ? ledgerTokenPrice : (positionData.tokenPrice || startupData.tokenPrice || unitPrice),
                totalInvested: newTotalInvested,
                averagePrice: newQuantity > 0 ? newTotalInvested / newQuantity : 0,
                updatedAt: now,
                ...(positionSnapshot.exists ? {} : { createdAt: now }),
            }, { merge: true });

            transaction.set(offerRef, {
                sellerId: uid,
                startupId: normalizedStartupId,
                startupName: startupData.name || positionData.startupName || "",
                sector: startupSector || positionData.sector || "",
                stage: startupData.stage || "",
                quantity,
                remainingQuantity: quantity,
                unitPrice,
                totalValue,
                reservedCost,
                reservedAveragePrice: averagePrice,
                status: 'open',
                source: 'balcao',
                createdAt: now,
                updatedAt: now,
            });

            transaction.set(transactionRef, {
                userId: uid,
                type: 'oferta_venda',
                title: 'Oferta de venda criada',
                description: 'Tokens reservados para venda no balcao',
                startupId: normalizedStartupId,
                startupName: startupData.name || positionData.startupName || "",
                sector: startupSector || positionData.sector || "",
                quantity,
                tokenPrice: unitPrice,
                totalValue,
                reservedCost,
                amount: 0,
                offerId: offerRef.id,
                createdAt: now,
            });
        });

        return { success: true, offerId: offerRef.id };
    } catch (error) {
        console.error('Erro ao criar oferta de venda:', error);
        if (error instanceof functions.https.HttpsError) {
            throw error;
        }
        throw new functions.https.HttpsError('internal', 'Erro interno ao criar oferta de venda.');
    }
});
