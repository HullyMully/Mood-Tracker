import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mood_provider.dart';
import '../models/mood.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            floating: true,
            title: Text('How are you feeling?'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 24),
                  _buildMoodButtons(context),
                  const SizedBox(height: 32),
                  Text(
                    'Recent Moods',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),
          _buildRecentMoods(context),
        ],
      ),
    );
  }

  Widget _buildMoodButtons(BuildContext context) {
    final moods = [
      {'emoji': '😊', 'label': 'Great', 'color': Colors.green},
      {'emoji': '🙂', 'label': 'Good', 'color': Colors.lightGreen},
      {'emoji': '😐', 'label': 'Okay', 'color': Colors.yellow},
      {'emoji': '😕', 'label': 'Sad', 'color': Colors.orange},
      {'emoji': '😢', 'label': 'Bad', 'color': Colors.red},
    ];

    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: moods.map((mood) => _buildMoodButton(
          context,
          mood['emoji'] as String,
          mood['label'] as String,
          mood['color'] as Color,
        )).toList(),
      ),
    );
  }

  Widget _buildMoodButton(
    BuildContext context,
    String emoji,
    String label,
    Color color,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final mood = Mood(
            date: DateTime.now(),
            emoji: emoji,
            label: label,
            color: color,
          );
          Provider.of<MoodProvider>(context, listen: false).addMood(mood);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Mood "$label" saved'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 40),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentMoods(BuildContext context) {
    return Consumer<MoodProvider>(
      builder: (context, provider, child) {
        if (provider.moods.isEmpty) {
          return const SliverFillRemaining(
            child: Center(
              child: Text('No moods recorded yet'),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final mood = provider.moods[index];
              return Dismissible(
                key: Key(mood.date.toString()),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (direction) {
                  provider.removeMood(index);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mood deleted'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Card(
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
                      _formatDate(mood.date),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withOpacity(0.6),
                          ),
                    ),
                  ),
                ),
              );
            },
            childCount: provider.moods.length,
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
} 