import 'package:flutter/material.dart';

class ResetPinCode extends StatelessWidget {
  const ResetPinCode({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reinitialisation de code pin"),
      ),
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Center(
            child: Text(
          "Générer un code de 5 chiffre puis l'envoyé par mail à l'utilisateur. \n\n Une fois authentifier, il poura changer son code pin.",
          style: TextStyle(fontSize: 15),
        )),
      ),
    );
  }
}
