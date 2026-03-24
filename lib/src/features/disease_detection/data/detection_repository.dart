import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:krishi_sahayak/src/features/disease_detection/domain/disease_report.dart';
import 'package:krishi_sahayak/src/core/network/api_client.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_service.dart';

class DetectionRepository {
  final ApiClient _apiClient;
  final DatabaseService _dbService;

  DetectionRepository(this._apiClient, this._dbService);

  Future<Map<String, dynamic>> detectDisease(String imagePath, String email) async {
    final response = await _apiClient.postImage(
      '/predict', 
      imagePath, 
      extraData: {'email': email},
    );
    
    final data = response.data;
    
    final report = DiseaseReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      diseaseName: data['disease_name'] ?? 'Unknown',
      confidence: data['confidence'] ?? '0.0%',
      treatment: data['treatment'] ?? 'Consult an expert.',
      pesticide: data['pesticide'] ?? 'Generic Bio-pesticide', // Added from report requirement
      shopUrl: data['shop_url'] ?? 'https://www.agristore.com', // Added from methodology requirement
      date: DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now()),
      imageUrl: imagePath,
    );

    await _dbService.saveReport(report);
    
    return data;
  }

  Future<List<DiseaseReport>> getRemoteReports() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    
    if (email == null) return [];

    try {
      final response = await _apiClient.get('/reports/$email');
      final List data = response.data;
      
      return data.map((item) => DiseaseReport(
        id: item['id'].toString(),
        diseaseName: item['diseaseName'],
        confidence: item['confidence'],
        treatment: item['treatment'],
        pesticide: item['pesticide'],
        shopUrl: item['shopUrl'],
        date: DateFormat('dd MMM yyyy').format(DateTime.parse(item['date'])),
      )).toList();
    } catch (e) {
      return []; 
    }
  }
}

final detectionRepositoryProvider = Provider((ref) {
  return DetectionRepository(
    ref.watch(apiClientProvider),
    DatabaseService(),
  );
});
