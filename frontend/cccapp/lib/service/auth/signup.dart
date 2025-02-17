import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

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
    print("Generated User ID: $userId");

    DatabaseReference ref = FirebaseDatabase.instance.ref("/users");
    await ref.set({
      userId: true,
    }).then((_) {
      print("User successfully added to database!");
    }).catchError((error) {
      print("Error writing to database: $error");
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
