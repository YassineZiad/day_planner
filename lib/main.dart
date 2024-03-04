import 'package:day_planner_web/components/current_time_line.dart';
import 'package:day_planner_web/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:io' show Platform;

import 'package:shared_preferences/shared_preferences.dart';

import 'components/day_table.dart';

void main() {
  initSP();
  runApp(const MyApp());
}

void initSP() async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  sp.setString('url', "https://localhost:8000/api/");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Day Planner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Day Planner'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  DateTime currentTime = DateTime.now();
  String displayTime = "00:00";
  int timelineDistance = 0;


  void _updateTime() {
    setState(() {
      currentTime = DateTime.now();

      var currentHour = currentTime.hour < 10 ? "0${currentTime.hour}" : currentTime.hour;
      var currentMinute = currentTime.minute < 10 ? "0${currentTime.minute}" : currentTime.minute;
      displayTime = "$currentHour:$currentMinute";

      timelineDistance = currentTime.hour * 60 + currentTime.minute;
    });
  }


  @override
  void initState() {
    super.initState();
    _updateTime();

    var now = DateTime.now();
    Timer.periodic(const Duration(minutes: 1) - Duration(seconds: now.second), (Timer t) => _updateTime());
  }

  @override
  Widget build(BuildContext context) {

    final _formKey = GlobalKey<FormState>();

    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    // FORM CONNEXION UTILISATEUR
    Future<void> _loginDialogBuilder(BuildContext context) {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Connexion Utilisateur'),
            children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Adresse mail'),
                    controller: emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Il manque l\'adresse mail';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: const InputDecoration(labelText: 'Mot de passe'),
                    controller: passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Il manque le mot de passe';
                      }
                      return null;
                    },
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        bool r = await UserRepository().login(emailController.text, passwordController.text);
                        if (r) {
                          SharedPreferences sp = await SharedPreferences.getInstance();
                          String? token = sp.getString('token');
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Connecté !")));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Veuillez vérifier les identifiants.")
                          ));
                        }
                      }
                    },
                    child: const Text('Valider'),
                  ),
                ),
              ],
            ),
          )
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle),
              tooltip: 'Se connecter',
              onPressed: () => _loginDialogBuilder(context),
            )
          ]
      ),
      body: GridView(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        padding: EdgeInsets.all(10),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1),
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              CurrentTimeLine(distance: timelineDistance, currentTime: displayTime)
            ],
          ),

          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Coucou")
            ],
          )
        ],
      ),
    );
  }
}

