import 'package:flutter/material.dart';
import '../Theme_controller.dart';
import 'package:intl/intl.dart';

class ViewPage extends StatefulWidget {
  final String title;
  final String body;
  final DateTime date;
  const ViewPage({Key key, this.title, this.body, this.date}) : super(key: key);

  @override
  _ViewPageState createState() => _ViewPageState();
}

class _ViewPageState extends State<ViewPage> {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(DateFormat.yMd().format(widget.date)),
      ),
      //body: Text(widget.body),
      body: ListTile(
        title: Text(
          widget.title,
          style: TextStyle(fontSize: 30),
        ),
        subtitle: Text(widget.body, style: TextStyle(fontSize: 20)),
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
    );
  }
}
