import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt_lib;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  final _secureStorage = const FlutterSecureStorage();
  
  // Keys for secure storage
  static const String _realPasswordHashKey = 'real_password_hash';
  static const String _realPasswordSaltKey = 'real_password_salt';
  static const String _fakePasswordHashKey = 'fake_password_hash';
  static const String _fakePasswordSaltKey = 'fake_password_salt';

  /// Generate a random salt
  String _generateSalt() {
    final random = encrypt_lib.SecureRandom(32);
    return base64Encode(random.bytes);
  }

  /// Hash password with salt using SHA-256
  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Set up plausible deniability with real and fake passwords
  Future<void> setupPlausibleDeniability({
    required String realPassword,
    required String fakePassword,
  }) async {
    // Generate salts
    final realSalt = _generateSalt();
    final fakeSalt = _generateSalt();

    // Hash passwords
    final realHash = _hashPassword(realPassword, realSalt);
    final fakeHash = _hashPassword(fakePassword, fakeSalt);

    // Store in secure storage
    await _secureStorage.write(key: _realPasswordHashKey, value: realHash);
    await _secureStorage.write(key: _realPasswordSaltKey, value: realSalt);
    await _secureStorage.write(key: _fakePasswordHashKey, value: fakeHash);
    await _secureStorage.write(key: _fakePasswordSaltKey, value: fakeSalt);
  }

  /// Verify password and return database type ('real', 'fake', or null)
  Future<String?> verifyPassword(String password) async {
    // Check real password
    final realHash = await _secureStorage.read(key: _realPasswordHashKey);
    final realSalt = await _secureStorage.read(key: _realPasswordSaltKey);
    
    if (realHash != null && realSalt != null) {
      final inputHash = _hashPassword(password, realSalt);
      if (inputHash == realHash) {
        return 'real';
      }
    }

    // Check fake password
    final fakeHash = await _secureStorage.read(key: _fakePasswordHashKey);
    final fakeSalt = await _secureStorage.read(key: _fakePasswordSaltKey);
    
    if (fakeHash != null && fakeSalt != null) {
      final inputHash = _hashPassword(password, fakeSalt);
      if (inputHash == fakeHash) {
        return 'fake';
      }
    }

    return null; // Invalid password
  }

  /// Check if plausible deniability is enabled
  Future<bool> isPlausibleDeniabilityEnabled() async {
    final realHash = await _secureStorage.read(key: _realPasswordHashKey);
    return realHash != null;
  }

  /// Disable plausible deniability (clear all passwords)
  Future<void> disablePlausibleDeniability() async {
    await _secureStorage.delete(key: _realPasswordHashKey);
    await _secureStorage.delete(key: _realPasswordSaltKey);
    await _secureStorage.delete(key: _fakePasswordHashKey);
    await _secureStorage.delete(key: _fakePasswordSaltKey);
  }

  /// Encrypt file data
  Uint8List encryptFile(Uint8List data, String password) {
    final key = encrypt_lib.Key.fromUtf8(password.padRight(32, '0').substring(0, 32));
    final iv = encrypt_lib.IV.fromLength(16);
    final encrypter = encrypt_lib.Encrypter(encrypt_lib.AES(key));
    
    final encrypted = encrypter.encryptBytes(data, iv: iv);
    
    // Prepend IV to encrypted data
    final result = Uint8List(iv.bytes.length + encrypted.bytes.length);
    result.setRange(0, iv.bytes.length, iv.bytes);
    result.setRange(iv.bytes.length, result.length, encrypted.bytes);
    
    return result;
  }

  /// Decrypt file data
  Uint8List decryptFile(Uint8List encryptedData, String password) {
    final key = encrypt_lib.Key.fromUtf8(password.padRight(32, '0').substring(0, 32));
    
    // Extract IV from beginning of encrypted data
    final iv = encrypt_lib.IV(encryptedData.sublist(0, 16));
    final encrypted = encrypt_lib.Encrypted(encryptedData.sublist(16));
    
    final encrypter = encrypt_lib.Encrypter(encrypt_lib.AES(key));
    final decrypted = encrypter.decryptBytes(encrypted, iv: iv);
    
    return Uint8List.fromList(decrypted);
  }

  /// Generate encryption key for PDF
  String generateEncryptionKey() {
    final random = encrypt_lib.SecureRandom(32);
    return base64Encode(random.bytes);
  }
}
