import 'package:flutter/material.dart';
import 'package:journal/screens/Add_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Theme_controller.dart';
import 'screens/View_screen.dart';
import 'components/Journal_scaffold.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.portraitUp
  ]);
  final prefs = await SharedPreferences.getInstance();
  final themeController = ThemeController(prefs);
  runApp(MyApp(themeController: themeController));
}

class MyApp extends StatelessWidget {
  final ThemeController themeController;
  const MyApp({Key key, this.themeController}) : super(key: key);
  Map<String, WidgetBuilder> getRoutes() {
    return {
      'view': (context) => ViewPage(),
      'add': (context) => AddScreen(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        return ThemeControllerProvider(
          controller: themeController,
          child: MaterialApp(
            title: 'Flutter Demo',
            theme: _buildCurrentTheme(),
            home: MyScaffold(),
            routes: getRoutes(),
          ),
        );
      },
    );
  }

  ThemeData _buildCurrentTheme() {
    switch (themeController.currentTheme) {
      case "dark":
        return ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.lightGreen,
            primaryColor: Colors.lightGreen,
            accentColor: Colors.lightGreenAccent);

      case "light":
      default:
        return ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
        );
    }
  }
}
