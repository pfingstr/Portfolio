import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../Theme_controller.dart';
import '../models/Journal_entry.dart';

class AddScreen extends StatefulWidget {
//  @override
  static const routeName = 'add';
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  final formKey = GlobalKey<FormState>();

  final journalEntryField = JournalEntry();

  ThemeController themeController;

  bool valueCheck() {
    if (ThemeController.of(context).currentTheme == 'light') {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      return Scaffold(
          appBar: AppBar(
            title: Text('New Entry'),
          ),
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
          body: Padding(
              padding: const EdgeInsets.all(10),
              child: Form(
                  key: formKey,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        TextFormField(
                          autofocus: true,
                          decoration: InputDecoration(
                              labelText: 'Title', border: OutlineInputBorder()),
                          onSaved: (value) {
                            journalEntryField.title = value;
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a title';
                            } else {
                              return null;
                            }
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          autofocus: true,
                          decoration: InputDecoration(
                              labelText: 'Body', border: OutlineInputBorder()),
                          onSaved: (value) {
                            journalEntryField.body = value;
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a body';
                            } else {
                              return null;
                            }
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          autofocus: true,
                          decoration: InputDecoration(
                              labelText: 'Rating',
                              border: OutlineInputBorder()),
                          onSaved: (value) {
                            journalEntryField.rating = int.parse(value);
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a rating';
                            } else if ((int.parse(value) > 4) |
                                (int.parse(value) < 1)) {
                              return 'Please enter rating between 1 and 4';
                            } else {
                              return null;
                            }
                          },
                        ),
                        SizedBox(height: 10),
                        RaisedButton(
                          onPressed: () async {
                            //await deleteDatabase('journal.db');
                            journalEntryField.date = DateTime.now();
                            if (formKey.currentState.validate()) {
                              formKey.currentState.save();
                              //await deleteDatabase('journal.db');
                              final Database database = await openDatabase(
                                  'journal.db',
                                  version: 1,
                                  onCreate: (Database db, int version) async {
                                await db.execute(
                                    'CREATE TABLE IF NOT EXISTS journal_entries(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, body TEXT NOT NULL, rating INTEGER NOT NULL, date TEXT NOT NULL)');
                              });
                              await database.transaction((txn) async {
                                await txn.rawInsert(
                                    'INSERT INTO journal_entries(title, body, rating, date) VALUES (?,?,?,?)',
                                    [
                                      journalEntryField.title,
                                      journalEntryField.body,
                                      journalEntryField.rating,
                                      journalEntryField.date.toString()
                                    ]);
                              });
                              await database.close();
                              Navigator.of(context).pop();
                            }
                          },
                          child: Text('Save Entry'),
                        )
                      ]))));
    } else {
      return Scaffold(
          appBar: AppBar(
            title: Text('New Entry'),
          ),
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
          body: SingleChildScrollView(
              child: Form(
                  key: formKey,
                  child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(children: [
                        TextFormField(
                          autofocus: true,
                          decoration: InputDecoration(
                              labelText: 'Title', border: OutlineInputBorder()),
                          onSaved: (value) {
                            journalEntryField.title = value;
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a title';
                            } else {
                              return null;
                            }
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          autofocus: true,
                          decoration: InputDecoration(
                              labelText: 'Body', border: OutlineInputBorder()),
                          onSaved: (value) {
                            journalEntryField.body = value;
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a body';
                            } else {
                              return null;
                            }
                          },
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          autofocus: true,
                          decoration: InputDecoration(
                              labelText: 'Rating',
                              border: OutlineInputBorder()),
                          onSaved: (value) {
                            journalEntryField.rating = int.parse(value);
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a rating';
                            } else if ((int.parse(value) > 4) |
                                (int.parse(value) < 1)) {
                              return 'Please enter rating between 1 and 4';
                            } else {
                              return null;
                            }
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        RaisedButton(
                          onPressed: () async {
                            //await deleteDatabase('journal.db');
                            journalEntryField.date = DateTime.now();
                            if (formKey.currentState.validate()) {
                              formKey.currentState.save();
                              //await deleteDatabase('journal.db');
                              final Database database = await openDatabase(
                                  'journal.db',
                                  version: 1,
                                  onCreate: (Database db, int version) async {
                                await db.execute(
                                    'CREATE TABLE IF NOT EXISTS journal_entries(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, body TEXT NOT NULL, rating INTEGER NOT NULL, date TEXT NOT NULL)');
                              });
                              await database.transaction((txn) async {
                                await txn.rawInsert(
                                    'INSERT INTO journal_entries(title, body, rating, date) VALUES (?,?,?,?)',
                                    [
                                      journalEntryField.title,
                                      journalEntryField.body,
                                      journalEntryField.rating,
                                      journalEntryField.date.toString()
                                    ]);
                              });
                              await database.close();
                              Navigator.of(context).pop();
                            }
                          },
                          child: Text('Save Entry'),
                        )
                      ])))));
    }
  }
}
