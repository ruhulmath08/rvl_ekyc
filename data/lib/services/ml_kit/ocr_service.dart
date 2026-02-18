import 'dart:typed_data';
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:domain/model/document_info_entity.dart';
import 'package:domain/model/document_side.dart';
import 'package:domain/exceptions/ekyc_exception.dart';
import 'package:path_provider/path_provider.dart';

/// OCR Service for Bangladesh National ID Card (BD NID)
/// Parses front and back sides based on official BD NID format
///
/// Front side: Name (Bengali/English), Father, Mother, DOB, NID No
/// Back side: Address, Blood Group, Place of Birth, Issue Date, MRZ
class OcrService {
  final TextRecognizer _textRecognizer;

  OcrService() : _textRecognizer = TextRecognizer();

  /// Extract text from image bytes
  /// Uses file-based InputImage for better ML Kit compatibility
  Future<DocumentInfoEntity> extractText(
    Uint8List imageBytes,
    int imageWidth,
    int imageHeight, {
    DocumentSide? side,
  }) async {
    File? tempFile;
    try {
      final tempDir = await getTemporaryDirectory();
      tempFile = File(
        '${tempDir.path}/ocr_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await tempFile.writeAsBytes(imageBytes);

      final inputImage = InputImage.fromFilePath(tempFile.path);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      if (recognizedText.text.isEmpty) {
        throw OcrException('No text found in document image');
      }

      return _parseDocumentInfo(recognizedText.text, side);
    } catch (e) {
      if (e is OcrException) rethrow;
      throw OcrException('Failed to extract text: ${e.toString()}');
    } finally {
      try {
        if (tempFile != null && await tempFile.exists()) {
          await tempFile.delete();
        }
      } catch (_) {}
    }
  }

  /// Parse raw OCR text into structured DocumentInfo
  /// Based on official BD NID card layout
  DocumentInfoEntity _parseDocumentInfo(String rawText, DocumentSide? side) {
    final lines = rawText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    Map<String, String?> frontData = {};
    Map<String, String?> backData = {};

    if (side == DocumentSide.back) {
      backData = _parseBackSide(lines, rawText);
    } else if (side == DocumentSide.front) {
      frontData = _parseFrontSide(lines, rawText);
    } else {
      final hasNidNo = RegExp(r'nid\s*no', caseSensitive: false).hasMatch(rawText) ||
          RegExp(r'\d{3}\s+\d{3}\s+\d{4}').hasMatch(rawText);
      final hasBackMarkers = rawText.toLowerCase().contains('blood group') ||
          rawText.toLowerCase().contains('place of birth') ||
          rawText.toLowerCase().contains('issue date') ||
          rawText.toLowerCase().contains('ঠিকানা');

      if (hasNidNo && !hasBackMarkers) {
        frontData = _parseFrontSide(lines, rawText);
      } else if (hasBackMarkers) {
        backData = _parseBackSide(lines, rawText);
      } else {
        frontData = _parseFrontSide(lines, rawText);
        backData = _parseBackSide(lines, rawText);
      }
    }

    return DocumentInfoEntity(
      rawText: rawText,
      name: frontData['name'],
      nameBangla: frontData['nameBangla'],
      documentNumber: frontData['documentNumber'] ?? backData['documentNumber'],
      dateOfBirth: frontData['dateOfBirth'],
      fatherName: frontData['fatherName'],
      motherName: frontData['motherName'],
      address: backData['address'],
      houseHolding: backData['houseHolding'],
      villageRoad: backData['villageRoad'],
      postOffice: backData['postOffice'],
      district: backData['district'],
      bloodGroup: backData['bloodGroup'],
      placeOfBirth: backData['placeOfBirth'],
      issueDate: backData['issueDate'],
      expiryDate: backData['expiryDate'],
    );
  }

  /// Parse front side of BD NID
  /// Layout: নাম/Name, পিতা/Father, মাতা/Mother, Date of Birth, NID No
  Map<String, String?> _parseFrontSide(List<String> lines, String rawText) {
    String? name;
    String? nameBangla;
    String? documentNumber;
    String? dateOfBirth;
    String? fatherName;
    String? motherName;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lower = line.toLowerCase();

      // Name (English) - after "Name" label, e.g. "MD. RUHUL AMIN"
      if (name == null && (lower.startsWith('name') || lower == 'name')) {
        if (i + 1 < lines.length) {
          final next = lines[i + 1];
          if (RegExp(r'^[A-Z][A-Z\.\s]+$').hasMatch(next) && next.length > 3) {
            name = next.trim();
          }
        }
        final inlineName = RegExp(
          r'(?:Name|নাম)[\s:ঃ]*(?:MD\.?|মোঃ)?\s*([A-Z][A-Z\.\s]{2,})',
          caseSensitive: false,
        ).firstMatch(line);
        if (inlineName != null) name ??= inlineName.group(1)?.trim();
      }

      // Name (Bangla) - e.g. "মোঃ রুহুল আমিন"
      if (nameBangla == null && RegExp(r'[\u0980-\u09FF]').hasMatch(line)) {
        final banglaName = RegExp(
          r'(?:নাম|Name)[\s:ঃ]*(?:মোঃ|মো\.)?\s*([\u0980-\u09FF\s\.]+)',
        ).firstMatch(line);
        if (banglaName != null) {
          nameBangla = banglaName.group(1)?.trim();
        } else if (!line.contains('পিতা') &&
            !line.contains('মাতা') &&
            !line.contains('ঠিকানা') &&
            line.length > 4 &&
            RegExp(r'[\u0980-\u09FF]').hasMatch(line)) {
          nameBangla = line.trim();
        }
      }

      // NID Number - "326 848 3744" or "NID No 326 848 3744"
      if (documentNumber == null) {
        final nidMatch = RegExp(r'(\d{3}\s+\d{3}\s+\d{4})').firstMatch(line);
        if (nidMatch != null) {
          documentNumber = nidMatch.group(1)?.replaceAll(' ', '');
        } else {
          final nidLabel = RegExp(
            r'(?:nid\s*no|nid)[\s:ঃ]*(\d{3}[\s-]?\d{3}[\s-]?\d{4}|\d{10})',
            caseSensitive: false,
          ).firstMatch(line);
          if (nidLabel != null) {
            documentNumber = nidLabel.group(1)?.replaceAll(RegExp(r'[\s-]'), '');
          }
        }
      }

      // Date of Birth - "21 Jan 1985"
      if (dateOfBirth == null && !lower.contains('issue')) {
        final dobMatch = RegExp(
          r'(?:date\s+of\s+birth|জন্ম\s*তারিখ)?[\s:ঃ]*(\d{1,2}\s+(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+\d{4})',
          caseSensitive: false,
        ).firstMatch(line);
        if (dobMatch != null) dateOfBirth = dobMatch.group(1);
      }

      // Father (পিতা) - e.g. "আককাচ আলী"
      if (fatherName == null) {
        final fatherMatch = RegExp(
          r'পিতা[\s:ঃ]*(?:মোঃ|মো\.)?\s*([\u0980-\u09FF\s]+)',
        ).firstMatch(line);
        if (fatherMatch != null) {
          fatherName = fatherMatch.group(1)?.trim();
        }
      }

      // Mother (মাতা) - e.g. "মোছাঃ রাহিমা খাতুন"
      if (motherName == null) {
        final motherMatch = RegExp(
          r'মাতা[\s:ঃ]*(?:মোছাঃ|মোছা\.)?\s*([\u0980-\u09FF\s]+)',
        ).firstMatch(line);
        if (motherMatch != null) {
          motherName = motherMatch.group(1)?.trim();
        }
      }
    }

    // Fallback: try to get English name from all-caps line
    if (name == null) {
      for (final line in lines) {
        if (RegExp(r'^[A-Z][A-Z\.\s]{4,}$').hasMatch(line) &&
            !line.contains('NID') &&
            !line.contains('BIRTH') &&
            !line.contains('DATE')) {
          name = line.trim();
          break;
        }
      }
    }

    return {
      'name': name,
      'nameBangla': nameBangla,
      'documentNumber': documentNumber,
      'dateOfBirth': dateOfBirth,
      'fatherName': fatherName,
      'motherName': motherName,
    };
  }

  /// Parse back side of BD NID
  /// Layout: ঠিকানা (Address), Blood Group, Place of Birth, Issue Date
  /// Address format: বাসা/হোল্ডিং: X, গ্রাম/রাস্তা: Y, ডাকঘর: Z, District
  Map<String, String?> _parseBackSide(List<String> lines, String rawText) {
    String? address;
    String? houseHolding;
    String? villageRoad;
    String? postOffice;
    String? district;
    String? bloodGroup;
    String? placeOfBirth;
    String? issueDate;
    String? documentNumber;

    // Try MRZ first for NID number (I<BGD326848374<43...)
    final mrzNid = RegExp(r'I<BGD(\d{9,10})').firstMatch(rawText);
    if (mrzNid != null) documentNumber = mrzNid.group(1);

    for (final line in lines) {
      final lower = line.toLowerCase().trim();
      final lineText = line.trim();

      // Address (ঠিকানা) - full format
      if (address == null && (lower.contains('ঠিকানা') || lower.contains('address'))) {
        address = lineText
            .replaceFirst(RegExp(r'^(?:ঠিকানা|address)[\s:ঃ]*', caseSensitive: false), '')
            .trim();
        if (address.isEmpty) address = lineText;

        // Parse address components: বাসা/হোল্ডিং, গ্রাম/রাস্তা, ডাকঘর
        final houseMatch = RegExp(
          r'(?:বাসা/হোল্ডিং|house/holding|householding)[\s:ঃ]*([^,]+)',
          caseSensitive: false,
        ).firstMatch(lineText);
        if (houseMatch != null) houseHolding = houseMatch.group(1)?.trim();

        final villageMatch = RegExp(
          r'(?:গ্রাম/রাস্তা|village/road)[\s:ঃ]*([^,]+)',
          caseSensitive: false,
        ).firstMatch(lineText);
        if (villageMatch != null) villageRoad = villageMatch.group(1)?.trim();

        final postMatch = RegExp(
          r'(?:ডাকঘর|post\s*office)[\s:ঃ]*([^,]+)',
          caseSensitive: false,
        ).firstMatch(lineText);
        if (postMatch != null) postOffice = postMatch.group(1)?.trim();

        // District - often last part: "ঢাকা দক্ষিণ সিটি কর্পোরেশন, ঢাকা"
        final districtMatch = RegExp(
          r'(?:সিটি কর্পোরেশন|city corporation|জেলা)[\s,]*([\u0980-\u09FF\s]+)|([\u0980-\u09FF]+)\s*$',
        ).firstMatch(lineText);
        if (districtMatch != null) {
          district = (districtMatch.group(1) ?? districtMatch.group(2))?.trim();
        }
      }

      // Blood Group - "Blood Group: AB+"
      if (bloodGroup == null) {
        final bloodMatch = RegExp(
          r'(?:Blood\s*Group|রক্তের\s*গ্রুপ)[\s:ঃ]*([ABO][+-]?|AB[+-]?)',
          caseSensitive: false,
        ).firstMatch(lineText);
        if (bloodMatch != null) bloodGroup = bloodMatch.group(1);
      }

      // Place of Birth - "Place of Birth: JHENAIDAH"
      if (placeOfBirth == null) {
        final pobMatch = RegExp(
          r'(?:Place\s+of\s+Birth|জন্ম\s*স্থান)[\s:ঃ]*([A-Za-z\s]+)',
          caseSensitive: false,
        ).firstMatch(lineText);
        if (pobMatch != null) placeOfBirth = pobMatch.group(1)?.trim();
      }

      // Issue Date - "Issue Date: 30 Nov 2015"
      if (issueDate == null) {
        final issueMatch = RegExp(
          r'(?:issue\s+date|প্রদানের\s*তারিখ)[\s:ঃ]*(\d{1,2}\s+(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+\d{4})',
          caseSensitive: false,
        ).firstMatch(lineText);
        if (issueMatch != null) issueDate = issueMatch.group(1);
      }
    }

    // Fallback: parse address from raw text if not found line-by-line
    if (address == null && rawText.contains('ঠিকানা')) {
      final addrStart = rawText.toLowerCase().indexOf('ঠিকানা');
      final addrEnd = rawText.toLowerCase().indexOf('blood group');
      if (addrEnd > addrStart) {
        address = rawText.substring(addrStart, addrEnd).trim();
      } else {
        address = rawText.substring(addrStart).trim();
      }
      address = address.replaceFirst(RegExp(r'^ঠিকানা[\s:ঃ]*', caseSensitive: false), '').trim();
    }

    return {
      'address': address,
      'houseHolding': houseHolding,
      'villageRoad': villageRoad,
      'postOffice': postOffice,
      'district': district,
      'bloodGroup': bloodGroup,
      'placeOfBirth': placeOfBirth,
      'issueDate': issueDate,
      'documentNumber': documentNumber,
    };
  }

  void dispose() {
    _textRecognizer.close();
  }
}
