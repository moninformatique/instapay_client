import 'package:flutter/material.dart';

String logoPath = "assets/logos/4-rb.png";
List<Map<String, dynamic>> providers = [
  {"id": 1, "name": "Instapay", "imagepath": "assets/logos/4-rb.png"},
  {"id": 2, "name": "MTN Mobile Money", "imagepath": "assets/images/mtn.jpeg"},
  {
    "id": 3,
    "name": "Orange Mobile Money",
    "imagepath": "assets/images/orange.png"
  },
  {"id": 4, "name": "Moov Mobile Money", "imagepath": "assets/images/moov.png"}
];

// FONCTIONNALITÉS DE L'API
class Api {
  static String domain = "http://164.92.134.116/api/v1";

  static String signup = "$domain/users/signup/";
  static String login = "$domain/users/login/";
  static String logout = "$domain/users/logout/";
  static String activeAccount = "$domain/users/active_my_account/";
  static String doubleAuthentication =
      "$domain/users/login/second_authentication/";

  static String resetPasswordRequest = "$domain/users/ask_for_reset_password/";
  static String resetPassword = "$domain/users/reset_password/";
  static String changePassword = "$domain/users/change_password/";
  static String changeUserInformations = "$domain/users/edit_profile/";

  static String paymentRequest = "$domain/users/payment_request/";
  static String sendMoney = "$domain/users/transactions/";
  static String sendMoneyByClient = "$domain/users/transactionsFromClient/";
  static String transactions = "$domain/users/transactions/";

  static String generateTransactionCode = "$domain/users/getTemporaryCode/";

  static String userProfil = "$domain/users/profil/";
  static String userSecurity = "$domain/users/security/";
  static String userAccount = "$domain/users/accounts/";
  static String userInformations = "$domain/users/";

  static String activeDoubleAuthentication =
      "$domain/users/securityoption/?double_authentication=1";
  static String desactiveDoubleAuthentication =
      "$domain/users/securityoption/?double_authentication=0";

  static String activeTransactionProtection =
      "$domain/users/securityoption/?transaction_protection=1";
  static String desactiveTransactionProtection =
      "$domain/users/securityoption/?transaction_protection=0";

  static String addPaymentMethod = "$domain/users/addPaymentMethod/";
}

// DIMENSIONS PADDING
class InstaSpacing {
  static double normal = 16.0;
  static double medium = 32.0;
  static double big = 50;
  static double large = 64.0;
}

// COULEURS DE L'APPLICATION
class InstaColors {
  // Couleurs propre à l'application
  static Color primary = const Color(0xFF613DE6);
  static Color simpleText = const Color(0xFF7184AD);
  static Color boldText = const Color(0xFF1F2C73);
  static Color weightBoldText = const Color(0xFF080643);
  static Color background = const Color(0xFFF6F9FC);

  static Color lightPrimary = const Color(0xFFC9C9E4);

  // Couleurs d'information
  static Color success = const Color.fromARGB(255, 35, 127, 38);
  static Color error = Colors.red;
  static Color warning = const Color.fromARGB(255, 236, 179, 44);

  // Couleurs générale
  static Color lightGrey = const Color(0xffE8E8E9);
  static Color black = const Color(0xff14121E);
  static Color grey = const Color(0xFF8492A2);
  static Color yellow = const Color(0xFFffcb66);
  static Color green = const Color(0xFFb2e1b5);
  static Color pink = const Color(0xFFf5bde8);
  static Color purple = const Color(0xFFd9bcff);
  static Color red = const Color(0xFFef5013);
}

// COULEURS DE WIDGETS DE L'APPLICATION
class InstaStyles {
  static TextStyle primaryTitle = const TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );
  static TextStyle seeAll = const TextStyle(
    fontSize: 17.0,
    color: Colors.black,
  );
  static TextStyle cardDetails = const TextStyle(
    fontSize: 17.0,
    color: Color(0xff66646d),
    fontWeight: FontWeight.w600,
  );
  static TextStyle cardMoney = const TextStyle(
    color: Colors.white,
    fontSize: 22.0,
    fontWeight: FontWeight.w700,
  );
  static TextStyle tagText = const TextStyle(
    fontStyle: FontStyle.italic,
    color: Colors.black,
    fontWeight: FontWeight.w500,
  );
  static TextStyle otherDetailsPrimary = const TextStyle(
    fontSize: 16.0,
    color: Colors.black,
  );
  static TextStyle otherDetailsSecondary = const TextStyle(
    fontSize: 12.0,
    color: Colors.grey,
  );
}

// DIMENSIONS ECRAN
class Screens {
  BuildContext context;
  late MediaQueryData mediaQueryData;

  late Size _size;
  late double _height;
  late double _width;
  late double _heightWithoutSafeArea;
  late double _heightWithoutStatusBar;
  late double _heightWithoutStatusToolBar;

  late EdgeInsets _viewPadding;

  Screens(this.context) {
    mediaQueryData = MediaQuery.of(context);
  }

  //double viewInset = MediaQuery.of(context).viewInsets.bottom;

  Size get size {
    _size = mediaQueryData.size;
    return _size;
  }

  EdgeInsets get viewPadding {
    return _viewPadding;
  }

  double get height {
    _height = size.height;
    return _height;
  }

  double get width {
    _width = size.width;
    return _width;
  }

  double get heightWithoutSafeArea {
    var padding = mediaQueryData.viewPadding;
    _heightWithoutSafeArea = height - padding.top - padding.bottom;
    return _heightWithoutSafeArea;
  }

  double get heightWithoutStatusBar {
    var padding = mediaQueryData.viewPadding;
    _heightWithoutStatusBar = height - padding.top;
    return _heightWithoutStatusBar;
  }

  double get heightWithoutStatusToolBar {
    var padding = mediaQueryData.viewPadding;
    _heightWithoutStatusToolBar = height - padding.top - kToolbarHeight;
    return _heightWithoutStatusToolBar;
  }
}

// ROUTES VERS LES PAGES
class PageRoutes {
  /// Définition des noms de route vers les pages de l'application
  static String authentication = "authentication";
  static String login = "login";
  static String noInternet = "interneterror";
  static String tokenInvalid = "login";
}
