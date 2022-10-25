import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../../../components/constants.dart';
import 'components/action_box.dart';
import 'mobilemoney/mobile_money_payment.dart';
import 'requestpayment/request_payment.dart';
import 'sendmoney/send_money.dart';

class Payment extends StatefulWidget {
  final bool accoutProtection;
  final String token;
  const Payment({Key? key, required this.accoutProtection, required this.token})
      : super(key: key);

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  TextEditingController destinationAddressController = TextEditingController();
  TextEditingController amountToSendController = TextEditingController();
  double balance = 0.0;
  String mysolde = "0";

  @override
  void initState() {
    getBalance();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: InstaSpacing.normal / 2),
        child: Expanded(
          child: Column(
            children: [
              const SizedBox(
                height: kToolbarHeight,
              ),
              actionsButtons(),
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
        "Opérations",
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

  // Les bouttons d'actions
  actionsButtons() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Boutton de transfert
            Expanded(
                child: ActionBox(
              title: "Transfert",
              icon: Icons.send,
              bgColor: InstaColors.green,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            SendMoney(balance: balance, token: widget.token)));
              },
            )),
            const SizedBox(
              width: 15,
            ),

            // Boutton Mobile Money
            Expanded(
                child: ActionBox(
              icon: Icons.send_to_mobile_outlined,
              title: "Mobile Money",
              bgColor: Colors.orange,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: ((context) => MobileMoneyPayment(
                              token: widget.token,
                            ))));
              },
            )),
            const SizedBox(
              width: 15,
            ),

            // Bouttons demande
            Expanded(
                child: ActionBox(
              title: "Demande",
              icon: Icons.arrow_circle_down_rounded,
              bgColor: InstaColors.purple,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RequestPayment(
                              token: widget.token,
                            )));
              },
            )),
          ],
        ),
      ],
    );
  }

  // Obtenir le solde
  getBalance() async {
    try {
      Response response = await get(Uri.parse(Api.userInformations),
          headers: {"Authorization": "Bearer ${widget.token}"});

      debugPrint("  --> Code de la reponse : [${response.statusCode}]");
      debugPrint("  --> Contenue de la reponse : ${response.body}");

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);

        setState(() {
          balance = result["balance"];
          //accountProtection = result["transaction_protection"];
          debugPrint("$balance");
        });
      } else {
        setState(() {
          balance = 0.0;

          debugPrint("$balance");
        });
      }
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        balance = 0.0;
        debugPrint("la balance est : $balance");
      });
    }
  }
}
