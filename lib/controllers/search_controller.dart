import 'package:app/models/record_entity.dart';
import 'package:app/models/summary_entity.dart';
import 'package:app/services/embeddings_service.dart';
import 'package:app/services/objectbox_service.dart';

class NativeSearchController {
  List<SummaryEntity> resultToBeShown = [];

  NativeSearchController();

  Future<void> fetchSummariesByQuery(String query) async {
    Embeddings embeddings = await Embeddings.create();
    final vector = await embeddings.getEmbeddings(query);
    final results = ObjectBoxService().getSimilarSummariesByContents(vector!, 2);
    for (final result in results) {
      for (final summaryEntity in result.keys) {
        resultToBeShown.add(summaryEntity);
      }
    }
  }

  Future<void> fetchSummariesByKeyword(String keyword) async {
    final results = ObjectBoxService().getSummariesByKeyword(keyword);
    for (final result in results!) {
      resultToBeShown.add(result);
    }
  }

  List<SummaryEntity>? getResults() {
    return resultToBeShown.isEmpty ? null : resultToBeShown;
  }
}