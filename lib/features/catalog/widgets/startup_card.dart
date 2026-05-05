import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/startup_model.dart';

const Color _orange = Color(0xFFFF5F14);

class StartupCard extends StatelessWidget {
  final StartupModel startup;
  final VoidCallback onTap;

  const StartupCard({
    super.key,
    required this.startup,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String firstLetter =
    startup.name.isNotEmpty ? startup.name[0].toUpperCase() : '?';

    final List<String> categories = startup.categories.isNotEmpty
        ? startup.categories
        : startup.sector.isNotEmpty
        ? [startup.sector]
        : [];

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF071E2D),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Wrap(
                  spacing: 14,
                  runSpacing: 8,
                  children: categories.map((category) {
                    return _SectorLabel(text: category);
                  }).toList(),
                ),
              ),
              const SizedBox(width: 12),
              _StageLabel(text: startup.stage),
            ],
          ),

          const SizedBox(height: 34),

          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFF6A00),
                      Color(0xFFE85D00),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                alignment: Alignment.center,
                child: Text(
                  firstLetter,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 22),
              Expanded(
                child: Text(
                  startup.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          Text(
            startup.description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 19,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 30),

          Row(
            children: [
              Expanded(
                child: _InfoBox(
                  title: 'Capital',
                  value: startup.capital,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _InfoBox(
                  title: 'Tokens',
                  value: startup.tokens,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 64,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: _orange,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: const Text(
                'Ver mais',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectorLabel extends StatelessWidget {
  final String text;

  const _SectorLabel({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.sell_rounded,
          size: 17,
          color: _orange,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: _orange,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _StageLabel extends StatelessWidget {
  final String text;

  const _StageLabel({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: const BoxConstraints(
        minWidth: 92,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String title;
  final String value;

  const _InfoBox({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 112,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            value.trim().isEmpty ? '-' : value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}