// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:instapay_client/components/constants.dart';
import 'package:instapay_client/screens/login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InvalidTokenScreen extends StatelessWidget {
  const InvalidTokenScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(InstaSpacing.normal),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Votre session a expirée, veuillez vous reconnecté",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: InstaSpacing.medium,),
                TextButton(
                    onPressed: () async {
                      SharedPreferences pref =
                          await SharedPreferences.getInstance();
                      await pref.clear();
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const Login()),
                          (route) => false);
                    },
                    child: const Text("Se connecter")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
