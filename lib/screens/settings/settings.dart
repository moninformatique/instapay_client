// ignore_for_file: file_names, avoid_unnecessary_containers, camel_case_types, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../errors/invalid_token.dart';
import '../login/login.dart';
import 'change_password.dart';
import 'generate_transaction_code.dart';
import 'register_payment_way.dart';
import 'user_informations.dart';
import '../../components/constants.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TextEditingController codeController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  Map<String, dynamic> userInformation = {};
  Map<String, dynamic> userAccountsInfo = {};
  Map<String, dynamic> tokens = {};
  int hasTransactionProtection = 1;
  int hasDoubleAuthentication = 1;
  bool loadingLogout = false;

  @override
  void initState() {
    super.initState();
    getUserInformation();
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: InstaSpacing.normal),
        child: SingleChildScrollView(
          child: Column(children: [
            const SizedBox(
              height: kToolbarHeight,
            ),
            // Titre de la page Paramètres
            Text(
              "Paramètres",
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: InstaColors.boldText),
            ),
            const SizedBox(
              height: 40,
            ),

            // Rubrique mon compte
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: InstaColors.primary,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "Mon compte",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: InstaColors.boldText),
                )
              ],
            ),
            const Divider(
              height: 15,
              thickness: 2,
            ),
            const SizedBox(
              height: 10,
            ),

            // Voir les informaions du compte
            optionWidget(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UserInformationProfile()));
              },
              data: "Informations sur mon compte",
            ),
            const SizedBox(
              height: 10,
            ),
            // Changer de mot depasse
            optionWidget(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const UserProfil()));
              },
              data: "Changer de mot de passe",
            ),
            const SizedBox(
              height: 10,
            ),
            // ajouter un moyen de paiement
            optionWidget(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PaymentWay()));
              },
              data: "Ajouter un moyen de paiement",
            ),
            const SizedBox(
              height: 10,
            ),
            // Générer un code de transaction
            optionWidget(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GenerateTransactionCode(
                              token: tokens['access'],
                            )));
              },
              data: "Générer un code de transaction",
            ),

            const SizedBox(
              height: 10,
            ),

            // Rubrique option de sécurité
            Row(
              children: [
                Icon(
                  Icons.security_rounded,
                  color: InstaColors.primary,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "Sécurité",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: InstaColors.boldText),
                )
              ],
            ),
            const Divider(
              height: 15,
              thickness: 2,
            ),

            // Code de protection de transactions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Code de transaction",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 120, 119, 119)),
                ),
                ToggleSwitch(
                  minWidth: size.width * 0.13,
                  minHeight: 25,
                  cornerRadius: 10,
                  activeBgColor: [InstaColors.boldText],
                  activeFgColor: Colors.white,
                  inactiveBgColor: InstaColors.lightPrimary,
                  inactiveFgColor: InstaColors.boldText,
                  totalSwitches: 2,
                  labels: const ['On', 'Off'],
                  initialLabelIndex: hasTransactionProtection,
                  onToggle: (index) async {
                    // index = 0 : On souhaite activer la protection
                    if (index != null) {
                      switch (index) {
                        case 1: // On souhaite désactiver
                          if (hasTransactionProtection != index) {
                            // pas encore désactivé : on désactive
                            disableTransactionProtection(index);
                          }

                          break;
                        case 0: // On souhaite activé
                          if (hasTransactionProtection != index) {
                            // Pas encore activé : on active
                            await showDialog(
                                context: context,
                                builder: ((context) {
                                  return AlertDialog(
                                    // Contenu du dialog
                                    content: Form(
                                        key: formKey,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            TextFormField(
                                              controller: codeController,
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: [
                                                LengthLimitingTextInputFormatter(
                                                    4),
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              validator: (value) {
                                                return value != null &&
                                                        value.length != 4
                                                    ? "Le code doit être de 4 chiffres"
                                                    : null;
                                              },
                                              decoration: const InputDecoration(
                                                  prefixIcon: Icon(Icons.pin),
                                                  hintText: "Code de sécurité"),
                                            )
                                          ],
                                        )),
                                    actions: [
                                      // boutton submit
                                      TextButton(
                                          onPressed: () {
                                            debugPrint(
                                                "Le code saisi est : ${codeController.text}");
                                            debugPrint(
                                                "L'index est (On : 0 / Off : 1) : $index");

                                            final isValidForm = formKey
                                                .currentState!
                                                .validate();
                                            if (isValidForm) {
                                              enableTransactionProtection(
                                                  index);
                                            } else {
                                              codeController.clear();
                                              setState(() {
                                                hasTransactionProtection = 1;
                                              });
                                              showInformation(context, false,
                                                  "Aucun changement n'a été éffectué");
                                            }
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            "Valider",
                                            style: TextStyle(
                                                color: InstaColors.primary,
                                                fontWeight: FontWeight.bold),
                                          ))
                                    ],
                                  );
                                }));
                          }
                          break;
                        default:
                          break;
                      }
                    }
                  },
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),

            // Boutton Double authentification
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Double authentification",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color.fromARGB(255, 120, 119, 119)),
                ),
                ToggleSwitch(
                  minWidth: size.width * 0.13,
                  minHeight: 25,
                  cornerRadius: 10,
                  activeBgColor: [InstaColors.boldText],
                  activeFgColor: Colors.white,
                  inactiveBgColor: InstaColors.lightPrimary,
                  inactiveFgColor: InstaColors.boldText,
                  initialLabelIndex: hasDoubleAuthentication,
                  totalSwitches: 2,
                  labels: const ['On', 'Off'],
                  onToggle: (index) async {
                    //userInformation['double_authentication']
                    if (index != null) {
                      switch (index) {
                        case 1: // on souhaite désactivé
                          if (hasDoubleAuthentication != index) {
                            // pas encode désactivé : on désactive
                            // Pas encore ctivé : On active
                            await showDialog(
                                context: context,
                                builder: ((context) {
                                  return AlertDialog(
                                    // Contenu du dialog
                                    content: const Text(
                                      "Voulez-vous vraiment désactiver la double authentification. Après desactivation, vous serez déconnecté automatiquement.",
                                    ),
                                    actions: [
                                      // boutton submit
                                      TextButton(
                                          onPressed: () {
                                            debugPrint(
                                                "L'index est (On : 0 / Off : 1) : $index");

                                            disableDoubleAuthentication(index);

                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            "Désactiver",
                                            style: TextStyle(
                                                color: InstaColors.primary,
                                                fontWeight: FontWeight.bold),
                                          ))
                                    ],
                                  );
                                }));
                          }
                          break;
                        case 0: // On souhaite activé
                          if (hasDoubleAuthentication != index) {
                            // Pas encore ctivé : On active
                            await showDialog(
                                context: context,
                                builder: ((context) {
                                  return AlertDialog(
                                    // Contenu du dialog
                                    content: const Text(
                                      "Vous etes sur le point d'activer la double authentification pour la protection de votre connexion. Après activation, vous serez déconnecté automatiquement.",
                                    ),
                                    actions: [
                                      // boutton submit
                                      TextButton(
                                          onPressed: () {
                                            debugPrint(
                                                "L'index est (On : 0 / Off : 1) : $index");

                                            enableDoubleAuthentication(index);

                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            "Activer",
                                            style: TextStyle(
                                                color: InstaColors.primary,
                                                fontWeight: FontWeight.bold),
                                          ))
                                    ],
                                  );
                                }));
                          }
                          break;
                        default:
                      }
                    }
                  },
                )
              ],
            ),

            const Divider(
              height: 15,
              thickness: 2,
            ),
            SizedBox(
              height: InstaSpacing.large,
            ),

            // Boutton de déconnexion
            loadingLogout
                ? Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: InstaSpacing.normal),
                    child: CircularProgressIndicator(
                      backgroundColor: InstaColors.primary,
                      color: Colors.grey.shade400,
                    ),
                  )
                : Center(
                    child: OutlinedButton(
                      onPressed: () async {
                        await logout();
                      },
                      child: const Text(
                        "Se déconnecté",
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                            color: Colors.red),
                      ),
                    ),
                  ),
          ]),
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

      var error = jsonDecode(response.body);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        setState(() {
          userInformation = jsonData;
          hasTransactionProtection =
              userInformation['transaction_protection'] ? 0 : 1;
          hasDoubleAuthentication =
              userInformation['double_authentication'] ? 0 : 1;
        });
        debugPrint("result = $userInformation");
      } else if (response.statusCode == 401 &&
          error["code"] == "token_not_valid" &&
          error["messages"][0]["token_type"] == "access") {
        debugPrint("Token expiré");
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const InvalidTokenScreen()),
            (route) => false);
      }
    } catch (e) {
      debugPrint(e.toString());
      showInformation(context, false, "Vous n'etes pas connecté à internet");
    }
    debugPrint(
        "je suis à la fin de la fonction getUserInformation : $userInformation");
  }

  enableDoubleAuthentication(int index) async {
    try {
      Response response = await patch(Uri.parse(Api.activeDoubleAuthentication),
          body: jsonEncode(<String, dynamic>{"double_authentication": true}),
          headers: {
            "Content-type": "application/json",
            "Authorization": "Bearer ${tokens['access']}"
          });
      if (response.statusCode == 200) {
        setState(() {
          debugPrint("je suis dans le setState");
          hasDoubleAuthentication = index;
        });
        showInformation(context, true, "Double authentification activé");

        logout();
      } else {
        debugPrint("echec de la requtes code = ${response.statusCode}");
        showInformation(context, false,
            "Échec de l'activation de la double authentification");
      }
    } catch (e) {
      debugPrint("une erreur est survenue : ${e.toString()}");
      showInformation(context, false, "Vérifiez votre connexion internet");
    }
  }

  disableDoubleAuthentication(int index) async {
    try {
      Response response = await patch(
          Uri.parse(Api.desactiveDoubleAuthentication),
          body: jsonEncode(<String, dynamic>{"double_authentication": false}),
          headers: {
            "Content-type": "application/json",
            "Authorization": "Bearer ${tokens['access']}"
          });
      if (response.statusCode == 200) {
        setState(() {
          debugPrint("je suis dans le setState");
          hasDoubleAuthentication = index;
        });
        showInformation(context, true, "Double authentification désactivé");
      } else {
        debugPrint("echec de la requtes code = ${response.statusCode}");
        showInformation(context, false,
            "Échec de la désctivation de la double authentification");
      }
    } catch (e) {
      debugPrint("une erreur est survenue : ${e.toString()}");
      showInformation(context, false, "Verifier votre connexion internet");
    }
  }

  enableTransactionProtection(int index) async {
    try {
      Response response = await patch(
          Uri.parse(Api.activeTransactionProtection),
          body: jsonEncode(<String, dynamic>{
            "transaction_protection_code": codeController.text
          }),
          headers: {
            "Content-type": "application/json",
            "Authorization": "Bearer ${tokens['access']}"
          });

      debugPrint("le code de la reponse : ${response.statusCode}");
      debugPrint("le contenu de la reponse : ${response.body}");

      if (response.statusCode == 200) {
        codeController.clear();
        debugPrint("les options de sécurité ont été activé");
        setState(() {
          hasTransactionProtection = index;
        });
        showInformation(context, true, "Code de transactions activé");
      } else {
        debugPrint("erreur : ${response.statusCode}");
        showInformation(context, false, "une erreur s'est produite");
      }
    } catch (e) {
      debugPrint("une erreur est survenu : ${e.toString()}");
      showInformation(context, false, "Vérifiez votre connexion internet");
    }
  }

  disableTransactionProtection(int index) async {
    try {
      Response response = await patch(
          Uri.parse(Api.desactiveTransactionProtection),
          body:
              jsonEncode(<String, dynamic>{"transaction_protection_code": ""}),
          headers: {
            "Content-type": "application/json",
            "Authorization": "Bearer ${tokens['access']}"
          });

      debugPrint("le code de la reponse : ${response.statusCode}");
      debugPrint("le contenu de la reponse : ${response.body}");

      if (response.statusCode == 200) {
        debugPrint("les options de sécurité ont été désactivé");
        setState(() {
          hasTransactionProtection = index;
        });
        showInformation(context, true, "Code de transactions désactivé");
      } else {
        debugPrint("erreur : ${response.statusCode}");
        showInformation(context, false, "Une erreur s'est produite");
      }
    } catch (e) {
      debugPrint("une erreur est survenu : ${e.toString()}");
      showInformation(context, false, "Verifiez votre connexion internet");
    }
  }

  // Fonction de décconexion de l'utilisateur connecté
  Future<void> logout() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() => loadingLogout = true);

    debugPrint(
        "[_] Déconnexon de l'utilisateur avec les tokens ... ${tokens["access"]} ");

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
      var error = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await pref.clear();
        debugPrint("[OK] Déconnexion reussie");
        setState(() => loadingLogout = false);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
            (route) => false);
      } else if (response.statusCode == 401 &&
          error["code"] == "token_not_valid" &&
          error["messages"][0]["token_type"] == "access") {
        debugPrint("[X] Déconnexion échouée : Token expiré");
        await pref.clear();
        setState(() => loadingLogout = false);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Login()),
            (route) => false);
      } else {
        debugPrint("[X] Déconnexion échouée");
        setState(() => loadingLogout = false);
        openDialog(false, "Déconnexion échouée", "Erreur inconnue");
      }
    } catch (e) {
      debugPrint("[X] Déconnexion échouée");
      debugPrint(e.toString());
      setState(() => loadingLogout = false);
      openDialog(
          false, "Déconnexion échouée", "Vérifiez votre connexion internet");
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

  // Afficher un message
  Future openDialog(bool status, String title, String message) => showDialog(
      context: context,
      builder: ((context) => AlertDialog(
            // ignore: sized_box_for_whitespace
            content: Container(
              height: 180,
              child: Column(
                children: [
                  Icon(
                    status ? Icons.check_circle : Icons.error,
                    color: status ? InstaColors.success : InstaColors.error,
                    size: 90,
                  ),
                  SizedBox(
                    height: InstaSpacing.normal,
                  ),
                  Text(
                    title,
                    style: TextStyle(
                        color: InstaColors.boldText,
                        fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          )));
}

class optionWidget extends StatelessWidget {
  final Function onTap;
  final String data;
  const optionWidget({Key? key, required this.onTap, required this.data})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            data,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: Colors.grey,
          )
        ],
      ),
    );
  }
}
