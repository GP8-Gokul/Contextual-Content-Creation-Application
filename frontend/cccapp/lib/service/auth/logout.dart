import 'package:firebase_auth/firebase_auth.dart';

Future<void> logoutUser() async {
  await FirebaseAuth.instance.signOut();
}
