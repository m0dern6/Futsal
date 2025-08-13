import 'package:flutter/material.dart';
import 'package:futsalpay/core/config/dimension.dart';

class SearchBox extends StatefulWidget {
  const SearchBox({super.key});

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  String selectedCategory = 'Category';

  final List<String> categories = ['Trending', 'Top Review', 'Nearby'];

  @override
  Widget build(BuildContext context) {
    Dimension.init(context);
    return Row(
      children: [
        Expanded(
          child: SearchBar(
            enabled: false,
            backgroundColor: WidgetStateProperty.all(Color(0xff013109)),
            leading: Icon(Icons.search, color: Colors.white),
            hintText: 'Search Futsal name or area...',
            hintStyle: WidgetStateProperty.all(TextStyle(color: Colors.white)),
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Dimension.width(8)),
              ),
            ),
          ),
        ),
        // SizedBox(width: Dimension.width(10)),
        // Container(
        //   height: Dimension.height(45),
        //   decoration: BoxDecoration(
        //     color: Color(0xff013109),
        //     borderRadius: BorderRadius.circular(Dimension.width(8)),
        //   ),
        //   child: DropdownButtonHideUnderline(
        //     child: DropdownButton<String>(
        //       value: selectedCategory == 'Category' ? null : selectedCategory,
        //       hint: Padding(
        //         padding: EdgeInsets.symmetric(
        //           horizontal: Dimension.width(12),
        //           vertical: Dimension.height(8),
        //         ),
        //         child: Text(
        //           selectedCategory,
        //           style: TextStyle(
        //             color: selectedCategory == 'Category'
        //                 ? Color(0xff91A693)
        //                 : Colors.white,
        //             fontSize: Dimension.font(14),
        //           ),
        //         ),
        //       ),
        //       icon: Padding(
        //         padding: EdgeInsets.only(right: Dimension.width(12)),
        //         child: Icon(Icons.keyboard_arrow_down, color: Colors.white),
        //       ),
        //       dropdownColor: Color(0xff013109),
        //       borderRadius: BorderRadius.circular(Dimension.width(8)),
        //       items: categories.map((String category) {
        //         return DropdownMenuItem<String>(
        //           value: category,
        //           child: Padding(
        //             padding: EdgeInsets.symmetric(
        //               horizontal: Dimension.width(12),
        //             ),
        //             child: Text(
        //               category,
        //               style: TextStyle(
        //                 color: Colors.white,
        //                 fontSize: Dimension.font(14),
        //               ),
        //             ),
        //           ),
        //         );
        //       }).toList(),
        //       onChanged: (String? newValue) {
        //         setState(() {
        //           selectedCategory = newValue ?? 'Category';
        //         });
        //       },
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
