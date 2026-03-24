class DiseaseReport {
  final String id;
  final String diseaseName;
  final String confidence;
  final String treatment;
  final String? pesticide; // Required by Objective #6
  final String? shopUrl;   // Required by Methodology #6
  final String date;
  final String? imageUrl;

  DiseaseReport({
    required this.id,
    required this.diseaseName,
    required this.confidence,
    required this.treatment,
    this.pesticide,
    this.shopUrl,
    required this.date,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'diseaseName': diseaseName,
      'confidence': confidence,
      'treatment': treatment,
      'pesticide': pesticide,
      'shopUrl': shopUrl,
      'date': date,
      'imageUrl': imageUrl,
    };
  }
}
