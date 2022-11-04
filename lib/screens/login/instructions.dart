import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../loading/loading.dart';
import '../../components/constants.dart';

class Instructions extends StatefulWidget {
  const Instructions({Key? key}) : super(key: key);

  @override
  State<Instructions> createState() => _InstructionsState();
}

enum _SupportState {
  unknown,
  supported,
  unsupported,
}

class _InstructionsState extends State<Instructions> {
  LocalAuthentication auth = LocalAuthentication();
  List<BiometricType> availableBiometrics = [];
  _SupportState _supportState = _SupportState.unknown;
  bool? _canCheckBiometrics;

  @override
  void initState() {
    getAvailableBiometrics();

    // Verifie si l'appareil supporte les moyens d'authentification local
    auth.isDeviceSupported().then(
          (bool isSupported) => setState(() => _supportState = isSupported
              ? _SupportState.supported
              : _SupportState.unsupported),
        );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(InstaSpacing.medium),
        child: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const SizedBox(
              height: kToolbarHeight,
            ),

            // Logo
            Image.asset(
              logoPath,
              height: 90,
              width: 90,
            ),

            // Titre bienvenue
            const Text(
              "Bienvenue sur Instapay",
              style: TextStyle(fontWeight: FontWeight.w400, fontSize: 20),
            ),

            SizedBox(
              height: InstaSpacing.big,
            ),

            // Méssage

            Container(
              padding: EdgeInsets.all(InstaSpacing.normal),
              decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(30)),
              child: Column(
                children: [
                  if (_supportState == _SupportState.supported)
                    Column(
                      children: [
                        const Text(
                            "Pensez a enregistrer un des moyens de protection disponible sur votre appareil si cela n'est pas encore fait."),
                        const Divider(),
                        checkCircle("Code PIN", true),
                        checkCircle("Mot de passe", true),
                        checkCircle("Schema", true),
                      ],
                    )
                  else
                    const Text(
                        "Aucun moyen de protection locale détecté sur votre appareil. Assures vous de le garder toujours à votre porté"),
                  if (_supportState == _SupportState.supported &&
                      _canCheckBiometrics == true)
                    Column(
                      children: [
                        checkCircle("Empreinte digitale",
                            availableBiometrics.contains(BiometricType.strong)),
                        checkCircle("Reconnaissance faciale",
                            availableBiometrics.contains(BiometricType.face)),
                        checkCircle("Reconnaissance vocale", false),
                      ],
                    ),
                  const Divider(),
                  if (_supportState == _SupportState.supported)
                    const Text(
                        "Vous aurez à vous authentifier la prochaine fois que vous allez acceder à l'application."),
                  SizedBox(
                    height: InstaSpacing.normal,
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Loading()));
                      },
                      child: Text(
                        "C'est compris",
                        style: TextStyle(
                            color: InstaColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 17),
                      )),
                ],
              ),
            ),

            //const Spacer(),
          ]),
        ),
      ),
    );
  }

  // Obtenir les moyens d'authentification biométrique disponible
  Future<void> getAvailableBiometrics() async {
    late bool canCheckBiometrics;
    late List<BiometricType> availableBiometricsList;
    try {
      // Recherche des moyens d'authentification local
      canCheckBiometrics = await auth.canCheckBiometrics;
      if (canCheckBiometrics) {
        availableBiometricsList = await auth.getAvailableBiometrics();
      }
    } on PlatformException catch (e) {
      availableBiometricsList = <BiometricType>[];
      debugPrint(e.toString());
    }
    if (!mounted) {
      return;
    }

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
      if (canCheckBiometrics) {
        availableBiometrics = availableBiometricsList;
      }
    });
  }

  Widget checkCircle(String title, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.cancel_outlined,
          color: isValid ? Colors.green : Colors.red,
        ),
        const SizedBox(
          width: 5,
        ),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        )
      ],
    );
  }
}
