import 'package:flutter/material.dart';

import 'checkin_screen.dart';
import 'finish_class_screen.dart';
import 'records_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2E6BFF), Color(0xFF7B1CFF)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 6),
                Row(
                  children: const [
                    Icon(Icons.school_outlined, color: Colors.white, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Smart Class',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Text(
                  'Welcome!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Check in to class or finish your session',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
                _ActionCard(
                  title: 'Check-in',
                  subtitle: 'Start your class session',
                  icon: Icons.login_rounded,
                  accentColor: const Color(0xFF2E6BFF),
                  onTap: () {
                    Navigator.pushNamed(context, CheckInScreen.routeName);
                  },
                ),
                const SizedBox(height: 18),
                _ActionCard(
                  title: 'Finish Class',
                  subtitle: 'End your class session',
                  icon: Icons.logout_rounded,
                  accentColor: const Color(0xFF9B3DFF),
                  onTap: () {
                    Navigator.pushNamed(context, FinishClassScreen.routeName);
                  },
                ),
                const SizedBox(height: 18),
                _ActionCard(
                  title: 'View Records',
                  subtitle: 'See daily check-in/check-out logs',
                  icon: Icons.list_alt_rounded,
                  accentColor: const Color(0xFF1E9C89),
                  onTap: () {
                    Navigator.pushNamed(context, RecordsScreen.routeName);
                  },
                ),
                const Spacer(),
                const Text(
                  '© 2026 Smart Class App',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: accentColor, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 28,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: accentColor.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
