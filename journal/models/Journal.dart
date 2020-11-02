import 'Journal_entry.dart';

class Journal {
  List<JournalEntry> entryList;

  Journal({this.entryList});

  bool isEmpty() {
    if (entryList.length == 0) {
      return true;
    } else
      return false;
  }
}
