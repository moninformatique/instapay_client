// Packages Flutter
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/constants.dart';
import 'screens/login/login.dart';
import 'screens/authentication/authentication.dart';

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

  if (userEmail != null && tokens != null) {
    // Les données ne sont pas nulles,  Un utilisateur connecté existe
    debugPrint("[$userEmail est déjà connecté]");
    sharedText = userEmail;

    var token = jsonDecode(tokens)["access"];

    debugPrint("Obtention des informations de l'utilisateur  ");

    try {
      Response response = await get(Uri.parse(Api.userInformations),
          headers: <String, String>{"Authorization": "Bearer $token"});

      debugPrint("  --> Envoie de la requete d'obtention des informations");
      debugPrint("  --> Code de la reponse : [${response.statusCode}]");
      debugPrint("  --> Contenue de la reponse : ${response.body}");
      var error = jsonDecode(response.body);
      if (response.statusCode == 200) {
        debugPrint("[OK] vérification reussie avec succès");
        routeName = PageRoutes.authentication;
      } else if (response.statusCode == 401 &&
          error["code"] == "token_not_valid" &&
          error["messages"][0]["token_type"] == "access") {
        debugPrint("Token expiré");
        await pref.clear();
      } else {
        debugPrint("[X] Vérification échoué : HTTP ${response.statusCode}");
      }
    } catch (e) {
      routeName = PageRoutes.authentication;
      debugPrint("[X] Une erreur est survenue : \n $e");
      // Network is unreachable
    }
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
              backgroundColor: InstaColors.primary,
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
          if (settings.name == PageRoutes.authentication &&
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
      routes: {
        //define routes in this map
        '/login/': (context) => const Login(),
        '/authentication/': (context) => Authentication(
              userEmail: widget.initData!.sharedText,
            ),
      },
    );
  }
}
