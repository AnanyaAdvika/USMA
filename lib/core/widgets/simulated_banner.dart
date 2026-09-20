import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../theme/tokens.dart';

/// Visible whenever Mock adapters are selected (`DATA_MODE=demo`).
class SimulatedBanner extends StatelessWidget {
  const SimulatedBanner({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.isDemo) return const SizedBox.shrink();

    return Semantics(
      label: 'Simulated data mode banner',
      child: Material(
        color: AppColors.warningBg,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              const Icon(Icons.science_outlined, color: AppColors.warning, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message ??
                      '${AppConfig.simulatedLabel}: demo data. Government systems are not called.',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
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

class SimulatedChip extends StatelessWidget {
  const SimulatedChip({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.isDemo) return const SizedBox.shrink();
    return Semantics(
      label: AppConfig.simulatedLabel,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.warningBg,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: const Text(
          AppConfig.simulatedLabel,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
            color: AppColors.warning,
          ),
        ),
      ),
    );
  }
}
