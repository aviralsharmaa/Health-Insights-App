import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_health_data.dart';

/// Service class for managing health data persistence
class HealthDataService {
  static const String _storageKey = 'health_data';

  /// Save health data to local storage
  Future<void> saveHealthData(UserHealthData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(data.toJson());
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      throw Exception('Failed to save health data: $e');
    }
  }

  /// Load health data from local storage
  Future<UserHealthData?> loadHealthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);
      
      if (jsonString == null) {
        return null;
      }
      
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserHealthData.fromJson(jsonMap);
    } catch (e) {
      throw Exception('Failed to load health data: $e');
    }
  }

  /// Get initial/mock health data
  UserHealthData getInitialHealthData() {
    const jsonData = '''
    {
      "user": "Alex Chen",
      "last_updated": "2024-01-15",
      "metrics": [
        {
          "name": "Hemoglobin",
          "value": 9.5,
          "unit": "g/dL",
          "status": "low",
          "range": "12 - 16",
          "history": [9.2, 9.3, 9.5]
        },
        {
          "name": "Vitamin D",
          "value": 20,
          "unit": "ng/mL",
          "status": "low",
          "range": "30 - 80",
          "history": [18, 19, 20]
        },
        {
          "name": "Fasting Glucose",
          "value": 138,
          "unit": "mg/dL",
          "status": "high",
          "range": "70 - 100",
          "history": [142, 140, 138]
        },
        {
          "name": "Platelets",
          "value": 210,
          "unit": "K/uL",
          "status": "normal",
          "range": "150 - 450",
          "history": [205, 208, 210]
        },
        {
          "name": "WBC Count",
          "value": 7.5,
          "unit": "K/uL",
          "status": "normal",
          "range": "4 - 11",
          "history": [7.2, 7.3, 7.5]
        }
      ]
    }
    ''';
    
    final jsonMap = jsonDecode(jsonData) as Map<String, dynamic>;
    return UserHealthData.fromJson(jsonMap);
  }

  /// Clear all stored health data
  Future<void> clearHealthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      throw Exception('Failed to clear health data: $e');
    }
  }
}

