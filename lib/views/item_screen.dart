import 'package:app/models/summary_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/item_controller.dart';
import '../controllers/style_controller.dart';

class ItemScreen extends StatefulWidget {
  final String type;

  const ItemScreen({super.key, required this.type});

  @override
  State<ItemScreen> createState() => _ItemScreenState();
}

class _ItemScreenState extends State<ItemScreen> {
  late final ItemController _controller;
  late Future<List<SummaryEntity>?> _resultsFuture;

  @override
  void initState() {
    super.initState();
    _controller = ItemController(type: widget.type);
    _resultsFuture = _fetchResults();
  }

  Future<List<SummaryEntity>?> _fetchResults() async {
    await _controller.fetchSummariesByType();
    return _controller.getResults();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width / 375;
    final screenHeight = MediaQuery.of(context).size.height / 812;
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.type),
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
                    subtitle: Text(
                      snapshot.data![index].content!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, color: themeNotifier.mode == Mode.light ? Colors.grey : Color(0xFFCBCBCB), size: screenWidth * 16),
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Details'),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: <Widget>[
                                    Text(snapshot.data![index].content!),
                                  ],
                                )
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Back'),
                                )
                              ],
                            );
                          }
                      );
                    },
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