import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';
import '../models/mood.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            floating: true,
            title: Text('Mood History'),
          ),
          _buildMoodHistory(),
        ],
      ),
    );
  }

  Widget _buildMoodHistory() {
    return Consumer<MoodProvider>(
      builder: (context, provider, child) {
        if (provider.moods.isEmpty) {
          return const SliverFillRemaining(
            child: Center(
              child: Text('No mood entries yet'),
            ),
          );
        }

        final groupedMoods = _groupMoodsByDate(provider.moods);
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final date = groupedMoods.keys.elementAt(index);
              final moods = groupedMoods[date]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _formatDate(date),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.color
                                ?.withOpacity(0.6),
                          ),
                    ),
                  ),
                  ...moods.map((mood) => _buildMoodCard(context, mood)).toList(),
                ],
              );
            },
            childCount: groupedMoods.length,
          ),
        );
      },
    );
  }

  Widget _buildMoodCard(BuildContext context, Mood mood) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      child: ListTile(
        leading: Text(
          mood.emoji,
          style: const TextStyle(fontSize: 24),
        ),
        title: Text(mood.label),
        subtitle: Text(
          DateFormat('HH:mm').format(mood.date),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withOpacity(0.6),
              ),
        ),
        trailing: mood.note != null
            ? const Icon(Icons.note_outlined)
            : null,
        onTap: mood.note != null
            ? () => _showNoteDialog(context, mood)
            : null,
      ),
    );
  }

  void _showNoteDialog(BuildContext context, Mood mood) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(mood.label),
        content: Text(mood.note ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Map<DateTime, List<Mood>> _groupMoodsByDate(List<Mood> moods) {
    final groupedMoods = <DateTime, List<Mood>>{};
    for (final mood in moods) {
      final date = DateTime(
        mood.date.year,
        mood.date.month,
        mood.date.day,
      );
      if (!groupedMoods.containsKey(date)) {
        groupedMoods[date] = [];
      }
      groupedMoods[date]!.add(mood);
    }
    return Map.fromEntries(
      groupedMoods.entries.toList()
        ..sort((a, b) => b.key.compareTo(a.key)),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return 'Today';
    } else if (date == yesterday) {
      return 'Yesterday';
    }
    return DateFormat('MMMM d, y').format(date);
  }
} 