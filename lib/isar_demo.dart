import 'package:flutter/material.dart';
import 'package:isar_demo/post.dart';

import 'isar.dart';

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
          // a stream builder widget to list posts
          StreamBuilder<List<Post>>(
            stream: IsarApi.posts(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Text('Loading...');
              }
              return Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children:
                      snapshot.data!.map((post) => Text(post.title)).toList(),
                ),
              );
            },
          ),
          Center(
            child: TextButton(
              onPressed: () async {
                await IsarApi.addPosts();
              },
              child: const Text('Add posts'),
            ),
          )
        ],
      ),
    );
  }
}
