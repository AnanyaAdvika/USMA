import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/tokens.dart';
import '../data/auth_repository.dart';

class EkycScreen extends ConsumerStatefulWidget {
  const EkycScreen({super.key});

  @override
  ConsumerState<EkycScreen> createState() => _EkycScreenState();
}

class _EkycScreenState extends ConsumerState<EkycScreen> {
  final _aadhaarController = TextEditingController();
  final _incomeController = TextEditingController();
  String _selectedTribe = 'Santhal';
  bool _isLoading = false;

  final List<String> _tribes = [
    'Santhal',
    'Gond',
    'Bhil',
    'Munda',
    'Oraon',
    'Bodo',
    'Khasi',
    'Garo',
    'Mizo',
    'Other Recognized ST'
  ];

  @override
  void dispose() {
    _aadhaarController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  Future<void> _submitEkyc() async {
    final aadhaar = _aadhaarController.text.trim();
    if (aadhaar.length < 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a 12-digit Aadhaar number')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final income = double.tryParse(_incomeController.text.trim()) ?? 150000.0;
      final repo = ref.read(authRepositoryProvider);
      await repo.completeEkyc(
        aadhaarNumber: aadhaar,
        tribe: _selectedTribe,
        income: income,
      );
      if (mounted) {
        context.go(AppRoutes.dashboard);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beneficiary e-KYC'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.infoBg,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Aadhaar e-KYC ensures seamless DBT scholarship fund transfer directly through the PFMS gateway.',
                        style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text('12-Digit Aadhaar Number', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _aadhaarController,
                keyboardType: TextInputType.number,
                maxLength: 12,
                decoration: const InputDecoration(
                  hintText: 'XXXX XXXX 4829',
                  prefixIcon: Icon(Icons.fingerprint_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text('Recognized Scheduled Tribe', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.xs),
              DropdownButtonFormField<String>(
                value: _selectedTribe,
                items: _tribes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedTribe = val);
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text('Annual Family Income (₹)', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.xs),
              TextField(
                controller: _incomeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'e.g. 180000',
                  prefixText: '₹ ',
                  prefixIcon: Icon(Icons.currency_rupee_rounded),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitEkyc,
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Complete Verification'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
