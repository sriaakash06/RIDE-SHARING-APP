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

  // Sign in with email and password — returns null on success, error string on fail
  Future<String?> signIn(String email, String password) async {
    if (!isFirebaseInitialized) {
      return null;
    }
    try {
      await _auth!.signInWithEmailAndPassword(email: email, password: password);
      return null; // success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'invalid-email':
          return 'Invalid email address.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        default:
          return e.message ?? 'Login failed. Please check your credentials.';
      }
    } catch (e) {
      return e.toString();
    }
  }

  // Register with email and password — returns null on success, error string on fail
  Future<String?> signUp(String email, String password, String name) async {
    if (!isFirebaseInitialized) {
      return null; // Mock success
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
      return null; // null = success
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'This email is already registered.';
        case 'weak-password':
          return 'Password must be at least 6 characters.';
        case 'invalid-email':
          return 'Invalid email address.';
        case 'operation-not-allowed':
          return 'Email/password sign-in is not enabled. Please enable it in Firebase Console.';
        default:
          return e.message ?? 'Registration failed. Try again.';
      }
    } on FirebaseException catch (e) {
       return e.message ?? 'Firestore database error: rules might not be set up.';
    } catch (e) {
      return e.toString();
    }
  }

  // Sign out
  Future<void> signOut() async {
    if (isFirebaseInitialized) {
      await _auth!.signOut();
    }
  }

  // Get user data -> Throws exception if Firestore fails
  Future<UserModel> getUserData(String uid) async {
    if (!isFirebaseInitialized) {
      return UserModel(uid: 'mock_uid', email: 'test@example.com', name: 'Test User');
    }
    
    DocumentSnapshot doc = await _firestore!.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    } else {
      // If user doc doesn't exist, we just create a temp one 
      return UserModel(uid: uid, email: _auth!.currentUser?.email ?? '', name: 'User');
    }
  }
}
