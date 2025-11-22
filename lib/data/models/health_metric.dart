/// Model class representing a single health metric
class HealthMetric {
  final String name;
  final double value;
  final String unit;
  final MetricStatus status;
  final String range;
  final List<double> history;

  HealthMetric({
    required this.name,
    required this.value,
    required this.unit,
    required this.status,
    required this.range,
    required this.history,
  });

  /// Creates a HealthMetric from JSON
  factory HealthMetric.fromJson(Map<String, dynamic> json) {
    return HealthMetric(
      name: json['name'] as String,
      value: (json['value'] as num).toDouble(),
      unit: json['unit'] as String,
      status: _statusFromString(json['status'] as String),
      range: json['range'] as String,
      history: (json['history'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );
  }

  /// Converts HealthMetric to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'value': value,
      'unit': unit,
      'status': status.name,
      'range': range,
      'history': history,
    };
  }

  /// Helper method to convert string to MetricStatus
  static MetricStatus _statusFromString(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
        return MetricStatus.normal;
      case 'high':
        return MetricStatus.high;
      case 'low':
        return MetricStatus.low;
      default:
        return MetricStatus.normal;
    }
  }

  /// Creates a copy of this metric with optional new values
  HealthMetric copyWith({
    String? name,
    double? value,
    String? unit,
    MetricStatus? status,
    String? range,
    List<double>? history,
  }) {
    return HealthMetric(
      name: name ?? this.name,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      status: status ?? this.status,
      range: range ?? this.range,
      history: history ?? this.history,
    );
  }
}

/// Enum representing the status of a health metric
enum MetricStatus {
  normal,
  high,
  low,
}

