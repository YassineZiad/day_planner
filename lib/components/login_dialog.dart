import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repositories/user_repository.dart';

class LoginDialog extends StatelessWidget {

  static final _formKey = GlobalKey<FormState>();

  static TextEditingController emailController = TextEditingController();
  static TextEditingController passwordController = TextEditingController();

  static Future<void> loginDialogBuilder(BuildContext context) {
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
                          bool r = await UserRepository.login(emailController.text, passwordController.text);
                          if (r) {
                            SharedPreferences sp = await SharedPreferences.getInstance();
                            String? token = sp.getString('token');
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Connecté !")));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
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

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }

}