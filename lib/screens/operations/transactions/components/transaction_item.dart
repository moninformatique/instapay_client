//import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
//import '../transaction_details.dart';
import '../../../../components/constants.dart';
import '../transactions_details.dart';

class TransactionItem extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final Map<String, dynamic> provider;
  const TransactionItem(
      {Key? key, required this.transaction, required this.provider})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var formatted = DateFormat('yyyy-MM-dd HH:mm');

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TransactionsDetails(
                      transaction: transaction,
                      provider: provider,
                    )));
      },
      child: Row(children: [
        // Image du provider
        Container(
          width: 35,
          height: 35,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: AssetImage(provider["imagepath"]),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Type de transaction, Expediteur et Date
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type de transactions
              Text(
                "Paiement ${(transaction["flow"] == "in") ? "de" : "à"}",
                style: TextStyle(
                  color: InstaColors.boldText,
                  fontSize: 12,
                ),
              ),

              // Nom complet de l'expéditeur
              Text(
                "${transaction["payer"]["full_name"]}",
                style: TextStyle(
                  color: InstaColors.primary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Date de la transaction
              Text(
                formatted.format(transaction["datetime"]),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        // Montant de la transaction
        Text(
          (transaction["flow"] == "in")
              ? "+ ${transaction["amount"]}"
              : "- ${transaction["amount"]}",
          style: TextStyle(
            color: (transaction["flow"] == "in") ? Colors.green : Colors.red,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Icon(
          Icons.keyboard_arrow_right,
          color: InstaColors.primary,
        ),
      ]),
    );
  }
}

class TransactionItemOrderedByDate extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final Map<String, dynamic> provider;
  final String period;
  const TransactionItemOrderedByDate(
      {Key? key,
      required this.transaction,
      required this.provider,
      required this.period})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var formatted = DateFormat('yyyy-MM-dd HH:mm');
    return Column(
      children: [
        // Date
        (period.isNotEmpty)
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    period,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Container(),
        SizedBox(
          height: InstaSpacing.normal / 2,
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TransactionsDetails(
                          transaction: transaction,
                          provider: provider,
                        )));
          },
          child: Row(children: [
            // Image du provider
            Container(
              width: 35,
              height: 35,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage(provider["imagepath"]),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Type de transaction, Expediteur et Date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type de transactions
                  Text(
                    "Paiement ${(transaction["flow"] == "in") ? "de" : "à"}",
                    style: TextStyle(
                      color: InstaColors.boldText,
                      fontSize: 12,
                    ),
                  ),

                  // Nom complet de l'expéditeur
                  Text(
                    "${transaction["payer"]["full_name"]}",
                    style: TextStyle(
                      color: InstaColors.primary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Date de la transaction
                  Text(
                    formatted.format(transaction["datetime"]),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Montant de la transaction
            Text(
              (transaction["flow"] == "in")
                  ? "+ ${transaction["amount"]}"
                  : "- ${transaction["amount"]}",
              style: TextStyle(
                color:
                    (transaction["flow"] == "in") ? Colors.green : Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_right,
              color: InstaColors.primary,
            ),
          ]),
        ),
      ],
    );
  }
}
