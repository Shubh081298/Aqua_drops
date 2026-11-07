const { initializeApp, cert } = require('firebase-admin/app');
const { getAuth } = require('firebase-admin/auth');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const serviceAccount = require('./serviceAccountKey.json');

initializeApp({
  credential: cert(serviceAccount),
});

const auth = getAuth();
const db = getFirestore();

async function createAdmin() {
  const email = 'shubham@aquadrops.com';
  const password = 'Admin@1234';
  const name = 'Shubham';

  try {
    const userRecord = await auth.createUser({ email, password });
    const uid = userRecord.uid;

    await db.collection('users').doc(uid).set({
      name,
      email,
      role: 'super_admin',
      status: 'active',
      language: 'en',
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });

    console.log('Admin created. UID:', uid);
    process.exit(0);
  } catch (err) {
    console.error('Error:', err.message);
    process.exit(1);
  }
}

createAdmin();
