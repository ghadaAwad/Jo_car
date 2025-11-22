import 'dart:typed_data';
import 'dart:io' show File;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// لاحظ إننا ننادي Storage بالـ bucket تبع مشروعك زي CarService
  final FirebaseStorage storage = FirebaseStorage.instanceFor(
    bucket: "gs://jocar97",
  );

  Future<String> uploadProfileImage({
    Uint8List? webImage,
    File? mobileImage,
  }) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final fileName =
          "profile_images/$uid/profile_${DateTime.now().millisecondsSinceEpoch}.jpg";

      UploadTask uploadTask;

      if (webImage != null) {
        uploadTask = storage
            .ref(fileName)
            .putData(webImage, SettableMetadata(contentType: 'image/jpeg'));
      } else if (mobileImage != null) {
        uploadTask = storage.ref(fileName).putFile(mobileImage);
      } else {
        throw Exception("No image provided");
      }

      TaskSnapshot snapshot = await uploadTask;
      String url = await snapshot.ref.getDownloadURL();

      print("🔥 Profile image uploaded: $url");

      return url;
    } catch (e) {
      print("🔥 Error uploading profile image: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> updateUserData({
    required String firstName,
    required String lastName,
    required String phone,
    String? imageUrl,
  }) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final data = {
        "firstName": firstName,
        "lastName": lastName,
        "phone": phone,
      };

      if (imageUrl != null) {
        data["imageUrl"] = imageUrl;
      }

      await firestore
          .collection("users")
          .doc(uid)
          .set(data, SetOptions(merge: true));

      print(" User updated in Firestore!");

      final snap = await firestore.collection("users").doc(uid).get();

      return snap.data();
    } catch (e) {
      print(" Error updating user: $e");
      return null;
    }
  }
}
