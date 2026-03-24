import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:krishi_sahayak/src/core/network/api_client.dart';

class UserProfile {
  final String name;
  final String email;
  final String title;
  final String location;
  final String landSize;
  final int cropTypes;
  final int ordersCount;

  UserProfile({
    required this.name,
    required this.email,
    required this.title,
    required this.location,
    required this.landSize,
    required this.cropTypes,
    required this.ordersCount,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      title: json['title'] ?? 'Progressive Farmer',
      location: json['location'] ?? 'Bihar, India',
      landSize: json['land_size'] ?? '0 Acres',
      cropTypes: json['crop_types'] ?? 0,
      ordersCount: json['orders_count'] ?? 0,
    );
  }
}

class AuthNotifier extends Notifier<bool> {
  late SharedPreferences _prefs;
  static const _authKey = 'is_logged_in';
  static const _userEmail = 'user_email';
  
  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;

  @override
  bool build() {
    return false; 
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    state = _prefs.getBool(_authKey) ?? false;
    if (state) {
      final email = _prefs.getString(_userEmail);
      if (email != null) {
        // Optimization: Don't await fetchProfile here. 
        // This allows the app to start immediately while the profile loads in the background.
        fetchProfile(email);
      }
    }
  }

  Future<void> register(String name, String email, String password) async {
    final apiClient = ref.read(apiClientProvider);
    try {
      final response = await apiClient.post('/register', data: {
        'name': name,
        'email': email,
        'password': password
      });
      
      if (response.statusCode == 201) {
        await login(email, password);
      }
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<void> login(String email, String password) async {
    final apiClient = ref.read(apiClientProvider);
    try {
      final response = await apiClient.post('/login', data: {
        'email': email,
        'password': password
      });

      if (response.statusCode == 200) {
        _userProfile = UserProfile.fromJson(response.data['user']);
        _prefs = await SharedPreferences.getInstance();
        await _prefs.setBool(_authKey, true);
        await _prefs.setString(_userEmail, email);
        state = true;
      }
    } catch (e) {
      throw Exception('Invalid email or password');
    }
  }

  Future<void> fetchProfile(String email) async {
    final apiClient = ref.read(apiClientProvider);
    try {
      final response = await apiClient.get('/profile/$email');
      if (response.statusCode == 200) {
        _userProfile = UserProfile.fromJson(response.data);
        // Correct way to notify listeners in Notifier: update the state
        // Even if bool hasn't changed, we reassignment triggers listeners
        state = state; 
      }
    } catch (e) {
      print('Error fetching profile: $e');
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final apiClient = ref.read(apiClientProvider);
    try {
      final response = await apiClient.post('/update_profile', data: {
        ...data,
        'email': _userProfile?.email,
      });
      if (response.statusCode == 200) {
        _userProfile = UserProfile.fromJson(response.data['user']);
        state = state;
      }
    } catch (e) {
      throw Exception('Update failed: $e');
    }
  }

  Future<void> logout() async {
    _prefs = await SharedPreferences.getInstance();
    await _prefs.clear();
    _userProfile = null;
    state = false;
  }
}

final authRepositoryProvider = NotifierProvider<AuthNotifier, bool>(() {
  return AuthNotifier();
});
