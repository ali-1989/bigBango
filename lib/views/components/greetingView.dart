import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:flutter/material.dart';

class GreetingView extends StatelessWidget {

  const GreetingView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 10),
        Image.asset(AppImages.greeting),

        SizedBox(height: 20),

        Text(AppMessages.youFinishedThis, style: TextStyle(fontSize: 15)),
        SizedBox(height: 16),
        Text('« ${AppMessages.greetingForYou} »', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
      ],
    );
  }
}
