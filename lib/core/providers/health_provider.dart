import 'package:flutter/foundation.dart';
import '../../data/models/health_metric.dart';
import '../../data/models/user_health_data.dart';
import '../../data/repositories/health_repository.dart';

/// Provider class for managing health data state
class HealthProvider with ChangeNotifier {
  final HealthRepository _repository;
  
  UserHealthData? _healthData;
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  MetricStatus? _filterStatus;

  HealthProvider(this._repository);

  // Getters
  UserHealthData? get healthData => _healthData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  MetricStatus? get filterStatus => _filterStatus;
  
  List<HealthMetric> get metrics => _healthData?.metrics ?? [];
  
  /// Get filtered metrics based on search query and status filter
  List<HealthMetric> get filteredMetrics {
    if (_healthData == null) return [];
    
    var filtered = _healthData!.metrics;
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((metric) {
        return metric.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }
    
    // Apply status filter
    if (_filterStatus != null) {
      filtered = filtered.where((metric) {
        return metric.status == _filterStatus;
      }).toList();
    }
    
    return filtered;
  }
  
  /// Get count of metrics by status
  int getMetricCountByStatus(MetricStatus status) {
    return metrics.where((m) => m.status == status).length;
  }
  
  /// Get critical metrics count
  int get criticalMetricsCount {
    return metrics.where((m) => 
      m.status == MetricStatus.high || m.status == MetricStatus.low
    ).length;
  }
  
  /// Initialize and load health data
  Future<void> loadHealthData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _healthData = await _repository.initializeHealthData();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load health data: ${e.toString()}';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh health data
  Future<void> refreshHealthData() async {
    try {
      _healthData = await _repository.refreshHealthData();
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to refresh health data: ${e.toString()}';
      debugPrint(_errorMessage);
      notifyListeners();
    }
  }

  /// Update a specific metric
  Future<void> updateMetric(HealthMetric metric) async {
    try {
      await _repository.updateMetric(metric);
      await refreshHealthData();
    } catch (e) {
      _errorMessage = 'Failed to update metric: ${e.toString()}';
      debugPrint(_errorMessage);
      notifyListeners();
    }
  }

  /// Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Clear search query
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  /// Set status filter
  void setStatusFilter(MetricStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }

  /// Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _filterStatus = null;
    notifyListeners();
  }

  /// Get metric by name
  HealthMetric? getMetricByName(String name) {
    try {
      return metrics.firstWhere(
        (metric) => metric.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }
}

