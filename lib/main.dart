// Packages Flutter
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/constants.dart';
import 'screens/login/login.dart';
import 'screens/pincode/authentication.dart';

/// InitData : Classe qui définit les paramètres dans l'initialisation de la première page
class InitData {
  // Le texte à partager avec la page suivante
  final String sharedText;
  // Le nom de la route suivante
  final String routeName;

  InitData(this.sharedText, this.routeName);
}

/// init() : Cette fonction initiaise les données de l'utilisateur s'il elles existe et choisi par conséquent la page qui doit être lancer
Future<InitData> init() async {
  String sharedText = "";
  String routeName = PageRoutes.login;

  debugPrint("[..] Recherche d'une session ");
  // Recherche de données utilisateur enregistrée dans la memoire de l'appareil
  SharedPreferences pref = await SharedPreferences.getInstance();
  String? userEmail = pref.getString("user");
  String? tokens = pref.getString("tokens");
  String? pincode = pref.getString("pincode");

  if (userEmail != null && pincode != null && tokens != null) {
    // Les données ne sont pas nulles,  Un utilisateur connecté existe
    debugPrint("[$userEmail est déjà connecté]");
    sharedText = userEmail;
    routeName = PageRoutes.pincode;
  } else {
    // Les données recupérées sont nulles, il n'existe aucun utilisateur connecté
    debugPrint("[Aucun utilisateur connecté]");
  }

  debugPrint("[OK] Recherche d'une session");
  return InitData(sharedText, routeName);
}

/// main() : Exécution de la page racine
Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  InitData initData = await init();

  runApp(MyApp(
    initData: initData,
  ));
}

/// MyApp : Widget racine de l'application
class MyApp extends StatefulWidget {
  final InitData? initData;
  const MyApp({Key? key, this.initData}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'instapay',

      // Définition du thème globale
      theme: ThemeData(
          // Couleure principale
          primaryColor: InstaColors.primary,
          //  Couleur de fond par défault des widgets Scaffold
          scaffoldBackgroundColor: InstaColors.background,
          // Police par défault des textes
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),

          // Style des buttons ElevatedButton
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              primary: InstaColors.primary,
              elevation: 0,
              //backgroundColor / primary (deprecié): ThemeColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              maximumSize: const Size(double.infinity, 56),
              minimumSize: const Size(double.infinity, 56),
            ),
          ),

          // Style des champs de formulaire
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            iconColor: Colors.grey,
            contentPadding: EdgeInsets.symmetric(
                horizontal: InstaSpacing.normal / 2,
                vertical: InstaSpacing.normal / 2),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
          )),

      // Route générée
      onGenerateRoute: (RouteSettings settings) {
        if (settings.name == PageRoutes.login) {
          return MaterialPageRoute(builder: (_) => const Login());
        } else {
          if (settings.name == PageRoutes.pincode &&
              widget.initData?.sharedText != null) {
            return MaterialPageRoute(
                builder: (_) => Authentication(
                      userEmail: widget.initData!.sharedText,
                    ));
          } else {
            return MaterialPageRoute(builder: (_) => const Login());
          }
        }
      },
      // Route initial définit dans la fonction d'initialisation
      initialRoute: widget.initData?.routeName,
    );
  }
}
