/// Extension de la classe [String] permettant l'ajout de méthodes
///
/// Extension of [String] class in order to add methods
extension StringExtension on String {

  /// Met en majuscule la première lettre d'une chaîne de charactères
  ///
  /// Capitalize first letter of a string
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

}

/// Extension de la classe [int] permettant l'ajout de méthodes
///
/// Extension of [int] class in order to add methods
extension IntExtension on int {

  /// Ajoute un zéro devant le nombre et le retourne sous forme de chaîne de charactères
  ///
  /// Add zero in front of number and returns it as a string
  String asTimeString() {
    return (this < 10) ? '0$this' : '$this';
  }

}