// ignore_for_file: use_build_context_synchronously
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'dart:convert';

import '../../../components/constants.dart';
import '../login.dart';

class RegisterForm extends StatefulWidget {
  final bool isLogin;
  final Duration animationDuration;
  final double width;
  final double height;

  const RegisterForm({
    Key? key,
    required this.isLogin,
    required this.animationDuration,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final formKey = GlobalKey<FormState>();
  bool obscuretext = true;
  bool loading = false;
  bool submit = false;

  late TextEditingController fullNameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  // InitState : Initialisation d e la page
  @override
  void initState() {
    super.initState();
    fullNameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    // On ecoute le controlleur du champ nom de l'utilisateur
    // à chaque modification du champ on indique si le bouton de soumission peut etre activer dans la variable submit
    fullNameController.addListener(() {
      setState(() {
        submit =
            validateForm(); // si le formulaire est valide, submit aura la valeur true
      });
    });

    // La même chose pour le controller du champ de nom de l'utilisateur
    emailController.addListener(() {
      setState(() {
        submit = validateForm();
      });
    });

    // La même chose pour le controller du champ de nom de l'utilisateur
    passwordController.addListener(() {
      setState(() {
        submit = validateForm();
      });
    });

    // La même chose pour le controller du champ de nom de l'utilisateur
    confirmPasswordController.addListener(() {
      setState(() {
        submit = validateForm();
      });
    });
  }

  // Dispose : Destruction des ressorces utilisées
  @override
  void dispose() {
    fullNameController.clear();
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();

    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      // Enleve l'opacité (0.0) si le formulaire de connexion n'est pas actif (isLogin = true)
      opacity: widget.isLogin ? 0.0 : 1.0,
      duration: widget.animationDuration * 5,
      child: Visibility(
        // Afficher le widget si le formulaire de connexion n'est pas actif (isLogin = false)
        visible: !widget.isLogin,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: widget.width,
            height: widget.height,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: InstaSpacing.medium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: InstaSpacing.big),

                    // Titre
                    const Text(
                      'Rejoingnez nous',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                    ),

                    // Message
                    Center(
                      child: Text(
                        'InstaPay, simple et sécurisé',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                      ),
                    ),

                    SizedBox(height: InstaSpacing.big * 3),

                    // Formulaire d'inscription
                    Form(
                      key: formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        children: [
                          // Champ du nom d'utilisateur
                          TextFormField(
                            controller: fullNameController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person),
                              hintText: "Nom complet",
                            ),
                            validator: (fullname) {
                              return fullname != null && fullname.length < 5
                                  ? "Nom complet trop court"
                                  : null;
                            },
                          ),

                          SizedBox(height: InstaSpacing.normal),

                          // Champ de l'adresse mail
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
                            validator: (value) {
                              if (value != null && value.length < 8) {
                                return "Mot de passe trop court";
                              } else {
                                return null;
                              }
                            },
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),

                          SizedBox(height: InstaSpacing.normal),

                          // Champ de Confirmation du mot de passe
                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: obscuretext,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.lock),
                              hintText: "Confirmez mot de passe",
                            ),
                            validator: (password) {
                              return (password != null && password.length < 8)
                                  ? "Mot de passe trop court"
                                  : null;
                            },
                          ),

                          SizedBox(height: InstaSpacing.medium),
                          // Champ de soumission du formulaire
                          loading
                              ? CircularProgressIndicator(
                                  color: InstaColors.primary,
                                  strokeWidth: 5,
                                )
                              :
                              // Boutton inscripton
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      onSurface: InstaColors.primary),
                                  onPressed: submit
                                      ? () {
                                          final isValidForm =
                                              formKey.currentState!.validate();
                                          if (isValidForm) {
                                            debugPrint("Formulaire valide ...");
                                            setState(() {
                                              loading = true;
                                            });
                                            signUp();
                                          } else {
                                            showInformation(context, false,
                                                "Vos informations ne sont pas valides");
                                          }
                                        }
                                      : null,
                                  child: Text("S'inscrire".toUpperCase())),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Verifie si le formulaire est valide
  bool validateForm() {
    bool isValid = EmailValidator.validate(emailController.text) &&
        fullNameController.text.length >= 5 &&
        passwordController.text.length >= 8 &&
        confirmPasswordController.text.length >= 8;
    debugPrint("Etat boutton connexion : $isValid");
    // Retourne true si le mail et le mot de passe respecte les conditions et non sinon
    return isValid;
  }

  // Inscription de l'utilisateur
  signUp() async {
    debugPrint("Exécution de la fonction d'inscription ...");

    if (passwordController.text == confirmPasswordController.text) {
      try {
        debugPrint("[_] Inscrition de l'utilisateur ${emailController.text}");
        // Requete vers l'API pour l'inscription de l'utilisateur
        Response response = await post(Uri.parse(Api.signup),
            body: jsonEncode(<String, String>{
              "full_name": fullNameController.text,
              "email": emailController.text,
              "password": passwordController.text,
              "status": "client"
            }),
            headers: <String, String>{"Content-Type": "application/json"});

        debugPrint("  --> Code de la reponse : [${response.statusCode}]");
        debugPrint("  --> Contenue de la reponse : ${response.body}");

        setState(() {
          // Arret du widget de chargement
          loading = false;
        });
        if (response.statusCode == 200 || response.statusCode == 201) {
          debugPrint("[OK] Inscription éffectué avec succès");
          String email = emailController.text;

          // Efface les information dans les différents champ
          emailController.clear();
          fullNameController.clear();
          passwordController.clear();
          confirmPasswordController.clear();

          // Envoie un message pour l'utilisateur
          openDialog(email);
        } else {
          var result = jsonDecode(response.body.toString());
          debugPrint("[X] ${result["erreur"]}");

          showInformation(context, false, "Ce compte existe déjà");
        }
      } catch (e) {
        debugPrint("[X] Une erreur est survenue  \n $e");
        showInformation(context, false, "Vérifiez votre connexion internet");
      }
    } else {
      showInformation(context, false, "Mots de passe différents");
      setState(() {
        loading = false;
      });
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

  // Boite de dialogue pour informer l'utilisateur de la reception d'un mail
  Future openDialog(String email) => showDialog(
      context: context,
      builder: ((context) => AlertDialog(
            content: Text(
                "Un mail a été envoyé à l'addresse $email pour l'activation de votre compte. Veuillez activez votre compte pour vous connecter"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                        (route) => true);
                  },
                  child: Text(
                    "Bien compris",
                    style: TextStyle(color: InstaColors.primary),
                  ))
            ],
          )));
}
