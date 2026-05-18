import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { db } from '../../shared/firebase';

export const addSimulatedBalance = functions.https.onCall(async (data, context) => {
    // Validar se o usuário está autenticado
    if (!context.auth || !context.auth.uid) {
        throw new functions.https.HttpsError(
            'unauthenticated',
            'O usuário deve estar autenticado para realizar esta ação.'
        );
    }

    const uid = context.auth.uid;
    const amount = data.amount;

    // Validar se amount existe, é número e é maior que zero
    if (typeof amount !== 'number' || isNaN(amount) || amount <= 0) {
        throw new functions.https.HttpsError(
            'invalid-argument',
            'O valor fornecido (amount) deve ser um número maior que zero.'
        );
    }

    const userRef = db.collection('users').doc(uid);
    const transactionRef = db.collection('transactions').doc();

    try {
        // Rodar transação atômica
        await db.runTransaction(async (transaction) => {
            const userSnapshot = await transaction.get(userRef);

            if (!userSnapshot.exists) {
                throw new functions.https.HttpsError(
                    'not-found',
                    'Documento do usuário não encontrado.'
                );
            }

            const userData = userSnapshot.data();
            const currentBalance = (userData && typeof userData.saldoFicticio === 'number') 
                ? userData.saldoFicticio 
                : 0;

            const newBalance = currentBalance + amount;

            transaction.update(userRef, {
                saldoFicticio: newBalance
            });

            transaction.set(transactionRef, {
                userId: uid,
                tipo: 'aporte_simulado',
                valorTotal: amount,
                descricao: 'Crédito adicionado',
                createdAt: admin.firestore.FieldValue.serverTimestamp()
            });
        });

        return { success: true };
    } catch (error) {
        console.error('Erro ao adicionar saldo simulado:', error);
        if (error instanceof functions.https.HttpsError) {
            throw error;
        }
        throw new functions.https.HttpsError('internal', 'Erro interno ao processar a transação.');
    }
});
