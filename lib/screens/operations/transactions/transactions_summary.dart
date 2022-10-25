import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../../../components/constants.dart';
import 'components/transaction_item.dart';
import 'transactions.dart';

class TransactionsSummary extends StatefulWidget {
  final String token;
  const TransactionsSummary({Key? key, required this.token}) : super(key: key);

  @override
  State<TransactionsSummary> createState() => _TransactionsSummaryState();
}

class _TransactionsSummaryState extends State<TransactionsSummary> {
  var inTransactions = [];
  var outTransactions = [];
  List<Map<String, dynamic>> allTransactionsList = [];
  List<Map<String, dynamic>> inTransactionsList = [];
  List<Map<String, dynamic>> outTransactionsList = [];

  List listOfUsers = [];

  @override
  void initState() {
    setState(() {
      debugPrint("Initstate transations summary");
      getTransactions(widget.token);
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Entête de liste des transactions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Titre
              Text(
                "Transactions",
                style: TextStyle(
                  color: InstaColors.boldText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Voir toutes les transactions en détails
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Transactions(
                              allTransactions: allTransactionsList,
                              inTransactions: inTransactionsList,
                              outTransactions: outTransactionsList,
                            )),
                  );
                },
                icon: Icon(
                  Icons.arrow_forward,
                  color: InstaColors.boldText,
                ),
              ),
            ],
          ),

          SizedBox(
            height: InstaSpacing.normal,
          ),

          // Résumé des transactions
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                getTransactions(widget.token);
              },
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    (allTransactionsList.isNotEmpty)
                        ? ListView.separated(
                            primary: false,
                            shrinkWrap: true,
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            itemCount: allTransactionsList.length,
                            itemBuilder: (context, index) => TransactionItem(
                              transaction: allTransactionsList[index],
                              provider: getProvider(
                                  allTransactionsList[index]["provider"]),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  SizedBox(
                                    height: InstaSpacing.large,
                                  ),
                                  Text(
                                    "Aucune transaction éffectuée",
                                    style: TextStyle(
                                        color: InstaColors.boldText,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              )
                            ],
                          ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Otenir toutes les transactions
  getTransactions(String token) async {
    debugPrint("Obtention des transactions");
    try {
      debugPrint("[_] Obtention des transaction en cours");
      Response response = await get(Uri.parse(Api.transactions),
          headers: {"Authorization": "Bearer $token"});

      debugPrint("  --> Code de la reponse : [${response.statusCode}]");
      debugPrint("  --> Contenue de la reponse : ${response.body}");

      if (response.statusCode == 200) {
        debugPrint("[OK] Obtention des transactions reussie");

        setState(() {
          var transactions = jsonDecode(response.body);
          outTransactions = transactions["payer"];
          inTransactions = transactions["payee"];
          debugPrint(
              "TOUTES LES TRANSACTIONS : \n ${inTransactions + outTransactions}");

          // Obtenir les identifiants des utilisateurs
          List<int>? usersId = getUsersId(inTransactions, outTransactions);

          if (usersId != null) {
            debugPrint("$usersId");
            // Obtenir les informations des utilisateurs à partir de leur identifiants
            getUsersInfosWithId(token, usersId);
          } else {
            allTransactionsList = [];
          }
        });
      } else {
        setState(() {
          inTransactions = [];
          outTransactions = [];
        });
      }
    } catch (e) {
      debugPrint("[X] Obtention des transactions échouée :  ${e.toString()}");
      setState(() {
        inTransactions = [];
        outTransactions = [];
      });
    }
  }

  // Obtenir les ID des utilisateurs
  // ayant envoyé de l'argent au compte de l'utilisateur principale
  // ou reçu de l'argent venant de son compte
  List<int>? getUsersId(var intransactions, var outtransactions) {
    debugPrint("Obtenir les ID des utilisateurs lié à une transaction");
    var userIdList = <int>[];

    // Recupération des ID des expéditeurs
    if (intransactions.isNotEmpty) {
      for (var element in intransactions) {
        if (!userIdList.contains(element["payer"])) {
          userIdList.add(element["payer"]);
        }
      }
    }

    // Récupération des ID des destinataires
    if (outtransactions.isNotEmpty) {
      for (var element in outtransactions) {
        if (!userIdList.contains(element["payee"])) {
          userIdList.add(element["payee"]);
        }
      }
    }

    if (userIdList.isNotEmpty) {
      return userIdList;
    } else {
      return null;
    }
  }

  // Obtenir des information des utilisateurs liés à une transaction grace aux identifiants récupéré
  getUsersInfosWithId(String token, List userIdList) async {
    debugPrint("Obtenir des infos sur les utilisateurs lié à une transaction");
    try {
      debugPrint("[_] Obtenir des infos sur les utilisateurs");
      Response response = await post(Uri.parse(Api.userInformations),
          headers: {
            "Authorization": "Bearer $token",
            "Content-type": "application/json"
          },
          body: jsonEncode({
            "users_id": userIdList,
          }));

      debugPrint("  --> Code de la reponse : [${response.statusCode}]");
      debugPrint("  --> Contenue de la reponse : ${response.body}");

      if (response.statusCode == 200) {
        debugPrint("[OK] Obtenir des infos sur les utilisateurs");

        setState(() {
          var users = jsonDecode(response.body);
          // Contruire la liste des information des utilisateurs contcerné par une transaction
          listOfUsers = buildUserInfosList(users, userIdList);
          debugPrint("LISTE DES UTILISATEURS CONCERNÉS : \n $listOfUsers");
          // Contruire la liste complète des transaction
          buildTransactionsList(inTransactions, outTransactions);
        });
      } else {
        debugPrint(
            "[X] Obtention des informations sur les utilisateurs : requete échoué");
      }
    } catch (e) {
      debugPrint(
          "[X] Obtention des informations sur les utilisateurs : pas de connexion");
      debugPrint(e.toString());
    }
  }

  // Contruire la liste des informations des utilisateurs
  List buildUserInfosList(List usersInformation, List usersId) {
    debugPrint("Contruire la liste des informations sur les utilisateurs");

    if (usersInformation.length == usersId.length) {
      // Contiendra les associations clé-valeur sur les infos d'un utilisateur lors d'une itération

      for (var i = 0; i < usersInformation.length; i++) {
        usersInformation[i]["id"] = usersId[i];
      }
      debugPrint("[OK] Contruction de la liste terminée");
    }
    return usersInformation;
  }

  // Construire la liste des transactions voulue
  buildTransactionsList(var intransactions, var outtransactions) {
    debugPrint("Contruction de la liste des transactions ");
    allTransactionsList = [];
    debugPrint("Entrant : $intransactions");
    debugPrint("Sortant : $outtransactions");
    debugPrint(" Tous : $allTransactionsList");
    Map<String, dynamic> item = {};

    if (intransactions.isNotEmpty) {
      debugPrint("TRANSACTIONS ENTRANTES");
      for (var i = 0; i < intransactions.length; i++) {
        debugPrint("Element : ${intransactions[i]}");
        item["id"] = intransactions[i]["id"];
        item["payer"] = getUserInfos(intransactions[i]["payer"]);
        item["amount"] = intransactions[i]["amount"];
        item["datetime"] = convertToDateTime(intransactions[i]["datetime"]);
        item["provider"] = intransactions[i]["provider"];
        item["flow"] = "in";
        item["status"] = intransactions[i]["status"];
        debugPrint("## $item ##");

        allTransactionsList.add(item);
        inTransactionsList.add(item);
        item = {};
        debugPrint(
            "---------------- ALLTRANSACTION STATUS  --------------- : \n $allTransactionsList");
      }
      debugPrint("TRANSACTIONS ENTRANTES TERMINEES");
      debugPrint("$allTransactionsList");
      inTransactionsList = inTransactionsList.reversed.toList();
    }
    if (outtransactions.isNotEmpty) {
      debugPrint("TRANSACTIONS SORTANTES");
      for (var element in outtransactions) {
        item["id"] = element["id"];
        item["payer"] = getUserInfos(element["payee"]);
        item["amount"] = element["amount"];
        item["datetime"] = convertToDateTime(element["datetime"]);
        item["provider"] = element["provider"];
        item["flow"] = "out";
        item["status"] = element["status"];

        allTransactionsList.add(item);
        outTransactionsList.add(item);
        item = {};
      }
      debugPrint("TRANSACTIONS SORTANTES TERMINÉE");
      debugPrint("$allTransactionsList");
      outTransactionsList = outTransactionsList.reversed.toList();
    }
    debugPrint("La liste des transactions construite avec succès ");
    sortTransactions();
  }

  // Tirer la liste des transactions par date la plus recente
  sortTransactions() {
    debugPrint("Trie de la liste de toutes les transactins");
    debugPrint("$allTransactionsList");
    Map<String, dynamic> temp = {};
    int latestDateIndex = 0;
    /* Utilisation de l'algorithme du trie par selection
    
      for i de 0 a T-2
        index_date_pus_recente = i
        for j de i+1 à t - 1
          if tab[j] > tab[index_date_pus_recente] 
            // ladate tab[j] vient après  tab[index_date_pus_recente]
            // la date tab[j] est plus recennte
            indmax = j
        
        if indmax != i
          aux = tab[i]
          tab[i] = tab[j]
          tab[j] = aux

    */
    for (var i = 0; i < allTransactionsList.length - 1; i++) {
      latestDateIndex = i;
      for (var j = i + 1; j < allTransactionsList.length; j++) {
        if (allTransactionsList[j]["datetime"]
            .isAfter(allTransactionsList[latestDateIndex]["datetime"])) {
          //
          latestDateIndex = j;
        }
      }

      if (latestDateIndex != i) {
        temp = allTransactionsList[i];
        allTransactionsList[i] = allTransactionsList[latestDateIndex];
        allTransactionsList[latestDateIndex] = temp;
      }
    }
    debugPrint("Liste de toutes les transactins triée");
    debugPrint("$allTransactionsList");
  }

  // Obtenir le nom d'utilisateur d'un utilisateur
  Map<String, dynamic> getUserInfos(int id) {
    debugPrint("Recuperation du nom complet lié à l'ID $id");

    int i = 0;
    while (i < listOfUsers.length && listOfUsers[i]["id"] != id) {
      i++;
    }
    return listOfUsers[i];
  }

  // Convertir chaine en datetime
  DateTime convertToDateTime(String date) {
    debugPrint("Convertion de la date : $date");
    date = date.substring(0, date.indexOf("."));
    return DateTime.parse(date);
  }

  // Obtenir le provider utilisaer pour faire la transaction
  Map<String, dynamic> getProvider(int providerID) {
    for (var element in providers) {
      if (element["id"] == providerID) {
        return element;
      }
    }
    return providers[1];
  }
}

/*
  DEMARCHES DE TRAITEMENT DES TRANSATIONS
  ---------------------------------------

+ Recuperer les informations de l'utilisateur
+ Extraire les transactions entrantes et sortantes
+ Recupérer les ID des utilisateurs concernés
+ Obtenir les informations sur chaque utilisateur à partir de son ID récupéré
+ contruire une liste d'informations sur les utilisateurs liés à une transactions
+ Contruire une nouvelle liste qui nous convient avec les informations voulues
en associant les transactions entrantes et sortante
+ Trier en fontion de la date


*/

/*
        "id": 2,
        "amount": 30500,
        "datetime_transfer":"2022-09-20 11:23:30",
        "status": true,
        "stats":"1",
        "sender": 28,
        "recipient": 14

        + id_transaction :  sha(id),
        + amount
        + datetime
        + status
        + stats
        - senderUsername
        - senderEmail
        - flow (in, out)

*/

/*
// RESUME DES TRANSACTIONS

Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: const [
                  TransactionItem(
                    imageUrl: "assets/images/uba.png",
                    fullName: "Rebecca Lucas",
                    status: "received",
                    amount: "1.030.489",
                  ),
                  /*TransactionItem(
                    imageUrl: "assets/logos/4-rb.png",
                    fullName: "Jose Young",
                    status: "sended",
                    amount: "19.63",
                  ),
                  TransactionItem(
                    imageUrl: "assets/logos/4-rb.png",
                    fullName: "Janice Brewer",
                    status: "received",
                    amount: "114.00",
                  ),
                  TransactionItem(
                    imageUrl: "assets/logos/5-rb.png",
                    fullName: "Phoebe Buffay",
                    status: "received",
                    amount: "70.16",
                  ),
                  TransactionItem(
                    imageUrl: "assets/logos/4.png",
                    fullName: "Monica Geller",
                    status: "received",
                    amount: "44.50",
                  ),
                  TransactionItem(
                    imageUrl: "assets/logos/5.png",
                    fullName: "Rachel Green",
                    status: "sended",
                    amount: "85.50",
                  ),
                  TransactionItem(
                    imageUrl: "assets/logos/4-rb.png",
                    fullName: "Kamila Fros",
                    status: "received",
                    amount: "155.00",
                  ),
                  TransactionItem(
                    imageUrl: "assets/logos/4-rb.png",
                    fullName: "Ross Geller",
                    status: "received",
                    amount: "23.50",
                  ),
                  TransactionItem(
                    imageUrl: "assets/logos/4-rb.png",
                    fullName: "Chandler Bing",
                    status: "received",
                    amount: "11.50",
                  ),
                  TransactionItem(
                    imageUrl: "assets/logos/4-rb.png",
                    fullName: "Yoyi Delirio",
                    status: "received",
                    amount: "36.00",
                  ),*/
                
                ],
              ),
            ),
          ),


          */
