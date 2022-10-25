// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:instapay_client/screens/loading/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/numeric_pad.dart';
import 'components/pin_widget.dart';
import 'components/top_pincode_screen.dart';
import '../../components/constants.dart';

/// CreatePinCode :
/// Cette page consiste à Permettre à l'utilisateur qui vient de se connecter ou de s'inscrire
/// de créer un code PIN pour acceder à la page d'accueil de l'application

class CreatePinCode extends StatefulWidget {
  final String userEmail;
  const CreatePinCode({super.key, required this.userEmail});

  @override
  State<CreatePinCode> createState() => _CreatePinCodeState();
}

class _CreatePinCodeState extends State<CreatePinCode> {
  String topMessage = "Enregistrez votre code PIN";
  bool codepinDoesntMatch = false;
  PinController pincodeController = PinController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: kToolbarHeight,
          ),

          // Partie supérieure de la page : logo et message
          TopPincodeScreen(
              userEmail: widget.userEmail,
              userImage: logoPath,
              userMessage: topMessage),

          // Points indiquant une entrée du code PIN
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Les points de marquage d'entrer ou pas d'un chiffre du code PIN
                PinWidget(
                    pinLength: 5,
                    controller: pincodeController,
                    onCompleted: (code) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SavePinCode(
                                userEmail: widget.userEmail, pincode: code),
                          ));
                    }),
              ],
            ),
          ),

          // Espace entre les Widgets d'en haut et celui du clavier numerique en bas
          const Spacer(),

          // Clavier numérique
          NumericPad(pincodeController: pincodeController),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
}

/// SavePinCode : Cette page permet de Confirmer et sauvegarder le code pin

class SavePinCode extends StatefulWidget {
  final String pincode;
  final String userEmail;
  const SavePinCode({
    Key? key,
    required this.pincode,
    required this.userEmail,
  }) : super(key: key);

  @override
  State<SavePinCode> createState() => _SavePinCodeState();
}

class _SavePinCodeState extends State<SavePinCode> {
  String topMessage = "Confirmez votre code PIN";

  bool codepinDoesntMatch = false;
  bool dataNotFound = false;
  PinController pincodeController = PinController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: kToolbarHeight,
          ),

          // Partie supérieur de la page
          TopPincodeScreen(
              userImage: logoPath,
              userMessage: topMessage,
              userEmail: widget.userEmail),

          // Boutton d'entre de code pin
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Les points de marquage d'entrer ou pas d'un chiffre du code PIN
                PinWidget(
                    pinLength: 5,
                    controller: pincodeController,
                    onCompleted: (codePin) {
                      if (codePin == widget.pincode) {
                        goToHomePage(codePin);
                      } else {
                        // Animation mauvais code PIN
                        pincodeController.notifyWrongInput();
                        codepinDoesntMatch = true;
                        setState(() {});
                      }
                    }),
              ],
            ),
          ),

          const SizedBox(
            height: 16,
          ),
          // Bouton de code PIN oublié en cas d'une entrée incorrecte
          (codepinDoesntMatch)
              ? TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreatePinCode(
                                  userEmail: widget.userEmail,
                                )));
                  },
                  child: Text("Recommencer",
                      style:
                          TextStyle(color: InstaColors.primary, fontSize: 12)),
                )
              : Container(),

          // Espace entre les Widgets d'en haut et celui du clavier numerique en bas
          const Spacer(),

          // Clavier numérique
          NumericPad(pincodeController: pincodeController),

          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  // Fonction de chargement de la page d'acceuil après enregistrement du code pin
  goToHomePage(String code) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    // Hasher le code pin
    var encodePin = utf8.encode(code);
    String pingHash = sha256.convert(encodePin).toString();

    // Stocker dans la memoire de l'appareil
    await pref.setString("pincode", pingHash);
    debugPrint("Code Pin : $code / $pingHash");

    // Charger la page d'accueil

    Navigator.pushAndRemoveUntil(context,
        MaterialPageRoute(builder: (_) => const Loading()), (route) => true);
  }
}
