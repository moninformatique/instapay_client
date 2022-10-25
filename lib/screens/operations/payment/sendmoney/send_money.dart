//Import des package Dart Flutter et ceux de l'application
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:email_validator/email_validator.dart';

import '../components/accounting.dart';
import '../../../../components/constants.dart';

// transférer de l'argent Instapay vers un autre compte
class SendMoney extends StatefulWidget {
  final double balance;
  final String receiptEmail;
  final String token;
  const SendMoney(
      {Key? key,
      required this.balance,
      required this.token,
      this.receiptEmail = ""})
      : super(key: key);

  @override
  State<SendMoney> createState() => _SendMoneyState();
}

class _SendMoneyState extends State<SendMoney> {
  // Clé du formulaire d'envoi d'argent
  final formKey = GlobalKey<FormState>();

  // Controlleur des champ du formulaire
  TextEditingController receiptAddressController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController codeController = TextEditingController();

  // Frais de la transaction :  montant à envoyer multiplier par 1%
  double transactionFees = 0.0;

  // Montant total à préléver du compte de l'utilisateur
  double amountToSend = 0.0;

  bool loading = false;
  bool submit = false;
  bool obscureText = true;
  bool accountProtection = false;

  @override
  void initState() {
    super.initState();
    getAccountProtection();

    // Dans le cas ou on accède à cette page par scann du code QR
    if (widget.receiptEmail.isNotEmpty) {
      receiptAddressController.text = widget.receiptEmail;
    }

    receiptAddressController.addListener(() {
      setState(() {
        submit = validateForm();
      });
    });

    amountController.addListener(() {
      var amount = amountController.text;

      setState(() {
        if (amount.isNotEmpty) {
          // Frais de la transaction
          transactionFees = double.parse(amount) * TransfertFees.instapay;
          amountToSend = double.parse(amount) + transactionFees;
          submit = validateForm();
        } else {
          amountToSend = 0.0;
          submit = false;
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
    return Scaffold(
      appBar: appBar(context),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: InstaSpacing.normal),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: InstaSpacing.normal,
              ),

              // Informations sur l'opérateur du transfert
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Informations sur l'opérateur du transfert
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Row(
                      children: [
                        // Logo de l'opérateur
                        Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                              color: InstaColors.background,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(50))),
                          child: Center(
                            child: Image.asset(
                              "assets/logos/4-rb.png",
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),

                        // Nom de l'opérateur
                        Text(
                          "InstaPay",
                          style: TextStyle(
                            color: InstaColors.boldText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: InstaSpacing.normal,
              ),

              // Informations sur le solde
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Votre sole : "),
                  Text(
                    "${widget.balance} Fcfa",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: InstaSpacing.normal,
              ),

              // Formulaire d'envoi d'argent
              sendMoneyForm(),
            ],
          ),
        ),
      ),
    );
  }

  // Barre d'application
  AppBar appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        "Transfert d'argent",
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

  // Formulaire d'nevoie d'argent
  Widget sendMoneyForm() {
    return SingleChildScrollView(
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            // Adresse mail du destinataire
            TextFormField(
              controller: receiptAddressController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.alternate_email),
                hintText: "Email du bénéficiaire",
              ),
              validator: (email) {
                return email != null && !EmailValidator.validate(email)
                    ? "Adresse mail invalide"
                    : null;
              },
            ),
            SizedBox(
              height: InstaSpacing.normal,
            ),

            // Montant à transférer
            TextFormField(
              controller: amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                LengthLimitingTextInputFormatter(15),
                FilteringTextInputFormatter.digitsOnly
              ],
              decoration: InputDecoration(
                filled: false,
                prefixIcon: const Icon(Icons.currency_franc),
                label: Text(
                  "Montant à envoyer",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
              validator: (amount) {
                return amount != null && amount.isNotEmpty
                    ? (amountToSend > widget.balance)
                        ? "Solde insuffisant"
                        : !(int.parse(amount) % 100 == 0)
                            ? "Doit être multiple de 100"
                            : null
                    : null;
              },
            ),
            SizedBox(
              height: InstaSpacing.normal,
            ),

            // Code de protection
            accountProtection
                ? Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: InstaSpacing.large),
                    child: TextFormField(
                      controller: codeController,
                      obscureText: obscureText,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(4),
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.pin),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              obscureText = !obscureText;
                            });
                          },
                          child: Icon(obscureText
                              ? Icons.visibility
                              : Icons.visibility_off),
                        ),
                        hintText: "Code de protection",
                      ),
                      validator: (authCode) {
                        return (authCode != null && authCode.length != 4)
                            ? "Contient 4 chiffres"
                            : null;
                      },
                    ),
                  )
                : Container(),
            SizedBox(height: InstaSpacing.medium),

            // Notes
            TextFormField(
              controller: noteController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.text_fields_outlined),
                hintText: "Note",
              ),
            ),
            SizedBox(height: InstaSpacing.big * 4),

            const Divider(),
            // Titre : Afficher  les frais de transaction
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Frais de l'opération : ",
                  style: TextStyle(fontSize: 12),
                ),
                Text("$transactionFees Fcfa",
                    style: const TextStyle(fontSize: 12)),
              ],
            ),

            // Titre : Afficher  le montant que recevra le destinataie
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Montant réçu : ",
                  style: TextStyle(
                      fontSize: 12,
                      color:
                          (submit) ? InstaColors.success : InstaColors.error),
                ),
                Text(
                    "${(amountController.text.isNotEmpty) ? double.parse(amountController.text) - transactionFees : "0.0"} Fcfa",
                    style: TextStyle(
                        fontSize: 12,
                        color: (submit)
                            ? InstaColors.success
                            : InstaColors.error)),
              ],
            ),
            const Divider(),

            SizedBox(height: InstaSpacing.normal),

            loading
                ? CircularProgressIndicator(
                    color: InstaColors.primary,
                    strokeWidth: 5,
                  )
                :
                // Boutton de connexion
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        onSurface: InstaColors.primary),
                    onPressed: (submit)
                        ? () async {
                            final isValidForm =
                                formKey.currentState!.validate();
                            if (isValidForm) {
                              setState(() {
                                loading = true;
                              });
                              debugPrint("Formulaire valide ... ");
                              sendMoney();
                            }
                          }
                        : null,
                    child: Text("Envoyer".toUpperCase())),
          ],
        ),
      ),
    );
  }

  // Obtenir l'etat de la protection du compte par un code : Activé ou Non activé ?
  getAccountProtection() async {
    debugPrint(" ############ GET ACCOUNT PROTECTION ############ ");
    try {
      Response response = await get(Uri.parse(Api.userInformations),
          headers: {"Authorization": "Bearer ${widget.token}"});

      debugPrint("  --> Code de la reponse : [${response.statusCode}]");
      debugPrint("  --> Contenue de la reponse : ${response.body}");

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);

        setState(() {
          debugPrint("Initialisation de accountProtection");
          accountProtection = result["transaction_protection"];
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Transférer de l'argent
  sendMoney() async {
    debugPrint("Transférer de l'argent vers un autre compte");

    try {
      Response response = await post(Uri.parse(Api.sendMoneyByClient),
          headers: {
            "Authorization": "Bearer ${widget.token}",
            "Content-type": "application/json"
          },
          body: jsonEncode({
            "provider": "INSTAPAY",
            "payee": receiptAddressController.text,
            "amount": amountController.text,
            "note": (noteController.text.isEmpty)
                ? "Transfert"
                : noteController.text,
            "transaction_protection_code":
                accountProtection ? codeController.text : ""
          }));

      debugPrint("  --> Code de la reponse : [${response.statusCode}]");
      debugPrint("  --> Contenue de la reponse : ${response.body}");
      setState(() {
        loading = false;
      });
      if (response.statusCode == 200) {
        debugPrint("[OK] Transfert d'argent éffectué");

        openDialog(true, "Transaction éffectué",
            " Vous venez de transférer ${double.parse(amountController.text) - transactionFees} Fcfa à ${receiptAddressController.text} par INSTAPAY.");
        clearField();
      } else {
        debugPrint("[OK] Transfert d'argent échoué");
        openDialog(false, "Transaction echouée",
            "Le compte ${receiptAddressController.text} n'existe pas.");
      }
    } catch (e) {
      debugPrint("erreur : ${e.toString()}");
      setState(() {
        loading = false;
      });
    }
  }

  // Verifie si le formulaire est valide
  bool validateForm() {
    bool isValid = EmailValidator.validate(receiptAddressController.text) &&
        amountController.text.isNotEmpty &&
        amountToSend < widget.balance &&
        (int.parse(amountController.text) % 100 == 0);
    // Retourne true
    // si le mail est valide et le champ du montant n'est pas vide
    // si le montant à transféré est un multiple de 100
    // Si le montant à transférer est inférieure au solde
    return isValid;
  }

  //Nettoyer les valeurs des champs
  clearField() {
    receiptAddressController.clear();
    amountController.clear();
    noteController.clear();
    amountToSend = 0.0;
    transactionFees = 0.0;
  }

  // Afficher un message
  Future openDialog(bool status, String title, String message) => showDialog(
      context: context,
      builder: ((context) => AlertDialog(
            // ignore: sized_box_for_whitespace
            content: Container(
              height: 300,
              child: Column(
                children: [
                  Icon(
                    status ? Icons.check_circle : Icons.error,
                    color: status ? InstaColors.success : InstaColors.error,
                    size: 90,
                  ),
                  SizedBox(
                    height: InstaSpacing.normal,
                  ),
                  Text(
                    title,
                    style: TextStyle(
                        color: InstaColors.boldText,
                        fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  Text(
                    message,
                  ),
                ],
              ),
            ),
          )));
}
