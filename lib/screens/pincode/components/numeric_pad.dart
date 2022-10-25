// Packages Flutter & Dart ainsi que ceux de l'application
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:instapay_client/screens/loading/loading.dart';
import 'package:instapay_client/screens/pincode/fingerprint.dart';
import 'pin_widget.dart';
import '../../../components/constants.dart';

/// NumericPad : Cette page a pour but de contruire le pavé numérique de saisie de code PIN

class NumericPad extends StatelessWidget {
  final PinController pincodeController;
  NumericPad({Key? key, required this.pincodeController}) : super(key: key);

  final List<int> firstRow = [1, 2, 3],
      secondRow = [4, 5, 6],
      thirdRow = [7, 8, 9];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Boutton de la première ligne : de 1 à 3
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: firstRow.map((e) => buildMaterialButton(e)).toList(),
        ),

        // Boutton de la deuxième ligne : de 4 à 6
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: secondRow.map((e) => buildMaterialButton(e)).toList(),
        ),

        // Boutton de la troisième ligne : de 7 à 9
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: thirdRow.map((e) => buildMaterialButton(e)).toList(),
        ),

        // Boutton de la dernière ligne : empreinte - 0 - backspace
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            MaterialButton(
              onPressed: () async {
                debugPrint("Deverouillage par empreinte");
                final isAuthenticated = await LocalAuthApi.authenticate();
                if (isAuthenticated) {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const Loading()));
                }
              },
              textColor: InstaColors.primary,
              child: const Icon(Icons.fingerprint),
            ),
            buildMaterialButton(0),
            MaterialButton(
              onPressed: () {
                pincodeController.delete();
              },
              textColor: InstaColors.primary,
              child: const Icon(Icons.backspace),
            ),
          ],
        ),
      ],
    );
  }

  // Widget de construction des bouttons du clavier numérique
  MaterialButton buildMaterialButton(int number) {
    return MaterialButton(
      onPressed: () {
        pincodeController.addInput('$number');
      },
      textColor: InstaColors.primary,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Text(
          '$number',
          style: const TextStyle(fontSize: 25),
        ),
      ),
    );
  }
}
