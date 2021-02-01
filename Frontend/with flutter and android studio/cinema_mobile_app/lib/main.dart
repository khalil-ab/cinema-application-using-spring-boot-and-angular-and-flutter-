import 'package:flutter/material.dart';
import 'MenuItem.dart';
import 'VillePage.dart';
import 'SettingPage.dart';

void main() => runApp(MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(color: Colors.orange),
      ),
      home: MyApp(),
    ));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final menus = [
    {'title': 'Home', 'icon': Icon(Icons.home), 'page': VillePage()},
    {'title': 'Setting', 'icon': Icon(Icons.settings), 'page': SettingPage()},
    {'title': 'Contact', 'icon': Icon(Icons.contact_mail), 'page': SettingPage()},

  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("cinema page"),
      ),
      body: Center(
        child: Text("Home Cinema ..."),
      ),
      drawer: Drawer(
        child: ListView(children: [
          DrawerHeader(
            child: Center(
              child: CircleAvatar(
                backgroundImage: AssetImage("./images/cinema.jpg"),
                radius: 70,
              ),
            ),
            decoration: BoxDecoration(
                gradient:
                    LinearGradient(colors: [Colors.white, Colors.orange])),
          ),
          ...this.menus.map((item) {
            return new Column(
              children: [
                Divider(color: Colors.orange),
                MenuItem(item['title'],item['icon'], (context) {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => item['page']));
                })
              ],
            );
          })
        ]),
      ),
    );
  }
}
