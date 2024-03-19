import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/var_json.dart';


// Config Screen
class ConfigScreen extends StatelessWidget{
  final ValueNotifier<bool> currentIsDarkMode;
  final ValueNotifier<Locale> currentLocale;
  final ValueNotifier<String> currentColor;
  final ValueNotifier<String> currentStartScreen;

  const ConfigScreen({super.key, 
    required this.currentIsDarkMode, 
    required this.currentLocale, 
    required this.currentColor, 
    required this.currentStartScreen
    });


  @override
  Widget build(BuildContext context) {

    // Save settings to file
    Future<void> saveSettings() async {
      final prefs = await SharedPreferences.getInstance();

      prefs.setBool('isDarkMode', currentIsDarkMode.value);
      prefs.setString('languageCode', currentLocale.value.languageCode);
      prefs.setString('colorTheme', currentColor.value);
      prefs.setString('startScreen', currentStartScreen.value);
    }

    var routeNameInitialItem = searchNameByRoute(currentStartScreen.value);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.configsPageTitle),
      ),


      body: Container()
    );
  }
}