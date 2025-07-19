import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ImageUploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image from camera: $e');
      return null;
    }
  }

  /// Upload image to Firebase Storage
  Future<String?> uploadImage(File imageFile) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Create a unique filename
      final String fileName = 'profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Reference to the storage location
      final Reference storageRef = _storage
          .ref()
          .child('profile_images')
          .child(fileName);

      // Set metadata for the upload
      final SettableMetadata metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'uploadedBy': user.uid,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // Upload the file with metadata
      final UploadTask uploadTask = storageRef.putFile(imageFile, metadata);
      
      // Wait for upload to complete
      final TaskSnapshot snapshot = await uploadTask;
      
      // Get the download URL
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } on FirebaseException catch (e) {
      print('Firebase Storage Error: ${e.code} - ${e.message}');
      
      // Handle specific Firebase Storage errors
      switch (e.code) {
        case 'storage/unauthorized':
          throw Exception('Upload unauthorized. Please check your Firebase Storage rules.');
        case 'storage/canceled':
          throw Exception('Upload was canceled.');
        case 'storage/unknown':
          throw Exception('Unknown error occurred during upload.');
        case 'storage/invalid-checksum':
          throw Exception('File checksum mismatch. Please try again.');
        case 'storage/retry-limit-exceeded':
          throw Exception('Upload failed after multiple retries. Please check your internet connection.');
        case 'storage/invalid-url':
          throw Exception('Invalid storage URL. Please check your Firebase configuration.');
        case 'storage/object-not-found':
          throw Exception('Storage bucket not found. Please check your Firebase Storage configuration.');
        default:
          throw Exception('Upload failed: ${e.message}');
      }
    } catch (e) {
      print('Error uploading image: $e');
      if (e.toString().contains('NetworkException') || e.toString().contains('SocketException')) {
        throw Exception('Network error. Please check your internet connection and try again.');
      }
      throw Exception('Upload failed: $e');
    }
  }

  /// Delete old profile image from storage
  Future<void> deleteOldImage(String imageUrl) async {
    try {
      if (imageUrl.isNotEmpty && imageUrl.contains('profile_images')) {
        final Reference storageRef = _storage.refFromURL(imageUrl);
        await storageRef.delete();
      }
    } catch (e) {
      print('Error deleting old image: $e');
      // Don't throw error as this is not critical
    }
  }


} 