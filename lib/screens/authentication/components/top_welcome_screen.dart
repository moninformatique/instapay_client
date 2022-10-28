import 'package:flutter/material.dart';

/// TopWelcomeScreen : Cette page décris la partie supérieur des interfaces
/// de bienvenue

class TopWelcomeScreen extends StatelessWidget {
  final String userImage;
  final String userMessage;
  final String userEmail;
  const TopWelcomeScreen(
      {Key? key,
      required this.userImage,
      required this.userMessage,
      required this.userEmail})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Logo ou Image de profile
        Image.asset(
          userImage,
          height: 90,
          width: 90,
        ),

        // Message
        Text(
          userMessage,
          style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 20),
        ),

        // Contact de l'utilisateur présentément connecté
        Text(
          userEmail,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 5,
        ),
      ],
    );
  }
}
