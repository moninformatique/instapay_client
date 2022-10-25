// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import './../../components/constants.dart';
import '../../components/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInformationProfile extends StatefulWidget {
  const UserInformationProfile({Key? key}) : super(key: key);

  @override
  State<UserInformationProfile> createState() => _UserInformationProfileState();
}

class _UserInformationProfileState extends State<UserInformationProfile> {
  Map<String, dynamic> userInformation = {};
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();
  Map<String, dynamic> tokens = {};
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

  saveUserInformation() async {
    try {
      Response response = await put(
          Uri.parse("${Api.domain}/users/edit_profile/"),
          body: jsonEncode(<String, dynamic>{
            "full_name": name.text,
            "email": email.text,
            "phone_number": phone.text
          }),
          headers: {
            "Content-type": "application/json",
            "Authorization": "Bearer ${tokens['access']}"
          });

      debugPrint("le code de la reponnse : ${response.statusCode}");
      debugPrint("le contenu de la reponse : ${response.body}");

      if (response.statusCode == 200) {
        await openDialog("succès.", true);
      } else {
        await openDialog("echec", false);
      }
    } catch (e) {
      debugPrint("une erreur est survenue : ${e.toString()}");
    }
  }

  modifyUserInformation(token) async {
    try {
      //Response response = await put(Uri.parse("${Api.domain}/users/edit_profile"))
    } catch (e) {
      debugPrint("@@@@@@@@@@@@@@ erreur dans modifiyUserInformation");
      debugPrint("this error is : $e");
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

  @override
  void initState() {
    super.initState();
    getUserInformation();
  }

  bool showPassword = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: Container(
        padding: const EdgeInsets.only(left: 16, top: 25, right: 16),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            children: [
              const Text(
                "Informations personnelles",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: 15,
              ),
              const SizedBox(
                height: 35,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: InstaSpacing.normal,
                    horizontal: InstaSpacing.normal * 2),
                child: TextFormField(
                  controller: name,
                  textInputAction: TextInputAction.done,
                  cursorColor: InstaColors.primary,
                  decoration: InputDecoration(
                    fillColor: Colors.white70,
                    hintText: userInformation['full_name'].toString() == "null"
                        ? "-"
                        : userInformation['full_name'].toString(),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: InstaColors.primary)),
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(InstaSpacing.normal),
                      child: const Icon(Icons.person),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 35,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: InstaSpacing.normal,
                    horizontal: InstaSpacing.normal * 2),
                child: TextFormField(
                  controller: email,
                  textInputAction: TextInputAction.done,
                  cursorColor: InstaColors.primary,
                  decoration: InputDecoration(
                    fillColor: Colors.white70,
                    hintText: userInformation['email'].toString() == "null"
                        ? "-"
                        : userInformation['email'].toString(),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: InstaColors.primary)),
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(InstaSpacing.normal),
                      child: const Icon(Icons.mail),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 35,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    vertical: InstaSpacing.normal,
                    horizontal: InstaSpacing.normal * 2),
                child: TextFormField(
                  controller: phone,
                  textInputAction: TextInputAction.done,
                  cursorColor: InstaColors.primary,
                  decoration: InputDecoration(
                    fillColor: Colors.white70,
                    hintText:
                        userInformation['phone_number'].toString() == "null"
                            ? "aucun contact"
                            : userInformation['phone_number'].toString(),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: InstaColors.primary)),
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(InstaSpacing.normal),
                      child: const Icon(Icons.numbers),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RaisedButton(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Retour",
                        style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 2.2,
                            color: Colors.black)),
                  ),
                  RaisedButton(
                    onPressed: () async {
                      await saveUserInformation();
                    },
                    color: InstaColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: const Text(
                      "Modifier",
                      style: TextStyle(
                          fontSize: 14,
                          letterSpacing: 2.2,
                          color: Colors.white),
                    ),
                  )
                ],
              )
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
        "Informations",
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
}
