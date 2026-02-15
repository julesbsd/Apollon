import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

/// Provider pour gérer l'état d'authentification
/// Utilise ChangeNotifier pour notifier les widgets des changements
/// Respecte le pattern Provider recommandé pour Apollon
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  /// Utilisateur actuellement connecté
  User? get user => _user;

  /// Indique si une opération d'authentification est en cours
  bool get isLoading => _isLoading;

  /// Message d'erreur de la dernière opération (null si succès)
  String? get errorMessage => _errorMessage;

  /// Indique si l'utilisateur est authentifié
  bool get isAuthenticated => _user != null;

  /// Stream des changements d'état d'authentification
  /// Utilisé par app.dart pour l'auto-login (US-1.2)
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  AuthProvider() {
    // Initialiser avec l'utilisateur actuel
    _user = _authService.currentUser;
    
    // Écouter les changements d'état d'authentification
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  /// Connexion avec Google (US-1.1)
  /// Retourne true si succès, false si échec
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final userCredential = await _authService.signInWithGoogle();
      _user = userCredential.user;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Déconnexion (US-1.3)
  /// Retourne true si succès, false si échec
  Future<bool> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signOut();
      _user = null;
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Effacer le message d'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
