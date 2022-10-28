// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart';
import 'package:instapay_client/components/constants.dart';

import '../../errors/invalid_token.dart';
import '../transactions/components/transaction_item.dart';
import '../transactions/transactions.dart';
import 'qrcode_container.dart';

class Home extends StatefulWidget {
  final String token;
  final String userEmail;
  const Home({
    super.key,
    required this.token,
    required this.userEmail,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Indique la partie visible de la carte d'infos solde (true : AVANT, false : ARRIERE)
  bool isFront = true;
  double balance = 0.0;
  bool loading = false;

  var inTransactions = [];
  var outTransactions = [];
  List<Map<String, dynamic>> allTransactionsList = [];
  List<Map<String, dynamic>> inTransactionsList = [];
  List<Map<String, dynamic>> outTransactionsList = [];

  List listOfUsers = [];

  @override
  void initState() {
    setState(() {
      debugPrint("-------------- Initstate Home ----------");
      isValidToken();
      getBalance(widget.token);
      getTransactions(widget.token);
      debugPrint("-------------- Initstate Home fin ----------");
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
      padding: EdgeInsets.symmetric(horizontal: InstaSpacing.normal),
      child: RefreshIndicator(
        onRefresh: () async {
          getBalance(widget.token);
          getTransactions(widget.token);
        },
        child: Column(
          children: [
            const SizedBox(
              height: kToolbarHeight / 2,
            ),
            (isFront) ? card() : cardBack(),
            SizedBox(
              height: InstaSpacing.big,
            ),
            transactionSummary(),
          ],
        ),
      ),
    ));
  }

  // Partie avant de la carte
  Widget card() {
    return Container(
      padding: const EdgeInsets.all(8),
      //margin: const EdgeInsets.symmetric(horizontal: defaultPadding),
      height: 180,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: InstaColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: InstaColors.primary.withOpacity(0.4),
            offset: const Offset(0, 8),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        // Ce widget Column est contitué de deux autres widgets Row, qui divise la carte en deux partie Supérieure et Inférieure
        // 1er Row : Partie supérieure qui contient un logo et les bouttons d'action
        // 2e Row : Partie inférieure en inférieur qui contient le solde du compte
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Partie Supérieure
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo sur la carte
              Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    color: InstaColors.background,
                    borderRadius: const BorderRadius.all(Radius.circular(50))),
                child: Center(
                  child: Image.asset(
                    "assets/logos/4-rb.png",
                  ),
                ),
              ),

              // Bouttons d'actions
              Row(
                children: [
                  // Pour se recharger
                  IconButton(
                    tooltip: "Se recharger",
                    onPressed: () {
                      debugPrint("Se recharger");
                    },
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                    ),
                  ),

                  // Afficher son code QR pour recevoir de l'argent
                  IconButton(
                    tooltip: "Voir mon QR code",
                    onPressed: () {
                      debugPrint("Voir mon QR code");
                      setState(() {
                        isFront = false;
                      });
                    },
                    icon: const Icon(
                      Icons.qr_code_2,
                      color: Colors.white,
                    ),
                  ),

                  // Scanner un code QR pour envoyer de l'argent
                  IconButton(
                    tooltip: "Scanner un QR code",
                    onPressed: () async {
                      debugPrint("Scanner un QR code");
                      String response = await FlutterBarcodeScanner.scanBarcode(
                          '#ffffff', 'Quitter', true, ScanMode.QR);

                      if (response != "-1") {
                        /*Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SendMoney(
                                      balance: (widget.balance == balance)
                                          ? widget.balance
                                          : balance,
                                      receiptEmail: response,
                                      token: widget.token,
                                    )));*/
                      } else {
                        debugPrint("Aucun Scann éffectué");
                      }
                    },
                    icon: const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Partie Inférieur
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Affichage du solde
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label solde
                  const Text(
                    "Solde",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  // Montant solde
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Montant
                      Text(
                        balance.toStringAsFixed(2),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        width: 5,
                      ),
                      // Devise
                      const Text("Fcfa",
                          style: TextStyle(color: Colors.white, fontSize: 15)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Partie arriere de la carte
  Widget cardBack() {
    return Container(
      padding: const EdgeInsets.all(8),
      //margin: const EdgeInsets.symmetric(horizontal: defaultPadding),
      height: 200,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: InstaColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: InstaColors.primary.withOpacity(0.4),
            offset: const Offset(0, 8),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        // Ce widget Column est contitué de deux autres widgets Row, qui divise la carte en deux partie Supérieure et Inférieure
        // 1er Row : Partie supérieure qui contient un logo et les bouttons d'action
        // 2e Row : Partie inférieure en inférieur qui contient le solde du compte
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Partie gauche
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo sur la carte
              Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    color: InstaColors.background,
                    borderRadius: const BorderRadius.all(Radius.circular(50))),
                child: Center(
                  child: Image.asset(
                    "assets/logos/4-rb.png",
                  ),
                ),
              ),
            ],
          ),

          // Partie centrée
          Container(
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(29),
              color: Colors.white,
              border: Border.all(color: InstaColors.primary, width: 1.0),
            ),
            child: QrcodeContainer(
              data: widget.userEmail,
            ),
          ),

          // Partie droite
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Pour se recharger
              IconButton(
                tooltip: "Se recharger",
                onPressed: () {
                  debugPrint("Se recharger : Afficher l'avant de la carte");
                  setState(() {
                    isFront = true;
                  });
                },
                icon: const Icon(
                  Icons.cached,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Obtenir le solde de l'utilisateur
  getBalance(String token) async {
    debugPrint("la tokens que je recois est : $token");
    try {
      Response response = await get(Uri.parse(Api.userInformations),
          headers: {"Authorization": "Bearer $token"});

      debugPrint("  --> Code de la reponse : [${response.statusCode}]");
      debugPrint("  --> Contenue de la reponse : ${response.body}");

      if (response.statusCode == 200) {
        var result = jsonDecode(response.body);

        setState(() {
          balance = result["balance"];
          debugPrint("$balance");
        });
      } else {
        debugPrint("Obtention du solde échoué : $balance");
      }
    } catch (e) {
      debugPrint("Erreur : ${e.toString()}");
      debugPrint("la balance est : $balance");
    }
  }

  // ======================================

  Widget transactionSummary() {
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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (loading)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              height: InstaSpacing.large,
                            ),
                            CircularProgressIndicator(
                              strokeWidth: 6.0,
                              color: InstaColors.primary,
                            ),
                          ],
                        )
                      ],
                    )
                  else if (allTransactionsList.isNotEmpty)
                    ListView.separated(
                      primary: false,
                      shrinkWrap: true,
                      separatorBuilder: (context, index) => const Divider(),
                      itemCount: allTransactionsList.length,
                      itemBuilder: (context, index) => TransactionItem(
                        transaction: allTransactionsList[index],
                        provider:
                            getProvider(allTransactionsList[index]["provider"]),
                      ),
                    )
                  else
                    Row(
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
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Otenir toutes les transactions
  getTransactions(String token) async {
    setState(() => loading = true);
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
          loading = false;
        });
      }
    } catch (e) {
      debugPrint("[X] Obtention des transactions échouée :  ${e.toString()}");
      setState(() {
        inTransactions = [];
        outTransactions = [];
        loading = false;
      });
      showInformation(context, false, "Vérifiez votre connexion internet");
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
        setState(() => loading = false);
      }
    } catch (e) {
      debugPrint(
          "[X] Obtention des informations sur les utilisateurs : pas de connexion");
      debugPrint(e.toString());
      setState(() => loading = false);
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
    setState(() => loading = false);
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

  isValidToken() async {
    debugPrint("Obtention des informations de l'utilisateur  ");

    try {
      Response response = await get(Uri.parse(Api.userInformations),
          headers: <String, String>{"Authorization": "Bearer ${widget.token}"});

      debugPrint("  --> Envoie de la requete d'obtention des informations");
      debugPrint("  --> Code de la reponse : [${response.statusCode}]");
      debugPrint("  --> Contenue de la reponse : ${response.body}");
      var error = jsonDecode(response.body);
      if (response.statusCode == 200) {
        debugPrint("[OK] vérification reussie avec succès : Token valide");
      } else if (response.statusCode == 401 &&
          error["code"] == "token_not_valid" &&
          error["messages"][0]["token_type"] == "access") {
        debugPrint("Token expiré");
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const InvalidTokenScreen()),
            (route) => false);
      } else {
        debugPrint("[X] Vérification échoué : HTTP ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("[X] Une erreur est survenue : \n $e");
      showInformation(context, false, "Vous n'etes pas connecté à internet");
    }
  }

// Affiche des informations en rapport avec les resultats des requetes à l'utilisateur
  showInformation(BuildContext context, bool isSuccess, String message) {
    return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: isSuccess ? InstaColors.success : InstaColors.error,
      elevation: 3,
    ));
  }
}
