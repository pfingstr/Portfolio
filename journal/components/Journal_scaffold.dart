import 'package:flutter/material.dart';
import '../Theme_controller.dart';
import '../screens/View_screen.dart';
import '../models/Journal_entry.dart';
//import '../models/Journal.dart';
import 'package:sqflite/sqflite.dart';
import '../screens/Add_screen.dart';

class MyScaffold extends StatefulWidget {
  @override
  _MyScaffoldState createState() => _MyScaffoldState();
}

class _MyScaffoldState extends State<MyScaffold> {
  ThemeController themeController;

  List<JournalEntry> journal;

  String wideViewTitle = '';
  String wideViewBody = '';
  String wideViewDate = '';

  @override
  void initState() {
    super.initState();
    loadJournal();
  }

  void loadJournal() async {
    final Database database = await openDatabase('journal.db', version: 1,
        onCreate: (Database db, int version) async {
      await db.execute(
          'CREATE TABLE IF NOT EXISTS journal_entries(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, body TEXT NOT NULL, rating INTEGER NOT NULL, date TEXT NOT NULL)');
    });
    List<Map> journalRecords =
        await database.rawQuery('SELECT * FROM journal_entries');

    final journalEntries = journalRecords.map((record) {
      return JournalEntry(
          title: record['title'],
          body: record['body'],
          rating: record['rating'],
          date: DateTime.parse(record['date']));
    }).toList();

    setState(() {
      journal = journalEntries;
    });
  }

  bool valueCheck() {
    if (ThemeController.of(context).currentTheme == 'light') {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (journal == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Loading'),
        ),
        body: Center(child: CircularProgressIndicator()),
        endDrawer: Drawer(
            elevation: 16.0,
            child: Column(
              children: <Widget>[
                ListTile(
                  title: new Text("SETTINGS"),
                ),
                SwitchListTile(
                  title: Text(ThemeController.of(context).currentTheme),
                  value: valueCheck(),
                  onChanged: (value) {
                    if (ThemeController.of(context).currentTheme == 'light') {
                      ThemeController.of(context).setTheme('dark');
                    } else {
                      ThemeController.of(context).setTheme('light');
                    }
                  },
                ),
              ],
            )),
      );
    } else if (journal.length == 0) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Welcome'),
        ),
        body: Center(
            child: FloatingActionButton(
                child: Icon(Icons.book),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddScreen()),
                  ).then((res) => loadJournal());
                })),
        endDrawer: Drawer(
            elevation: 16.0,
            child: Column(
              children: <Widget>[
                ListTile(
                  title: new Text("SETTINGS"),
                ),
                SwitchListTile(
                  title: Text(ThemeController.of(context).currentTheme),
                  value: valueCheck(),
                  onChanged: (value) {
                    if (ThemeController.of(context).currentTheme == 'light') {
                      ThemeController.of(context).setTheme('dark');
                    } else {
                      ThemeController.of(context).setTheme('light');
                    }
                  },
                ),
              ],
            )),
      );
    } else {
      if (MediaQuery.of(context).orientation == Orientation.portrait) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Journal Entries'),
          ),
          body: ListView.builder(
              itemCount: journal.length,
              itemBuilder: (context, index) {
                return ListTile(
                    leading: Icon(Icons.access_time),
                    trailing: Icon(Icons.more_horiz),
                    title: Text(journal[index].title),
                    subtitle: Text(journal[index].date.toString()),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => ViewPage(
                              title: journal[index].title,
                              body: journal[index].body,
                              date: journal[index].date)));
                    });
              }),
          floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddScreen()),
                ).then((res) => loadJournal());
              }),
          endDrawer: Drawer(
              elevation: 16.0,
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: new Text("SETTINGS"),
                  ),
                  SwitchListTile(
                    title: Text(ThemeController.of(context).currentTheme),
                    value: valueCheck(),
                    onChanged: (value) {
                      if (ThemeController.of(context).currentTheme == 'light') {
                        ThemeController.of(context).setTheme('dark');
                      } else {
                        ThemeController.of(context).setTheme('light');
                      }
                    },
                  ),
                ],
              )),
        );
      } else {
        return Scaffold(
          appBar: AppBar(
            title: Text('Journal Entries'),
          ),
          body: Row(children: <Widget>[
            Expanded(
                child: ListView.builder(
                    itemCount: journal.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                          leading: Icon(Icons.access_time),
                          trailing: Icon(Icons.more_horiz),
                          title: Text(journal[index].title),
                          subtitle: Text(journal[index].body),
                          onTap: () {
                            setState(() {
                              wideViewTitle = journal[index].title;
                              wideViewBody = journal[index].body;
                              wideViewDate = journal[index].date.toString();
                            });
                          });
                    })),
            Expanded(
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(children: [
                      Text(wideViewTitle),
                      Text(wideViewBody),
                      Text(wideViewDate)
                    ])))
          ]),
          floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddScreen()),
                ).then((res) => loadJournal());
              }),
          endDrawer: Drawer(
              elevation: 16.0,
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: new Text("SETTINGS"),
                  ),
                  SwitchListTile(
                    title: Text(ThemeController.of(context).currentTheme),
                    value: valueCheck(),
                    onChanged: (value) {
                      if (ThemeController.of(context).currentTheme == 'light') {
                        ThemeController.of(context).setTheme('dark');
                      } else {
                        ThemeController.of(context).setTheme('light');
                      }
                    },
                  ),
                ],
              )),
        );
      }
    }
  }
}
