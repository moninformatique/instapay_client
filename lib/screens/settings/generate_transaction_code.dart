// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../../components/constants.dart';

class GenerateTransactionCode extends StatefulWidget {
  final String token;
  const GenerateTransactionCode({Key? key, required this.token})
      : super(key: key);

  @override
  State<GenerateTransactionCode> createState() =>
      _GenerateTransactionCodeState();
}

class _GenerateTransactionCodeState extends State<GenerateTransactionCode> {
  String code = "*****";
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: InstaSpacing.normal),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: kToolbarHeight,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    code,
                    style: TextStyle(color: InstaColors.primary, fontSize: 30),
                  ),
                ],
              ),
              SizedBox(
                height: InstaSpacing.medium,
              ),
              !loading
                  ? Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: InstaSpacing.medium),
                      child: ElevatedButton(
                          onPressed: () => generateTransactionCode(),
                          child: const Text("GENERER UN CODE")))
                  : CircularProgressIndicator(
                      color: Colors.grey.shade400,
                      backgroundColor: InstaColors.primary,
                    ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text("Instapay, pour des transactions sécurisées"),
                ],
              ),
              const Spacer(),
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
        "Générer un code",
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

  // Générer un code de transaction
  // Une fois le code générer, on peut éffectuer un payement à partir du terminal du marchand
  // de notre compte vers on compte
  generateTransactionCode() async {
    setState(() => loading = true);
    try {
      Response response = await get(Uri.parse(Api.generateTransactionCode),
          headers: <String, String>{"Authorization": "Bearer ${widget.token}"});

      debugPrint("  --> le code de la reponse est : [${response.statusCode}]");
      debugPrint("  --> le contenu de la reponse est : [${response.body}]");
      setState(() => loading = false);
      if (response.statusCode == 200) {
        var generatedCode = jsonDecode(response.body);
        debugPrint("Génération de code reussie $generatedCode");
        setState(() => code = generatedCode["code"]);
      } else {
        debugPrint("Génération de code échouée");

        showInformation(context, false, "Impossible de générer un code");
      }
    } catch (e) {
      setState(() => loading = false);
      debugPrint(e.toString());
      showInformation(context, false, "Vérifiez votre connexion internet");
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
}
