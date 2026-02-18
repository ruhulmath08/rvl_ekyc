/// Document information extracted from OCR
/// Specifically designed for Bangladesh National ID Card (BD NID)
///
/// Front: Name (নাম), Father (পিতা), Mother (মাতা), DOB, NID No
/// Back: Address (ঠিকানা), Blood Group, Place of Birth, Issue Date
class DocumentInfoEntity {
  final String rawText;

  // Front side - Basic Information
  final String? name; // English name (e.g. MD. RUHUL AMIN)
  final String? nameBangla; // Bangla name (e.g. মোঃ রুহুল আমিন)
  final String? documentNumber; // NID Number (e.g. 3268483744)
  final String? dateOfBirth; // Date of Birth (e.g. 21 Jan 1985)

  // Front side - Family Information
  final String? fatherName; // Father's name (পিতা)
  final String? motherName; // Mother's name (মাতা)

  // Back side - Address Information (ঠিকানা)
  final String? address; // Full address
  final String? houseHolding; // বাসা/হোল্ডিং
  final String? villageRoad; // গ্রাম/রাস্তা
  final String? postOffice; // ডাকঘর
  final String? district; // District/জেলা

  // Back side - Additional Information
  final String? bloodGroup; // Blood Group (e.g. AB+)
  final String? placeOfBirth; // Place of Birth (e.g. JHENAIDAH)
  final String? issueDate; // Issue Date (e.g. 30 Nov 2015)
  final String? expiryDate; // Expiry Date (if applicable)

  final Map<String, String> additionalFields;

  DocumentInfoEntity({
    required this.rawText,
    this.name,
    this.nameBangla,
    this.documentNumber,
    this.dateOfBirth,
    this.fatherName,
    this.motherName,
    this.address,
    this.houseHolding,
    this.villageRoad,
    this.postOffice,
    this.district,
    this.bloodGroup,
    this.placeOfBirth,
    this.issueDate,
    this.expiryDate,
    Map<String, String>? additionalFields,
  }) : additionalFields = additionalFields ?? {};

  bool get isValid => rawText.isNotEmpty;

  /// Display name (prefer English, fallback to Bangla)
  String? get displayName => name ?? nameBangla;

  /// NID number formatted as XXX XXX XXXX (e.g. 326 848 3744)
  String? get formattedNidNumber {
    if (documentNumber == null) return null;
    final digits = documentNumber!.replaceAll(RegExp(r'\D'), '');
    if (digits.length >= 10) {
      return '${digits.substring(0, 3)} ${digits.substring(3, 6)} ${digits.substring(6, 10)}';
    }
    return documentNumber;
  }

  /// Check if front side data is available
  bool get hasFrontSideData =>
      (name != null || nameBangla != null) &&
      documentNumber != null &&
      dateOfBirth != null;

  /// Check if back side data is available
  bool get hasBackSideData => address != null || bloodGroup != null;
}
