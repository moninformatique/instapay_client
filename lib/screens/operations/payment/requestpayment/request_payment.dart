import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:email_validator/email_validator.dart';
import 'package:http/http.dart';
import '../../../../components/constants.dart';

class RequestPayment extends StatefulWidget {
  final String token;
  const RequestPayment({
    Key? key,
    required this.token,
  }) : super(key: key);

  @override
  State<RequestPayment> createState() => _RequestPaymentState();
}

class _RequestPaymentState extends State<RequestPayment> {
  // Clé du formulaire d'envoi d'argent
  final formKey = GlobalKey<FormState>();

  // Controlleur des champ du formulaire
  TextEditingController receiptAddressController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController reasonController = TextEditingController();
  TextEditingController codeController = TextEditingController();

  // Frais de la transaction montant à envoyer multiplier par 1%
  double transactionFees = 0.0;
  // Montant total à préléver du compte de l'utilisateur
  double amountToSend = 0.0;

  bool loading = false;
  bool submit = false;
  bool obscureText = true;
  bool accountProtection = false;

  @override
  void initState() {
    getAccountProtection();

    receiptAddressController.addListener(() {
      setState(() {
        submit = validateForm();
      });
    });
    amountController.addListener(() {
      setState(() {
        submit = validateForm();
      });
    });
    reasonController.addListener(() {
      setState(() {
        submit = validateForm();
      });
    });

    super.initState();
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
              const SizedBox(
                height: kToolbarHeight,
              ),
              SizedBox(
                height: InstaSpacing.large,
              ),

              // Formulaire de requete de paiement
              requestMoneyForm(),
            ],
          ),
        ),
      ),
    );
  }

  // barre d'application
  AppBar appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Text(
        "Requête de paiement",
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

  // Formulaire de requete de paiement
  Widget requestMoneyForm() {
    return Form(
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
              hintText: "Email du destinataire",
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

          // Montant demander
          TextFormField(
            controller: amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              LengthLimitingTextInputFormatter(15),
              FilteringTextInputFormatter.digitsOnly
            ],
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.currency_franc),
              hintText: "Montant demandé",
            ),
            validator: (amount) {
              return amount != null && amount.isNotEmpty
                  ? !(int.parse(amount) % 100 == 0)
                      ? "Doit être multiple de 100"
                      : null
                  : null;
            },
          ),

          SizedBox(
            height: InstaSpacing.normal,
          ),

          // Raison de la requete
          TextFormField(
            controller: reasonController,
            minLines: 3,
            maxLines: 7,
            keyboardType: TextInputType.multiline,
            decoration: const InputDecoration(
              hintText: "Motif de votre requète",
            ),
            validator: (message) {
              return message != null && message.length < 10
                  ? "10 caractères minimun"
                  : null;
            },
          ),

          SizedBox(height: InstaSpacing.medium),
          // Code de protection
          accountProtection
              ? Padding(
                  padding: EdgeInsets.symmetric(horizontal: InstaSpacing.large),
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

          SizedBox(height: InstaSpacing.big * 4),

          SizedBox(height: InstaSpacing.normal),
          loading
              ? CircularProgressIndicator(
                  color: InstaColors.primary,
                  strokeWidth: 5,
                )
              :
              // Boutton de connexion
              ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(onSurface: InstaColors.primary),
                  onPressed: (submit)
                      ? () async {
                          final isValidForm = formKey.currentState!.validate();
                          if (isValidForm) {
                            setState(() {
                              loading = true;
                            });
                            debugPrint("Formulaire valide ... ");
                            sendRequest();
                          }
                        }
                      : null,
                  child: Text("Envoyer".toUpperCase())),
        ],
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

  // Envoyer la requete de paiement
  sendRequest() async {
    try {
      Response response = await post(
          Uri.parse("${Api.domain}users/transactions/"),
          headers: {
            "Authorization": "Bearer ${widget.token}",
            "Content-type": "application/json"
          },
          body: jsonEncode({
            "receiver": receiptAddressController.text,
            "amount": amountController.text,
            "reason": reasonController.text
          }));
      setState(() {
        loading = false;
      });
      if (response.statusCode == 200) {
        debugPrint(" [OK] Requete de paiement éffectué");
        openDialog("Requete de paiement envoyée.", true);
      } else {
        debugPrint("echec du paiement : ${response.body}");
        openDialog("Requête de paiement non envoyée.", false);
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      debugPrint("erreur : ${e.toString()}");
    }
  }

  // Afficher un méssage
  Future openDialog(String message, bool status) => showDialog(
      context: context,
      builder: ((context) => AlertDialog(
            content: SizedBox(
              height: 300,
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

  // Verifier que le formulaire est valide
  bool validateForm() {
    bool isValid = EmailValidator.validate(receiptAddressController.text) &&
        reasonController.text.length >= 10;
    if (isValid && amountController.text.isNotEmpty) {
      isValid = int.parse(amountController.text) % 100 == 0;
    } else {
      isValid = false;
    }
    return isValid;
  }
}
