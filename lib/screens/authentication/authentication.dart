// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../login/login.dart';
import '../loading/loading.dart';
import 'components/top_welcome_screen.dart';
import '../../components/constants.dart';

// Etat de la compatibilité de l'appareil vis à vis des moyens d'authentifications local
enum _SupportState {
  unknown,
  supported,
  unsupported,
}

class Authentication extends StatefulWidget {
  final String userEmail;
  const Authentication({super.key, required this.userEmail});

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  LocalAuthentication auth = LocalAuthentication();
  _SupportState _supportState = _SupportState.unknown;

  List<BiometricType>? availableBiometrics;
  bool? _canCheckBiometrics;
  bool authorized = false;
  bool isAuthenticating = false;
  bool loadingLogout = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    if (_canCheckBiometrics == true) _getAvailableBiometrics();
    // verifie si l'appareil supporte les moyens d'authentification local
    auth.isDeviceSupported().then(
          (bool isSupported) => setState(() => _supportState = isSupported
              ? _SupportState.supported
              : _SupportState.unsupported),
        );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(InstaSpacing.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Espacememnt en haut de page
              SizedBox(
                height: InstaSpacing.large,
              ),

              // Partie supérieur de la page
              TopWelcomeScreen(
                userEmail: widget.userEmail,
                userImage: logoPath,
                userMessage: "Bon retour",
              ),

              !loadingLogout
                  ?
                  // Boutton de déconnexion
                  SizedBox(
                      width: 180,
                      child: TextButton(
                        onPressed: () => logout(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.logout,
                              color: Colors.red,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "Se déconecter",
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.only(top: InstaSpacing.normal),
                      child: CircularProgressIndicator(
                        backgroundColor: InstaColors.primary,
                        color: Colors.grey.shade400,
                      ),
                    ),

              const Spacer(),

              if (_supportState == _SupportState.supported && isAuthenticating)
                // Bouttonn d'arret du processus d'authentification
                ElevatedButton(
                  onPressed: cancelAuthentication,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const <Widget>[
                      Text("STOPER L'AUTHENTIFICATION"),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(Icons.cancel_outlined),
                    ],
                  ),
                )
              else if (_supportState == _SupportState.supported &&
                  !isAuthenticating)
                // Boutton d'authentificaiton
                ElevatedButton(
                  onPressed: () => authenticate(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const <Widget>[
                      Text("S'AUTHENTIFIER"),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(Icons.perm_device_information_outlined),
                    ],
                  ),
                )
              else
                // Boutton pour continuer sans authentification
                Column(
                  children: [
                    const Text(
                      "Aucun moyen d'authentification supporté",
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Loading()),
                            (route) => false);
                      },
                      child: const Text("CONTINUER QUAND MEME"),
                    )
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Recherche des moyens d'authentification local
  Future<void> _checkBiometrics() async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      debugPrint(e.toString());
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
      debugPrint("Can check biometrics : $_canCheckBiometrics ");
    });
  }

  // Obtenir les moyens d'authentification biométrique disponible
  Future<void> _getAvailableBiometrics() async {
    late List<BiometricType> availableBiometricsList;
    try {
      availableBiometricsList = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      availableBiometricsList = <BiometricType>[];
      debugPrint(e.toString());
    }
    if (!mounted) {
      return;
    }

    setState(() {
      availableBiometrics = availableBiometricsList;
    });
  }

  // Exécuter le processus d'authentiification
  Future<void> authenticate() async {
    bool authenticated = false;
    try {
      setState(() => isAuthenticating = true);

      authenticated = await auth.authenticate(
        localizedReason: 'Confirmez votre identité',
        options: const AuthenticationOptions(),
      );
      debugPrint("Etat Authenticated : $authenticated ");

      setState(() => isAuthenticating = false);
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      setState(() => isAuthenticating = false);
      return;
    }
    if (!mounted) {
      return;
    }
    if (authenticated) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Loading()),
          (route) => true);
    }
  }

  // Arreter le processus d'authentification
  Future<void> cancelAuthentication() async {
    await auth.stopAuthentication();
    setState(() => isAuthenticating = false);
  }

  // Fonction de décconexion de l'utilisateur connecté
  Future<void> logout() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? userTokens = pref.getString("tokens");

    if (userTokens != null) {
      setState(() => loadingLogout = true);
      var tokens = jsonDecode(userTokens);

      debugPrint(
          "[_] Déconnexon de l'utilisateur avec les tokens ... $tokens ");

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
    } else {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false);
    }
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
