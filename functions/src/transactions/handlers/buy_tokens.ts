import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { db } from '../../shared/firebase';

export const buyTokens = functions.https.onCall(async (data, context) => {
    if (!context.auth || !context.auth.uid) {
        throw new functions.https.HttpsError(
            'unauthenticated',
            'Usuario nao autenticado.'
        );
    }

    const uid = context.auth.uid;
    const { startupId, quantity } = data;

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

    const normalizedStartupId = startupId.trim();
    const userRef = db.collection('users').doc(uid);
    const startupRef = db.collection('startups').doc(normalizedStartupId);
    const positionRef = userRef.collection('positions').doc(normalizedStartupId);
    const transactionRef = db.collection('transactions').doc();

    try {
        await db.runTransaction(async (transaction) => {
            const userSnapshot = await transaction.get(userRef);
            if (!userSnapshot.exists) {
                throw new functions.https.HttpsError('not-found', 'Usuario nao encontrado.');
            }

            const startupSnapshot = await transaction.get(startupRef);
            if (!startupSnapshot.exists) {
                throw new functions.https.HttpsError('not-found', 'Startup nao encontrada.');
            }

            const positionSnapshot = await transaction.get(positionRef);
            const userData = userSnapshot.data() || {};
            const startupData = startupSnapshot.data() || {};
            const positionData = positionSnapshot.data() || {};

            const saldoFicticio = typeof userData.saldoFicticio === 'number' ? userData.saldoFicticio : 0;
            const tokenPrice = typeof startupData.tokenPrice === 'number' ? startupData.tokenPrice : 0;

            if (tokenPrice <= 0) {
                throw new functions.https.HttpsError('failed-precondition', 'Preco do token invalido na startup.');
            }

            const availableTokens = typeof startupData.availableTokens === 'number' ? startupData.availableTokens : 0;
            const capitalRaised = typeof startupData.capitalRaised === 'number' ? startupData.capitalRaised : 0;
            const totalValue = quantity * tokenPrice;

            if (saldoFicticio < totalValue) {
                throw new functions.https.HttpsError('failed-precondition', 'saldo_insuficiente');
            }

            if (availableTokens < quantity) {
                throw new functions.https.HttpsError('failed-precondition', 'Tokens insuficientes disponiveis na startup.');
            }

            const currentQuantity = typeof positionData.quantity === 'number' ? positionData.quantity : 0;
            const currentTotalInvested = typeof positionData.totalInvested === 'number' ? positionData.totalInvested : 0;
            const newQuantity = currentQuantity + quantity;
            const newTotalInvested = currentTotalInvested + totalValue;
            const startupSector = startupData.sector || (startupData.categorias && startupData.categorias.length > 0 ? startupData.categorias[0] : "");
            const now = admin.firestore.FieldValue.serverTimestamp();

            transaction.update(userRef, {
                saldoFicticio: saldoFicticio - totalValue
            });

            transaction.update(startupRef, {
                availableTokens: availableTokens - quantity,
                capitalRaised: capitalRaised + totalValue
            });

            transaction.set(positionRef, {
                startupId: normalizedStartupId,
                startupName: startupData.name || "",
                sector: startupSector,
                quantity: newQuantity,
                tokenPrice: tokenPrice,
                totalInvested: newTotalInvested,
                averagePrice: newTotalInvested / newQuantity,
                updatedAt: now,
                ...(positionSnapshot.exists ? {} : { createdAt: now }),
            }, { merge: true });

            transaction.set(transactionRef, {
                userId: uid,
                type: "compra",
                title: "Compra de tokens",
                description: "Compra de tokens da startup",
                startupId: normalizedStartupId,
                startupName: startupData.name || "",
                sector: startupSector,
                quantity: quantity,
                tokenPrice: tokenPrice,
                totalValue: totalValue,
                amount: -totalValue,
                createdAt: now
            });
        });

        return { success: true };
    } catch (error) {
        console.error('Erro na transacao de compra:', error);
        if (error instanceof functions.https.HttpsError) {
            throw error;
        }
        throw new functions.https.HttpsError('internal', 'Erro interno ao processar a transacao.');
    }
});
