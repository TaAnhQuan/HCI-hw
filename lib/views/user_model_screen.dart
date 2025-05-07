import 'package:app/views/ui/layout/bud_scaffold.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../controllers/user_model_controller.dart';

class UserModelScreen extends StatefulWidget{
  const UserModelScreen({super.key});

  @override
  _UserModelScreenState createState() => _UserModelScreenState();
}

class _UserModelScreenState extends State<UserModelScreen>{

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BudScaffold(
      title: "User Model",
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Fluttertoast.showToast(
              msg: "The model is generating response, please wait",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 16.0
          );
          Provider.of<UserModelController>(context, listen: false).updateUserDescription();
        },
        label: const Text('Get user model'),
        icon: const Icon(Icons.refresh, color: Colors.white, size: 25),
      ),
      body: Consumer<UserModelController>(
        builder: (context, controller, child) {
          final List<Map<String, String>> sections = [
            {'title': 'Personality', 'content': controller.personality},
            {'title': 'Hobbies', 'content': controller.hobbies},
            {'title': 'Habits', 'content': controller.habits},
          ];

          return ListView.builder(
            itemCount: sections.length,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ExpansionTile(
                  title: Text(
                    sections[index]['title']!,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        sections[index]['content']!,
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}