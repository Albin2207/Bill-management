import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';

class ShareService {
  /// Share a file (PDF, image, etc.)
  static Future<void> shareFile({
    required File file,
    required String subject,
    String? text,
  }) async {
    try {
      final xFile = XFile(file.path);
      await Share.shareXFiles(
        [xFile],
        subject: subject,
        text: text,
      );
    } catch (e) {
      debugPrint('Error sharing file: $e');
      rethrow;
    }
  }

  /// Share text only
  static Future<void> shareText({
    required String text,
    String? subject,
  }) async {
    try {
      await Share.share(
        text,
        subject: subject,
      );
    } catch (e) {
      debugPrint('Error sharing text: $e');
      rethrow;
    }
  }

  /// Share to WhatsApp specifically
  static Future<void> shareToWhatsApp({
    required File file,
    String? phoneNumber,
  }) async {
    try {
      final xFile = XFile(file.path);
      await Share.shareXFiles(
        [xFile],
        subject: 'Invoice',
      );
      // Note: WhatsApp-specific sharing requires platform-specific implementation
      // This will show all share options including WhatsApp
    } catch (e) {
      debugPrint('Error sharing to WhatsApp: $e');
      rethrow;
    }
  }

  /// Share via Email
  static Future<void> shareViaEmail({
    required File file,
    required String subject,
    String? body,
    List<String>? recipients,
  }) async {
    try {
      final xFile = XFile(file.path);
      await Share.shareXFiles(
        [xFile],
        subject: subject,
        text: body,
      );
    } catch (e) {
      debugPrint('Error sharing via email: $e');
      rethrow;
    }
  }
}

