// ignore_for_file: use_build_context_synchronously

/*import 'package:flutter/material.dart';
import 'constants.dart';

class SettingScreen extends StatelessWidget {
  final Map<String, dynamic>? data;
  const SettingScreen({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text('PARATRÈMES'),
        leading: const Icon(Icons.settings),
        backgroundColor: InstaColors.primary,
      ),
      body: Container(
        height: size.height,
        width: double.infinity,
        child: ListView(
          children: [
            ListTile(
              title: Text("Nom : " + data!['lastname']),
              onTap: () {},
            ),
            ListTile(
              title: Text("Prenoms : " + data!['firstname']),
              onTap: () {},
            ),
            ListTile(
              title: Text("Email : " + data!['email']),
              onTap: () {},
            ),
            ListTile(
              title: Text("Numero de téléphone: " + data!['number']),
              onTap: () {},
            ),
            ListTile(
              title: Text("Numéro CNI : " + data!['cni']),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}*/
// ignore_for_file: file_names, avoid_unnecessary_containers, camel_case_types

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:toggle_switch/toggle_switch.dart';

import '../login/login.dart';
import 'change_password.dart';
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
  Map<String, dynamic> userInformation = {};
  Map<String, dynamic> userAccountsInfo = {};
  Map<String, dynamic> tokens = {};
  int? optSecured = 1;
  int? dblOAuth = 1;

  @override
  void initState() {
    super.initState();
    getUserInformation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: InstaSpacing.normal),
        child: ListView(
          children: [
            const SizedBox(
              height: kToolbarHeight,
            ),
            // Titre de la page Paramètres
            Text(
              "Paramètres",
              style: TextStyle(
                  fontSize: 24,
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
            optionWidget(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PaymentWay()));
              },
              data: "Moyens de paiement",
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

            // Code de transaction
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
                  initialLabelIndex:
                      userInformation['transaction_protection'].toString() ==
                              "true"
                          ? 0
                          : 1,
                  onToggle: (index) async {
                    await showDialog(
                        context: context,
                        builder: ((context) {
                          TextEditingController securedCode =
                              TextEditingController();
                          return AlertDialog(
                            content: Form(
                                child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextFormField(
                                  controller: securedCode,
                                  validator: (value) {
                                    return value!.isNotEmpty
                                        ? null
                                        : "remplissez le champs";
                                  },
                                  decoration: const InputDecoration(
                                      hintText: "code de sécurité"),
                                )
                              ],
                            )),
                            actions: [
                              TextButton(
                                  onPressed: () async {
                                    await securedOpt(securedCode.text, index);
                                    Navigator.pop(context);
                                  },
                                  child: const Text("valider"))
                            ],
                          );
                        }));
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
                  initialLabelIndex:
                      (userInformation['double_authentication'].toString() ==
                              "true"
                          ? 0
                          : 1),
                  totalSwitches: 2,
                  labels: const ['On', 'Off'],
                  onToggle: (index) async {
                    secondOAuthValue(index);
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
            Center(
              child: OutlinedButton(
                onPressed: () async {
                  await logout();
                },
                child: const Text(
                  "Se déconnecté",
                  style: TextStyle(
                      fontSize: 12, letterSpacing: 2.2, color: Colors.red),
                ),
              ),
            ),
          ],
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
      Response response =
          await get(Uri.parse("${Api.domain}/users/"), headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer ${tokens['access']}"
      });

      if (response.statusCode == 200) {
        String data = response.body.toString();
        var jsonData = jsonDecode(data);
        setState(() {
          userInformation = jsonData;
        });
        debugPrint("result = $userInformation");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    debugPrint(
        "je suis à la fin de la fonction getUserInformation : $userInformation");
  }

  secondOAuthValue(int? index) async {
    try {
      Response response = (index == 0
          ? await patch(Uri.parse(Api.activeDoubleAuthentication),
              body:
                  jsonEncode(<String, dynamic>{"double_authentication": true}),
              headers: {
                  "Content-type": "application/json",
                  "Authorization": "Bearer ${tokens['access']}"
                })
          : await patch(Uri.parse(Api.desactiveDoubleAuthentication),
              body:
                  jsonEncode(<String, dynamic>{"double_authentication": false}),
              headers: {
                  "Content-type": "application/json",
                  "Authorization": "Bearer ${tokens['access']}"
                }));
      if (response.statusCode == 200) {
        setState(() {
          debugPrint("je suis dans le setState");
          dblOAuth = index;
        });

        if (index == 0) {
          logout();
        }
      } else {
        debugPrint("echec de la requtes code = ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("une erreur est survenue : ${e.toString()}");
    }
    setState(() {});
  }

  securedOpt(String code, int? index) async {
    debugPrint("le code saisi est : $code");
    debugPrint("l'index est : $index");
    try {
      Response response = index == 1
          ? await patch(Uri.parse(Api.activeTransactionProtection),
              body: jsonEncode(
                  <String, dynamic>{"transaction_protection_code": code}),
              headers: {
                  "Content-type": "application/json",
                  "Authorization": "Bearer ${tokens['access']}"
                })
          : await patch(Uri.parse(Api.desactiveTransactionProtection),
              body: jsonEncode(
                  <String, dynamic>{"transaction_protection_code": code}),
              headers: {
                  "Content-type": "application/json",
                  "Authorization": "Bearer ${tokens['access']}"
                });

      debugPrint("le code de la reponse : ${response.statusCode}");
      debugPrint("le contenu de la reponse : ${response.body}");

      if (response.statusCode == 200) {
        setState(() {
          optSecured = index;
        });
        debugPrint("les options de sécurité ont été activé");
      } else {
        debugPrint("erreur : ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("une erreur est survenu : ${e.toString()}");
    }

    setState(() {});
  }

  // Déconnexion
  logout() async {
    try {
      Response response = await post(Uri.parse(Api.logout),
          body: jsonEncode(<String, dynamic>{"refresh": tokens['refresh']}),
          headers: {
            "Content-type": "application/json",
            "Authorization": "Bearer ${tokens['access']}"
          });
      debugPrint("le code de la reponse est : ${response.statusCode}");
      debugPrint("le contenu de la reponse est : ${response.body}");

      if (response.statusCode == 200) {
        SharedPreferences pref = await SharedPreferences.getInstance();
        await pref.clear();

        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (_) => const Login()), (route) => false);
      }
    } catch (e) {
      debugPrint("une erreur est survenu : ${e.toString()}");
    }
  }

  /*getAccount() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      tokens = jsonDecode(pref.getString("tokens")!);
      debugPrint("la tokens est : ${tokens}");
    });
    try {
      Response response =
          await get(Uri.parse("${Api.domain}/users/accounts/"), headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer ${tokens['access']}"
      });
      debugPrint(
          "code de la reponse pour les informations du compte : ${response.statusCode}");
      debugPrint("le contenu de la reponse : ${response.body}");

      if (response.statusCode == 200) {
        String data = response.body.toString();
        var jsonData = jsonDecode(data);
        setState(() {
          userAccountsInfo = jsonData;
        });
      }
    } catch (e) {
      debugPrint("erreur : ${e.toString()}");
    }
  }*/

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
