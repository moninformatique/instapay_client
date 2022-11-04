// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/constants.dart';

class UserProfil extends StatefulWidget {
  const UserProfil({Key? key}) : super(key: key);

  @override
  State<UserProfil> createState() => _UserProfilState();
}

class _UserProfilState extends State<UserProfil> {
  Map<String, dynamic> tokens = {};
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController oldPasswordController = TextEditingController();
  bool obscuretext = true;
  bool loading = false;
  bool submit = false;

  @override
  void initState() {
    oldPasswordController
        .addListener(() => setState(() => submit = validateForm()));
    newPasswordController
        .addListener(() => setState(() => submit = validateForm()));
    super.initState();
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: InstaSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: kToolbarHeight,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Modification du mot de passe",
                  style: TextStyle(
                    color: InstaColors.boldText,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 0.9,
                  ),
                ),
              ],
            ),

            SizedBox(
              height: InstaSpacing.normal,
            ),
            const Divider(),
            SizedBox(
              height: InstaSpacing.normal,
            ),

            // Formulaire de changement d e mot de passe
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Fonrmulaire de changement de mot de passe
                Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    children: [
                      // Champ de l'ancien mot de passe
                      TextFormField(
                        controller: oldPasswordController,
                        obscureText: obscuretext,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.password),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                obscuretext = !obscuretext;
                              });
                            },
                            child: Icon(obscuretext
                                ? Icons.visibility
                                : Icons.visibility_off),
                          ),
                          hintText: "Mot de passe actuel",
                        ),
                        validator: (password) {
                          return password != null && password.length < 8
                              ? "Mot de passe trop court"
                              : null;
                        },
                      ),

                      // Espacement
                      SizedBox(height: InstaSpacing.normal),

                      // Champ du nouveau mot de passe
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: obscuretext,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.password),
                          hintText: "Nouveau mot de passe",
                        ),
                        validator: (password) {
                          return password != null && password.length < 8
                              ? "Mot de passe trop court"
                              : null;
                        },
                      ),

                      // Espacement
                      SizedBox(height: InstaSpacing.normal),

                      // Champ de soumission du formulaire

                      loading
                          ? CircularProgressIndicator(
                              color: InstaColors.primary,
                              strokeWidth: 5,
                            )
                          :
                          // Boutton de mangement de mot de passe
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  onSurface: InstaColors.primary),
                              onPressed: submit
                                  ? () {
                                      final isValidForm =
                                          formKey.currentState!.validate();
                                      if (isValidForm) {
                                        debugPrint("Formulaire valide ... ");
                                        setState(() => loading = true);
                                        changePassword();
                                      } else {
                                        debugPrint("Formulaire invalide ... ");
                                        showInformation(context, false,
                                            "Vos informations ne sont pas valides");
                                      }
                                    }
                                  : null,
                              child: const Text("MODIFIER")),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        "Mot de passe",
        style: TextStyle(
          color: InstaColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(
          Icons.arrow_back,
          color: InstaColors.primary,
        ),
      ),
    );
  }

  changePassword() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      tokens = jsonDecode(pref.getString("tokens")!);
    });
    try {
      debugPrint("Tentative de changement de mot de passe");

      Response response = await patch(Uri.parse(Api.changePassword),
          body: jsonEncode(<String, dynamic>{
            "old_password": oldPasswordController.text,
            "new_password": newPasswordController.text
          }),
          headers: <String, String>{
            "Content-Type": "application/json",
            "Authorization": "Bearer ${tokens['access']}"
          });

      debugPrint("Code de la reponse : [${response.statusCode}]");
      debugPrint("Contenue de la reponse : ${response.body}");

      setState(() => loading = false);
      if (response.statusCode == 200) {
        debugPrint("Le changement du mot de passe a été éffectué");
        oldPasswordController.clear();
        newPasswordController.clear();
        showInformation(context, true,
            "Le changement de votre mot de passe a été éffectué");
      } else {
        debugPrint("le changement de mot de passe a échoué");
        showInformation(context, false, "Une érreur est survenue");
      }
    } catch (e) {
      debugPrint(e.toString());
      setState(() => loading = false);
      showInformation(context, false, "Vérifiez votre connexion internet");
    }
  }

  // Affiche des informations en rapport avec les resultats des requetes à l'utilisateur
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
      behavior: SnackBarBehavior.floating,
      backgroundColor: isSuccess ? InstaColors.success : InstaColors.error,
      elevation: 3,
    ));
  }

  // Verifie si le formulaire est valide
  bool validateForm() {
    bool isValid = oldPasswordController.text.length >= 8 &&
        newPasswordController.text.length >= 8;
    // Retourne true si le mail et le mot de passe respecte les conditions et non sinon
    return isValid;
  }
}
