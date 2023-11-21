import 'package:flutter/material.dart';

import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';

class GreetingView extends StatelessWidget {

  const GreetingView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Image.asset(AppImages.greeting),

        const SizedBox(height: 20),

        Text(AppMessages.youFinishedThis, style: const TextStyle(fontSize: 15)),
        const SizedBox(height: 16),
        Text('« ${AppMessages.greetingForYou} »', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
      ],
    );
  }
}
