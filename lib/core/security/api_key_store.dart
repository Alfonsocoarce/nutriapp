import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores the user's own Gemini API key in the OS Keychain/Keystore.
///
/// This is a runtime, user-supplied key (entered in Settings), not one
/// embedded in the app binary or source control — each user brings their
/// own free key from https://aistudio.google.com/app/apikey. That is a
/// materially different risk than hardcoding a shared key: extracting it
/// from the device only exposes that one user's own quota, not shared
/// infrastructure. For a store-published multi-user app this should still
/// move behind a stateless backend proxy (see docs/ERS.md Section 3); for
/// personal/local-first use, storing the key in secure, per-device storage
/// is the pragmatic choice.
class ApiKeyStore {
  ApiKeyStore._();

  static final ApiKeyStore instance = ApiKeyStore._();

  static const _secureStorage = FlutterSecureStorage();
  static const _geminiKeyStorageKey = 'nutriapp_gemini_api_key';

  Future<String?> getGeminiApiKey() {
    return _secureStorage.read(key: _geminiKeyStorageKey);
  }

  Future<void> setGeminiApiKey(String key) {
    return _secureStorage.write(key: _geminiKeyStorageKey, value: key.trim());
  }

  Future<void> clearGeminiApiKey() {
    return _secureStorage.delete(key: _geminiKeyStorageKey);
  }
}
