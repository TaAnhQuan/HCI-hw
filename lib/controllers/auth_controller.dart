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

  Future<String> fetchLlmToken() async {
    final authController = Get.find<MyAuthController>();
    final authToken = await authController.userCredential.value?.user?.getIdToken();

    final response = await http.get(
      Uri.parse('https://token.one-api.bud.inc/'),
      headers: {'Authorization': 'Bearer $authToken'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.containsKey('token')) {
        log("Retrieved Llm token: ${data['token']}");
        return data['token'];
      }
    }
    throw Exception("Failed to retrieve Llm token.");
  }
}
