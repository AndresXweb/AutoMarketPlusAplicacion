import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../shared/models/vehicle.dart';

class CatalogRepository {
  CatalogRepository(this._api);
  final ApiClient _api;

  Future<List<Vehicle>> listVehicles({
    String? q,
    String? brand,
    String? city,
    String? listingType,
  }) async {
    final res = await _api.dio.get(
      '/api/vehicles',
      queryParameters: {
        if (q != null && q.isNotEmpty) 'q': q,
        if (brand != null && brand.isNotEmpty) 'brand': brand,
        if (city != null && city.isNotEmpty) 'city': city,
        if (listingType != null && listingType.isNotEmpty) 'listingType': listingType,
      },
    );
    final list = res.data as List<dynamic>;
    return list.map((e) => Vehicle.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<List<Vehicle>> featured() async {
    final res = await _api.dio.get('/api/featured');
    final list = res.data as List<dynamic>;
    return list.map((e) => Vehicle.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<Map<String, dynamic>> stats() async {
    final res = await _api.dio.get('/api/stats');
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Vehicle> getById(int id) async {
    final res = await _api.dio.get('/api/vehicles/$id');
    return Vehicle.fromJson(Map<String, dynamic>.from(res.data as Map));
  }
}

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository(ref.watch(apiClientProvider));
});
