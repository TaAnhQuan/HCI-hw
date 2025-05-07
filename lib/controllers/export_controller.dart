import 'dart:convert';
import 'dart:io';

import 'package:app/models/record_entity.dart';
import 'package:app/services/objectbox_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';

class ExportDataDialog extends StatefulWidget {
  @override
  _ExportDataDialogState createState() => _ExportDataDialogState();
}

class _ExportDataDialogState extends State<ExportDataDialog> {
  DateTimeRange? _selectedDateRange;
  TextEditingController _fileNameController = TextEditingController();
  String _fileName = 'exported_data.csv';

  @override
  void initState() {
    super.initState();
    _fileNameController.text = _fileName;
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  Future<void> _pickDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null && picked != _selectedDateRange)
      setState(() {
        _selectedDateRange = picked;
      });
  }

  Future<String?> _pickDirectory() async {
    final result = await FilePicker.platform.getDirectoryPath();
    return result;
  }
  Future<String> _getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<void> _exportData() async {
    String? path = await _pickDirectory();

    List<RecordEntity>? results;
    if (_selectedDateRange == null) {
      results = ObjectBoxService().getRecords();
    } else {
      results = ObjectBoxService().getRecordsByTimeRange(
        _selectedDateRange!.start.millisecondsSinceEpoch,
        _selectedDateRange!.end.millisecondsSinceEpoch,
      );
    }

    List<List<dynamic>> rows = [];
    rows.add(['Role', 'Content', 'Timestamp']);
    for (var record in results!) {
      rows.add([record.role, record.content, DateTime.fromMillisecondsSinceEpoch(record.createdAt!).toString()]);
    }
    String csvData = ListToCsvConverter().convert(rows);
    if (path != null) {
      String filePath = '$path/$_fileName';
      if (!filePath.endsWith('.csv')) {
        filePath = '$filePath.csv';
      }
      File(filePath).writeAsBytes(utf8.encode(csvData)).then((file) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File has been saved to: ${file.path}')),
        );
      }).catchError((e) {
        print('Error saving CSV file: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving file: $e')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Export Data'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Select Date Range'),
              subtitle: _selectedDateRange == null
                  ? Text('No date range selected')
                  : Text('From ${_selectedDateRange!.start} to ${_selectedDateRange!.end}'),
              onTap: _pickDateRange,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'File Name'),
              controller: _fileNameController,
              onChanged: (value) {
                setState(() {
                  _fileName = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Confirm'),
          onPressed: () async {
            await _exportData();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class ExportLatencyLog extends StatefulWidget {
  @override
  _ExportLatencyLogState createState() => _ExportLatencyLogState();
}

class _ExportLatencyLogState extends State<ExportLatencyLog> {
  TextEditingController _fileNameController = TextEditingController();
  String _fileName = 'latency_log.txt';

  @override
  void initState() {
    super.initState();
    _fileNameController.text = _fileName;
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }

  Future<String?> _pickDirectory() async {
    final result = await FilePicker.platform.getDirectoryPath();
    return result;
  }

  Future<void> _exportData() async {
    String? path = await _pickDirectory();

    String results;

    final directory = await getApplicationDocumentsDirectory();
    final logFile = File('${directory.path}/latency_report.txt');

    try {
      results = await logFile.readAsString();
    } catch (e) {
      print("Error reading file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving file: $e')),
      );
      return;
    }

    if (path != null) {
      String filePath = '$path/$_fileName';
      if (!filePath.endsWith('.txt')) {
        filePath = '$filePath.txt';
      }
      File(filePath).writeAsBytes(utf8.encode(results)).then((file) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File has been saved to: ${file.path}')),
        );
      }).catchError((e) {
        print('Error saving TXT file: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving file: $e')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Export Latency Log'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'File Name'),
              controller: _fileNameController,
              onChanged: (value) {
                setState(() {
                  _fileName = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Confirm'),
          onPressed: () async {
            await _exportData();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}