import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future registerEmail(String email, String password) async {
    try {
      FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      )
          .then((UserCredential userCredential) {
        addUser(userCredential.user!.email, userCredential.user!.uid);

        return userCredential;
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  Future loginEmail(String email, String password) async {
    try {
      FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password)
          .then((UserCredential userCredential) {
        print(userCredential);
        return userCredential;
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  Future login<UserCredential>(String email, String password) async {
    checkEmail(email).then((isExist) {
      print(isExist);
      if (isExist) {
        loginEmail(email, password).then((value) {
          return value;
        });
      } else {
        registerEmail(email, password).then((value) {
          return value;
        });
      }
    });
  }

  Future addUser(final email, String uid) async {
    return users
        .doc(uid)
        .set({
          'email': email,
          'uid': uid,
        })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Future<bool> checkEmail(String email) async {
    final QuerySnapshot result =
        await users.where('email', isEqualTo: email).get();

    final List<DocumentSnapshot> documents = result.docs;

    if (documents.length > 0) {
      //exists
      return true;
    } else {
      //not exists
      return false;
    }
  }
}
