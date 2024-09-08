import 'dart:io';

/// Classe pour effectuer des requêtes HTTP sur l'api de développement.
///
/// A UTILISER QU'EN VERSION DE DEVELOPPEMENT
class CustomHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}