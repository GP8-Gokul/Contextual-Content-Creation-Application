import 'package:firebase_auth/firebase_auth.dart';

String? getUserId() {
  final user = FirebaseAuth.instance.currentUser;
  return user?.uid;
}
