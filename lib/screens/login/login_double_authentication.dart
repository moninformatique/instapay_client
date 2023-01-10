// ignore_for_file: use_build_context_synchronously

// packages flutter et dart puis ceux propre à l'application
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:instapay_client/screens/login/instructions.dart';
import 'dart:convert';

import '../../../components/constants.dart';

///  DoubleAuthentication : Formulaire pour valider la double authentification
class DoubleAuthentication extends StatefulWidget {
  final String userToken;
  final String userEmail;
  const DoubleAuthentication(
      {Key? key, required this.userToken, required this.userEmail})
      : super(key: key);

  @override
  State<DoubleAuthentication> createState() => _DoubleAuthenticationState();
}

class _DoubleAuthenticationState extends State<DoubleAuthentication> {
  bool loading = false;
  bool submit = false;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController codeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(InstaSpacing.medium),
          child: Column(children: [
            SizedBox(
              height: InstaSpacing.large,
            ),

            // Titre
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Double authentification',
                    style: GoogleFonts.poppins(
                        textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: InstaColors.boldText)),
                  ),
                ),
              ],
            ),

            // Message
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    "Vous avez réçu un code à l'addresse ${widget.userEmail}.",
                    style: TextStyle(color: Colors.grey.shade600),
                    maxLines: 3,
                  ),
                ),
              ],
            ),

            // Formulaire de double authetification
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: InstaSpacing.large * 3,
                ),
                // Fonrmulaire de double authentification
                doubleAuthentificationForm(),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  // Formulaire de saisie de code pour la double authentificaiton
  Widget doubleAuthentificationForm() {
    return SingleChildScrollView(
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            // Champ du code d'authentification
            TextFormField(
              onChanged: (value) {
                setState(() {
                  submit = (value.length == 8) ? true : false;
                });
              },
              controller: codeController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                LengthLimitingTextInputFormatter(8),
                FilteringTextInputFormatter.digitsOnly
              ],
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.numbers),
                hintText: "Code d'authentification",
              ),
              validator: (authCode) {
                return authCode != null && authCode.length != 8
                    ? "Doit contenir 8 caractères numérique"
                    : null;
              },
            ),

            SizedBox(height: InstaSpacing.big),

            loading
                ? CircularProgressIndicator(
                    color: InstaColors.primary,
                    strokeWidth: 5,
                  )
                :
                // Boutton de connexion
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        disabledForegroundColor: InstaColors.primary.withOpacity(0.38), disabledBackgroundColor: InstaColors.primary.withOpacity(0.12)),
                    onPressed: (submit)
                        ? () async {
                            final isValidForm =
                                formKey.currentState!.validate();
                            if (isValidForm) {
                              setState(() {
                                loading = true;
                              });
                              debugPrint("Formulaire valide ... ");

                              confirmCodeForDoubleAuthentication();
                            }
                          }
                        : null,
                    child: Text("Confirmer".toUpperCase())),

            SizedBox(height: InstaSpacing.normal),

            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade500,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Retour".toUpperCase())),
          ],
        ),
      ),
    );
  }

  // validation de la double authentification
  void confirmCodeForDoubleAuthentication() async {
    debugPrint(
        "Exécution de la fonction de validation de code de la double authentification ... ");

    try {
      debugPrint("[..] Tentative de seconde authentification");
      Response response = await post(Uri.parse(Api.doubleAuthentication),
          body: jsonEncode(<String, dynamic>{
            "second_authentication_code": codeController.text,
          }),
          headers: {
            "Content-Type": "application/json",
            "Authorization": "Bearer ${widget.userToken}"
          });

      debugPrint("  --> Code de la reponse : [${response.statusCode}]");
      debugPrint("  --> Contenue de la reponse : ${response.body}");
      setState(() {
        loading = false;
      });
      if (response.statusCode == 200) {
        goToCreatePinCodeScreen(widget.userEmail);
      } else {
        showInformation(context, false, "Authentification échouée");
      }
    } catch (e) {
      showInformation(context, false, "Vérifiez votre connexion internet");
      setState(() {
        loading = false;
      });
    }
  }

  // Fonction de chargement de la page de creation de code PIN
  void goToCreatePinCodeScreen(String userEmail) {
    debugPrint(" Chargement de la page d'accueil");
    codeController.clear();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Instructions()),
        (route) => false);
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
