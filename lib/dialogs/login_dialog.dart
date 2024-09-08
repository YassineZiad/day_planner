import 'package:day_planner/configs/app_config.dart';
import 'package:day_planner/models/user.dart';
import 'package:day_planner/repositories/user_repository.dart';
import 'package:flutter/material.dart';

/// Classe du dialog de connexion et de création de compte.
///
/// Affiche les informations de l'utilisateur une fois connecté.
class LoginDialog {

  static bool isConnected = false;

  static final _loginFormKey = GlobalKey<FormState>();
  static final TextEditingController _loginEmailController = TextEditingController();
  static final TextEditingController _loginPasswordController = TextEditingController();

  static final _registerFormKey = GlobalKey<FormState>();
  static final TextEditingController _registerEmailController = TextEditingController();
  static final TextEditingController _registerNicknameController = TextEditingController();
  static final TextEditingController _registerPassword1Controller = TextEditingController();
  static final TextEditingController _registerPassword2Controller = TextEditingController();

  static Future<void> buildUserDialog(User? user, bool connected, BuildContext context) {

    isConnected = connected;

    if (connected) {

      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {

          // Compte connecté
          return SimpleDialog(
            title: const Text('Profil'),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${user!.nickname} (${user.mail})", style: TextStyle(fontSize: DayPlannerConfig.fontSizeS)),
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

      // Connexion Utilisateur
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
                      controller: _loginEmailController,
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
                      controller: _loginPasswordController,
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
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Connexion...")));
                                bool r = await UserRepository.login(
                                    _loginEmailController.text,
                                    _loginPasswordController.text
                                );
                                if (r) {
                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text("Identifiants incorrects.")
                                      ));
                                }
                                _loginPasswordController.text = "";
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
                      controller: _registerEmailController,
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
                      controller: _registerNicknameController,
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
                      controller: _registerPassword1Controller,
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
                      controller: _registerPassword2Controller,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Confirmez le mot de passe';
                        }
                        if (value != _registerPassword1Controller.text) {
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
                                _registerNicknameController.text, _registerEmailController.text, _registerPassword1Controller.text
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