import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

/**
 * Creates or updates the user profile in Firestore.
 * This is a callable function that ensures sensitive fields like 'role'
 * are controlled by the backend.
 */
export const createUserProfile = functions.https.onCall(async (data, context) => {
  // 1. Validate authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'O usuário deve estar autenticado para criar um perfil.'
    );
  }

  const uid = context.auth.uid;
  const email = context.auth.token.email || "";

  // 2. Extract and validate input data
  const { fullName, cpf, phone } = data;

  if (!fullName || typeof fullName !== 'string' || fullName.trim() === '') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'O nome completo é obrigatório e deve ser uma string.'
    );
  }

  if (!cpf || typeof cpf !== 'string' || cpf.trim() === '') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'O CPF é obrigatório e deve ser uma string.'
    );
  }

  if (!phone || typeof phone !== 'string' || phone.trim() === '') {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'O telefone é obrigatório e deve ser uma string.'
    );
  }

  try {
    const userRef = admin.firestore().collection('users').doc(uid);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      // Create new profile
      await userRef.set({
        fullName: fullName.trim(),
        email: email,
        cpf: cpf.trim(),
        phone: phone.trim(),
        role: "investidor",
        mfaEnabled: false,
        saldoFicticio: 0,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    } else {
      // Update existing profile (preserving sensitive fields)
      await userRef.update({
        fullName: fullName.trim(),
        email: email,
        cpf: cpf.trim(),
        phone: phone.trim(),
      });
    }

    return { success: true, message: 'Perfil do usuário processado com sucesso.' };
  } catch (error) {
    console.error('Error creating user profile:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Erro ao processar o perfil do usuário no servidor.'
    );
  }
});
