import 'package:flutter/material.dart';
import 'package:futsalpay/core/config/dimension.dart';

class SearchBox extends StatelessWidget {
  const SearchBox({super.key});

  @override
  Widget build(BuildContext context) {
    Dimension.init(context);
    return SearchBar(
      enabled: false,
      backgroundColor: WidgetStateProperty.all(Color(0xff013109)),
      leading: Icon(Icons.search, color: Colors.white),
      hintText: 'Search Futsal name or area...',
      hintStyle: WidgetStateProperty.all(TextStyle(color: Color(0xff91A693))),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimension.width(8)),
        ),
      ),
    );
  }
}
