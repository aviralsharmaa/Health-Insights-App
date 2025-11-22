import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/providers/health_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/themes/app_theme.dart';
import '../../data/models/health_metric.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/health_metric_card.dart';
import '../widgets/loading_widget.dart';
import '../widgets/search_bar_widget.dart';
import 'critical_metrics_screen.dart';
import 'metric_detail_screen.dart';

/// Dashboard/Home screen showing health metrics overview
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
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

    // Load health data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HealthProvider>().loadHealthData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
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

          return FadeTransition(
            opacity: _fadeAnimation,
            child: RefreshIndicator(
              onRefresh: () => healthProvider.refreshHealthData(),
              child: CustomScrollView(
                slivers: [
                  // Header section
                  SliverToBoxAdapter(
                    child: _buildHeader(context, healthProvider),
                  ),

                  // Summary cards
                  SliverToBoxAdapter(
                    child: _buildSummarySection(context, healthProvider),
                  ),

                  // Search and filter
                  SliverToBoxAdapter(
                    child: _buildSearchSection(context, healthProvider),
                  ),

                  // Metrics list
                  _buildMetricsList(context, healthProvider),

                  // Bottom padding
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 24),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(AppConstants.appName),
      actions: [
        // Theme toggle
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return IconButton(
              icon: Icon(
                themeProvider.isDarkMode
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onPressed: () => themeProvider.toggleTheme(),
              tooltip: 'Toggle theme',
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, HealthProvider provider) {
    final healthData = provider.healthData!;
    final lastUpdated = DateFormat('MMM dd, yyyy').format(healthData.lastUpdated);

    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, ${healthData.userName}',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              const SizedBox(width: 4),
              Text(
                'Last updated: $lastUpdated',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, HealthProvider provider) {
    final normalCount = provider.getMetricCountByStatus(MetricStatus.normal);
    final highCount = provider.getMetricCountByStatus(MetricStatus.high);
    final lowCount = provider.getMetricCountByStatus(MetricStatus.low);
    final totalCount = provider.metrics.length;
    final criticalCount = highCount + lowCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health Overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Main stats card - Full width
          _buildMainStatsCard(context, totalCount, criticalCount),
          
          const SizedBox(height: 12),
          
          // Status breakdown - 3 equal cards
          Row(
            children: [
              Expanded(
                child: _buildCompactStatCard(
                  context: context,
                  title: 'Normal',
                  value: normalCount.toString(),
                  icon: Icons.check_circle_outline,
                  color: AppTheme.normalColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCompactStatCard(
                  context: context,
                  title: 'High',
                  value: highCount.toString(),
                  icon: Icons.trending_up,
                  color: AppTheme.highColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCompactStatCard(
                  context: context,
                  title: 'Low',
                  value: lowCount.toString(),
                  icon: Icons.trending_down,
                  color: AppTheme.lowColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainStatsCard(BuildContext context, int total, int critical) {
    final percentage = total > 0 ? ((total - critical) / total * 100).round() : 0;
    
    return InkWell(
      onTap: critical > 0 
          ? () => _navigateToCriticalMetrics(context)
          : null,
      borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
            // Left side - Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.health_and_safety,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            
            // Middle - Stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Metrics',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    total.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$percentage% in normal range',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Right side - Critical count with tap indicator
            if (critical > 0)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          critical.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Critical',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.white70,
                        size: 10,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactStatCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? color.withValues(alpha: 0.15)
            : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipColor = color ?? AppTheme.primaryColor;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor
              : (isDark 
                  ? chipColor.withValues(alpha: 0.15)
                  : chipColor.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected 
                ? chipColor 
                : chipColor.withValues(alpha: isDark ? 0.3 : 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected 
                  ? Colors.white 
                  : (isDark ? chipColor.withValues(alpha: 0.9) : chipColor),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected 
                    ? Colors.white 
                    : (isDark 
                        ? Theme.of(context).textTheme.bodyMedium?.color 
                        : chipColor),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context, HealthProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            'Your Metrics',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          SearchBarWidget(
            hintText: 'Search metrics...',
            onChanged: (query) => provider.setSearchQuery(query),
            onClear: () => provider.clearSearch(),
          ),
          const SizedBox(height: 12),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  context: context,
                  label: 'All',
                  icon: Icons.grid_view_rounded,
                  isSelected: provider.filterStatus == null,
                  onTap: () => provider.setStatusFilter(null),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context: context,
                  label: 'Normal',
                  icon: Icons.check_circle_outline,
                  color: AppTheme.normalColor,
                  isSelected: provider.filterStatus == MetricStatus.normal,
                  onTap: () => provider.setStatusFilter(
                    provider.filterStatus == MetricStatus.normal 
                        ? null 
                        : MetricStatus.normal,
                  ),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context: context,
                  label: 'High',
                  icon: Icons.trending_up,
                  color: AppTheme.highColor,
                  isSelected: provider.filterStatus == MetricStatus.high,
                  onTap: () => provider.setStatusFilter(
                    provider.filterStatus == MetricStatus.high 
                        ? null 
                        : MetricStatus.high,
                  ),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  context: context,
                  label: 'Low',
                  icon: Icons.trending_down,
                  color: AppTheme.lowColor,
                  isSelected: provider.filterStatus == MetricStatus.low,
                  onTap: () => provider.setStatusFilter(
                    provider.filterStatus == MetricStatus.low 
                        ? null 
                        : MetricStatus.low,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsList(BuildContext context, HealthProvider provider) {
    final metrics = provider.filteredMetrics;

    if (metrics.isEmpty) {
      return SliverFillRemaining(
        child: EmptyStateWidget(
          icon: Icons.search_off,
          title: 'No Results',
          subtitle: 'No metrics match your search or filter',
          action: TextButton(
            onPressed: () => provider.clearFilters(),
            child: const Text('Clear Filters'),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final metric = metrics[index];
          return AnimatedOpacity(
            duration: AppConstants.shortAnimationDuration,
            opacity: 1.0,
            child: HealthMetricCard(
              metric: metric,
              onTap: () => _navigateToDetail(context, metric),
            ),
          );
        },
        childCount: metrics.length,
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

  void _navigateToCriticalMetrics(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CriticalMetricsScreen(),
      ),
    );
  }
}

