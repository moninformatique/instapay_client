import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/constants.dart';

class PaymentWay extends StatefulWidget {
  const PaymentWay({Key? key}) : super(key: key);

  @override
  State<PaymentWay> createState() => _PaymentWayState();
}

class _PaymentWayState extends State<PaymentWay> {
  final _formKey = GlobalKey<FormState>();
  Map<String, dynamic> tokens = {};
  late TextEditingController _phoneController;

  bool isSubmitEnable = false;

  String providerTxt = "";
  String providerName = "";
  Color textColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _phoneController.addListener(() {
      String phonenumber = _phoneController.text;
      if (phonenumber.length > 3) {
        setState(() {
          debugPrint("Taille numero : ${phonenumber.length}");
          debugPrint("Indicatif: ${phonenumber.substring(0, 3)}");
          debugPrint("Provider : $providerTxt");
          if (phonenumber.length == 13 &&
              phonenumber.substring(0, 3) == "225" &&
              providerTxt != "") {
            isSubmitEnable = true;
            debugPrint("phoneController ok : $isSubmitEnable");
          } else {
            isSubmitEnable = false;
            debugPrint("phoneController pas ok : $isSubmitEnable");
          }
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _phoneController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: InstaSpacing.normal),
          child: Column(
            children: [
              const SizedBox(
                height: kToolbarHeight,
              ),
              // image des providers
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  mobileMoneyChoice(
                      "MTN", const AssetImage("assets/images/mtn.jpeg")),
                  SizedBox(
                    width: InstaSpacing.medium,
                  ),
                  mobileMoneyChoice(
                      "MOOV", const AssetImage("assets/images/moov.png")),
                  SizedBox(
                    width: InstaSpacing.medium,
                  ),
                  mobileMoneyChoice(
                      "ORANGE", const AssetImage("assets/images/orange.png")),
                  SizedBox(
                    width: InstaSpacing.normal,
                  ),
                  /*mobileMoneyChoice(
                                "UBA", const AssetImage("assets/images/uba.png")),*/
                ],
              ),
              SizedBox(
                height: InstaSpacing.large,
              ),
              Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.always,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        // Champ du numéro de téléphone
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.numbers_outlined),
                            hintText: "(CIV) 2250701020304",
                          ),
                          validator: (number) {
                            if (number == null ||
                                number.length != 13 ||
                                number.substring(0, 3) != "225") {
                              debugPrint(number);
                              return "Numéro invalide";
                            } else {
                              if (providerTxt == "") {
                                return "Choisissez un provider";
                              } else {
                                return null;
                              }
                            }
                          },
                        ),
                        SizedBox(
                          height: InstaSpacing.normal,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              onSurface: InstaColors.primary),
                          onPressed: (isSubmitEnable)
                              ? () {
                                  final isValidForm =
                                      _formKey.currentState!.validate();

                                  if (isValidForm) {
                                    registerPaymentWay();
                                  }
                                }
                              : null,
                          child: Text("Ajouter".toUpperCase()),
                        ),
                        SizedBox(
                          height: InstaSpacing.normal,
                        ),
                        Text(
                          providerTxt,
                          style: TextStyle(color: textColor),
                        ),
                      ],
                    ),
                  )),
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
        "Moyen de paiement",
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

  Widget mobileMoneyChoice(String provider, AssetImage img) {
    return GestureDetector(
      onTap: () {
        setState(() {
          provider = provider;
          providerTxt = "vous avez selectionné $provider";
          providerName = provider;
          isSubmitEnable = (_phoneController.text.length == 13 &&
              _phoneController.text.substring(0, 3) == "225");
          debugPrint("MobileMoney ok : $isSubmitEnable");
        });
      },
      child: CircleAvatar(
        backgroundImage: img,
      ),
    );
  }

  Future openDialog(String message, bool status) => showDialog(
      context: context,
      builder: ((context) => AlertDialog(
            content: SizedBox(
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

  // Enregistrement d'un moyen de paiement
  registerPaymentWay() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      setState(() {
        tokens = jsonDecode(pref.getString("tokens")!);
      });
      debugPrint(" --> tokens : ${tokens['access']}");
      Response response = await post(Uri.parse(Api.addPaymentMethod),
          headers: {
            "Authorization": "Bearer ${tokens['access']}",
            "Content-type": "application/json",
          },
          body: jsonEncode(<String, String>{
            "provider": providerName,
            "phone_number": _phoneController.text
          }));

      debugPrint("  --> le code de la reponse est : [${response.statusCode}]");
      debugPrint("  --> le contenu de la reponse est : [${response.body}]");

      if (response.statusCode == 200) {
        debugPrint("enregistrement du moyen de paiement éffectué");
        openDialog("Enregistremment éffectué", true);
      } else {
        debugPrint("l'enregistrement à échoué");
        openDialog("Enregistrement échoué", false);
      }
    } catch (e) {
      debugPrint("@@@@@@@@@@@@@ une exception est survenue");
    }
  }
}
