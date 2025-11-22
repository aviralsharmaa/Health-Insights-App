import '../models/user_health_data.dart';
import '../models/health_metric.dart';
import '../services/health_data_service.dart';

/// Repository class for managing health data operations
class HealthRepository {
  final HealthDataService _dataService;

  HealthRepository(this._dataService);

  /// Initialize health data - load from storage or use initial data
  Future<UserHealthData> initializeHealthData() async {
    try {
      final savedData = await _dataService.loadHealthData();
      
      if (savedData != null) {
        return savedData;
      }
      
      // If no saved data, use initial data and save it
      final initialData = _dataService.getInitialHealthData();
      await _dataService.saveHealthData(initialData);
      return initialData;
    } catch (e) {
      // If any error, return initial data
      return _dataService.getInitialHealthData();
    }
  }

  /// Get all health metrics
  Future<List<HealthMetric>> getAllMetrics() async {
    final data = await _dataService.loadHealthData();
    return data?.metrics ?? [];
  }

  /// Get a specific metric by name
  Future<HealthMetric?> getMetricByName(String name) async {
    final data = await _dataService.loadHealthData();
    if (data == null) return null;
    
    try {
      return data.metrics.firstWhere(
        (metric) => metric.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Update a specific metric
  Future<void> updateMetric(HealthMetric updatedMetric) async {
    final data = await _dataService.loadHealthData();
    if (data == null) return;

    final updatedMetrics = data.metrics.map((metric) {
      if (metric.name == updatedMetric.name) {
        return updatedMetric;
      }
      return metric;
    }).toList();

    final updatedData = data.copyWith(
      metrics: updatedMetrics,
      lastUpdated: DateTime.now(),
    );

    await _dataService.saveHealthData(updatedData);
  }

  /// Save complete health data
  Future<void> saveHealthData(UserHealthData data) async {
    await _dataService.saveHealthData(data);
  }

  /// Refresh health data (simulates fetching new data)
  Future<UserHealthData> refreshHealthData() async {
    // In a real app, this would fetch from an API
    final currentData = await _dataService.loadHealthData();
    if (currentData != null) {
      final refreshedData = currentData.copyWith(
        lastUpdated: DateTime.now(),
      );
      await _dataService.saveHealthData(refreshedData);
      return refreshedData;
    }
    return _dataService.getInitialHealthData();
  }
}

