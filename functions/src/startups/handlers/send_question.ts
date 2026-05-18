import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { db } from '../../shared/firebase';

export const sendQuestion = functions.https.onCall(async (data, context) => {
    // 2. Validar se o usuário está autenticado
    if (!context.auth || !context.auth.uid) {
        throw new functions.https.HttpsError(
            'unauthenticated',
            'O usuário deve estar autenticado para realizar esta ação.'
        );
    }

    const uid = context.auth.uid;
    const { startupId, startupName, question } = data;

    // 4. Validar os campos obrigatórios
    if (!startupId || typeof startupId !== 'string' || startupId.trim() === '') {
        throw new functions.https.HttpsError(
            'invalid-argument',
            'O campo startupId é obrigatório e não pode ser vazio.'
        );
    }

    if (!startupName || typeof startupName !== 'string' || startupName.trim() === '') {
        throw new functions.https.HttpsError(
            'invalid-argument',
            'O campo startupName é obrigatório e não pode ser vazio.'
        );
    }

    if (!question || typeof question !== 'string' || question.trim() === '') {
        throw new functions.https.HttpsError(
            'invalid-argument',
            'O campo question é obrigatório e não pode ser vazio.'
        );
    }

    // Usar email e displayName do token autenticado
    const userEmail = context.auth.token.email || "";
    const userName = context.auth.token.name || userEmail || "Usuário";

    // 6. Criar novo documento na collection questions
    try {
        await db.collection('questions').add({
            startupId: startupId.trim(),
            startupName: startupName.trim(),
            question: question.trim(),
            answer: "",
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
            answeredAt: null,
            userId: uid,
            userName: userName,
            userEmail: userEmail,
            isPublic: true,
            status: "aguardando_resposta"
        });

        return { success: true };
    } catch (error) {
        console.error('Erro ao enviar pergunta:', error);
        throw new functions.https.HttpsError(
            'internal',
            'Ocorreu um erro interno ao salvar a pergunta.'
        );
    }
});
