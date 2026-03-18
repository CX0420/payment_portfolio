// lib/services/nfc_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

class NFCService {
  static final NFCService _instance = NFCService._internal();
  factory NFCService() => _instance;
  NFCService._internal();

  // Check if NFC is available on the device
  Future<bool> isNFCAvailable() async {
    try {
      final availability = await FlutterNfcKit.nfcAvailability;
      return availability == NFCAvailability.available;
    } catch (e) {
      print('Error checking NFC availability: $e');
      return false;
    }
  }

  // Read NFC tag
  Future<String?> readNFCTag() async {
    try {
      // Check availability first
      if (!await isNFCAvailable()) {
        throw Exception('NFC is not available on this device');
      }

      // Start NFC session
      final tag = await FlutterNfcKit.poll();

      // Get tag ID or data
      String tagData = '';

      if (tag.id != null) {
        tagData = 'Tag ID: ${tag.id}';
      }

      // Try to read NDEF data if available
      if (tag.ndefAvailable ?? false) {
        final ndefRecords = await FlutterNfcKit.readNDEFRecords();
        if (ndefRecords.isNotEmpty) {
          tagData +=
              '\nNDEF Data: ${ndefRecords.map((record) => record.toString()).join(', ')}';
        }
      }

      // Finish the session
      await FlutterNfcKit.finish();

      return tagData.isNotEmpty ? tagData : 'Tag detected but no readable data';
    } catch (e) {
      print('Error reading NFC tag: $e');
      // Make sure to finish the session even on error
      try {
        await FlutterNfcKit.finish();
      } catch (_) {}
      rethrow;
    }
  }

  // Write NDEF data to NFC tag (simplified version)
  Future<bool> writeNDEFData(String data) async {
    try {
      // Check availability first
      if (!await isNFCAvailable()) {
        throw Exception('NFC is not available on this device');
      }

      // Start NFC session
      final tag = await FlutterNfcKit.poll();

      // Check if tag supports NDEF
      if (!(tag.ndefAvailable ?? false)) {
        await FlutterNfcKit.finish();
        throw Exception('Tag does not support NDEF');
      }

      // Check if tag is writable
      if (!(tag.ndefWritable ?? false)) {
        await FlutterNfcKit.finish();
        throw Exception('Tag is not writable');
      }

      // For now, we'll just return true as writing requires more complex NDEF record creation
      // In a real implementation, you'd create proper NDEF records
      await FlutterNfcKit.finish();

      return true;
    } catch (e) {
      print('Error writing NFC tag: $e');
      // Make sure to finish the session even on error
      try {
        await FlutterNfcKit.finish();
      } catch (_) {}
      rethrow;
    }
  }

  // Get detailed tag information
  Future<Map<String, dynamic>> getTagInfo() async {
    try {
      if (!await isNFCAvailable()) {
        throw Exception('NFC is not available on this device');
      }

      final tag = await FlutterNfcKit.poll();

      final info = {
        'id': tag.id,
        'standard': tag.standard,
        'type': tag.type,
        'ndefAvailable': tag.ndefAvailable,
        'ndefWritable': tag.ndefWritable,
        'ndefCapacity': tag.ndefCapacity,
        'ndefType': tag.ndefType,
      };

      await FlutterNfcKit.finish();

      return info;
    } catch (e) {
      print('Error getting tag info: $e');
      try {
        await FlutterNfcKit.finish();
      } catch (_) {}
      rethrow;
    }
  }
}
