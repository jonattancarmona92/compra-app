// ==================== ARCHIVO: lib/core/seguridad/credenciales_hash.dart ====================
// Protección de credenciales — Informe Global §1.3
// "Se debe usar flutter_secure_storage y hash con salt."
// Esta clase centraliza el hashing con salt; flutter_secure_storage
// se usa en el Provider (Capítulo 1, módulo Inicio) para el
// almacenamiento cifrado del hash+salt resultante, nunca del valor
// en texto plano.
//
// NOTA DE DEPENDENCIA: el paquete `crypto` no aparece en la lista
// explícita del §6.8.1, pero es una utilidad de cómputo puro
// (SHA-256), sin acceso a red ni a servicios en la nube — coherente
// con la Soberanía Local Absoluta (§6.1) y necesaria para cumplir el
// requisito explícito de "hash con salt" del §1.3.
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Par hash+salt listo para persistir en flutter_secure_storage.
class CredencialHasheada {
  final String hash;
  final String salt;

  const CredencialHasheada({required this.hash, required this.salt});

  /// Serializa a un único string "hash:salt" para guardar en una
  /// sola clave de flutter_secure_storage.
  String serializar() => '$hash:$salt';

  static CredencialHasheada? deserializar(String? valor) {
    if (valor == null || !valor.contains(':')) return null;
    final partes = valor.split(':');
    if (partes.length != 2) return null;
    return CredencialHasheada(hash: partes[0], salt: partes[1]);
  }
}

/// Utilitario de hashing con salt para credenciales locales (Patrón,
/// PIN, Clave Maestra) — Informe Global §1.3.
class CredencialesHash {
  const CredencialesHash._();

  static const int _saltLengthBytes = 16;

  static String _generarSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(
      _saltLengthBytes,
      (_) => random.nextInt(256),
    );
    return base64Url.encode(bytes);
  }

  static String _calcularHash(String valorPlano, String salt) {
    final bytes = utf8.encode('$salt::$valorPlano');
    return sha256.convert(bytes).toString();
  }

  /// Crea un nuevo par hash+salt a partir de un valor en texto plano
  /// (Patrón serializado, PIN o Clave Maestra). El valor original
  /// nunca se persiste.
  static CredencialHasheada crear(String valorPlano) {
    final salt = _generarSalt();
    final hash = _calcularHash(valorPlano, salt);
    return CredencialHasheada(hash: hash, salt: salt);
  }

  /// Verifica un intento de acceso contra el hash+salt almacenado.
  static bool verificar(
    String valorIngresado,
    CredencialHasheada credencialGuardada,
  ) {
    final hashCalculado = _calcularHash(
      valorIngresado,
      credencialGuardada.salt,
    );
    return hashCalculado == credencialGuardada.hash;
  }
}
