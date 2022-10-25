// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:instapay_client/components/constants.dart';
import 'package:instapay_client/screens/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../login/login.dart';

class Loading extends StatefulWidget {
  const Loading({
    super.key,
  });

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      debugPrint("Executé apres 3 seconds");
      // Aller à la page principale de l'application
      goToHomeScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(left: width / 3, right: width / 3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image de chargement
            Image.asset(
              logoPath,
              height: 120,
              width: 120,
            ),

            const SizedBox(
              height: 20,
            ),

            // indicateur de progression
            Padding(
              padding: const EdgeInsets.only(),
              child: LinearProgressIndicator(
                backgroundColor: InstaColors.lightPrimary,
                color: InstaColors.primary,
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  goToHomeScreen() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? tokens = pref.getString("tokens");
    String? userEmail = pref.getString("user");

    if (tokens != null && userEmail != null) {
      var token = jsonDecode(tokens);
      debugPrint(token["access"]);

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => MyHomePage(
                    token: token["access"],
                    userEmail: userEmail,
                  )),
          (route) => true);
    } else {
      await pref.clear();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false);
    }
  }
}
