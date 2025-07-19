import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class LocalImageService {
  static const String _profileImagesDir = 'profile_images';

  /// Save image to local storage
  Future<String?> saveImageLocally(File imageFile, String userId) async {
    try {
      // Get the app's documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory profileDir = Directory('${appDir.path}/$_profileImagesDir');
      
      // Create directory if it doesn't exist
      if (!await profileDir.exists()) {
        await profileDir.create(recursive: true);
      }

      // Create unique filename
      final String fileName = 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String filePath = '${profileDir.path}/$fileName';

      // Copy the image file
      await imageFile.copy(filePath);

      return filePath;
    } catch (e) {
      print('Error saving image locally: $e');
      return null;
    }
  }

  /// Load image from local storage
  Future<File?> loadImageFromPath(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        return imageFile;
      }
      return null;
    } catch (e) {
      print('Error loading image from path: $e');
      return null;
    }
  }

  /// Delete old profile images
  Future<void> deleteOldImages(String userId) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory profileDir = Directory('${appDir.path}/$_profileImagesDir');
      
      if (await profileDir.exists()) {
        final List<FileSystemEntity> files = await profileDir.list().toList();
        
        for (FileSystemEntity file in files) {
          if (file is File && file.path.contains('profile_${userId}_')) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      print('Error deleting old images: $e');
    }
  }

  /// Compress image for better performance
  Future<File> compressImage(File imageFile) async {
    try {
      // Read the image file
      final Uint8List bytes = await imageFile.readAsBytes();
      final img.Image? image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize image if it's too large
      img.Image resizedImage = image;
      if (image.width > 1024 || image.height > 1024) {
        resizedImage = img.copyResize(
          image,
          width: 1024,
          height: 1024,
          interpolation: img.Interpolation.linear,
        );
      }

      // Encode as JPEG with 85% quality
      final Uint8List compressedBytes = img.encodeJpg(resizedImage, quality: 85);
      
      // Create temporary file
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File compressedFile = File(tempPath);
      
      // Write compressed image
      await compressedFile.writeAsBytes(compressedBytes);
      
      return compressedFile;
    } catch (e) {
      print('Error compressing image: $e');
      // Return original file if compression fails
      return imageFile;
    }
  }

  /// Get local image path for user
  Future<String?> getLocalImagePath(String userId) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory profileDir = Directory('${appDir.path}/$_profileImagesDir');
      
      if (await profileDir.exists()) {
        final List<FileSystemEntity> files = await profileDir.list().toList();
        
        // Find the most recent profile image for this user
        File? latestFile;
        DateTime? latestTime;
        
        for (FileSystemEntity file in files) {
          if (file is File && file.path.contains('profile_${userId}_')) {
            final DateTime fileTime = await file.lastModified();
            if (latestTime == null || fileTime.isAfter(latestTime)) {
              latestTime = fileTime;
              latestFile = file;
            }
          }
        }
        
        return latestFile?.path;
      }
      return null;
    } catch (e) {
      print('Error getting local image path: $e');
      return null;
    }
  }
} 