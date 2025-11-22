import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/health_provider.dart';
import '../../data/models/health_metric.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/health_metric_card.dart';
import '../widgets/loading_widget.dart';
import 'metric_detail_screen.dart';

/// Screen showing only critical health metrics (High and Low status)
class CriticalMetricsScreen extends StatefulWidget {
  const CriticalMetricsScreen({super.key});

  @override
  State<CriticalMetricsScreen> createState() => _CriticalMetricsScreenState();
}

class _CriticalMetricsScreenState extends State<CriticalMetricsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.mediumAnimationDuration,
    );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Critical Metrics'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<HealthProvider>(
        builder: (context, healthProvider, child) {
          if (healthProvider.isLoading) {
            return const LoadingWidget(
              message: AppConstants.loadingMessage,
            );
          }

          if (healthProvider.errorMessage != null) {
            return EmptyStateWidget(
              icon: Icons.error_outline,
              title: 'Error',
              subtitle: healthProvider.errorMessage,
              action: ElevatedButton.icon(
                onPressed: () => healthProvider.loadHealthData(),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            );
          }

          if (healthProvider.healthData == null) {
            return const EmptyStateWidget(
              icon: Icons.health_and_safety_outlined,
              title: 'No Data',
              subtitle: AppConstants.noDataMessage,
            );
          }

          final criticalMetrics = healthProvider.healthData!.getCriticalMetrics();

          if (criticalMetrics.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.celebration,
              title: 'Great News!',
              subtitle: 'All your health metrics are in the normal range! 🎉',
            );
          }

          return FadeTransition(
            opacity: _fadeAnimation,
            child: CustomScrollView(
              slivers: [
                // Header section
                SliverToBoxAdapter(
                  child: _buildHeader(context, criticalMetrics.length),
                ),

                // Critical metrics list
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final metric = criticalMetrics[index];
                        return AnimatedOpacity(
                          duration: AppConstants.shortAnimationDuration,
                          opacity: 1.0,
                          child: HealthMetricCard(
                            metric: metric,
                            onTap: () => _navigateToDetail(context, metric),
                          ),
                        );
                      },
                      childCount: criticalMetrics.length,
                    ),
                  ),
                ),

                // Bottom padding
                const SliverToBoxAdapter(
                  child: SizedBox(height: 24),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Critical Metrics',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$count metric${count > 1 ? 's' : ''} need attention',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.orange.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'These metrics are outside the normal range. Tap any card for detailed information.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _navigateToDetail(BuildContext context, HealthMetric metric) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MetricDetailScreen(metric: metric),
      ),
    );
  }
}

