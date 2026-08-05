/// Table des diacritiques latins courants vers leur equivalent ASCII.
///
/// Pourquoi une table statique plutot qu'une lib de normalisation Unicode
/// (type NFD + suppression des marques combinantes) : le SDK Dart standard
/// n'expose pas de normalisation Unicode native, et le projet n'a pas de
/// dependance dediee (`unicode`/`characters` ne suffisent pas seuls). Le
/// perimetre metier (noms d'exercices/muscles en francais) est restreint a
/// un alphabet latin connu, donc une table explicite est plus simple, plus
/// rapide et enterement testable, plutot que d'ajouter une dependance pour
/// un besoin borne.
const Map<String, String> _diacriticsToAscii = {
  'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a', 'ã': 'a', 'å': 'a',
  'ç': 'c',
  'è': 'e', 'é': 'e', 'ê': 'e', 'ë': 'e',
  'ì': 'i', 'í': 'i', 'î': 'i', 'ï': 'i',
  'ñ': 'n',
  'ò': 'o', 'ó': 'o', 'ô': 'o', 'ö': 'o', 'õ': 'o',
  'ù': 'u', 'ú': 'u', 'û': 'u', 'ü': 'u',
  'ý': 'y', 'ÿ': 'y',
  'œ': 'oe', 'æ': 'ae',
};

/// Normalise une chaine pour une comparaison insensible a la casse et aux
/// accents (ex: 'DÉVELOPPÉ' et 'developpe' produisent le meme resultat).
///
/// Utilisee par la recherche du catalogue d'exercices : les utilisateurs
/// tapent souvent leur requete sans accents ou dans une casse quelconque
/// (clavier, autocorrection, habitude), et il ne faut pas que cela les prive
/// de resultats pourtant pertinents. Fonction pure, sans effet de bord, donc
/// testable isolement sans dependre du provider ni de Firestore.
String normalizeString(String input) {
  final lowered = input.trim().toLowerCase();
  final buffer = StringBuffer();

  for (final rune in lowered.runes) {
    final char = String.fromCharCode(rune);
    buffer.write(_diacriticsToAscii[char] ?? char);
  }

  return buffer.toString();
}
