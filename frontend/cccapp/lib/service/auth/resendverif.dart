import 'package:firebase_auth/firebase_auth.dart';

Future<String?> resendVerificationEmail() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null && !user.emailVerified) {
    await user.sendEmailVerification();
    return "Verification email sent again.";
  }
  return "User not found or already verified.";
}
