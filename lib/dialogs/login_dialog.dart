import 'package:day_planner/models/user.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repositories/user_repository.dart';

class LoginDialog {

  static bool isConnected = false;

  static final _loginFormKey = GlobalKey<FormState>();
  static TextEditingController loginEmailController = TextEditingController();
  static TextEditingController loginPasswordController = TextEditingController();

  static final _registerFormKey = GlobalKey<FormState>();
  static TextEditingController registerEmailController = TextEditingController();
  static TextEditingController registerNicknameController = TextEditingController();
  static TextEditingController registerPassword1Controller = TextEditingController();
  static TextEditingController registerPassword2Controller = TextEditingController();

  static Future<void> buildUserDialog(User? user, bool connected, BuildContext context) {

    isConnected = connected;

    if (connected) {

      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {

          return SimpleDialog(
            title: const Text('Profil'),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${user!.nickname} (${user!.mail})"),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await UserRepository.disconnect();
                          isConnected = false;
                          Navigator.pop(context);
                        },
                        child: const Text('Déconnexion'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          showDialog(context: context, builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Supprimer"),
                              content: const Text("Supprimer votre compte ? L'action est irréversible."),
                              icon: const Icon(Icons.delete_forever),
                              actions: [
                                TextButton(
                                  child: const Text("Annuler"),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                TextButton(
                                  child: const Text("Supprimer"),
                                  onPressed: () async {
                                    bool b = await UserRepository.deleteUser();
                                    if (b) {
                                      Navigator.pop(context);
                                      await UserRepository.disconnect();
                                      isConnected = false;
                                      Navigator.pop(context);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Echec de la suppression du compte...")));
                                    }
                                  },
                                )
                              ],
                            );
                          });
                        },
                        child: const Text('Supprimer le compte'),
                      )
                    ],
                  )
                ],
              )
            ],
          );

        }
      );

    } else {

      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {

          return SimpleDialog(
            title: const Text('Connexion Utilisateur'),
            children: <Widget>[
              Form(
                key: _loginFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Adresse mail'),
                      controller: loginEmailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Il manque l\'adresse mail';
                        }
                        return null;
                      }
                    ),
                    TextFormField(
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: const InputDecoration(
                          labelText: 'Mot de passe'),
                      controller: loginPasswordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Il manque le mot de passe';
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              if (_loginFormKey.currentState!.validate()) {
                                bool r = await UserRepository.login(
                                    loginEmailController.text,
                                    loginPasswordController.text
                                );
                                if (r) {
                                  SharedPreferences sp = await SharedPreferences
                                      .getInstance();
                                  Navigator.pop(context);
                                  //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Connecté !")));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text("Identifiants incorrects.")
                                      ));
                                }
                                isConnected = r;
                              }
                            },
                            child: const Text('Valider'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              buildRegisterDialog(context);
                            },
                            child: const Text('Créer un compte'),
                          )
                        ],
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
  }


  static Future<void> buildRegisterDialog(BuildContext context) {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Nouveau Compte Utilisateur'),
            children: <Widget>[
              Form(
                key: _registerFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      autocorrect: false,
                      decoration: const InputDecoration(labelText: 'Adresse mail'),
                      controller: registerEmailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Il manque l\'adresse mail';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: const InputDecoration(labelText: 'Nom d\'utilisateur'),
                      controller: registerNicknameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Il manque le pseudo';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: const InputDecoration(labelText: 'Mot de passe'),
                      controller: registerPassword1Controller,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez saisir un mot de passe';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: const InputDecoration(labelText: 'Confirmer le mot de passe'),
                      controller: registerPassword2Controller,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirmez le mot de passe';
                        }
                        if (value != registerPassword1Controller.text) {
                          return 'Les mots de passe ne correspondent pas';
                        }
                        return null;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_registerFormKey.currentState!.validate()) {
                            bool r = await UserRepository.register(
                                registerNicknameController.text, registerEmailController.text, registerPassword1Controller.text
                            );
                            if (r) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Compte créé, veuillez vous connecter.")));
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

}