import 'package:flutter/material.dart';
import '../../../../components/constants.dart';

class SearchBar extends StatelessWidget {
  final String hintText;
  final IconData iconData;

  const SearchBar({
    Key? key,
    required this.hintText,
    required this.iconData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: TextField(
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          enabledBorder:  UnderlineInputBorder(
            borderSide: BorderSide(
              color: InstaColors.primary,
              width: 2,
            ),
          ),
          focusedBorder:  UnderlineInputBorder(
            borderSide: BorderSide(
              color: InstaColors.primary,
              width: 2,
            ),
          ),
          border:  UnderlineInputBorder(
            borderSide: BorderSide(
              color: InstaColors.primary,
              width: 2,
            ),
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              iconData,
              color: InstaColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
