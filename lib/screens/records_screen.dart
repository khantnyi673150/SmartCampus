import 'package:flutter/material.dart';

import '../data/local_db.dart';

class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  static const routeName = '/records';

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  bool _showCheckinHistory = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Records'),
        backgroundColor: const Color(0xFF2E6BFF),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2E6BFF), Color(0xFF7B1CFF)],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: _HistoryToggleCard(
                      title: 'Check-in History',
                      icon: Icons.login_rounded,
                      accentColor: const Color(0xFF2E6BFF),
                      selected: _showCheckinHistory,
                      onTap: () {
                        setState(() => _showCheckinHistory = true);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _HistoryToggleCard(
                      title: 'Check-out History',
                      icon: Icons.logout_rounded,
                      accentColor: const Color(0xFF9B3DFF),
                      selected: !_showCheckinHistory,
                      onTap: () {
                        setState(() => _showCheckinHistory = false);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search by ID, name, date, or time',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Expanded(
              child: _HistoryList(
                futureRecords: _showCheckinHistory
                    ? LocalDb.instance.getCheckinHistory()
                    : LocalDb.instance.getCheckoutHistory(),
                query: _searchController.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryToggleCard extends StatelessWidget {
  const _HistoryToggleCard({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color accentColor;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor = selected ? Colors.white : Colors.white.withValues(alpha: 0.88);
    final borderColor = selected ? accentColor : Colors.transparent;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: accentColor, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.futureRecords, required this.query});

  final Future<List<Map<String, dynamic>>> futureRecords;
  final String query;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: futureRecords,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var records = snapshot.data ?? <Map<String, dynamic>>[];
        if (query.trim().isNotEmpty) {
          final normalized = query.trim().toLowerCase();
          records = records.where((record) {
            final timestamp = record['timestamp']?.toString() ?? '';
            final date = DateTime.tryParse(timestamp);
            final dateText = date == null ? '' : _formatDate(date);
            final timeText = date == null ? '' : _formatTime(date);
            final id = (record['studentId']?.toString() ?? '').toLowerCase();
            final name = (record['studentName']?.toString() ?? '').toLowerCase();

            return id.contains(normalized) ||
                name.contains(normalized) ||
                dateText.toLowerCase().contains(normalized) ||
                timeText.toLowerCase().contains(normalized);
          }).toList();
        }

        if (records.isEmpty) {
          return const Center(child: Text('No matching records found.'));
        }

        final grouped = <String, List<Map<String, dynamic>>>{};
        for (final record in records) {
          final timestamp = record['timestamp']?.toString() ?? '';
          final date = DateTime.tryParse(timestamp);
          final dateKey = date == null ? 'Unknown Date' : _formatDate(date);
          grouped.putIfAbsent(dateKey, () => <Map<String, dynamic>>[]).add(record);
        }

        final dateKeys = grouped.keys.toList()
          ..sort((a, b) {
            if (a == 'Unknown Date') return 1;
            if (b == 'Unknown Date') return -1;
            return b.compareTo(a);
          });

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: dateKeys.length,
          itemBuilder: (context, index) {
            final dateKey = dateKeys[index];
            final dayRecords = grouped[dateKey]!;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateKey,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...dayRecords.map((record) {
                      final date = DateTime.tryParse(
                        record['timestamp']?.toString() ?? '',
                      );
                      final time = date == null ? '--:--:--' : _formatTime(date);

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          '${record['type']} • ID: ${record['studentId']}',
                        ),
                        subtitle: Text(
                          'Student: ${record['studentName']}\nTime: $time',
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final second = date.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }
}
