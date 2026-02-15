import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Service d'authentification Google avec Firebase
/// Gère la connexion, déconnexion et création du profil utilisateur
/// Respecte RG-001: Authentification Google obligatoire
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Utilisateur actuellement connecté (null si déconnecté)
  User? get currentUser => _auth.currentUser;

  /// Stream des changements d'état d'authentification
  /// Utilisé pour l'auto-login (US-1.2)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Connexion avec Google Sign-In (US-1.1)
  /// 
  /// Processus:
  /// 1. Déconnexion Google pour forcer sélection de compte
  /// 2. Authentification Google (popup)
  /// 3. Authentification Firebase avec credentials Google
  /// 4. Création/Mise à jour profil utilisateur dans Firestore
  /// 
  /// Throws:
  /// - Exception si l'utilisateur annule
  /// - FirebaseAuthException en cas d'erreur Firebase
  /// - Exception en cas d'erreur réseau
  Future<UserCredential> signInWithGoogle() async {
    try {
      // Déconnexion Google pour forcer sélection de compte
      await _googleSignIn.signOut();

      // Déclencher le flux d'authentification Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Utilisateur a annulé la connexion
      if (googleUser == null) {
        throw Exception('Connexion annulée par l\'utilisateur');
      }

      // Obtenir les détails d'authentification
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Créer les credentials Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Connecter avec Firebase
      final UserCredential userCredential = 
          await _auth.signInWithCredential(credential);

      // Créer ou mettre à jour le profil utilisateur dans Firestore
      if (userCredential.user != null) {
        await _createOrUpdateUserProfile(userCredential.user!);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Erreurs Firebase spécifiques
      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw Exception('Un compte existe déjà avec cette adresse email');
        case 'invalid-credential':
          throw Exception('Identifiants invalides');
        case 'operation-not-allowed':
          throw Exception('Connexion Google non activée');
        case 'user-disabled':
          throw Exception('Ce compte a été désactivé');
        default:
          throw Exception('Erreur d\'authentification: ${e.message}');
      }
    } catch (e) {
      // Autres erreurs (réseau, etc.)
      throw Exception('Erreur lors de la connexion: $e');
    }
  }

  /// Déconnexion (US-1.3)
  /// Déconnecte à la fois de Firebase et de Google Sign-In
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Erreur lors de la déconnexion: $e');
    }
  }

  /// Créer ou mettre à jour le profil utilisateur dans Firestore
  /// Collection: users/{userId}
  /// 
  /// Structure document:
  /// - uid: ID utilisateur Firebase
  /// - email: Email du compte Google
  /// - displayName: Nom complet
  /// - photoURL: URL photo de profil Google
  /// - createdAt: Date de création (première connexion)
  /// - updatedAt: Date de dernière mise à jour
  Future<void> _createOrUpdateUserProfile(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final docSnapshot = await userDoc.get();

    final now = FieldValue.serverTimestamp();

    if (!docSnapshot.exists) {
      // Création du profil (première connexion)
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'createdAt': now,
        'updatedAt': now,
      });
    } else {
      // Mise à jour du profil (reconnexion)
      await userDoc.update({
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'updatedAt': now,
      });
    }
  }
}
