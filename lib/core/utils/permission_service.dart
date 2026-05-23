import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Runtime permissions for camera, gallery, and legacy storage (mobile only).
class PermissionService {
  PermissionService._();

  static bool get _isMobile =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static Future<bool> ensureCamera() async {
    if (!_isMobile) return true;

    var status = await Permission.camera.status;
    if (status.isGranted) return true;

    status = await Permission.camera.request();
    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
    return false;
  }

  static Future<bool> ensureGallery() async {
    if (!_isMobile) return true;

    if (Platform.isIOS) {
      var status = await Permission.photos.status;
      if (status.isGranted || status.isLimited) return true;

      status = await Permission.photos.request();
      if (status.isGranted || status.isLimited) return true;

      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
      return false;
    }

    var photos = await Permission.photos.status;
    if (photos.isGranted || photos.isLimited) return true;

    photos = await Permission.photos.request();
    if (photos.isGranted || photos.isLimited) return true;

    var storage = await Permission.storage.status;
    if (storage.isGranted) return true;

    storage = await Permission.storage.request();
    if (storage.isGranted) return true;

    if (photos.isPermanentlyDenied || storage.isPermanentlyDenied) {
      await openAppSettings();
    }
    return false;
  }

  /// Best-effort access for picking PDFs on older Android; modern pickers need no grant.
  static Future<bool> ensureStorageForFiles() async {
    if (!_isMobile || Platform.isIOS) return true;

    final storage = await Permission.storage.status;
    if (storage.isGranted) return true;

    await Permission.storage.request();
    return true;
  }
}
