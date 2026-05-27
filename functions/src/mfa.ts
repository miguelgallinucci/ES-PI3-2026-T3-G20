import { onCall, HttpsError } from 'firebase-functions/v2/https';
import * as logger from 'firebase-functions/logger';
import * as admin from 'firebase-admin';

// eslint-disable-next-line @typescript-eslint/no-var-requires
const nodemailer = require('nodemailer');

if (!admin.apps.length) {
  admin.initializeApp();
}

const db = admin.firestore();

function generateSixDigitCode(): string {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

function normalizeEmail(email: unknown): string {
  if (typeof email !== 'string') {
    throw new HttpsError('invalid-argument', 'E-mail inválido.');
  }

  const cleanEmail = email.trim().toLowerCase();

  if (!cleanEmail || !cleanEmail.includes('@')) {
    throw new HttpsError('invalid-argument', 'E-mail inválido.');
  }

  return cleanEmail;
}

function normalizeCode(code: unknown): string {
  if (typeof code !== 'string') {
    throw new HttpsError('invalid-argument', 'Código inválido.');
  }

  const cleanCode = code.trim();

  if (!/^\d{6}$/.test(cleanCode)) {
    throw new HttpsError('invalid-argument', 'Código inválido.');
  }

  return cleanCode;
}

function getEmailTransporter() {
  const emailUser = process.env.EMAIL_USER;
  const emailPass = process.env.EMAIL_PASS;

  if (!emailUser || !emailPass) {
    throw new HttpsError(
      'failed-precondition',
      'Configuração de e-mail não encontrada no backend.',
    );
  }

  return nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: emailUser,
      pass: emailPass,
    },
  });
}

export const sendEmailMfaCode = onCall(async (request) => {
  const email = normalizeEmail(request.data?.email);
  const code = generateSixDigitCode();

  const expiresAt = admin.firestore.Timestamp.fromDate(
    new Date(Date.now() + 5 * 60 * 1000),
  );

  await db.collection('emailMfaCodes').doc(email).set({
    email,
    code,
    used: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    expiresAt,
  });

  const transporter = getEmailTransporter();

  await transporter.sendMail({
    from: `MesclaInvest <${process.env.EMAIL_USER}>`,
    to: email,
    subject: 'Código de verificação - MesclaInvest',
    html: `
      <div style="font-family: Arial, sans-serif; padding: 24px; color: #0f172a;">
        <h2 style="margin-bottom: 8px;">Verificação em duas etapas</h2>
        <p>Use o código abaixo para concluir seu login no MesclaInvest:</p>
        <div style="font-size: 32px; font-weight: 700; letter-spacing: 6px; margin: 24px 0;">
          ${code}
        </div>
        <p>Este código expira em 5 minutos.</p>
        <p style="color: #64748b; font-size: 13px;">
          Se você não tentou fazer login, ignore este e-mail.
        </p>
      </div>
    `,
  });

  logger.info('MFA code sent by email', { email });

  return {
    sent: true,
  };
});

export const verifyEmailMfaCode = onCall(async (request) => {
  const email = normalizeEmail(request.data?.email);
  const code = normalizeCode(request.data?.code);

  const codeRef = db.collection('emailMfaCodes').doc(email);
  const snapshot = await codeRef.get();

  if (!snapshot.exists) {
    return { valid: false };
  }

  const data = snapshot.data();

  if (!data) {
    return { valid: false };
  }

  const savedCode = data.code;
  const used = data.used === true;
  const expiresAt = data.expiresAt as admin.firestore.Timestamp | undefined;

  if (used || !expiresAt) {
    return { valid: false };
  }

  const isExpired = expiresAt.toDate().getTime() < Date.now();

  if (isExpired) {
    return { valid: false };
  }

  if (savedCode !== code) {
    return { valid: false };
  }

  await codeRef.update({
    used: true,
    verifiedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  logger.info('MFA code verified by email', { email });

  return {
    valid: true,
  };
});
