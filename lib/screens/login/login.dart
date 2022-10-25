// Packages Flutter et Dart puis ceux propres à l'application
import 'package:flutter/material.dart';

import '../../components/constants.dart';
import 'forms/login_form.dart';
import 'forms/register_form.dart';

/// Login : Widget d'organisation des formulaires de conexion et d'inscription
///         il présente le formulaire de connexion par défault et propose l'inscription
class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  bool isLogin = true;
  AnimationController? animationController;
  Duration animationDuration = const Duration(milliseconds: 270);

  // InitState : Initialisation de la page
  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: animationDuration);
  }

  // Dispose : Destruction des ressources utilisées
  @override
  void dispose() {
    animationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtention des dimensions de l'écrans
    Size size = MediaQuery.of(context).size;
    double viewInsetBottom = MediaQuery.of(context).viewInsets.bottom;

    // Calculer la hauteur du formulaire d'inscription
    double registerFormHeight = size.height - (size.height * 0.1);

    // Taille du widget Container de proposition d'inscription
    Animation<double> containerSize =
        Tween<double>(begin: size.height * 0.1, end: registerFormHeight)
            .animate(CurvedAnimation(
                parent: animationController!, curve: Curves.linear));

    return Scaffold(
      body: Stack(children: [
        // Boutons de fermeture du formulaire d'inscription pour revenir à celui de la connexion
        CancelButton(
          isLogin: isLogin,
          animationDuration: animationDuration,
          size: size,
          animationController: animationController,
          tapEvent: isLogin
              ? null // Dans le cas ou on se trouve déjà sur le formulaire de connexion
              : () {
                  animationController!.reverse();
                  setState(() {
                    isLogin = !isLogin;
                  });
                },
        ),

        // Formulaire de connexion
        LoginForm(
          isLogin: isLogin,
          animationDuration: animationDuration,
        ),

        // Animation de déroulement du formulaire d'inscription en cas de demande.
        AnimatedBuilder(
          animation: animationController!,
          builder: (context, child) {
            if (viewInsetBottom == 0 && isLogin) {
              return buildRegisterForm(containerSize.value);
            } else if (!isLogin) {
              return buildRegisterForm(containerSize.value);
            }

            // Retour d'un containeur vide donc rien
            return Container();
          },
        ),

        // Formulaire d'inscriotion
        RegisterForm(
          isLogin: isLogin,
          animationDuration: animationDuration,
          width: size.width,
          height: registerFormHeight,
        ),
      ]),
    );
  }

  // Ce widget est un conteneur qui propose l'inscription si l'on n'a pas de compte et change les conditions (isLogin)
  // pour que le formulaire d'inscription soi visible
  Widget buildRegisterForm(double containerSize) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        height: containerSize,
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(100),
              topRight: Radius.circular(100),
            ),
            color: Colors.white),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.only(top: 20),
          child: GestureDetector(
            onTap: !isLogin
                ? null // Dans le cas ou isLogin est faux donc c'est le formulaire d'inscription qui est présentement actif
                : () {
                    animationController!.forward();
                    setState(() {
                      isLogin = !isLogin;
                    });
                  },
            child: isLogin
                ? Row(
                    // Si le formulaire de connexion est actif, on propose celui de l'inscription
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          const Text(
                            "Vous n'avez pas de compte ?",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            "Inscrivez-vous",
                            style: TextStyle(
                                color: InstaColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          )
                        ],
                      ),
                    ],
                  )
                : null, // Dans le cas contraire on annule le widget
          ),
        ),
      ),
    );
  }
}

// Boutton de fermeture du formulaire d'inscription
class CancelButton extends StatelessWidget {
  final bool isLogin;
  final Size size;
  final Duration animationDuration;
  final AnimationController? animationController;
  final GestureTapCallback? tapEvent;

  const CancelButton(
      {Key? key,
      required this.isLogin,
      required this.size,
      required this.animationDuration,
      required this.animationController,
      required this.tapEvent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isLogin ? 0.0 : 1.0,
      duration: animationDuration,
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: size.width,
          height: size.height * 0.1,
          alignment: Alignment.bottomCenter,
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: tapEvent,
            color: InstaColors.primary,
          ),
        ),
      ),
    );
  }
}
