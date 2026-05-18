import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { db } from '../../shared/firebase';

/**
 * Cria ou atualiza o perfil do usuário no Firestore.
 * Essa é uma callable function que garante que campos sensíveis como 'role'
 * sejam controlados exclusivamente pelo backend.
 *
 * Suporta dois modos de autenticação:
 * 1. context.auth (autenticação automática do Firebase Callable)
 * 2. data.idToken (token explícito enviado pelo client como fallback)
 *
 * O fallback existe porque context.auth pode chegar vazio quando a
 * callable é invocada logo após createUserWithEmailAndPassword,
 * antes do SDK propagar o estado de autenticação.
 */
export const createUserProfile = functions.https.onCall(async (data, context) => {
  const hasContextAuth = !!(context && context.auth);
  const hasIdToken = !!(data && data.idToken);

  // Resolução de uid e email
  let uid: string;
  let email: string;

  if (hasContextAuth) {
    // Caminho principal: o SDK do Firebase populou context.auth
    uid = context.auth!.uid;
    email = context.auth!.token.email || '';
  } else if (hasIdToken) {
    // Fallback: o client enviou um idToken explícito no payload
    try {
      const decodedToken = await admin.auth().verifyIdToken(data.idToken);
      uid = decodedToken.uid;
      email = decodedToken.email || '';
    } catch (tokenError: any) {
      console.error('Falha ao verificar idToken:', tokenError?.code, tokenError?.message);
      throw new functions.https.HttpsError(
        'unauthenticated',
        'Token de autenticação inválido ou expirado.'
      );
    }
  } else {
    // Sem nenhum tipo de autenticação
    console.error('createUserProfile chamado sem autenticação');
    throw new functions.https.HttpsError(
      'unauthenticated',
      'O usuário deve estar autenticado para criar um perfil.'
    );
  }

  console.log(`createUserProfile — uid=${uid}`);

  // Validação dos dados de entrada
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

  // Criação / Atualização do documento no Firestore
  try {
    const userRef = db.collection('users').doc(uid);
    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      // Cria um novo perfil
      await userRef.set({
        fullName: fullName.trim(),
        email: email,
        cpf: cpf.trim(),
        phone: phone.trim(),
        role: 'investidor',
        mfaEnabled: false,
        saldoFicticio: 0,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      console.log(`Perfil CRIADO no Firestore para uid=${uid}`);
    } else {
      // Atualiza perfil existente (preserva campos sensíveis)
      await userRef.update({
        fullName: fullName.trim(),
        email: email,
        cpf: cpf.trim(),
        phone: phone.trim(),
      });
      console.log(`Perfil ATUALIZADO no Firestore para uid=${uid}`);
    }

    console.log('createUserProfile concluído com sucesso');
    return { success: true, message: 'Perfil do usuário processado com sucesso.' };
  } catch (error: any) {
    console.error('Erro ao criar/atualizar perfil do usuário:', error?.message || error);
    throw new functions.https.HttpsError(
      'internal',
      'Erro ao processar o perfil do usuário no servidor.'
    );
  }
});
