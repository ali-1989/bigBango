import 'package:flutter/material.dart';

class S1 extends StatefulWidget {
  static String id$head = '${identityHashCode(null)}';
  static String id$head2 = '${(S1).hashCode}';

   S1({Key? key}) : super(key: key){
     id$head2 = 'qqq2';
     print(identityHashCode(null));
     print((S1).hashCode.toString());
     print(hashCode.toString());
     print('==============*==================');
  }

  @override
  State<S1> createState() => _S1State();
}

class _S1State extends State<S1> {
  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 100),
        Text(S1.id$head),
        Text(S1.id$head2),
        Text(hashCode.toString()),
      ],
    );
  }
}
