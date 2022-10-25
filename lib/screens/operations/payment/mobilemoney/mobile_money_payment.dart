import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';


import '../../../../components/constants.dart';
import '../components/accounting.dart';

class MobileMoneyPayment extends StatefulWidget {
  final String token;
  const MobileMoneyPayment({Key? key, required this.token}) : super(key: key);

  @override
  State<MobileMoneyPayment> createState() => _MobileMoneyPaymentState();
}

class _MobileMoneyPaymentState extends State<MobileMoneyPayment> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _adresseMarchand = TextEditingController();
  final TextEditingController _amountToSend = TextEditingController();
  final TextEditingController _noteToSend = TextEditingController();
  bool accountProtection = false;
  bool addressIsValid = false;
  bool phoneNumber = false;
  bool isSubmitEnable = false;
  bool amountIsValid = false;
  String date = "";
  String providerTxt = "";
  Color c = Colors.white;
  String provider = "";
  // Frais de la transaction montant à envoyer multiplier par 1%
  double transactionFees = 0.0;
  // Montant total à préléver du compte de l'utilisateur
  double amountToSend = 0.0;
  //final TextEditingController _mobileMoneyCodePin = TextEditingController();
  @override
  void initState() {
    super.initState();
    //getAccountProtection();
    _adresseMarchand.addListener(() {
      setState(() {
        if (_adresseMarchand.text.isNotEmpty) {
          addressIsValid = true;
        } else {
          addressIsValid = false;
        }
      });
    });

    _amountToSend.addListener(() {
      setState(() {
        if (_amountToSend.text.isNotEmpty) {
          transactionFees =
              double.parse(_amountToSend.text) * TransfertFees.instapay;

          amountToSend = double.parse(_amountToSend.text) + transactionFees;
          debugPrint("${(int.parse(_amountToSend.text) % 100 == 0)}");
          debugPrint("${_adresseMarchand.text.isNotEmpty}");
          if (((int.parse(_amountToSend.text) % 100 == 0) &&
              _adresseMarchand.text.isNotEmpty &&
              provider != "")) {
            amountIsValid = true;
            isSubmitEnable = true;
          } else {
            amountIsValid = false;
            isSubmitEnable = false;
          }
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: appBar(context), body: sendByMobileMoneyForm());
  }

  AppBar appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        "Paiement par mobile money",
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

  Widget sendByMobileMoneyForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(15),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.always,
        child: Column(
          children: [
            const SizedBox(
              height: kToolbarHeight,
            ),
            SizedBox(
              height: InstaSpacing.normal,
            ),
            // l'adresse du marchand
            TextFormField(
              controller: _adresseMarchand,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.alternate_email),
                hintText: "Email du bénéficiaire",
              ),
              validator: (email) {
                if (email == null || !EmailValidator.validate(email)) {
                  return "entrer un mail valide";
                }
                addressIsValid = true;
                return null;
              },
            ),
            SizedBox(
              height: InstaSpacing.normal,
            ),
            // montant à envoyer
            TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: [
                LengthLimitingTextInputFormatter(10),
                FilteringTextInputFormatter.digitsOnly
              ],
              decoration: const InputDecoration(
                filled: false,
                prefixIcon: Icon(Icons.currency_franc),
                label: Text(
                  "Montant à envoyer",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              controller: _amountToSend,
              validator: (amount) {
                if (amount == null || amount.isEmpty) {
                  return "Cet champ est obligatoire!";
                } else if (int.parse(amount) % 10 != 0 ||
                    int.parse(amount) < 1000) {
                  return "montant invalide";
                }
                amountIsValid = true;
                return null;
              },
            ),

            SizedBox(
              height: InstaSpacing.normal,
            ),

            // petit mot d'envoie

            TextFormField(
              controller: _noteToSend,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.text_fields),
                hintText: "commentaire",
              ),
            ),

            SizedBox(
              height: InstaSpacing.normal,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /*mobileMoneyChoice(
                    "INSTAPAY", const AssetImage("assets/logos/4-rb.png")),*/
                const SizedBox(
                  width: 10,
                ),
                mobileMoneyChoice(
                    "MTN", const AssetImage("assets/images/mtn.jpeg")),
                const SizedBox(
                  width: 10,
                ),
                mobileMoneyChoice(
                    "MOOV", const AssetImage("assets/images/moov.png")),
                const SizedBox(
                  width: 10,
                ),
                mobileMoneyChoice(
                    "ORANGE", const AssetImage("assets/images/orange.png")),
                const SizedBox(
                  width: 10,
                ),
                /*mobileMoneyChoice(
                    "UBA", const AssetImage("assets/images/uba.png")),*/
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(onSurface: InstaColors.primary),
              onPressed: () {
                sendMoneyToSomeone();
              },
              child: Text("confirmer".toUpperCase()),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  providerTxt,
                  style: TextStyle(color: c),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget mobileMoneyChoice(String prov, AssetImage img) {
    return GestureDetector(
      onTap: () {
        setState(() {
          provider = prov;
          providerTxt = "vous avez selectionné $provider";
          c = Colors.grey;
        });
      },
      child: CircleAvatar(
        backgroundImage: img,
        backgroundColor: Colors.white,
      ),
    );
  }

  getAccountProtection() async {
    debugPrint(
        "################ GET ACCOUNT PROTECTION##########################");
    debugPrint(widget.token);
    try {
      Response response = await get(Uri.parse(Api.userAccount),
          headers: {"Authorization": "Bearer ${widget.token}"});

      debugPrint("  --> Code de la reponse : [${response.statusCode}]");
      debugPrint("  --> Contenue de la reponse : ${response.body}");

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);

        setState(() {
          debugPrint("Initialisation de accountProtection");
          accountProtection = result["account_protection"];
          debugPrint(
              " @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@à ACCOUNT PROTECTION $accountProtection @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    debugPrint("##########################################");
  }

  sendMoneyToSomeone() async {
    try {
      Response response = await post(Uri.parse(Api.sendMoneyByClient),
          headers: {
            "Authorization": "Bearer ${widget.token}",
            "Content-type": "application/json"
          },
          body: jsonEncode({
            "provider": provider,
            "payee": _adresseMarchand.text,
            "amount": amountToSend,
            "note": (_noteToSend.text.isEmpty) ? "transfert" : _noteToSend.text,
            "transaction_protection_code": ""
          }));

      if (response.statusCode == 200) {
        debugPrint("paiement éffectué");
        debugPrint('le contenu de la reponse : ${response.body}');
        var result = jsonDecode(response.body);
        final hasKey = result.containsKey("error");
        if (hasKey) {
          openDialog("Transaction échouée", false);
        } else {
          openDialog("Transaction éffectué", true);
        }
      } else {
        debugPrint("echec du paiement : ${response.body}");
        openDialog("Transaction echouée", false);
      }
    } catch (e) {
      debugPrint("erreur : ${e.toString()}");
    }
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
}
