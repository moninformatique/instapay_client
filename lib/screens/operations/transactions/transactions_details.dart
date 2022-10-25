// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../components/constants.dart';

class TransactionsDetails extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final Map<String, dynamic> provider;
  const TransactionsDetails(
      {Key? key, required this.transaction, required this.provider})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var formatted = DateFormat('MMMM dd,  yyyy à HH:mm');
    // Description en bas de la page
    double amountCredited = double.parse(
        (transaction["amount"] + transaction["amount"] * 0.01)
            .toStringAsFixed(0));
    return Scaffold(
      appBar: appBar(context),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: InstaSpacing.normal),
        child: Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: kToolbarHeight,
                ),

                // Top infos
                // Bref résumé de la transaction : montant, expediteur/destinataire, status
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          // Montant réçu/envoyé
                          Text(
                              (transaction["flow"] == "in")
                                  ? "+ ${transaction["amount"]} FCFA"
                                  : "- ${transaction["amount"]} FCFA",
                              style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.w600,
                                color: InstaColors.primary,
                              )),

                          // Expéditeur / Destinataire
                          Text(
                              "${(transaction["flow"] == "in") ? "Réçu de" : "Envoyé à"}  ${transaction["payer"]["full_name"]}"),

                          // Status de la transaction
                          Text(
                              (transaction["status"])
                                  ? "Effectuée"
                                  : "En attente",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: (transaction["status"])
                                    ? Colors.green
                                    : Colors.orange,
                              )),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: InstaSpacing.large,
                ),

                // Date et heure
                OtherDetailsItem(
                    label: "Date et Heure",
                    info: formatted.format(transaction["datetime"])),
                OtherDetailsDivider(),

                // Montant crédité
                OtherDetailsItem(
                    label: "Montant crédité", info: "$amountCredited FCFA"),
                OtherDetailsDivider(),

                // Frais de transfert
                OtherDetailsItem(
                    //toStringAsFixed(0)
                    label: "Frais de transaction",
                    info: "${amountCredited * 0.01} FCFA"),
                OtherDetailsDivider(),

                // Montant réçu
                OtherDetailsItem(
                    label: "Montant réçu",
                    info: "${transaction["amount"]} FCFA"),
                OtherDetailsDivider(),

                // Nom complet de l'Expéditeur/Destinataire
                OtherDetailsItem(
                    label: (transaction["flow"] == "in")
                        ? "Expéditeur"
                        : "Destinataire",
                    info: "${transaction["payer"]["full_name"]}"),
                OtherDetailsDivider(),

                // Email de l'Expéditeur/Destinataire
                OtherDetailsItem(
                    label: (transaction["flow"] == "in")
                        ? "Email de l'expéditeur"
                        : "Email du destinataire",
                    info: "${transaction["payer"]["email"]}"),
                OtherDetailsDivider(),

                // ID de la transaction
                OtherDetailsItem(
                    label: "ID transaction", info: transaction["id"]),
                OtherDetailsDivider(),

                // Opérateur de la transaction
                OtherDetailsItem(label: "Opérateur", info: provider["name"]),
                OtherDetailsDivider(),

                // Imprimer le réçu
                TextButton(
                    onPressed: () => debugPrint("Imprimer réçu"),
                    child: Text(
                      "Impprimer le réçu",
                      style: TextStyle(color: Colors.black),
                    ))
              ],
            ),
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
        "Détails de transaction",
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

class OtherDetailsDivider extends StatelessWidget {
  const OtherDetailsDivider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(
        color: Colors.grey.withOpacity(0.4),
        thickness: 0.5,
        indent: 16,
        endIndent: 16,
      ),
    );
  }
}

class OtherDetailsItem extends StatelessWidget {
  final String label;
  final String info;
  const OtherDetailsItem({Key? key, required this.label, required this.info})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: InstaStyles.otherDetailsSecondary),
            SizedBox(height: 5.0),
            Text(info, style: InstaStyles.otherDetailsPrimary),
          ],
        ),
      ],
    );
  }
}

/* 

  PROBLEMATIQUE  : 
    Retrouvé le montant crédité et déduire les frais qui ont été réelement 
    déduit du montant lors de la transaction

------------------------ Théorie -----------------------
montant_credite = montant retirer du compte de l'expéditeur
montant_recu = Montant réçu
  -                     -------------
frais_transaction = frais de transaction sur le montant crédité (1% montant_credite)
frais_montant_recu = frais sur le montant réçu (1% montant_recu)

frais_transaction = 0.01 * montant_credite
frais_montant_recu = 0.01 * montant_recu
                          --------------
montant_recu = montant_credite - frais_transaction
(Solution)
montant_credite = montant_recu + frais_montant_recu (arrondi à 0 chifre àprès la virgule)


-------------------------- Example -------------------------
A envoie 2500 à B
Example de details de transaction sur l'interface de B :

Informations perdues lors de la transaction
  montant_credite = 2500
  frais_transaction = 25


montant_recu = 2475
frais_montant_recu = 24.75

montant_credite = 2475 + 24.75 = 2499.75 +-= 2500


*/