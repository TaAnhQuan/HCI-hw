import 'package:app/models/record_entity.dart';
import 'package:app/models/summary_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../controllers/search_controller.dart';

class SearchScreen extends StatefulWidget {
  final String query;

  const SearchScreen({super.key, required this.query});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final NativeSearchController _controller;
  late Future<List<SummaryEntity>?> _resultsFuture;

  @override
  void initState() {
    super.initState();
    _controller = NativeSearchController();
    _resultsFuture = _fetchResults();
  }

  Future<List<SummaryEntity>?> _fetchResults() async {
    await _controller.fetchSummariesByKeyword(widget.query);
    return _controller.getResults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Native Search'),
      ),
      body: Center(
        child: FutureBuilder<List<SummaryEntity>?>(
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
                    title: Text(DateFormat('yyyy-MM-dd HH:mm').format(DateTime.fromMillisecondsSinceEpoch(snapshot.data![index].startTime))),
                    subtitle: Text('${snapshot.data![index].content!}'),
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