// ignore_for_file: use_build_context_synchronously
// Package Flutter et Dart et ceux propore à l'application

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart';
import 'dart:convert';

import '../login/login.dart';
import '../../components/constants.dart';

/// ResetPassword :  Page de reinitialisation du mot de passe en cas d'oubli.
/// Cette page possède deux formulaires au lieu d'un seul
/// une pour la demande de reinitialisation et mot de passe et l'autre pour saisir le noveau mot de passe

class ResetPassword extends StatefulWidget {
  final String userEmail;
  const ResetPassword({Key? key, required this.userEmail}) : super(key: key);

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final formKey = GlobalKey<FormState>();
  final formKey2 = GlobalKey<FormState>();
  bool submit1 = false;
  bool submit2 = false;
  bool obscuretext = true;
  bool loading1 = false;
  bool loading2 = false;

  // Indique l'état du formulaire de saisie du nouveau mot de passe actif ou non
  bool resetPassword = false;
  late TextEditingController emailController;
  late TextEditingController reinitialisationCodeController;
  late TextEditingController newPasswordController;
  late TextEditingController cNewPasswordController;

  // InitState : Initisalisation  de la page
  @override
  void initState() {
    super.initState();

    emailController = TextEditingController();
    reinitialisationCodeController = TextEditingController();
    newPasswordController = TextEditingController();
    cNewPasswordController = TextEditingController();

    emailController.text = widget.userEmail;

    // Verifie si le mail est correcte avant de permettre l'activation du boutton de validation
    emailController.addListener(() {
      var email = EmailValidator.validate(emailController.text);
      setState(() {
        submit1 = email ? true : false;
      });
    });

    reinitialisationCodeController.addListener(() {
      setState(() {
        submit2 = resetPasswordFormIsValid();
      });
    });

    newPasswordController.addListener(() {
      setState(() {
        submit2 = resetPasswordFormIsValid();
      });
    });
    cNewPasswordController.addListener(() {
      setState(() {
        submit2 = resetPasswordFormIsValid();
      });
    });
  }

  // Dispose : destruction des ressources utilisées
  @override
  void dispose() {
    emailController.dispose();
    reinitialisationCodeController.dispose();
    newPasswordController.dispose();
    cNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(InstaSpacing.medium),
          child: Expanded(
            child: Column(children: [
              SizedBox(
                height: InstaSpacing.large * 2,
              ),

              // Titre
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'Mot de passe oublié ?',
                      style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
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
                      !loading1 && !resetPassword
                          ? "Pas de panique !"
                          : (!resetPassword)
                              ? "Vous recevrez un mail à l'addresse ${emailController.text} dans quelques instants."
                              : "Vous avez reçu un code de reinitialisation à l'addresse ${emailController.text}.",
                      style: TextStyle(color: Colors.grey.shade600),
                      maxLines: 3,
                    ),
                  ),
                ],
              ),

              // Formulaires
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: InstaSpacing.large * 3,
                  ),

                  // Si le formulaire de reinitialisation du mot de passe n'est pas activé,
                  // afficher le formulaire de confirmation du mail qui reçevra le code de reinitialisation
                  !resetPassword ? confirmEmailForm() : resetPasswordForm(),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }

  // Formulaire de confirmation de l'adresse à laquelle l'on veux recevoir le code de reinitialisation
  Form confirmEmailForm() {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          // Champ de l'adresse Mail
          TextFormField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.alternate_email),
              hintText: "Email du compte",
            ),
            validator: (email) {
              return email != null && !EmailValidator.validate(email)
                  ? "Adresse mail invalide"
                  : null;
            },
          ),
          SizedBox(height: InstaSpacing.big),

          loading1
              ? CircularProgressIndicator(
                  color: InstaColors.primary,
                  strokeWidth: 5,
                )
              :
              // Boutton de validation
              ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(onSurface: InstaColors.primary),
                  onPressed: (submit1)
                      ? () async {
                          final isValidForm = formKey.currentState!.validate();
                          if (isValidForm) {
                            setState(() {
                              loading1 = true;
                            });
                            debugPrint("Formulaire valide ... ");

                            try {
                              debugPrint(
                                  "[..] Demande de reinitialisation de mot de passe du ${emailController.text}");
                              Response response = await post(
                                  Uri.parse(Api.resetPasswordRequest),
                                  body: jsonEncode(<String, dynamic>{
                                    "email": emailController.text,
                                  }),
                                  headers: <String, String>{
                                    "Content-Type": "application/json"
                                  });

                              debugPrint(
                                  "  --> Code de la reponse : [${response.statusCode}]");
                              debugPrint(
                                  "  --> Contenue de la reponse : ${response.body}");

                              if (response.statusCode == 200) {
                                setState(() {
                                  loading1 = false;
                                  resetPassword = true;
                                });
                              } else {
                                showInformation(
                                    context, false, "Compte inexistant");
                                setState(() {
                                  loading1 = false;
                                  resetPassword = false;
                                });
                              }
                            } catch (e) {
                              showInformation(context, false,
                                  "Vérifiez votre connexion internet");
                              setState(() {
                                loading1 = false;
                                resetPassword = false;
                              });
                            }
                          }
                        }
                      : null,
                  child: Text("Confirmer".toUpperCase())),
          SizedBox(height: InstaSpacing.normal),

          // Boutton de retour
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.grey.shade500,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Retour".toUpperCase())),
        ],
      ),
    );
  }

  // Formulaire de saisi du code de reinitialisation et du nouveau mot de passe
  Form resetPasswordForm() {
    return Form(
      key: formKey2,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        children: [
          // Champ du code de reinitialisation de mot de passe
          TextFormField(
            controller: reinitialisationCodeController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.pin),
              hintText: "Code de reinitialisation",
            ),
            validator: (code) {
              return code != null && code.length != 10
                  ? "Contient 10 caractères"
                  : null;
            },
          ),

          SizedBox(height: InstaSpacing.normal),

          // Champ du nouveau mot de passe
          TextFormField(
            controller: newPasswordController,
            obscureText: obscuretext,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.password),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    obscuretext = !obscuretext;
                  });
                },
                child:
                    Icon(obscuretext ? Icons.visibility : Icons.visibility_off),
              ),
              hintText: "Nouveau mot de passe",
            ),
            validator: (password) {
              return password != null && password.length < 8
                  ? "Mot de passe trop court"
                  : null;
            },
          ),

          SizedBox(height: InstaSpacing.normal),

          // Confirmation du nouveau mot de passe
          TextFormField(
            controller: cNewPasswordController,
            obscureText: obscuretext,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.password),
              hintText: "Confirmez le mot de passe",
            ),
            validator: (password) {
              return password != null && password == newPasswordController.text
                  ? "Mots de passe différents"
                  : (password != null && password.length < 8)
                      ? "Mot de passe trop court"
                      : null;
            },
          ),

          SizedBox(height: InstaSpacing.big),

          loading2
              ? CircularProgressIndicator(
                  color: InstaColors.primary,
                  strokeWidth: 5,
                )
              : ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(onSurface: InstaColors.primary),
                  onPressed: (submit2)
                      ? () async {
                          final isValidForm = formKey2.currentState!.validate();
                          if (isValidForm) {
                            // le formulaire est valide
                            setState(() {
                              // Demarrage du widget de chargement
                              loading2 = true;
                            });
                            debugPrint("Formulaire valide ... ");

                            try {
                              debugPrint(
                                  "[..] reinitialisation du mot de passe du ${emailController.text}");
                              // Envoie de requete vers l'API pour la reinititialisation du mot de passe
                              Response response = await post(
                                  Uri.parse(Api.resetPassword),
                                  body: jsonEncode(<String, dynamic>{
                                    "email": emailController.text,
                                    "reset_code":
                                        reinitialisationCodeController.text,
                                    "new_password": newPasswordController.text,
                                  }),
                                  headers: <String, String>{
                                    "Content-Type": "application/json"
                                  });

                              debugPrint(
                                  "  --> Code de la reponse : [${response.statusCode}]");
                              debugPrint(
                                  "  --> Contenue de la reponse : ${response.body}");

                              if (response.statusCode == 200) {
                                // Une fois le mot de passe reinitialisé, retourner vers la page de connexion
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Login()),
                                    (route) => false);
                                setState(() {
                                  loading2 = false;
                                  resetPassword = true;
                                });
                              } else {
                                showInformation(context, false,
                                    "Impossible de reinitialiser le mot de passe");
                                setState(() {
                                  loading2 = false;
                                  resetPassword = false;
                                });
                              }
                            } catch (e) {
                              showInformation(context, false,
                                  "Vérifiez votre connexion internet");
                              setState(() {
                                loading2 = false;
                                resetPassword = false;
                              });
                            }
                          }
                        }
                      : null,
                  child: Text("Restaurer".toUpperCase())),

          SizedBox(
            height: InstaSpacing.normal,
          ),

          // Boutton de retour
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.grey.shade500,
              ),
              onPressed: () {
                setState(() {
                  resetPassword = false;
                  loading1 = false;
                  loading2 = false;
                  reinitialisationCodeController.clear();
                  newPasswordController.clear();
                  cNewPasswordController.clear();
                });
              },
              child: Text("Retour".toUpperCase())),
        ],
      ),
    );
  }

  // Indique l'état du formulaire de saisie du nouveau mot de passe : valide ou non
  bool resetPasswordFormIsValid() {
    bool isValid = reinitialisationCodeController.text.length == 10 &&
        newPasswordController.text.length >= 8 &&
        cNewPasswordController.text == newPasswordController.text;
    debugPrint("Boutton de reinitialisation de  mot de passe $isValid");
    return isValid;
  }

  // Afficher des informations après avoir valider le formulaire
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
