import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';
import '../models/mood.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String _selectedPeriod = 'Week';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            floating: true,
            title: Text('Mood Statistics'),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildPeriodSelector(),
                _buildMoodChart(),
                const Divider(height: 32),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Mood Distribution',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
          ),
          _buildMoodDistribution(),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment<String>(
            value: 'Week',
            label: Text('Week'),
          ),
          ButtonSegment<String>(
            value: 'Month',
            label: Text('Month'),
          ),
          ButtonSegment<String>(
            value: 'Year',
            label: Text('Year'),
          ),
        ],
        selected: {_selectedPeriod},
        onSelectionChanged: (Set<String> newSelection) {
          setState(() {
            _selectedPeriod = newSelection.first;
          });
        },
      ),
    );
  }

  Widget _buildMoodChart() {
    return SizedBox(
      height: 200,
      child: Consumer<MoodProvider>(
        builder: (context, provider, child) {
          final moods = _getMoodsForPeriod(provider);
          if (moods.isEmpty) {
            return const Center(
              child: Text('No data for selected period'),
            );
          }

          final moodStats = _calculateMoodDistribution(moods);
          final sortedStats = moodStats.entries.toList()
            ..sort((a, b) => b.value.percentage.compareTo(a.value.percentage));

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: sortedStats.map((entry) {
                final maxHeight = 140.0;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(fontSize: 24),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: maxHeight * entry.value.percentage,
                      width: 40,
                      decoration: BoxDecoration(
                        color: moods.firstWhere((m) => m.emoji == entry.key).color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMoodDistribution() {
    return Consumer<MoodProvider>(
      builder: (context, provider, child) {
        final moods = _getMoodsForPeriod(provider);
        if (moods.isEmpty) {
          return const SliverFillRemaining(
            child: Center(
              child: Text('No data for selected period'),
            ),
          );
        }

        final distribution = _calculateMoodDistribution(moods);
        final sortedDistribution = distribution.entries.toList()
          ..sort((a, b) => b.value.percentage.compareTo(a.value.percentage));

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final entry = sortedDistribution[index];
              return ListTile(
                leading: Text(
                  entry.key,
                  style: const TextStyle(fontSize: 24),
                ),
                title: Text(entry.value.label),
                trailing: Text('${(entry.value.percentage * 100).toInt()}%'),
              );
            },
            childCount: distribution.length,
          ),
        );
      },
    );
  }

  List<Mood> _getMoodsForPeriod(MoodProvider provider) {
    final now = DateTime.now();
    late DateTime startDate;

    switch (_selectedPeriod) {
      case 'Week':
        startDate = now.subtract(const Duration(days: 7));
      case 'Month':
        startDate = DateTime(now.year, now.month - 1, now.day);
      case 'Year':
        startDate = DateTime(now.year - 1, now.month, now.day);
      default:
        startDate = now.subtract(const Duration(days: 7));
    }

    return provider.getMoodsForPeriod(startDate, now);
  }

  Map<String, ({String label, double percentage})> _calculateMoodDistribution(
      List<Mood> moods) {
    final distribution = <String, int>{};
    for (final mood in moods) {
      distribution[mood.emoji] = (distribution[mood.emoji] ?? 0) + 1;
    }

    final result = <String, ({String label, double percentage})>{};
    for (final entry in distribution.entries) {
      result[entry.key] = (
        label: moods.firstWhere((m) => m.emoji == entry.key).label,
        percentage: entry.value / moods.length,
      );
    }

    return result;
  }
} 