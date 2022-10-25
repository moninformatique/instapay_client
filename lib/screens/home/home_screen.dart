import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart';
import 'package:instapay_client/components/constants.dart';
import 'package:instapay_client/screens/operations/payment/payment.dart';

import '../operations/home/home.dart';
import '../settings/settings.dart';

class MyHomePage extends StatefulWidget {
  final String token;
  final String userEmail;
  const MyHomePage({super.key, required this.token, required this.userEmail});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Variable de gestion des pages de la barre de navigation du bas
  PageStorageBucket bucket = PageStorageBucket();

  double balance = 0.0;
  int selectedScreenIndex = 0;
  bool accountProtection = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      debugPrint("---------------- InitState -----------------------");
      getBalance(widget.token);
      debugPrint("---------------- InitState fin------------------");
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Liste des pages du menu
    List<Widget> screenList = [
      Home(
        token: widget.token,
        balance: balance,
        userEmail: widget.userEmail,
      ),
      const SettingsScreen(),
    ];

    return Scaffold(
      // Barre d'application en haut
      appBar: appBar(),

      // Page active
      body: PageStorage(
        bucket: bucket,
        child: screenList[selectedScreenIndex],
      ),

      // Boutton d'action destiner à charger la page pour envoyer de l'argent
      floatingActionButton: floatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Barre de navigation de bas
      bottomNavigationBar: bottomNavigationBar(),
    );
  }

  // Barre de l'application en haut
  AppBar appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,

      // Nom de l'application
      title: Text(
        "Instapay",
        style: TextStyle(
            color: InstaColors.primary,
            fontSize: 30,
            fontWeight: FontWeight.bold),
      ),

      // Fleche de retour de page deactivé
      automaticallyImplyLeading: false,
      actions: [
        // Cloche de notifications
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Row(
            children: [
              // Bouttons de notifications
              IconButton(
                onPressed: () {
                  debugPrint('Chargement de la page des notifications');
                },
                icon: Icon(
                  Icons.notifications,
                  color: InstaColors.primary,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Boutton d'action floattant
  Widget floatingActionButton() {
    return Container(
      padding: EdgeInsets.all(InstaSpacing.normal),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.all(Radius.circular(50)),
      ),
      child: FloatingActionButton(
        backgroundColor: InstaColors.primary,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Payment(
                        accoutProtection: false,
                        token: widget.token,
                      )));
        },
        child: SvgPicture.asset(
          "assets/icons/transactions-icon.svg",
          color: Colors.white,
        ),
      ),
    );
  }

  // Barre de navigation du bas
  Widget bottomNavigationBar() {
    return BottomAppBar(
      child: SizedBox(
        height: 70,
        width: MediaQuery.of(context).size.width,
        child: Row(
          //crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Boutton Accueil
            ButtonBottomBar(
                label: "Accueil",
                icon:
                    selectedScreenIndex == 0 ? Icons.home : Icons.home_outlined,
                selected: selectedScreenIndex == 0,
                onPressed: () {
                  setState(() {
                    selectedScreenIndex = 0;
                  });
                }),

            // Boutton Paramètres
            ButtonBottomBar(
                label: "Paramètres",
                icon: selectedScreenIndex == 1
                    ? Icons.settings
                    : Icons.settings_outlined,
                selected: selectedScreenIndex == 1,
                onPressed: () {
                  setState(() {
                    selectedScreenIndex = 1;
                  });
                })
          ],
        ),
      ),
    );
  }

  // obtenir le sold de l'utilisateur connecté
  getBalance(String token) async {
    debugPrint("GetBallance ......");

    debugPrint("Token de l'utilisateur $token");
    try {
      debugPrint("[_] Obtention du sole de l'utilisateur en cours");
      Response response = await get(Uri.parse(Api.userInformations),
          headers: {"Authorization": "Bearer $token"});

      debugPrint("  --> Code de la reponse : [${response.statusCode}]");
      debugPrint("  --> Contenue de la reponse : ${response.body}");

      if (response.statusCode == 200) {
        debugPrint("[OK] Obtention du sole de l'utilisateur reussi");
        var result = jsonDecode(response.body);

        setState(() {
          balance = result["balance"].round();
          accountProtection = result["transaction_protection"];
          debugPrint("la balance est : $balance");
        });
      } else {
        setState(() {
          balance = 0.0;
          debugPrint("$balance");
        });
      }
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        balance = 0.0;
        debugPrint("la balance est : $balance");
      });
    }
  }
}

// bouttons de la barre de ménu du bas
class ButtonBottomBar extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Function() onPressed;
  const ButtonBottomBar(
      {Key? key,
      required this.label,
      required this.icon,
      required this.selected,
      required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      minWidth: 40,
      onPressed: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: selected ? InstaColors.primary : Colors.grey.shade600,
            size: 30,
          ),
          Text(
            label,
            style: TextStyle(
                color: selected ? InstaColors.primary : Colors.grey,
                fontSize: 10),
          ),
        ],
      ),
    );
  }
}

// les différentes pages du menu
class Page extends StatelessWidget {
  final String title;
  const Page({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 24),
            ),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("retour"))
          ],
        ),
      ),
    );
  }
}
