import 'package:flutter/material.dart';

class IsarDemo extends StatefulWidget {
  IsarDemo({Key? key}) : super(key: key);

  @override
  State<IsarDemo> createState() => _IsarDemoState();
}

class _IsarDemoState extends State<IsarDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Center(
            child: TextButton(
              onPressed: () async {},
              child: const Text('Add posts'),
            ),
          )
        ],
      ),
    );
  }
}
