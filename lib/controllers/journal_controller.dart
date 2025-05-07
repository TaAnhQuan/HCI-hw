import '../models/summary_entity.dart';
import '../services/objectbox_service.dart';

class JournalController {

  // List to hold fetched journal summaries
  List<SummaryEntity> summaries = [];

  JournalController() {
    fetchSummaries();
  }

  // Fetch summaries from the database
  void fetchSummaries() {
    summaries = ObjectBoxService.summaryBox.getAll();
  }
}
