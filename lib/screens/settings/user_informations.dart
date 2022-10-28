// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:convert';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../errors/invalid_token.dart';
import './../../components/constants.dart';
import '../../components/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInformationProfile extends StatefulWidget {
  const UserInformationProfile({Key? key}) : super(key: key);

  @override
  State<UserInformationProfile> createState() => _UserInformationProfileState();
}

class _UserInformationProfileState extends State<UserInformationProfile> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phonenumberConroller = TextEditingController();

  Map<String, dynamic> userInformation = {};
  Map<String, dynamic> tokens = {};

  bool submit = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    getUserInformation();

    usernameController
        .addListener(() => setState(() => submit = validateForm()));

    emailController.addListener(() => setState(() => submit = validateForm()));

    phonenumberConroller
        .addListener(() => setState(() => submit = validateForm()));
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    phonenumberConroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: InstaSpacing.medium),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            children: [
              const SizedBox(
                height: kToolbarHeight,
              ),
              // Titre de page
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Informations personnelles",
                    style: TextStyle(
                      color: InstaColors.boldText,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 0.9,
                    ),
                  ),
                ],
              ),

              // Espacement
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
                  // Fonrmulaire informations personnelles
                  Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      children: [
                        // Champ de nom d'utilisateur
                        TextFormField(
                          controller: usernameController,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person),
                            hintText: userInformation['full_name'] != null
                                ? userInformation['full_name'].toString()
                                : "",
                          ),
                          validator: (username) {
                            return username != null &&
                                    username.isNotEmpty &&
                                    username.length < 5
                                ? "Nom d'utilisateur trop court"
                                : null;
                          },
                        ),

                        // Espacement
                        SizedBox(height: InstaSpacing.normal),

                        // Champ de de l'email
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.alternate_email),
                            hintText: userInformation['email'] != null
                                ? userInformation['email'].toString()
                                : "",
                          ),
                          validator: (email) {
                            return email != null &&
                                    email.isNotEmpty &&
                                    !EmailValidator.validate(email)
                                ? "Adresse mail invalide"
                                : null;
                          },
                        ),

                        // Espacement
                        SizedBox(height: InstaSpacing.normal),

                        // Champ du numéro de téléphone
                        TextFormField(
                          controller: phonenumberConroller,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.numbers),
                            hintText: userInformation['phone_number'] != null
                                ? userInformation['phone_number'].toString()
                                : "Aucun contact enregistré",
                          ),
                          validator: (phonenumber) {
                            return phonenumber != null &&
                                    phonenumber.isNotEmpty &&
                                    phonenumber.length != 10
                                ? "Numéro de téléphone incorrect"
                                : null;
                          },
                        ),

                        // Espacement
                        SizedBox(height: InstaSpacing.big),

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
                                        final isValidForm = validateForm();
                                        if (isValidForm) {
                                          debugPrint("Formulaire valide ... ");
                                          setState(() => loading = true);
                                          saveUserInformation();
                                        } else {
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
      ),
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        "Informations",
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

  getUserInformation() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      tokens = jsonDecode(pref.getString("tokens")!);
    });
    try {
      Response response = await get(Uri.parse(Api.userInformations), headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer ${tokens['access']}"
      });
      var message = jsonDecode(response.body);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        setState(() {
          userInformation = jsonData;
        });
        debugPrint("result = $userInformation");
      } else if (response.statusCode == 401 &&
          message["code"] == "token_not_valid" &&
          message["messages"][0]["token_type"] == "access") {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const InvalidTokenScreen()),
            (route) => false);
      }
    } catch (e) {
      debugPrint(e.toString());
      showInformation(context, false, "vous netes pas connecté à internet");
    }
    debugPrint(
        "je suis à la fin de la fonction getUserInformation : $userInformation");
  }

  saveUserInformation() async {
    try {
      Response response = await put(Uri.parse(Api.changeUserInformations),
          body: jsonEncode(<String, dynamic>{
            "full_name": usernameController.text,
            "email": emailController.text,
            "phone_number": phonenumberConroller.text
          }),
          headers: {
            "Content-type": "application/json",
            "Authorization": "Bearer ${tokens['access']}"
          });

      debugPrint("le code de la reponnse : ${response.statusCode}");
      debugPrint("le contenu de la reponse : ${response.body}");

      setState(() => loading = false);
      if (response.statusCode == 200) {
        usernameController.clear();
        emailController.clear();
        phonenumberConroller.clear();
        showInformation(context, true, "Modification des informations reussie");
      } else {
        showInformation(
            context, true, "Echec lors de la modification des informations");
      }
    } catch (e) {
      setState(() => loading = false);
      debugPrint("une erreur est survenue : ${e.toString()}");
      showInformation(context, false, "Verifiez votre connexion internet");
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
    bool isValid = usernameController.text.length >= 5 ||
        EmailValidator.validate(emailController.text) ||
        phonenumberConroller.text.length == 10;
    // Retourne true si le mail et le mot de passe respecte les conditions et non sinon
    return isValid;
  }
}
