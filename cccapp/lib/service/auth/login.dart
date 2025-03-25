import 'package:firebase_auth/firebase_auth.dart';

Future<String?> loginUser(String email, String password) async {
  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (!userCredential.user!.emailVerified) {
      await FirebaseAuth.instance.signOut(); // Sign out unverified users
      return "Please verify your email before logging in.";
    }

    return null; // Login successful
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      return "Email not registered";
    } else if (e.code == 'wrong-password') {
      return "Incorrect password";
    } else if (e.code == 'invalid-email') {
      return "Invalid email format";
    } else {
      return "An unexpected error occurred";
    }
  }
}
