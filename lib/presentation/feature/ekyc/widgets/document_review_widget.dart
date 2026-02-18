import 'dart:typed_data';
import 'package:domain/model/document_info_entity.dart';
import 'package:flutter/material.dart';
import 'package:hello_flutter/presentation/feature/ekyc/ekyc_view_model.dart';

class DocumentReviewWidget extends StatelessWidget {
  final EkycViewModel viewModel;

  const DocumentReviewWidget({
    required this.viewModel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Uint8List?>(
      valueListenable: viewModel.documentImage,
      builder: (context, imageBytes, _) {
        if (imageBytes == null) {
          return const Center(child: Text('No document image'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Document image preview
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.memory(
                  imageBytes,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 16),

              // Document info
              ValueListenableBuilder(
                valueListenable: viewModel.documentInfo,
                builder: (context, DocumentInfoEntity? docInfo, _) {
                  if (docInfo == null) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Extracting document information...'),
                      ),
                    );
                  }

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.badge, color: Colors.blue.shade700),
                              const SizedBox(width: 8),
                              const Text(
                                'National ID Card',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Front Side (নাম, পিতা, মাতা, DOB, NID No)
                          if (docInfo.hasFrontSideData ||
                              docInfo.name != null ||
                              docInfo.fatherName != null ||
                              docInfo.motherName != null)
                            ...[
                              _buildSectionHeader('Front Side', 'সামনের পৃষ্ঠা'),
                              const SizedBox(height: 8),
                              if (docInfo.nameBangla != null)
                                _buildInfoRow('নাম (Name)', docInfo.nameBangla!),
                              if (docInfo.name != null)
                                _buildInfoRow('Name (English)', docInfo.name!),
                              if (docInfo.fatherName != null)
                                _buildInfoRow('পিতা (Father)', docInfo.fatherName!),
                              if (docInfo.motherName != null)
                                _buildInfoRow('মাতা (Mother)', docInfo.motherName!),
                              if (docInfo.dateOfBirth != null)
                                _buildInfoRow('Date of Birth', docInfo.dateOfBirth!),
                              if (docInfo.formattedNidNumber != null)
                                _buildInfoRow('NID No', docInfo.formattedNidNumber!),
                              const SizedBox(height: 16),
                            ],

                          // Back Side (ঠিকানা, Blood Group, Place of Birth, Issue Date)
                          if (docInfo.hasBackSideData ||
                              docInfo.address != null ||
                              docInfo.bloodGroup != null ||
                              docInfo.placeOfBirth != null ||
                              docInfo.issueDate != null)
                            ...[
                              _buildSectionHeader('Back Side', 'পিছনের পৃষ্ঠা'),
                              const SizedBox(height: 8),
                              if (docInfo.address != null)
                                _buildInfoRow('ঠিকানা (Address)', docInfo.address!),
                              if (docInfo.houseHolding != null)
                                _buildInfoRow('বাসা/হোল্ডিং', docInfo.houseHolding!),
                              if (docInfo.villageRoad != null)
                                _buildInfoRow('গ্রাম/রাস্তা', docInfo.villageRoad!),
                              if (docInfo.postOffice != null)
                                _buildInfoRow('ডাকঘর (Post Office)', docInfo.postOffice!),
                              if (docInfo.district != null)
                                _buildInfoRow('District', docInfo.district!),
                              if (docInfo.bloodGroup != null)
                                _buildInfoRow('Blood Group', docInfo.bloodGroup!),
                              if (docInfo.placeOfBirth != null)
                                _buildInfoRow('Place of Birth', docInfo.placeOfBirth!),
                              if (docInfo.issueDate != null)
                                _buildInfoRow('Issue Date', docInfo.issueDate!),
                              const SizedBox(height: 16),
                            ],

                          if (docInfo.expiryDate != null)
                            _buildInfoRow('Expiry Date', docInfo.expiryDate!),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // Face detection result
              ValueListenableBuilder(
                valueListenable: viewModel.documentFaceResult,
                builder: (context, faceResult, _) {
                  if (faceResult == null) {
                    return const SizedBox.shrink();
                  }

                  return Card(
                    color: faceResult.faceDetected
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            faceResult.faceDetected
                                ? Icons.check_circle
                                : Icons.error,
                            color: faceResult.faceDetected
                                ? Colors.green
                                : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              faceResult.faceDetected
                                  ? 'Face detected successfully'
                                  : faceResult.errorMessage ?? 'Face detection failed',
                              style: TextStyle(
                                color: faceResult.faceDetected
                                    ? Colors.green.shade900
                                    : Colors.red.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Action buttons
              ElevatedButton(
                onPressed: () => viewModel.proceedToSelfieCapture(),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Continue to Selfie Capture'),
              ),

              const SizedBox(height: 8),

              OutlinedButton(
                onPressed: () => viewModel.retry(),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String english, String bangla) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '$english / $bangla',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
