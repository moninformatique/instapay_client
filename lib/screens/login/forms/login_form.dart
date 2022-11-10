// ignore_for_file: use_build_context_synchronously

// packages Flutter et Dart puis ceux propre à l'application
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:instapay_client/screens/login/instructions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart';
import 'dart:convert';

import '../../../components/constants.dart';
import '../../settings/reset_password.dart';
import '../login_double_authentication.dart';

/// LoginForm : Formulaire de connexion
class LoginForm extends StatefulWidget {
  final bool isLogin;
  final Duration animationDuration;

  const LoginForm({
    Key? key,
    required this.isLogin,
    required this.animationDuration,
  }) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  // Variables
  bool loading = false; // Chargement
  bool obscuretext = true; // Cacher ou afficher le mot de passe
  bool forgetPassword = false;
  bool submit = false; // Etat du boutton de validation : actuf ou non actuf

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController emailController;
  late TextEditingController passwordController;

  // InitState : Initialisation de la page
  @override
  void initState() {
    super.initState();

    emailController = TextEditingController();
    passwordController = TextEditingController();

    // On ecoute le controlleur du champ email
    // à chaque modification du champ on indique si le bouton de soumission peut etre activer dans l a variable submit
    emailController.addListener(() {
      setState(() {
        submit =
            validateForm(); // si le formulaire est valide,  submit aura la valeur true
      });
    });

    // On fait la même chose sur le controlleur du champ de mot de passe
    passwordController.addListener(() {
      setState(() {
        submit = validateForm();
      });
    });
  }

  // Dispose : Destruction des ressources utilisées
  @override
  void dispose() {
    emailController.clear();
    passwordController.clear();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
        // Enleve l'opacité (0.0) si le formulaire de connexion n'est pas actif (isLogin = false)
        opacity: widget.isLogin ? 1.0 : 0.0,
        duration: widget.animationDuration * 4,
        child: Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
                child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: InstaSpacing.medium),
                    child: Column(children: [
                      // Titre
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            'InstaPay',
                            style: TextStyle(
                                fontFamily: 'Ultra',
                                fontSize: 35,
                                color: InstaColors.primary),
                          ),
                        ],
                      ),

                      // Message
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome !",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),

                      // Formulaire de connexion
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: InstaSpacing.normal * 3,
                          ),
                          // Fonrmulaire de connexion
                          Form(
                            key: formKey,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            child: Column(
                              children: [
                                // Champ de l'adresse Mail
                                TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.alternate_email),
                                    hintText: "Email",
                                  ),
                                  validator: (email) {
                                    return email != null &&
                                            !EmailValidator.validate(email)
                                        ? "Adresse mail invalide"
                                        : null;
                                  },
                                ),

                                // Espacement
                                SizedBox(height: InstaSpacing.normal),

                                // Champ du mot de passe
                                TextFormField(
                                  controller: passwordController,
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
                                    hintText: "Mot de passe",
                                  ),
                                  validator: (password) {
                                    return password != null &&
                                            password.length < 8
                                        ? "Mot de passe trop court"
                                        : null;
                                  },
                                ),

                                // Espacement
                                SizedBox(height: InstaSpacing.normal),

                                // Mot de passe oublié
                                if (forgetPassword)
                                  TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ResetPassword(
                                                      userEmail:
                                                          emailController.text,
                                                    )));
                                      },
                                      child: Text(
                                        "Mot de passe oublié ?",
                                        style: TextStyle(
                                            color: InstaColors.boldText),
                                      )),

                                // Espacement
                                SizedBox(height: InstaSpacing.normal),

                                // Champ de soumission du formulaire
                                loading
                                    ? CircularProgressIndicator(
                                        color: InstaColors.primary,
                                        strokeWidth: 5,
                                      )
                                    :
                                    // Boutton de connexion
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            onSurface: InstaColors.primary),
                                        onPressed: submit
                                            ? () {
                                                final isValidForm = formKey
                                                    .currentState!
                                                    .validate();
                                                if (isValidForm) {
                                                  debugPrint(
                                                      "Formulaire valide ... ");
                                                  setState(() {
                                                    loading = true;
                                                  });

                                                  signIn();
                                                } else {
                                                  showInformation(
                                                      context,
                                                      false,
                                                      "Vos informations ne sont pas valides");
                                                }
                                              }
                                            : null,
                                        child:
                                            Text("Se connecter".toUpperCase())),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ])))));
  }

  // Verifie si le formulaire est valide
  bool validateForm() {
    bool isValid = EmailValidator.validate(emailController.text) &&
        passwordController.text.length >= 8;
    // Retourne true si le mail et le mot de passe respecte les conditions et non sinon
    return isValid;
  }

  // Fonction de connexion de l'utilisateur
  void signIn() async {
    debugPrint("Exécution de la fonction de connexion ... ");

    // Création d'une variable de sauvegarde de donnée en locale
    SharedPreferences pref = await SharedPreferences.getInstance();

    try {
      debugPrint("[_] Connexion de l'utilisateur ${emailController.text} ");
      // Requete vers l'API pour la connexion
      Response response = await post(Uri.parse(Api.login),
          body: jsonEncode(<String, String>{
            "email": emailController.text,
            "password": passwordController.text
          }),
          headers: {
            "Content-Type": "application/json",
            "X-Api-Key": "ZmFiaW8gZGV2ZWxvcHBlZCB0aGlzIGFwaQ=="
          });

      debugPrint("  --> Code de la reponse : [${response.statusCode}]");
      debugPrint("  --> Contenue de la reponse : ${response.body}");

      if (response.statusCode == 200) {
        debugPrint("[OK] Connexion éffectué avec succès");

        // Sauvegarde des données de l'utilisateur en local
        await pref.setString("tokens", response.body);
        await pref.setString("user", emailController.text);

        // Vérification de la présence d'une double authentification
        var tokens = jsonDecode(response.body);
        verifyDoubleAuthentication(tokens["access"]);
      } else {
        debugPrint("[X] Connexion échoué : HTTP ${response.statusCode}");
        setState(() {
          // Arret du widget de chargement
          loading = false;
        });
        if (response.statusCode == 401) {
          setState(() {
            forgetPassword = true;
          });
          showInformation(context, false,
              "Ces informations ne correspondent a aucun compte actif");
        } else {
          showInformation(context, false, "Tentative de connexion échouée");
        }
      }
    } catch (e) {
      debugPrint("[X] Une erreur est survenue : \n $e");
      setState(() {
        loading = false;
      });
      showInformation(context, false, "Vérifiez votre connexion internet");
    }
  }

  // Verifier si l'utilisateur à activer la double authentification  pour son compte
  void verifyDoubleAuthentication(String token) async {
    debugPrint(
        "Exécution de la fonction de verification de double authentification ... ");

    try {
      debugPrint("[_] Verification de la double authentification ");
      // Requete vers l'API pour vérifier si la double authentificiation est activée sur le compte
      // En obtenant les information du compte de l'utilisateur
      Response response = await get(Uri.parse(Api.userInformations),
          headers: <String, String>{"Authorization": "Bearer $token"});

      debugPrint(
          "  --> Envoie de la requete de verification de la double authentification");
      debugPrint("  --> Code de la reponse : [${response.statusCode}]");
      debugPrint("  --> Contenue de la reponse : ${response.body}");

      if (response.statusCode == 200) {
        debugPrint("[OK] vérification reussie avec succès");
        var userInfos = jsonDecode(response.body);

        if (userInfos["double_authentication"]) {
          // La double authentification est activée
          debugPrint("[OK] Double authentification activé");
          requestDoubleAuthentication(token);
        } else {
          // La double authentification n'est pas activée

          setState(() {
            // Arret du widget de chargement
            loading = false;
          });
          debugPrint("[OK] Double authentification déactivé");
          gotToInstructionsScreen(emailController.text);
        }
      } else {
        setState(() {
          // Arret du widget de chargement
          loading = false;
        });
        debugPrint("[X] Vérification échoué : HTTP ${response.statusCode}");
        showInformation(
            context, false, "Recherche de double authentification échouée");
      }
    } catch (e) {
      debugPrint("[X] Une erreur est survenue : \n $e");
      setState(() {
        // Arret du widget de chargement
        loading = false;
      });
      showInformation(context, false, "Vérifiez votre connexion internet");
    }
  }

  //Fonction de requete pour l'obtention d'un code pour valider la double authentification
  void requestDoubleAuthentication(String token) async {
    debugPrint(
        "Exécution de la fonction d'envoi de requete pour le code de la double authentification ... ");

    try {
      debugPrint(
          "[_] Requete de demande de code pour la double authentification ");
      // Requête vers l'API pour demander un code de seconde authentification
      Response response = await get(Uri.parse(Api.doubleAuthentication),
          headers: <String, String>{"Authorization": "Bearer $token"});

      debugPrint(
          "  --> Envoie de la requete de demande de code pour la double authentification");
      debugPrint("  --> Code de la reponse : [${response.statusCode}]");
      debugPrint("  --> Contenue de la reponse : ${response.body}");

      setState(() {
        // Arret du widget de chargement
        loading = false;
      });
      if (response.statusCode == 200) {
        debugPrint(
            "[OK] Requete de demande de code pour la double authentification reussie avec succès");

        goToDoubleAuthenticationScreen(token, emailController.text);
      } else {
        debugPrint("[X] Vérification échoué : HTTP ${response.statusCode}");

        showInformation(
            context, false, "Impossible d'obtenir le code d'authentification");
      }
    } catch (e) {
      debugPrint("[X] Une erreur est survenue : \n $e");
      setState(() {
        // Arret du widget de chargement
        loading = false;
      });
      showInformation(context, false, "Vérifiez votre connexion internet");
    }
  }

  // Fonction de chargement de la page de validation de la double authentification
  void goToDoubleAuthenticationScreen(String token, String email) {
    debugPrint(
        " Chargement de la page de validation de double authentification");
    emailController.clear();
    passwordController.clear();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DoubleAuthentication(
                  userToken: token,
                  userEmail: email,
                )));
  }

  // Fonction de chargement de la page d'instruction'
  void gotToInstructionsScreen(String userEmail) {
    emailController.clear();
    passwordController.clear();

    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Instructions()),
        (route) => true);
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
}
