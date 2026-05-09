import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { db } from '../../shared/firebase';

export const buyTokens = functions.https.onCall(async (data, context) => {
    // 2. Validar se o usuário está autenticado
    if (!context.auth || !context.auth.uid) {
        throw new functions.https.HttpsError(
            'unauthenticated',
            'Usuário não autenticado.'
        );
    }

    const uid = context.auth.uid;
    const { startupId, quantity } = data;

    // 4. Validar os campos obrigatórios
    if (!startupId || typeof startupId !== 'string' || startupId.trim() === '') {
        throw new functions.https.HttpsError(
            'invalid-argument',
            'O campo startupId é obrigatório e deve ser uma string válida.'
        );
    }

    if (typeof quantity !== 'number' || quantity <= 0 || !Number.isInteger(quantity)) {
        throw new functions.https.HttpsError(
            'invalid-argument',
            'A quantidade deve ser um número inteiro maior que zero.'
        );
    }

    const userRef = db.collection('users').doc(uid);
    const startupRef = db.collection('startups').doc(startupId.trim());
    const transactionRef = db.collection('transactions').doc();

    try {
        await db.runTransaction(async (transaction) => {
            // 1. Ler users/{uid}
            const userSnapshot = await transaction.get(userRef);
            // 2. Se o usuário não existir, lançar erro
            if (!userSnapshot.exists) {
                throw new functions.https.HttpsError('not-found', 'Usuário não encontrado.');
            }

            // 3. Ler startups/{startupId}
            const startupSnapshot = await transaction.get(startupRef);
            // 4. Se a startup não existir, lançar erro
            if (!startupSnapshot.exists) {
                throw new functions.https.HttpsError('not-found', 'Startup não encontrada.');
            }

            const userData = userSnapshot.data() || {};
            const startupData = startupSnapshot.data() || {};

            // 5. Ler saldoFicticio do usuário, usando 0 como padrão se não existir
            const saldoFicticio = typeof userData.saldoFicticio === 'number' ? userData.saldoFicticio : 0;
            
            // 6. Ler tokenPrice da startup
            const tokenPrice = typeof startupData.tokenPrice === 'number' ? startupData.tokenPrice : 0;
            if (tokenPrice <= 0) {
                throw new functions.https.HttpsError('failed-precondition', 'Preço do token inválido na startup.');
            }

            // 7. Ler availableTokens da startup
            const availableTokens = typeof startupData.availableTokens === 'number' ? startupData.availableTokens : 0;

            // 8. Ler capitalRaised da startup, usando 0 como padrão se não existir
            const capitalRaised = typeof startupData.capitalRaised === 'number' ? startupData.capitalRaised : 0;

            // 9. Calcular totalValue = quantity * tokenPrice
            const totalValue = quantity * tokenPrice;

            // 10. Se saldoFicticio < totalValue, lançar erro de saldo insuficiente
            if (saldoFicticio < totalValue) {
                throw new functions.https.HttpsError('failed-precondition', 'saldo_insuficiente');
            }

            // 11. Se availableTokens < quantity, lançar erro de tokens insuficientes
            if (availableTokens < quantity) {
                throw new functions.https.HttpsError('failed-precondition', 'Tokens insuficientes disponíveis na startup.');
            }

            // 12. Atualizar users/{uid}
            transaction.update(userRef, {
                saldoFicticio: saldoFicticio - totalValue
            });

            // 13. Atualizar startups/{startupId}
            transaction.update(startupRef, {
                availableTokens: availableTokens - quantity,
                capitalRaised: capitalRaised + totalValue
            });

            // 14. Criar novo documento em transactions
            transaction.set(transactionRef, {
                userId: uid,
                type: "compra",
                title: "Compra de tokens",
                description: "Compra de tokens da startup",
                startupId: startupId.trim(),
                startupName: startupData.name || "",
                sector: startupData.sector || (startupData.categorias && startupData.categorias.length > 0 ? startupData.categorias[0] : ""),
                quantity: quantity,
                tokenPrice: tokenPrice,
                totalValue: totalValue,
                amount: -totalValue,
                createdAt: admin.firestore.FieldValue.serverTimestamp()
            });
        });

        return { success: true };
    } catch (error) {
        console.error('Erro na transação de compra:', error);
        if (error instanceof functions.https.HttpsError) {
            throw error;
        }
        throw new functions.https.HttpsError('internal', 'Erro interno ao processar a transação.');
    }
});
