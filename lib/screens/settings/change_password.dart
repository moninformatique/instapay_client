import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/constants.dart';

class UserProfil extends StatefulWidget {
  const UserProfil({Key? key}) : super(key: key);

  @override
  State<UserProfil> createState() => _UserProfilState();
}

class _UserProfilState extends State<UserProfil> {
  Map<String, dynamic> tokens = {};

  @override
  Widget build(BuildContext context) {
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController oldPasswordController = TextEditingController();
    return Scaffold(
      appBar: appBar(context),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SizedBox(
                height: 100,
              ),
              Text(
                "Modification du mot de passe",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 0.9,
                ),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: InstaSpacing.normal * 2),
            child: TextFormField(
              controller: oldPasswordController,
              textInputAction: TextInputAction.next,
              obscureText: true,
              cursorColor: InstaColors.primary,
              decoration: InputDecoration(
                fillColor: Colors.transparent,
                hintText: "Saisisez le mode passe actuel",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: InstaColors.primary)),
                prefixIcon: Padding(
                  padding: EdgeInsets.all(InstaSpacing.normal),
                  child: const Icon(Icons.lock),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: InstaSpacing.normal,
                horizontal: InstaSpacing.normal * 2),
            child: TextFormField(
              controller: newPasswordController,
              textInputAction: TextInputAction.done,
              obscureText: true,
              cursorColor: InstaColors.primary,
              decoration: InputDecoration(
                fillColor: Colors.white70,
                hintText: "Saisisez le nouveau mot de passe",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: InstaColors.primary)),
                prefixIcon: Padding(
                  padding: EdgeInsets.all(InstaSpacing.normal),
                  child: const Icon(Icons.lock),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: InstaSpacing.normal,
                horizontal: InstaSpacing.normal * 3),
            child: ElevatedButton(
              onPressed: () async {
                debugPrint("Hashage du mot de passe");
                var encodeOldPassword = utf8.encode(oldPasswordController.text);
                var encodeNewPassword = utf8.encode(newPasswordController.text);

                String hashOldPassword =
                    sha256.convert(encodeOldPassword).toString();
                String hashNewPassword =
                    sha256.convert(encodeNewPassword).toString();
                debugPrint("Old : $hashOldPassword");
                debugPrint("new : $hashNewPassword");
                await changePassword(hashOldPassword, hashNewPassword);
              },
              child: const Text(
                "Valider",
              ),
            ),
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
    );
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        "Mot de passe",
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

  Future<void> changePassword(String oldPassword, String newPassword) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      tokens = jsonDecode(pref.getString("tokens")!);
    });
    try {
      debugPrint("Tentative de changement de mot de passe");

      Response response = await patch(
          //Uri.parse('http://164.92.134.116/api/v1/change_password/'),
          Uri.parse('${Api.domain}/users/change_password/'),
          body: jsonEncode(<String, dynamic>{
            "old_password": oldPassword,
            "new_password": newPassword
          }),
          headers: <String, String>{
            "Content-Type": "application/json",
            "Authorization": "Bearer ${tokens['access']}"
          });

      debugPrint("Code de la reponse : [${response.statusCode}]");
      debugPrint("Contenue de la reponse : ${response.body}");
      //String content = response.body.toString();
      //file.writeAsStringSync(content);

      if (response.statusCode == 200) {
        debugPrint("Le changement du mot de passe a été éffectué");
        openDialog("succès", true);
      } else {
        debugPrint("le changement de mot de passe a échoué");
        openDialog("echec", false);
      }
    } catch (e) {
      debugPrint(e.toString());
      openDialog("echec", false);
    }
  }

  Future openDialog(String message, bool status) => showDialog(
      context: context,
      builder: ((context) => AlertDialog(
            // ignore: sized_box_for_whitespace
            content: Container(
              height: 150,
              child: Column(
                children: [
                  Icon(
                    status ? Icons.check_circle : Icons.error,
                    color: status ? InstaColors.success : InstaColors.error,
                    size: 100,
                  ),
                  SizedBox(
                    height: InstaSpacing.normal,
                  ),
                  Text(message),
                ],
              ),
            ),
          )));
}
