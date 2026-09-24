import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../shared/models/vehicle.dart';

class CatalogFilters {
  const CatalogFilters({
    this.q,
    this.brand,
    this.city,
    this.listingType,
    this.bodyType,
    this.fuel,
    this.minPrice,
    this.maxPrice,
    this.yearMin,
    this.yearMax,
    this.verifiedOnly = false,
  });

  final String? q;
  final String? brand;
  final String? city;
  final String? listingType;
  final String? bodyType;
  final String? fuel;
  final double? minPrice;
  final double? maxPrice;
  final int? yearMin;
  final int? yearMax;
  final bool verifiedOnly;

  CatalogFilters copyWith({
    String? q,
    String? brand,
    String? city,
    String? listingType,
    String? bodyType,
    String? fuel,
    double? minPrice,
    double? maxPrice,
    int? yearMin,
    int? yearMax,
    bool? verifiedOnly,
    bool clearBrand = false,
    bool clearCity = false,
    bool clearListing = false,
  }) {
    return CatalogFilters(
      q: q ?? this.q,
      brand: clearBrand ? null : (brand ?? this.brand),
      city: clearCity ? null : (city ?? this.city),
      listingType: clearListing ? null : (listingType ?? this.listingType),
      bodyType: bodyType ?? this.bodyType,
      fuel: fuel ?? this.fuel,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      yearMin: yearMin ?? this.yearMin,
      yearMax: yearMax ?? this.yearMax,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
    );
  }

  Map<String, dynamic> toQuery() {
    return {
      if (q != null && q!.isNotEmpty) 'q': q,
      if (brand != null && brand!.isNotEmpty) 'brand': brand,
      if (city != null && city!.isNotEmpty) 'city': city,
      if (listingType != null && listingType!.isNotEmpty) 'listingType': listingType,
      if (bodyType != null && bodyType!.isNotEmpty) 'bodyType': bodyType,
      if (fuel != null && fuel!.isNotEmpty) 'fuel': fuel,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (yearMin != null) 'yearMin': yearMin,
      if (yearMax != null) 'yearMax': yearMax,
      if (verifiedOnly) 'verifiedOnly': 'true',
    };
  }
}

class CatalogRepository {
  CatalogRepository(this._api);
  final ApiClient _api;

  Future<List<Vehicle>> listVehicles([CatalogFilters filters = const CatalogFilters()]) async {
    final res = await _api.dio.get(
      '/api/vehicles',
      queryParameters: filters.toQuery(),
    );
    final list = res.data as List<dynamic>;
    return list
        .map((e) => Vehicle.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<Vehicle>> featured() async {
    final res = await _api.dio.get('/api/featured');
    final list = res.data as List<dynamic>;
    return list
        .map((e) => Vehicle.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
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
