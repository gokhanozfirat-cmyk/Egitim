import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../core/config/env.dart';
import '../models/question.dart';

class FirebaseService {
  FirebaseService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  Future<void>? _googleInitFuture;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<void> _ensureGoogleInitialized() {
    return _googleInitFuture ??= _googleSignIn.initialize(
      clientId: Env.googleClientId.isEmpty ? null : Env.googleClientId,
      serverClientId: Env.googleServerClientId.isEmpty
          ? null
          : Env.googleServerClientId,
    );
  }

  Future<UserCredential> createAccountWithEmail({
    required String email,
    required String password,
  }) async {
    final UserCredential credential = await _auth
        .createUserWithEmailAndPassword(email: email, password: password);
    await _syncUserProfile(credential.user);
    return credential;
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final UserCredential credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _syncUserProfile(credential.user);
    return credential;
  }

  Future<UserCredential> signInWithGoogle() async {
    await _ensureGoogleInitialized();
    final GoogleSignInAccount account = await _googleSignIn.authenticate();
    final GoogleSignInAuthentication authData = account.authentication;

    if (authData.idToken == null || authData.idToken!.isEmpty) {
      throw StateError('Google Sign-In did not provide an ID token.');
    }

    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: authData.idToken,
    );
    final UserCredential userCredential = await _auth.signInWithCredential(
      credential,
    );
    await _syncUserProfile(userCredential.user);
    return userCredential;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    if (_googleInitFuture != null) {
      await _googleSignIn.signOut();
    }
  }

  Future<void> saveQuestion(Question question) async {
    await _firestore
        .collection('questions')
        .doc(question.id)
        .set(question.toMap());
  }

  Stream<List<Question>> watchQuestionsForUser(String userId) {
    return _firestore
        .collection('questions')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Question.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  Stream<Question?> watchQuestionById(String questionId) {
    return _firestore.collection('questions').doc(questionId).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return Question.fromMap(snapshot.data()!, snapshot.id);
    });
  }

  Future<void> setQuestionFeedback({
    required String questionId,
    required bool helpful,
  }) async {
    await _firestore.collection('questions').doc(questionId).update(
      <String, dynamic>{'helpful': helpful},
    );
  }

  Future<void> _syncUserProfile(User? user) async {
    if (user == null) {
      return;
    }

    await _firestore.collection('users').doc(user.uid).set(<String, dynamic>{
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoUrl': user.photoURL,
      'lastLoginAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
