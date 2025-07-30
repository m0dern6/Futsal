import 'package:flutter/widgets.dart';

class Past extends StatelessWidget {
  const Past({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Color(0xff251737),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 5,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: const Color(0xff029E70),
                      borderRadius: BorderRadius.circular(8.75),
                    ),
                    child: const Text(
                      'May 29,2024',
                      style: TextStyle(color: Color(0xff8DD5B7), fontSize: 15),
                    ),
                  ),
                  Text(
                    '6:00PM-7:00PM',
                    style: const TextStyle(
                      color: Color(0xffBFBBC7),
                      fontSize: 19,
                    ),
                  ),
                  Text(
                    'Star Futsal',
                    style: TextStyle(color: Color(0xffAEA9B6), fontSize: 16),
                  ),
                  const Text(
                    'Riverside Arena',
                    style: TextStyle(color: Color(0xff8B8699), fontSize: 14),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 10.0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xff1C0D2E),
                      borderRadius: BorderRadius.circular(8.75),
                    ),
                    child: const Text(
                      'Manage',
                      style: TextStyle(color: Color(0xffADA8B4), fontSize: 15),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
