import 'package:app/models/summary_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../controllers/todo_controller.dart';
import '../models/todo_entity.dart';

class TodoScreen extends StatefulWidget {
  final Status status;

  const TodoScreen({super.key, required this.status});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  late final TodoController _controller;
  late Future<List<ShownTask>?> _resultsFuture;

  @override
  void initState() {
    super.initState();
    _controller = TodoController(status: widget.status);
    _resultsFuture = _fetchResults();
  }

  Future<List<ShownTask>?> _fetchResults() async {
    return _controller.getResultsByStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
      ),
      body: Center(
        child: FutureBuilder<List<ShownTask>?>(
          future: _resultsFuture,  // Provide the future to FutureBuilder
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show a loading spinner while waiting for the result
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              // Handle any errors that might occur during fetching
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              // Show the fetched results when data is available
              return ListView.separated(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  // Extract and display each element in the list
                  return ListTile(
                    title: Text(snapshot.data![index].task!),
                    subtitle: Text('Deadline: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.fromMillisecondsSinceEpoch(snapshot.data![index].deadline!))}'),
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                },
              );
            } else {
              // If no data found, show a default message
              return const Text('No records found.');
            }
          },
        ),
      ),
    );
  }
}