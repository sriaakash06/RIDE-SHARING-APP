import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../main.dart'; // Import to access isFirebaseInitialized

class AuthService {
  FirebaseAuth? get _auth => isFirebaseInitialized ? FirebaseAuth.instance : null;
  FirebaseFirestore? get _firestore => isFirebaseInitialized ? FirebaseFirestore.instance : null;

  // Stream of auth changes
  Stream<User?> get user {
    if (isFirebaseInitialized) {
      return _auth!.authStateChanges();
    } else {
      return Stream.value(null); // Mock no user
    }
  }

  // Sign in with email and password
  Future<dynamic> signIn(String email, String password) async {
    if (!isFirebaseInitialized) {
      // Mock successful login for prototype
      return "mock_user_credential";
    }
    try {
      return await _auth!.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Register with email and password
  Future<dynamic> signUp(String email, String password, String name) async {
    if (!isFirebaseInitialized) {
      // Mock successful registration
      return "mock_user_credential";
    }
    try {
      UserCredential result = await _auth!.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      if (user != null) {
        await _firestore!.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'name': name,
          'profilePic': '',
        });
      }
      return result;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    if (isFirebaseInitialized) {
      await _auth!.signOut();
    }
  }

  // Get user data
  Future<UserModel?> getUserData(String uid) async {
    if (!isFirebaseInitialized) {
      return UserModel(uid: 'mock_uid', email: 'test@example.com', name: 'Test User');
    }
    try {
      DocumentSnapshot doc = await _firestore!.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
