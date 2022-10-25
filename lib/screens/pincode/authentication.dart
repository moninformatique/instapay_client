// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:instapay_client/screens/loading/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../login/login.dart';
import '../settings/reset_pincode.dart';
import 'components/numeric_pad.dart';
import 'components/pin_widget.dart';
import 'components/top_pincode_screen.dart';
import '../../components/constants.dart';

class Authentication extends StatefulWidget {
  final String userEmail;
  const Authentication({super.key, required this.userEmail});

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  bool forgetPin = false;
  PinController pincodeController = PinController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: kToolbarHeight,
          ),

          // Bouton de déconnexion
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Boutton de déconnexion
              TextButton(
                  onPressed: () {
                    logout();
                  },
                  child: const Text(
                    "Déconnexion",
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  )),
            ],
          ),

          // Partie supérieur de la page
          TopPincodeScreen(
            userEmail: widget.userEmail,
            userImage: logoPath,
            userMessage: "Bon retour",
          ),

          // Les points de marquage d'entrer ou pas d'un chiffre du code PIN
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                PinWidget(
                    pinLength: 5,
                    controller: pincodeController,
                    onCompleted: (pincode) {
                      verifyCodePin(pincode);
                    }),
              ],
            ),
          ),

          const SizedBox(
            height: 16,
          ),

          // Bouton de code PIN oublié en cas d'une entrée incorrecte
          (forgetPin)
              ? TextButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const ResetPinCode()));
                  },
                  child: Text("Code Pin oublié ?",
                      style: TextStyle(
                          color: InstaColors.weightBoldText, fontSize: 12)),
                )
              : Container(),

          // Espace entre les Widgets d'en haut et celui du clavier numerique en bas
          const Spacer(),

          // Clavier numérique
          NumericPad(
            pincodeController: pincodeController,
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  // Fonction de vérification de l'exactitude du code PIN entré
  verifyCodePin(String code) async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    //hasher le code pin pour le comparer avec celui qui a été déjà enregistré
    var encodePin = utf8.encode(code);
    String pinEntred = sha256.convert(encodePin).toString();
    String? pinSaved = pref.getString("pincode");

    if (pinSaved != null) {
      // Un code PIN a été enregistré
      debugPrint(" PIN  Enregistré : $pinSaved \n PIN Entré : $pinEntred");
      if (pinSaved == pinEntred) {
        // Le code PIN entré est correct
        debugPrint("Le code PIN est correcte");
        String? userEmail = pref.getString("user");
        String? userTokens = pref.getString("tokens");
        if (userEmail != null && userTokens != null) {
          var tokens = jsonDecode(userTokens);
          debugPrint(
              "Le token d'acces de l'utilisateur est : ${tokens["access"]}");
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Loading()),
              (route) => true);
        } else {
          logout();
        }
      } else {
        // le code PIN entré est incorret
        debugPrint("Le code PIN est incorrecte");
        pincodeController.notifyWrongInput();
        forgetPin = true;
      }
    } else {
      // Aucun code PIN n'a été enregistré, conduire l'utilisateur à la page de connexion
      debugPrint("Aucun code PIN n'as été enregistré");
      logout();
    }
    setState(() {});
  }

  // Fonction de décconexio de l'utilisateur connecté
  void logout() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? userTokens = pref.getString("tokens");
    debugPrint(userTokens);
    await pref.clear();

    if (userTokens != null) {
      var tokens = jsonDecode(userTokens);

      debugPrint("[_]Déconnexon de l'utilisateur avec les tokens ... $tokens ");

      try {
        Response response = await post(Uri.parse(Api.logout),
            body: jsonEncode(<String, dynamic>{
              "refresh": tokens["refresh"],
            }),
            headers: {
              "Content-Type": "application/json",
              "Authorization": "Bearer ${tokens["access"]}"
            });

        debugPrint("  --> Code de la reponse : [${response.statusCode}]");
        debugPrint("  --> Contenue de la reponse : ${response.body}");
        if (response.statusCode == 200) {
          await pref.clear();
          debugPrint("[OK] Déconnexion reussie");
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Login()),
              (route) => false);
        } else {
          debugPrint("[X] Déconnexion reussie");
          showInformation(context, false, "Déconnexion échouée");
        }
      } catch (e) {
        debugPrint("[X] Déconnexion reussie");
        showInformation(context, false, "Vérifiez votre connexion internet");
      }
    } else {
      debugPrint("[X] Déconnexion reussie");
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false);
    }
  }

  // Afficher des informations après la validation d'un formulaire
  showInformation(BuildContext context, bool isSuccess, String message) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
      //behavior: SnackBarBehavior.floating,
      backgroundColor: isSuccess ? InstaColors.success : InstaColors.error,
      //elevation: 3,
    ));
  }
}
