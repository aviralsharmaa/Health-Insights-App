import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_constants.dart';
import '../../core/themes/app_theme.dart';
import '../../data/models/health_metric.dart';
import '../widgets/metric_chart.dart';

/// Detail screen showing comprehensive information about a specific metric
class MetricDetailScreen extends StatefulWidget {
  final HealthMetric metric;

  const MetricDetailScreen({
    super.key,
    required this.metric,
  });

  @override
  State<MetricDetailScreen> createState() => _MetricDetailScreenState();
}

class _MetricDetailScreenState extends State<MetricDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.mediumAnimationDuration,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = AppTheme.getStatusColor(widget.metric.status.name);
    final backgroundColor = AppTheme.getStatusBackgroundColor(
      widget.metric.status.name,
      isDark,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.metric.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareMetric(context),
            tooltip: 'Share',
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ListView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            children: [
              // Hero metric card
              _buildHeroCard(context, statusColor, backgroundColor),
              const SizedBox(height: 24),

              // Chart
              MetricChart(metric: widget.metric),
              const SizedBox(height: 24),

              // Statistics
              _buildStatisticsCard(context),
              const SizedBox(height: 24),

              // Information
              _buildInformationCard(context, statusColor),
              const SizedBox(height: 24),

              // History
              _buildHistoryCard(context, statusColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    Color statusColor,
    Color backgroundColor,
  ) {
    return Card(
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          children: [
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.metric.status.name.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Value
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.metric.value.toString(),
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    widget.metric.unit,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: statusColor.withValues(alpha: 0.8),
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Normal range
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Normal Range',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.metric.range} ${widget.metric.unit}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(BuildContext context) {
    final history = widget.metric.history;
    final average = history.reduce((a, b) => a + b) / history.length;
    final minValue = history.reduce((a, b) => a < b ? a : b);
    final maxValue = history.reduce((a, b) => a > b ? a : b);
    final trend = _calculateTrend();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildStatRow(context, 'Average', average.toStringAsFixed(1)),
            const Divider(height: 24),
            _buildStatRow(context, 'Minimum', minValue.toStringAsFixed(1)),
            const Divider(height: 24),
            _buildStatRow(context, 'Maximum', maxValue.toStringAsFixed(1)),
            const Divider(height: 24),
            _buildStatRow(context, 'Trend', trend),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildInformationCard(BuildContext context, Color statusColor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About ${widget.metric.name}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
              context,
              Icons.info_outline,
              'Status',
              widget.metric.status.name.toUpperCase(),
              statusColor,
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              context,
              Icons.straighten,
              'Unit of Measurement',
              widget.metric.unit,
              null,
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              context,
              Icons.bar_chart,
              'Normal Range',
              '${widget.metric.range} ${widget.metric.unit}',
              null,
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              context,
              Icons.timeline,
              'Data Points',
              '${widget.metric.history.length} readings',
              null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color? valueColor,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: valueColor,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(BuildContext context, Color statusColor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...widget.metric.history.asMap().entries.map((entry) {
              final index = entry.key;
              final value = entry.value;
              final isLatest = index == widget.metric.history.length - 1;
              final date = DateTime.now().subtract(
                Duration(days: widget.metric.history.length - index - 1),
              );
              final formattedDate = DateFormat('MMM dd').format(date);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isLatest ? statusColor : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        formattedDate,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '$value ${widget.metric.unit}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: isLatest ? FontWeight.bold : FontWeight.normal,
                            color: isLatest ? statusColor : null,
                          ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _calculateTrend() {
    if (widget.metric.history.length < 2) return 'Insufficient data';

    final firstValue = widget.metric.history.first;
    final lastValue = widget.metric.history.last;
    final change = lastValue - firstValue;
    final percentChange = (change / firstValue * 100).abs();

    if (change > 0) {
      return '↑ ${percentChange.toStringAsFixed(1)}% increase';
    } else if (change < 0) {
      return '↓ ${percentChange.toStringAsFixed(1)}% decrease';
    } else {
      return 'Stable';
    }
  }

  void _shareMetric(BuildContext context) async {
    // Calculate statistics
    final history = widget.metric.history;
    final average = history.reduce((a, b) => a + b) / history.length;
    final minValue = history.reduce((a, b) => a < b ? a : b);
    final maxValue = history.reduce((a, b) => a > b ? a : b);
    
    // Format the share message
    final shareText = '''
📊 Health Metric Report

━━━━━━━━━━━━━━━━━━━━━━

📌 ${widget.metric.name}

Current Value: ${widget.metric.value} ${widget.metric.unit}
Status: ${widget.metric.status.name.toUpperCase()} ${_getStatusEmoji(widget.metric.status.name)}

Normal Range: ${widget.metric.range} ${widget.metric.unit}

━━━━━━━━━━━━━━━━━━━━━━

📈 Statistics:
• Average: ${average.toStringAsFixed(1)} ${widget.metric.unit}
• Minimum: ${minValue.toStringAsFixed(1)} ${widget.metric.unit}
• Maximum: ${maxValue.toStringAsFixed(1)} ${widget.metric.unit}
• Trend: ${_calculateTrend()}

━━━━━━━━━━━━━━━━━━━━━━

📅 Recent History:
${_formatHistory()}

━━━━━━━━━━━━━━━━━━━━━━

Generated by Health Insights App
${DateFormat('MMM dd, yyyy • hh:mm a').format(DateTime.now())}
    '''.trim();

    try {
      // Share the formatted text
      await Share.share(
        shareText,
        subject: '${widget.metric.name} Health Report',
      );

      // Show success feedback
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Share dialog opened'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Text('Failed to share: ${e.toString()}'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _getStatusEmoji(String status) {
    switch (status.toLowerCase()) {
      case 'normal':
        return '✅';
      case 'high':
        return '⚠️';
      case 'low':
        return '🔻';
      default:
        return '📊';
    }
  }

  String _formatHistory() {
    final buffer = StringBuffer();
    for (var i = 0; i < widget.metric.history.length; i++) {
      final date = DateTime.now().subtract(
        Duration(days: widget.metric.history.length - i - 1),
      );
      final value = widget.metric.history[i];
      final isLatest = i == widget.metric.history.length - 1;
      
      buffer.write('${DateFormat('MMM dd').format(date)}: ');
      buffer.write('${value.toStringAsFixed(1)} ${widget.metric.unit}');
      if (isLatest) {
        buffer.write(' ⭐ (Current)');
      }
      if (i < widget.metric.history.length - 1) {
        buffer.write('\n');
      }
    }
    return buffer.toString();
  }
}

