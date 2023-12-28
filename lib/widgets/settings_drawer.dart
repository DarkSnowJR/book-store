import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsDrawer extends StatefulWidget {
  const SettingsDrawer({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SettingsDrawerState createState() => _SettingsDrawerState();
}

class _SettingsDrawerState extends State<SettingsDrawer> {
  int _fontSize = 16; // Default font size as an int

  @override
  void initState() {
    super.initState();
    _loadFontSize();
  }

  _loadFontSize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = prefs.getInt('fontSize') ?? 16;
    });
  }

  _saveFontSize(int fontSize) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('fontSize', fontSize);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [Colors.red, Colors.blue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )),
            child: Text(
              'Settings',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
          ListTile(
            title: const Text('Dark/Light Theme'),
            trailing: Switch(
              activeColor: Colors.white,
              value: Provider.of<ThemeProvider>(context).themeMode ==
                  ThemeMode.dark,
              onChanged: (value) {
                Provider.of<ThemeProvider>(context, listen: false)
                    .toggleTheme();
              },
            ),
          ),
          ListTile(
            title: const Text('Font Size'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Font Size: $_fontSize'),
                Slider(
                  value: _fontSize.toDouble(),
                  min: 12.0,
                  max: 24.0,
                  onChanged: (value) {
                    setState(() {
                      _fontSize = value.round();
                    });
                  },
                  onChangeEnd: (value) {
                    _saveFontSize(value.round());
                  },
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Start: 12'),
                    Text('End: 24'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
