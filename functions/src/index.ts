import * as admin from 'firebase-admin';

// Initialize Firebase Admin app
admin.initializeApp();

// Export function modules
export * from './auth';
export * from './startups';
export * from './wallet';
export * from './transactions';
// export * from './dashboard';
