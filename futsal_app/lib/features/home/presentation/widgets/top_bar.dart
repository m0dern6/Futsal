import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:futsalpay/core/config/dimension.dart';
import 'package:futsalpay/shared/user_info/bloc/user_info_bloc.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    Dimension.init(context);
    return BlocBuilder<UserInfoBloc, UserInfoState>(
      builder: (context, state) {
        final user = state is UserInfoLoaded ? state.userInfo : null;
        final username = user?.username ?? 'Guest';
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hello, $username',
              style: TextStyle(
                color: Colors.white,
                fontSize: Dimension.font(20),
                fontWeight: FontWeight.bold,
              ),
            ),
            Column(
              children: [
                Image.asset(
                  'assets/logo/inapplogo.png',
                  width: Dimension.width(65),
                  height: Dimension.height(35),
                ),
                Text(
                  'Futsal Pay',
                  style: TextStyle(
                    color: Color(0xff618E6A),
                    fontSize: Dimension.font(14),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
