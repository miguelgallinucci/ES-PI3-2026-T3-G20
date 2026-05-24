import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { db } from '../../shared/firebase';

export const cancelSellOffer = functions.https.onCall(async (data, context) => {
    if (!context.auth || !context.auth.uid) {
        throw new functions.https.HttpsError(
            'unauthenticated',
            'Usuario nao autenticado.'
        );
    }

    const uid = context.auth.uid;
    const { offerId } = data;

    if (!offerId || typeof offerId !== 'string' || offerId.trim() === '') {
        throw new functions.https.HttpsError(
            'invalid-argument',
            'O campo offerId e obrigatorio e deve ser uma string valida.'
        );
    }

    const normalizedOfferId = offerId.trim();
    const offerRef = db.collection('marketOffers').doc(normalizedOfferId);
    const transactionRef = db.collection('transactions').doc();

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

            if (sellerId !== uid) {
                throw new functions.https.HttpsError('permission-denied', 'Voce so pode cancelar suas proprias ofertas.');
            }

            if (status !== 'open' || remainingQuantity <= 0) {
                throw new functions.https.HttpsError('failed-precondition', 'Oferta indisponivel para cancelamento.');
            }

            if (!startupId) {
                throw new functions.https.HttpsError('failed-precondition', 'Oferta invalida.');
            }

            const positionRef = db.collection('users').doc(uid).collection('positions').doc(startupId);
            const positionSnapshot = await transaction.get(positionRef);
            const positionData = positionSnapshot.data() || {};
            const currentQuantity = typeof positionData.quantity === 'number' ? positionData.quantity : 0;
            const currentTotalInvested = typeof positionData.totalInvested === 'number' ? positionData.totalInvested : 0;
            const reservedAveragePrice = typeof offerData.reservedAveragePrice === 'number'
                ? offerData.reservedAveragePrice
                : (typeof positionData.averagePrice === 'number' ? positionData.averagePrice : 0);
            const reservedCost = remainingQuantity * reservedAveragePrice;
            const newQuantity = currentQuantity + remainingQuantity;
            const newTotalInvested = currentTotalInvested + reservedCost;
            const now = admin.firestore.FieldValue.serverTimestamp();

            transaction.set(positionRef, {
                startupId,
                startupName: offerData.startupName || positionData.startupName || "",
                sector: offerData.sector || positionData.sector || "",
                quantity: newQuantity,
                tokenPrice: positionData.tokenPrice || offerData.unitPrice || 0,
                totalInvested: newTotalInvested,
                averagePrice: newQuantity > 0 ? newTotalInvested / newQuantity : 0,
                updatedAt: now,
                ...(positionSnapshot.exists ? {} : { createdAt: now }),
            }, { merge: true });

            transaction.update(offerRef, {
                remainingQuantity: 0,
                status: 'canceled',
                canceledAt: now,
                updatedAt: now,
            });

            transaction.set(transactionRef, {
                userId: uid,
                type: 'cancelamento_oferta',
                title: 'Oferta cancelada',
                description: 'Tokens retornados para a carteira',
                startupId,
                startupName: offerData.startupName || "",
                sector: offerData.sector || "",
                quantity: remainingQuantity,
                tokenPrice: offerData.unitPrice || 0,
                totalValue: remainingQuantity * (offerData.unitPrice || 0),
                reservedCost,
                amount: 0,
                offerId: normalizedOfferId,
                createdAt: now,
            });
        });

        return { success: true };
    } catch (error) {
        console.error('Erro ao cancelar oferta de venda:', error);
        if (error instanceof functions.https.HttpsError) {
            throw error;
        }
        throw new functions.https.HttpsError('internal', 'Erro interno ao cancelar oferta de venda.');
    }
});
