import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../constants/cloudinary_config.dart';

class CloudinaryService {
  // Upload image using unsigned preset
  static Future<String> uploadImage({
    required File imageFile,
    String? folder,
  }) async {
    try {
      debugPrint('🔵 Starting Cloudinary upload...');
      debugPrint('Cloud Name: ${CloudinaryConfig.cloudName}');
      debugPrint('Upload Preset: ${CloudinaryConfig.uploadPreset}');
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(CloudinaryConfig.uploadUrl),
      );
      
      // Add upload preset (REQUIRED for unsigned uploads)
      request.fields['upload_preset'] = CloudinaryConfig.uploadPreset ?? 'public_uploads';
      
      // Add folder if provided
      if (folder != null) {
        request.fields['folder'] = folder;
      }
      
      // Add file
      final fileBytes = await imageFile.readAsBytes();
      debugPrint('File size: ${fileBytes.length} bytes');
      
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: 'upload_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );
      
      debugPrint('Sending upload request...');
      
      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final url = jsonResponse['secure_url'] ?? jsonResponse['url'];
        debugPrint('✅ Upload successful! URL: $url');
        return url;
      } else {
        final errorBody = jsonDecode(response.body);
        final errorMsg = errorBody['error']?['message'] ?? 'Unknown error';
        throw Exception('Upload failed: $errorMsg');
      }
    } catch (e, stackTrace) {
      debugPrint('🔴 Cloudinary upload error: $e');
      debugPrint('Stack: $stackTrace');
      throw Exception('Failed to upload image: $e');
    }
  }
  
  
  // Get optimized image URL
  static String getOptimizedImageUrl(
    String publicId, {
    int? width,
    int? height,
    String? format,
    String quality = 'auto',
  }) {
    final transformations = <String>[];
    
    if (width != null || height != null) {
      transformations.add('w_${width ?? "auto"},h_${height ?? "auto"},c_fill');
    }
    
    if (format != null) {
      transformations.add('f_$format');
    }
    
    transformations.add('q_$quality');
    
    final transformString = transformations.join(',');
    return 'https://res.cloudinary.com/${CloudinaryConfig.cloudName}/image/upload/$transformString/$publicId';
  }
}
