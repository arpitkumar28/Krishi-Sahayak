import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:krishi_sahayak/src/features/disease_detection/data/detection_repository.dart';
import 'package:krishi_sahayak/src/features/authentication/data/auth_repository.dart';
import 'package:krishi_sahayak/src/core/utils/snackbar_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class DetectionScreen extends ConsumerStatefulWidget {
  const DetectionScreen({super.key});

  @override
  ConsumerState<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends ConsumerState<DetectionScreen> {
  File? _image;
  bool _isAnalyzing = false;
  final _picker = ImagePicker();

  static const String _apiKey = 'AIzaSyD4DA0-AiZDhO6o33d1Xp_UmED4GvW6Cyo';

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 1080,
      imageQuality: 75,
    );
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null) return;

    setState(() => _isAnalyzing = true);
    
    try {
      final imageBytes = await _image!.readAsBytes();
      final base64Image = base64Encode(imageBytes);
      final dio = Dio();

      String modelName = 'gemini-1.5-flash';
      String url = 'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$_apiKey';

      final requestBody = {
        "contents": [
          {
            "parts": [
              {
                "text": "Analyze this plant leaf. Identify disease, confidence, treatment, and specific pesticide. "
                        "Return result in JSON with keys: disease_name, confidence, treatment, pesticide, shop_url. "
                        "Always provide a valid URL for shop_url. No other text."
              },
              {
                "inline_data": {
                  "mime_type": "image/jpeg",
                  "data": base64Image
                }
              }
            ]
          }
        ],
        "generationConfig": {
          "response_mime_type": "application/json",
        }
      };

      final response = await dio.post(url, data: requestBody);
      final candidates = response.data['candidates'] as List;
      final textResponse = candidates[0]['content']['parts'][0]['text'];
      final result = jsonDecode(textResponse);

      if (mounted) {
        _showStyledResult(
          result['disease_name'] ?? 'Unknown',
          result['confidence'] ?? 'N/A',
          result['treatment'] ?? 'No treatment info.',
          result['pesticide'] ?? 'Generic Bio-pesticide',
          result['shop_url'] ?? 'https://www.agristore.com',
        );
      }

      final user = ref.read(authRepositoryProvider.notifier).userProfile;
      ref.read(detectionRepositoryProvider).detectDisease(
            _image!.path,
            user?.email ?? 'anonymous',
          );

    } catch (e) {
      if (mounted) SnackBarUtils.showError(context, "Analysis failed. Please try again.");
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  void _showStyledResult(String name, String confidence, String treatment, String pesticide, String shopUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: SingleChildScrollView( 
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        name,
                        style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Text('Confidence: $confidence', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green)),
                ),
                const SizedBox(height: 20),
                _buildInfoSection('📋 Treatment Plan', treatment),
                const SizedBox(height: 16),
                _buildInfoSection('🧪 Recommended Pesticide', pesticide),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => launchUrl(Uri.parse(shopUrl)),
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: const Text('BUY RECOMMENDED PRODUCTS'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade800,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('CLOSE', style: GoogleFonts.poppins(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
        const SizedBox(height: 6),
        Text(content, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black54, height: 1.4)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Disease Detection', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 350,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: _image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.file(_image!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, size: 60, color: Colors.green.shade200),
                        const SizedBox(height: 16),
                        Text('Take a photo of the infected leaf', style: GoogleFonts.poppins(color: Colors.grey)),
                      ],
                    ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: Icons.camera_alt_rounded,
                    label: 'Camera',
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ActionButton(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: Icons.photo_size_select_actual_rounded,
                    label: 'Gallery',
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 58,
              child: ElevatedButton(
                onPressed: _image == null || _isAnalyzing ? null : _analyzeImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isAnalyzing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('ANALYZE CROP HEALTH', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color color;

  const _ActionButton({required this.onPressed, required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color, width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
