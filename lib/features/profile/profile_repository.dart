import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../../shared/models/vehicle.dart';
import '../../shared/models/profile.dart';

class ProfileRepository {
  ProfileRepository(this._api);
  final ApiClient _api;

  Future<Profile> getProfile() async {
    final res = await _api.dio.get('/api/profile');
    return Profile.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<void> updateProfile(Map<String, dynamic> body) async {
    await _api.dio.patch('/api/profile', data: body);
  }

  Future<List<Vehicle>> myVehicles() async {
    final res = await _api.dio.get('/api/my-vehicles');
    final list = res.data as List<dynamic>;
    return list.map((e) => Vehicle.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<List<Vehicle>> favorites() async {
    final res = await _api.dio.get('/api/favorites');
    final list = res.data as List<dynamic>;
    return list.map((e) => Vehicle.fromJson(Map<String, dynamic>.from(e as Map))).toList();
  }

  Future<bool> toggleFavorite(int vehicleId) async {
    final res = await _api.dio.post('/api/favorites', data: {'vehicleId': vehicleId});
    return res.data['favorite'] == true;
  }

  Future<Map<String, dynamic>> offers() async {
    final res = await _api.dio.get('/api/offers');
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<void> createOffer({
    required int vehicleId,
    required String offerType,
    double? amount,
    String? message,
  }) async {
    await _api.dio.post('/api/offers', data: {
      'vehicleId': vehicleId,
      'offerType': offerType,
      if (amount != null) 'amount': amount,
      if (message != null) 'message': message,
    });
  }

  Future<void> respondOffer(int id, String action, {String? message, double? amount}) async {
    await _api.dio.post('/api/offers/$id', data: {
      'action': action,
      if (message != null) 'message': message,
      if (amount != null) 'amount': amount,
    });
  }

  Future<void> updateVehicleStatus(int id, String status) async {
    await _api.dio.patch('/api/my-vehicles/$id', data: {'status': status});
  }

  Future<void> deleteVehicle(int id) async {
    await _api.dio.delete('/api/my-vehicles/$id');
  }

  Future<void> contact({
    required String name,
    required String email,
    required String phone,
    required String message,
    String? subject,
  }) async {
    await _api.dio.post('/api/contact', data: {
      'name': name,
      'email': email,
      'phone': phone,
      'message': message,
      if (subject != null) 'subject': subject,
    });
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(apiClientProvider));
});
