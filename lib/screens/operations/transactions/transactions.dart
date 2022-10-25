import 'package:flutter/material.dart';
import '../../../components/constants.dart';
import 'components/search_bar.dart';
import 'components/transaction_item.dart';

class Transactions extends StatefulWidget {
  final List<Map<String, dynamic>> allTransactions;
  final List<Map<String, dynamic>> inTransactions;
  final List<Map<String, dynamic>> outTransactions;
  const Transactions(
      {Key? key,
      required this.allTransactions,
      required this.inTransactions,
      required this.outTransactions})
      : super(key: key);

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  int active = 0;
  static int tous = 0;
  static int entrant = 1;
  static int sortant = 2;
  List navBarIndex = [0, 1, 2];
  String date = "3000-12-12 00:00:00.000";
  double amoutIn = 0.0;
  double amoutOut = 0.0;
  late DateTime dt;

  @override
  void initState() {
    setState(() {
      debugPrint("Initstate transations");
      dt = DateTime.parse(date);
      for (var element in widget.inTransactions) {
        amoutIn += element["amount"];
      }
      for (var element in widget.outTransactions) {
        amoutOut += element["amount"];
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      dt = DateTime.parse(date);
    });
    return Scaffold(
      appBar: appBar(context),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: InstaSpacing.normal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barre de recherche
            const SearchBar(
              hintText: "Nom ou Email",
              iconData: Icons.search,
            ),

            // Barre de navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                navBar(tous, "Tous"),
                navBar(entrant, "Entrants"),
                navBar(sortant, "Sortants"),
              ],
            ),

            SizedBox(
              height: InstaSpacing.medium,
            ),

            // Statistiques et Liste des transactions
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Statistiques",
                      style: TextStyle(
                        color: InstaColors.boldText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: InstaSpacing.normal,
                    ),
                    statsItem("Entrants", "$amoutIn", true),
                    statsItem("Sortants", "$amoutOut", false),
                    SizedBox(
                      height: InstaSpacing.normal,
                    ),
                    Divider(
                      color: InstaColors.primary,
                      height: 1,
                      thickness: 1,
                    ),
                    SizedBox(
                      height: InstaSpacing.medium,
                    ),
                    // Liste des transactions
                    (active == tous)
                        ? allTransactions()
                        : (active == entrant)
                            ? incomingTransactions()
                            : outcomingTransactions(),
                  ],
                ),
              ),
            ),
          ],
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
        "Transactions",
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
      actions: [
        Padding(
          padding: EdgeInsets.only(right: InstaSpacing.normal),
          child: Icon(
            Icons.notifications,
            color: InstaColors.primary,
          ),
        ),
      ],
    );
  }

  Widget navBar(int index, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          active = index;
          //dt = DateTime.parse(date);
        });
      },
      child: Container(
        padding:
            EdgeInsets.symmetric(vertical: 4, horizontal: InstaSpacing.normal),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(10),
          ),
          color: (index == active) ? InstaColors.primary : Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: (index == active) ? Colors.white : Colors.grey[400],
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Row statsItem(String label, String amount, bool income) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Icone et label
        Row(
          children: [
            //Icone
            Icon(
              income
                  ? Icons.arrow_circle_down_rounded
                  : Icons.arrow_circle_up_rounded,
              color: income ? Colors.green : Colors.red,
              size: 30,
            ),
            const SizedBox(
              width: 20,
            ),

            // Label
            Text(
              label,
              style: TextStyle(
                color: InstaColors.boldText,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        // Montant
        Text(
          "${income ? "+" : "-"} $amount FCFA",
          style: TextStyle(
            color: income ? Colors.green : Colors.red,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // liste de toutes les transactions
  Widget allTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Titre
        Text(
          "Toutes les transactions",
          style: TextStyle(
            color: InstaColors.boldText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: InstaSpacing.normal,
        ),

        // Lites de transactions
        (widget.allTransactions.isNotEmpty)
            ? ListView.separated(
                primary: false,
                shrinkWrap: true,
                separatorBuilder: (context, index) => const Divider(),
                itemCount: widget.allTransactions.length,
                itemBuilder: (context, index) => TransactionItemOrderedByDate(
                  transaction: widget.allTransactions[index],
                  provider:
                      getProvider(widget.allTransactions[index]["provider"]),
                  period: getPeriod(widget.allTransactions[index]["datetime"]),
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

        SizedBox(
          height: InstaSpacing.normal,
        ),
      ],
    );
  }

  // Liste des transctions entrantes
  Widget incomingTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre
        Text(
          "Transactions entrantes",
          style: TextStyle(
            color: InstaColors.boldText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: InstaSpacing.normal,
        ),

        // Lites de transactions
        (widget.inTransactions.isNotEmpty)
            ? ListView.separated(
                primary: false,
                shrinkWrap: true,
                separatorBuilder: (context, index) => const Divider(),
                itemCount: widget.inTransactions.length,
                itemBuilder: (context, index) => TransactionItemOrderedByDate(
                  transaction: widget.inTransactions[index],
                  provider:
                      getProvider(widget.inTransactions[index]["provider"]),
                  period: getPeriod(widget.inTransactions[index]["datetime"]),
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

        SizedBox(
          height: InstaSpacing.normal,
        ),
      ],
    );
  }

  // Liste des transactions sortantes
  Widget outcomingTransactions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Titre
        Text(
          "Transactions sortantes",
          style: TextStyle(
            color: InstaColors.boldText,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          height: InstaSpacing.normal,
        ),

        // Lites de transactions
        (widget.outTransactions.isNotEmpty)
            ? ListView.separated(
                primary: false,
                shrinkWrap: true,
                separatorBuilder: (context, index) => const Divider(),
                itemCount: widget.outTransactions.length,
                itemBuilder: (context, index) => TransactionItemOrderedByDate(
                  transaction: widget.outTransactions[index],
                  provider:
                      getProvider(widget.outTransactions[index]["provider"]),
                  period: getPeriod(widget.outTransactions[index]["datetime"]),
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

        SizedBox(
          height: InstaSpacing.normal,
        ),
      ],
    );
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

  String getPeriod(DateTime date) {
    List month = [
      "Janvier",
      "Fevrier",
      "Mars",
      "Avril",
      "Mai",
      "Juin",
      "Juillet",
      "Août",
      "Septempbre",
      "Obtobre",
      "Novembre",
      "Decembre"
    ];

    if (date.year < dt.year) {
      dt = date;
      return "${month[dt.month - 1]} ${dt.year}";
    } else {
      if (date.year == dt.year) {
        if (date.month < dt.month) {
          dt = date;
          return "${month[dt.month - 1]} ${dt.year}";
        } else {
          if (date.month != dt.month) {
            debugPrint("Impossible");
            debugPrint("$date : $dt");
            return "";
          }
        }
      }
    }
    return "";
  }
}
