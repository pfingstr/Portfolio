import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

//src:https://stackoverflow.com/questions/53105320/how-to-load-theme-at-beginning-in-fluttter/53107519#53107519
// I hate to use something from the web but I couldnt get the prefrences to save on my own with the videos

class ThemeController extends ChangeNotifier {
  static const themePrefKey = 'theme';

  ThemeController(this._prefs) {
    _currentTheme = _prefs.getString(themePrefKey) ?? 'light';
  }

  final SharedPreferences _prefs;
  String _currentTheme;

  String get currentTheme => _currentTheme;

  void setTheme(String theme) {
    _currentTheme = theme;

    notifyListeners();

    _prefs.setString(themePrefKey, theme);
  }

  //Changed from stackoverflow post to updated format.
  static ThemeController of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<ThemeControllerProvider>();
    return provider.controller;
  }
}

class ThemeControllerProvider extends InheritedWidget {
  const ThemeControllerProvider({Key key, this.controller, Widget child})
      : super(key: key, child: child);

  final ThemeController controller;

  @override
  bool updateShouldNotify(ThemeControllerProvider old) =>
      controller != old.controller;
}
