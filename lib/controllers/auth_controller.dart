import 'dart:convert';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;


class MyAuthController extends GetxController {
  Rx<UserCredential?> userCredential = Rx<UserCredential?>(null);

  Future<void> signInAnonymously() async {
    userCredential.value = await FirebaseAuth.instance.signInAnonymously();
    try {
      log("Signed in with temporary account: ${userCredential.value?.user?.uid}");
    } on FirebaseAuthException catch (e) {
      log("Unknown error: ${e.code} ${e.message}");
    }
  }
}
