import 'package:flutter/material.dart';
import 'package:card_settings/card_settings.dart';
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


      body: SafeArea(
        child: SingleChildScrollView(
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child:CardSettings.sectioned(
                  children: [

                    CardSettingsSection(
                      header: CardSettingsHeader(
                        label: AppLocalizations.of(context)!.configsHeader,
                      ),
                      children: [

                        // Config Theme
                        CardSettingsSwitch(
                          trueLabel: '', 
                          falseLabel: '',
                          label: AppLocalizations.of(context)!.configsModeTheme,
                          initialValue:  currentIsDarkMode.value,
                          onChanged: (value) {
                            currentIsDarkMode.value = value;
                            saveSettings();
                          },
                        ),

                        // Config Locale
                        CardSettingsListPicker(
                          label: AppLocalizations.of(context)!.configsLanguagePick,
                          items: AppLocalizations.supportedLocales,
                          initialItem: currentLocale.value,
                          onChanged: (value1) {
                            currentLocale.value = value1!;
                            saveSettings();
                          }
                        ),

                        // Config Color
                        CardSettingsListPicker(
                          items: varColor.map((item) => item['name']).toList(),
                          label: AppLocalizations.of(context)!.configColor,
                          
                          initialItem: currentColor.value,

                          onChanged: (value2) {
                            currentColor.value = value2.toString();
                            saveSettings();
                          },
                        ),
                        CardSettingsListPicker(
                          label: AppLocalizations.of(context)!.configStartScreen,
                          items: starScreenList.map((item) => item['name']).toList(),
                          initialItem:  routeNameInitialItem,
                          onChanged: (value3) {
                            var routeFinal = searchRouteByName(value3.toString());
                            currentStartScreen.value = routeFinal;

                            saveSettings();
                          },
                        )
                      ],
                    ),
                  ],
                ),
              )
            ),
          ),
        ),
      ),
    );
  }
}