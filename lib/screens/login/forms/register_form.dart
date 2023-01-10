// ignore_for_file: use_build_context_synchronously
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

  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController phoneNumberController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  // InitState : Initialisation d e la page
  @override
  void initState() {
    super.initState();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    phoneNumberController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    phoneNumberController.addListener(() {
      setState(() {
        submit = validateForm();
      });
    });

    passwordController.addListener(() {
      setState(() {
        submit = validateForm();
      });
    });

    confirmPasswordController.addListener(() {
      setState(() {
        submit = validateForm();
      });
    });
  }

  // Dispose : Destruction des ressorces utilisées
  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneNumberController.dispose();
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

                    SizedBox(height: InstaSpacing.big * 2),

                    // Formulaire d'inscription
                    Form(
                      key: formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        children: [
                          // Champ du nom de l'utilisateur
                          TextFormField(
                            controller: lastNameController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person),
                              hintText: "Nom",
                            ),
                            validator: (lastname) {
                              return lastname != null && lastname.length < 2
                                  ? "Nom requis"
                                  : null;
                            },
                          ),

                          SizedBox(height: InstaSpacing.normal),

                          // Champ des prénoms de l'utilisateur
                          TextFormField(
                            controller: firstNameController,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person),
                              hintText: "Prénoms",
                            ),
                            validator: (firstname) {
                              return firstname != null && firstname.length < 2
                                  ? "Prénoms requis"
                                  : null;
                            },
                          ),

                          SizedBox(height: InstaSpacing.normal),

                          // Champ du numéro de téléphone
                          TextFormField(
                            controller: phoneNumberController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.phone),
                              hintText: "Numéro de téléphone",
                            ),
                            validator: (phonenumber) {
                              return phonenumber != null &&
                                      !isValidPhoneNumber(phonenumber)
                                  ? "Numéro de téléphone invalide"
                                  : null;
                            },
                          ),

                          SizedBox(height: InstaSpacing.normal),

                          // Champ du mot de passe
                          TextFormField(
                            controller: passwordController,
                            obscureText: obscuretext,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.next,
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
                            textInputAction: TextInputAction.done,
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
                                      disabledForegroundColor:
                                          InstaColors.primary.withOpacity(0.38),
                                      disabledBackgroundColor: InstaColors
                                          .primary
                                          .withOpacity(0.12)),
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
    bool isValid = isValidPhoneNumber(phoneNumberController.text) &&
        passwordController.text.length >= 8 &&
        confirmPasswordController.text.length >= 8;
    debugPrint("Etat boutton connexion : $isValid");
    // Retourne true si le mail et le mot de passe respecte les conditions et non sinon
    return isValid;
  }

  bool isValidPhoneNumber(String phonenumber) {
    RegExp regExp = RegExp(r'(^(?:[+0]9)?[0-9]{10}$)');
    return regExp.hasMatch(phonenumber);
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

  // Inscription de l'utilisateur
  signUp() async {
    debugPrint("Exécution de la fonction d'inscription ...");

    if (passwordController.text == confirmPasswordController.text) {
      try {
        debugPrint(
            "[_] Inscrition de l'utilisateur ${phoneNumberController.text}");
        // Requete vers l'API pour l'inscription de l'utilisateur
        Response response = await post(Uri.parse(Api.signup),
            body: jsonEncode(<String, String>{
              "first_name": firstNameController.text,
              "last_name": lastNameController.text,
              "phone_number": phoneNumberController.text,
              "password": passwordController.text
            }),
            headers: {
              "Content-Type": "application/json",
              "Authorization":
                  "Api-Key RvUJpQNZ.YI8sE7iqoCR42Sw4MPjP3FGCiuoCu7Tt"
            });

        debugPrint("  --> Code de la reponse : [${response.statusCode}]");
        debugPrint("  --> Contenue de la reponse : ${response.body}");

        setState(() {
          loading = false;
        });

        if (response.statusCode == 201) {
          debugPrint("[OK] Inscription éffectué avec succès");

          // Efface les information dans les différents champ
          phoneNumberController.clear();
          firstNameController.clear();
          passwordController.clear();
          confirmPasswordController.clear();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const Login()),
              (route) => true);
        } else {
          var result = jsonDecode(response.body.toString());
          debugPrint("[X] ${result["detail"]}");

          showInformation(context, false, "Ce compte existe déjà");
        }
      } catch (e) {
        debugPrint("[X] Une erreur est survenue  \n $e");
        setState(() {
          loading = false;
        });
        showInformation(context, false, "Une erreur est survenue");
      }
    } else {
      showInformation(context, false, "Mots de passe différents");
      setState(() {
        loading = false;
      });
    }
  }
}
