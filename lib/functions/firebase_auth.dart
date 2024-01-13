import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';


signup({
    required String email,
    required String password,
    }) async {
  try {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    signin(email: email, password: password);
  } on FirebaseAuthException catch (e) {
    Fluttertoast.showToast(msg: e.message.toString());
  }
}

verifyEmail() async {
  await FirebaseAuth.instance.currentUser!.sendEmailVerification();
}

signin({required String email, required String password}) async {
  try {
    Fluttertoast.showToast(msg: "Signing in...");
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
  } on FirebaseAuthException catch (e) {
    Fluttertoast.showToast(msg: e.message.toString());
  }
}

changePassword({required String oldPass, required String newPass}) async {
  try {
    await FirebaseAuth.instance.currentUser!
        .reauthenticateWithCredential(EmailAuthProvider.credential(
            email: FirebaseAuth.instance.currentUser!.email!,
            password: oldPass))
        .then((value) {
      FirebaseAuth.instance.currentUser!.updatePassword(newPass).then((value) {
        Fluttertoast.showToast(
            msg: "Password Successfull Update. Login with new password");
        FirebaseAuth.instance.signOut();
      });
    });
  } catch (e) {
    Fluttertoast.showToast(msg: "$e");
  }
}

deleteAccount({required String password}) async {
  try {
    await FirebaseAuth.instance.currentUser!
        .reauthenticateWithCredential(EmailAuthProvider.credential(
            email: FirebaseAuth.instance.currentUser!.email!,
            password: password))
        .then((value) {
      FirebaseAuth.instance.currentUser!.delete().then((value) {
        Fluttertoast.showToast(msg: "Account Deleted");
        FirebaseAuth.instance.signOut();
      });
    });
  } catch (e) {
    Fluttertoast.showToast(msg: "$e");
  }
}
