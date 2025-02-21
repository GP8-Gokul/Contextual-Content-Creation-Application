import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:developer';

Future<String?> signUpUser(String email, String password) async {
  try {
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await userCredential.user!.sendEmailVerification();
    await FirebaseAuth.instance.signOut();

    String userId = userCredential.user!.uid;
    log("User ID: $userId");

    DatabaseReference ref = FirebaseDatabase.instance
        .refFromURL(
            "https://contextual-content-creation-default-rtdb.asia-southeast1.firebasedatabase.app/")
        .child("users/$userId");

    await ref.set({
      "createdAt": DateTime.now().toIso8601String(),
    }).then((_) {
      log("User added to database");
    }).catchError((error) {
      log("Failed to add user: $error");
    });

    return "Verification email sent. Please verify your email before logging in.";
  } on FirebaseAuthException catch (e) {
    if (e.code == 'email-already-in-use') {
      return "Email is already registered";
    } else if (e.code == 'invalid-email') {
      return "Invalid email format";
    } else if (e.code == 'weak-password') {
      return "Password is too weak";
    } else {
      return "An unexpected error occurred";
    }
  }
}
