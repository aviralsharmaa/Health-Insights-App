import 'health_metric.dart';

/// Model class representing user's complete health data
class UserHealthData {
  final String userName;
  final DateTime lastUpdated;
  final List<HealthMetric> metrics;

  UserHealthData({
    required this.userName,
    required this.lastUpdated,
    required this.metrics,
  });

  /// Creates UserHealthData from JSON
  factory UserHealthData.fromJson(Map<String, dynamic> json) {
    return UserHealthData(
      userName: json['user'] as String,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      metrics: (json['metrics'] as List<dynamic>)
          .map((e) => HealthMetric.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converts UserHealthData to JSON
  Map<String, dynamic> toJson() {
    return {
      'user': userName,
      'last_updated': lastUpdated.toIso8601String(),
      'metrics': metrics.map((m) => m.toJson()).toList(),
    };
  }

  /// Creates a copy with optional new values
  UserHealthData copyWith({
    String? userName,
    DateTime? lastUpdated,
    List<HealthMetric>? metrics,
  }) {
    return UserHealthData(
      userName: userName ?? this.userName,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      metrics: metrics ?? this.metrics,
    );
  }

  /// Get metrics by status
  List<HealthMetric> getMetricsByStatus(MetricStatus status) {
    return metrics.where((m) => m.status == status).toList();
  }

  /// Get critical metrics (high or low)
  List<HealthMetric> getCriticalMetrics() {
    return metrics
        .where((m) => m.status == MetricStatus.high || m.status == MetricStatus.low)
        .toList();
  }

  /// Get normal metrics
  List<HealthMetric> getNormalMetrics() {
    return metrics.where((m) => m.status == MetricStatus.normal).toList();
  }
}

