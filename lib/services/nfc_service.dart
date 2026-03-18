// lib/services/nfc_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

class NFCService {
  static final NFCService _instance = NFCService._internal();
  factory NFCService() => _instance;
  NFCService._internal();

  // EMV AID (Application Identifier) constants
  static const String VISA_AID = 'A0000000031010';
  static const String MASTERCARD_AID = 'A0000000041010';
  static const String AMEX_AID = 'A00000002501';
  static const String DISCOVER_AID = 'A0000003241010';

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

  /// Get basic tag information for debugging
  Future<Map<String, dynamic>> getBasicTagInfo() async {
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
      print('Error getting basic tag info: $e');
      try {
        await FlutterNfcKit.finish();
      } catch (_) {}
      rethrow;
    }
  }

  // EMV Card Reading Methods

  /// Read EMV card data
  Future<Map<String, dynamic>?> readEMVCard() async {
    try {
      if (!await isNFCAvailable()) {
        throw Exception('NFC is not available on this device');
      }

      final tag = await FlutterNfcKit.poll();

      // Log tag information for debugging
      print('Tag detected:');
      print('  ID: ${tag.id}');
      print('  Standard: ${tag.standard}');
      print('  Type: ${tag.type}');

      // Check if it's a contactless card (more permissive check)
      // EMV cards typically use ISO 14443 standards
      if (!tag.standard.contains('ISO 14443')) {
        await FlutterNfcKit.finish();
        print('Not an ISO 14443 card, standard: ${tag.standard}');
        return null; // Return null instead of throwing to allow fallback
      }

      final cardData = await _readEMVData(tag);

      await FlutterNfcKit.finish();

      return cardData;
    } catch (e) {
      print('Error reading EMV card: $e');
      try {
        await FlutterNfcKit.finish();
      } catch (_) {}
      rethrow;
    }
  }

  /// Internal method to read EMV data
  Future<Map<String, dynamic>> _readEMVData(NFCTag tag) async {
    final cardData = <String, dynamic>{};

    try {
      // Try to select EMV applications
      final applications = await _selectEMVApplications();

      if (applications.isEmpty) {
        print('No EMV applications found, trying fallback methods...');
        // Try to read basic card information even without application selection
        cardData['cardType'] = 'Unknown EMV Card';
        cardData['tagId'] = tag.id;
        cardData['standard'] = tag.standard;
        return cardData;
      }

      // Use the first available application
      final selectedApp = applications.first;
      cardData['application'] = selectedApp;
      print('Selected EMV application: $selectedApp');

      // First, try GET DATA commands for PAN and expiry
      print('Trying GET DATA for PAN and expiry...');
      final pan = await _readPAN();
      if (pan != null) {
        cardData['pan'] = pan;
        print('Found PAN via GET DATA: $pan');
      }

      final expiry = await _readExpiryDate();
      if (expiry != null) {
        cardData['expiryDate'] = expiry;
        print('Found expiry via GET DATA: $expiry');
      }

      // If we have both, return early
      if (cardData.containsKey('pan') && cardData.containsKey('expiryDate')) {
        print('Found PAN and expiry via GET DATA, returning');
        return cardData;
      }

      // Try to read using READ RECORD for EMV files (SFI 1-4)
      // SFI 1: Application Directory, SFI 2: Track 2 Equivalent, SFI 3: Track 1 Equivalent, SFI 4: Additional
      for (int sfi = 1; sfi <= 4; sfi++) {
        for (int record = 1; record <= 3; record++) {
          // Check first 3 records per SFI
          try {
            final response = await _readEMVRecord(sfi, record);
            if (response != null && response.isNotEmpty) {
              print('READ RECORD SFI=$sfi Record=$record Response: $response');
              _parseTrack2EquivalentData(response, cardData);

              // Stop if we found PAN and expiry
              if (cardData.containsKey('pan') &&
                  cardData.containsKey('expiryDate')) {
                print(
                    'Found PAN and expiry in SFI=$sfi Record=$record, stopping record read');
                return cardData;
              }
            }
          } catch (e) {
            print('Could not read SFI=$sfi Record=$record: $e');
            // If card is removed, stop trying
            if (e.toString().contains('Tag already removed')) {
              print('Card removed, stopping EMV read');
              return cardData;
            }
          }
        }
      }

      // If still no data, try cardholder name
      if (!cardData.containsKey('cardholderName')) {
        final name = await _readCardholderName();
        if (name != null) {
          cardData['cardholderName'] = name;
          print('Found cardholder name: $name');
        }
      }
    } catch (e) {
      print('Error reading EMV data: $e');
      // Return partial data if available
      if (cardData.isNotEmpty) {
        cardData['error'] = e.toString();
      }
    }

    return cardData;
  }

  /// Select EMV applications
  Future<List<String>> _selectEMVApplications() async {
    final applications = <String>[];

    // Extended list of common EMV AIDs including more Visa variants
    final aids = [
      VISA_AID, // A0000000031010 - Visa Debit/Credit
      'A0000000032010', // Visa Electron
      'A0000000032020', // Visa
      'A0000000033010', // Visa
      'A000000003101001', // Visa Credit
      'A000000003101002', // Visa Debit
      MASTERCARD_AID, // A0000000041010 - Mastercard
      'A0000000042203', // Mastercard Credit
      'A0000000043010', // Mastercard Debit
      'A0000000043060', // Maestro
      AMEX_AID, // A00000002501 - American Express
      DISCOVER_AID, // A0000003241010 - Discover
      'A0000001523010', // Discover Debit
      'A0000001524010', // Discover Credit
    ];

    for (final aid in aids) {
      try {
        final lc =
            (aid.length ~/ 2).toRadixString(16).padLeft(2, '0').toUpperCase();
        final command = '00A40400' + lc + aid;
        print('Trying to select AID: $aid with command: $command');
        final response = await _sendAPDU(command);
        if (_isSuccessResponse(response)) {
          applications.add(aid);
          print('Successfully selected AID: $aid');
          break; // Stop after first successful selection
        } else {
          print('AID $aid not supported, response: $response');
        }
      } catch (e) {
        print('Error selecting AID $aid: $e');
        // Continue to next AID
        continue;
      }
    }

    return applications;
  }

  /// Read Primary Account Number (PAN)
  Future<String?> _readPAN() async {
    try {
      // Read PAN (tag 5A)
      final response =
          await _sendAPDU('80CA5A0002FF'); // GET DATA command for PAN
      print('PAN response: $response');
      if (_isSuccessResponse(response)) {
        return _parsePAN(response);
      }
    } catch (e) {
      print('Error reading PAN: $e');
    }
    return null;
  }

  /// Read expiry date
  Future<String?> _readExpiryDate() async {
    try {
      final response = await _sendAPDU(
          '80CA5F2400'); // GET DATA command for Application Expiration Date (tag 5F24)
      print('Expiry response: $response');
      if (_isSuccessResponse(response)) {
        return _parseExpiryDateFromResponse(response);
      }
    } catch (e) {
      print('Error reading expiry date: $e');
    }
    return null;
  }

  /// Read cardholder name
  Future<String?> _readCardholderName() async {
    try {
      final response = await _sendAPDU(
          '80CA5F2000'); // GET DATA command for Cardholder Name (tag 5F20)
      print('Cardholder name response: $response');
      if (_isSuccessResponse(response)) {
        return _parseCardholderName(response);
      }
    } catch (e) {
      print('Error reading cardholder name: $e');
    }
    return null;
  }

  /// Read Track 2 data
  Future<String?> _readTrack2Data() async {
    try {
      final response =
          await _sendAPDU('80CA009F6B00'); // GET DATA command for Track 2 Data
      if (_isSuccessResponse(response)) {
        return _parseTrack2Data(response);
      }
    } catch (e) {
      print('Error reading Track 2 data: $e');
    }
    return null;
  }

  /// Read EMV record using READ RECORD command
  Future<String?> _readEMVRecord(int sfi, int record) async {
    try {
      // READ RECORD command:
      // CLA=00, INS=B2, P1=record, P2=(sfi << 3) | 04, Le=00
      final p2 = ((sfi << 3) | 0x04).toRadixString(16).padLeft(2, '0');
      final p1 = record.toRadixString(16).padLeft(2, '0');
      final command = '00B2$p1${p2}00';
      print('READ RECORD command: $command');

      final response = await _sendAPDU(command);
      print('READ RECORD response: $response');

      if (_isSuccessResponse(response)) {
        return response.substring(0, response.length - 4); // Remove status word
      }
    } catch (e) {
      print('Error reading EMV record: $e');
    }
    return null;
  }

  /// Get EMV tag data using GET DATA command
  Future<String?> _getEMVTag(String tag) async {
    try {
      // GET DATA command for specific tag
      final command = '80CA${tag}00';
      print('GET EMV tag $tag command: $command');

      final response = await _sendAPDU(command);
      print('GET EMV tag response: $response');

      if (!_isSuccessResponse(response)) {
        return null;
      }

      return response.substring(0, response.length - 4); // Remove status word
    } catch (e) {
      print('Error getting EMV tag $tag: $e');
    }
    return null;
  }

  /// Parse Track 2 Equivalent Data and extract PAN, expiry
  void _parseTrack2EquivalentData(String data, Map<String, dynamic> cardData) {
    try {
      print('Parsing TLV data: $data');

      // Parse TLV (Tag-Length-Value) format using BER-TLV
      // Handle response templates and nested structures
      _parseBERTLV(data, 0, data.length ~/ 2, cardData);
    } catch (e) {
      print('Error parsing track 2 data: $e');
    }
  }

  /// Parse BER-TLV format and extract card data
  void _parseBERTLV(String hexData, int startByte, int endByte,
      Map<String, dynamic> cardData) {
    final bytes = _hexToBytes(hexData);
    int idx = startByte;

    while (idx < endByte) {
      if (idx + 1 >= endByte) break;

      // Parse tag
      int tag = bytes[idx];
      idx++;
      if ((tag & 0x1F) == 0x1F) {
        // Multi-byte tag
        if (idx >= endByte) break;
        tag = (tag << 8) | bytes[idx];
        idx++;
      }

      // Parse length
      if (idx >= endByte) break;
      int length = bytes[idx];
      idx++;
      if ((length & 0x80) != 0) {
        // Long form length
        int numLengthBytes = length & 0x7F;
        length = 0;
        for (int i = 0; i < numLengthBytes; i++) {
          if (idx >= endByte) break;
          length = (length << 8) | bytes[idx];
          idx++;
        }
      }

      // Parse value
      if (idx + length > endByte) {
        print(
            'Not enough data for value: need $length bytes, available ${endByte - idx}');
        break;
      }

      final valueBytes = bytes.sublist(idx, idx + length);
      final valueHex = _bytesToHex(valueBytes);
      idx += length;

      final tagHex =
          tag.toRadixString(16).padLeft(tag > 0xFF ? 4 : 2, '0').toUpperCase();
      print(
          'TLV Tag: $tagHex, Length: $length, Value: ${valueHex.length > 40 ? valueHex.substring(0, 40) + "..." : valueHex}');

      // Parse specific tags
      switch (tagHex) {
        case '5A':
          // PAN in BCD format
          final pan = _bcdToString(valueHex);
          if (pan.isNotEmpty && pan.length >= 13) {
            cardData['pan'] = pan;
            print('✓ Extracted PAN: $pan');
          }
          break;

        case '5F24':
          // Application Expiration Date (BCD encoded YYMMDD format)
          if (valueBytes.length >= 3) {
            try {
              // Parse BCD: each byte represents two decimal digits
              final yy =
                  ((valueBytes[0] >> 4) & 0x0F) * 10 + (valueBytes[0] & 0x0F);
              final mm =
                  ((valueBytes[1] >> 4) & 0x0F) * 10 + (valueBytes[1] & 0x0F);

              final expiry =
                  '${yy.toString().padLeft(2, '0')}/${mm.toString().padLeft(2, '0')}';
              cardData['expiryDate'] = expiry;
              print('✓ Extracted expiry: $expiry');
            } catch (e) {
              print('Failed to parse expiry: $e');
            }
          }
          break;

        case '5F20':
          // Cardholder name
          final name = String.fromCharCodes(valueBytes).trim();
          if (name.isNotEmpty) {
            cardData['cardholderName'] = name;
            print('✓ Extracted cardholder name: $name');
          }
          break;

        case '70':
        case '71':
          // Response template - recursively parse contents
          print('Found template tag $tagHex, parsing contents...');
          _parseBERTLV(valueHex, 0, valueBytes.length, cardData);
          break;

        case '77':
          // Response Message Template Format 2 - parse contents
          print('Found F2 template tag $tagHex, parsing contents...');
          _parseBERTLV(valueHex, 0, valueBytes.length, cardData);
          break;
      }
    }
  }

  /// Send APDU command
  Future<String> _sendAPDU(String commandHex) async {
    try {
      final bytes = _hexToBytes(commandHex);
      final response = await FlutterNfcKit.transceive(bytes);
      return _bytesToHex(response);
    } catch (e) {
      throw Exception('APDU command failed: $e');
    }
  }

  /// Check if APDU response indicates success
  bool _isSuccessResponse(String response) {
    if (response.length < 4) return false;
    final sw = response.substring(response.length - 4);
    return sw == '9000'; // Success status word
  }

  /// Parse PAN from raw EMV data
  String? _parsePAN(String response) {
    try {
      if (response.length < 8) return null;
      final data =
          response.substring(0, response.length - 4); // Remove status word
      print('PAN data (hex): $data');
      final bytes = _hexToBytes(data);

      // PAN is typically BCD encoded, but may also be ASCII
      // First, strip tag (5A) and length bytes
      if (data.length >= 4) {
        // Skip tag and length bytes
        final panHex = data.substring(4); // Skip first 2 bytes (tag+length)
        print('PAN hex after stripping header: $panHex');

        // Convert BCD to ASCII
        final pan = _bcdToString(panHex);
        print('Parsed PAN: $pan');
        return pan;
      }
    } catch (e) {
      print('Error parsing PAN: $e');
    }
    return null;
  }

  /// Parse expiry date from EMV tag 5F24
  String? _parseExpiryDateFromResponse(String response) {
    try {
      if (response.length < 8) return null;
      final data = response.substring(0, response.length - 4);
      print('Expiry data (hex): $data');

      // Strip tag (5F24) and length bytes, keep expiry bytes
      if (data.length >= 8) {
        // 5F24 03 YYMMDD format typically
        final expiryHex = data.substring(
            6, data.length); // Get last 6 chars (3 bytes = YYMMDD)
        print('Expiry hex: $expiryHex');

        if (expiryHex.length >= 6) {
          final bytes = _hexToBytes(expiryHex);
          if (bytes.length >= 2) {
            // Parse BCD: each byte represents two decimal digits
            final yy = ((bytes[0] >> 4) & 0x0F) * 10 + (bytes[0] & 0x0F);
            final mm = ((bytes[1] >> 4) & 0x0F) * 10 + (bytes[1] & 0x0F);
            return '${yy.toString().padLeft(2, '0')}/${mm.toString().padLeft(2, '0')}'; // YY/MM format
          }
        }
      }
    } catch (e) {
      print('Error parsing expiry date: $e');
    }
    return null;
  }

  /// Parse cardholder name
  String? _parseCardholderName(String response) {
    try {
      if (response.length < 8) return null;
      final data = response.substring(0, response.length - 4);
      final bytes = _hexToBytes(data);
      return String.fromCharCodes(bytes).trim();
    } catch (e) {
      print('Error parsing cardholder name: $e');
    }
    return null;
  }

  /// Parse Track 2 data
  String? _parseTrack2Data(String response) {
    try {
      if (response.length < 8) return null;
      final data = response.substring(0, response.length - 4);
      final bytes = _hexToBytes(data);
      return String.fromCharCodes(bytes);
    } catch (e) {
      print('Error parsing Track 2 data: $e');
    }
    return null;
  }

  /// Convert hex string to bytes
  Uint8List _hexToBytes(String hex) {
    final bytes = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      final byte = int.parse(hex.substring(i, i + 2), radix: 16);
      bytes.add(byte);
    }
    return Uint8List.fromList(bytes);
  }

  /// Convert bytes to hex string
  String _bytesToHex(Uint8List bytes) {
    return bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join()
        .toUpperCase();
  }

  /// Convert BCD (Binary Coded Decimal) to ASCII string
  String _bcdToString(String hex) {
    final result = StringBuffer();
    for (int i = 0; i < hex.length; i += 2) {
      if (i + 1 < hex.length) {
        final nibble = hex.substring(i, i + 2);
        final byte = int.parse(nibble, radix: 16);
        final upper = (byte >> 4) & 0x0F;
        final lower = byte & 0x0F;

        if (upper < 10) result.write(upper);
        if (lower < 10) result.write(lower);
      }
    }
    return result.toString();
  }
}
