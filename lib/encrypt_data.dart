import 'package:encrypt/encrypt.dart';

class EncryptedUserData {
  final String userName;
  final String iv;
  EncryptedUserData(this.userName, this.iv);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = userName;
    data['iv'] = iv;
    return data;
  }
}

class EncryptData {
//for AES Algorithms

  static Encrypted? encrypted;
  static var decrypted;

  final key = Key.fromUtf8('my 32 length key................');

  Future<EncryptedUserData> encryptWithAESAlgorithm(userName) async {
    final encrypter = Encrypter(AES(key));
    final iv = IV.fromLength(16);
    encrypted = encrypter.encrypt(userName, iv: iv);
    return EncryptedUserData(encrypted!.base64, iv.base64);
  }

  Future<String> decryptWithAESAlgorithm(userName, iv) async {
    final encrypter = Encrypter(AES(key));
    decrypted = encrypter.decrypt(Encrypted.fromBase64(userName), iv: IV.fromBase64(iv));
    return decrypted.toString();
  }
}
