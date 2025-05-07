import 'dart:io';

import 'package:app/models/record_entity.dart';
import 'package:app/models/summary_entity.dart';
import 'package:app/services/embeddings_service.dart';
import 'package:app/services/objectbox_service.dart';

class ItemController {
  final String type;
  List<SummaryEntity> resultToBeShown = [];

  ItemController({required this.type});

  Future<void> fetchSummariesByType() async {
    final results = ObjectBoxService().getSummariesBySubject(type);
    if (results == null) {
      return;
    }
    for (var result in results) {
      resultToBeShown.add(result);
    }
  }

  List<SummaryEntity>? getResults() {
    return resultToBeShown.isEmpty ? null : resultToBeShown;
  }
}