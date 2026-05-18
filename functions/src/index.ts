import * as admin from 'firebase-admin';

// Inicializa o Firebase Admin
admin.initializeApp();

// Exporta módulos das funções
export * from './auth';
export * from './startups';
export * from './wallet';
export * from './transactions';
// export * from './dashboard';
