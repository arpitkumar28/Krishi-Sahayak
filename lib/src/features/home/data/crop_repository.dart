import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:krishi_sahayak/src/features/home/domain/crop.dart';

class CropRepository {
  final Dio _dio;
  CropRepository(this._dio);

  Future<List<Crop>> fetchMarketPrices() async {
    // Artificial delay removed for better performance
    final data = [
      {'id': '1', 'name': 'Wheat', 'price': '₹2,100/quintal', 'category': 'Grains'},
      {'id': '2', 'name': 'Rice', 'price': '₹1,900/quintal', 'category': 'Grains'},
      {'id': '3', 'name': 'Mustard', 'price': '₹5,400/quintal', 'category': 'Oilseeds'},
      {'id': '4', 'name': 'Cotton', 'price': '₹7,200/quintal', 'category': 'Fiber'},
      {'id': '5', 'name': 'Soybean', 'price': '₹4,800/quintal', 'category': 'Oilseeds'},
    ];

    return data.map((e) => Crop.fromMap(e)).toList();
  }
}

final dioProvider = Provider((ref) => Dio());

final cropRepositoryProvider = Provider((ref) {
  return CropRepository(ref.watch(dioProvider));
});

final marketPricesProvider = FutureProvider<List<Crop>>((ref) {
  return ref.watch(cropRepositoryProvider).fetchMarketPrices();
});
