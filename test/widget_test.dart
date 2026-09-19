import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usma/app.dart';
import 'package:usma/core/network/connectivity_provider.dart';
import 'package:usma/features/auth/data/auth_repository.dart';
import 'package:usma/features/auth/domain/models/user_model.dart';

void main() {
  testWidgets('USMA App smoke test', (WidgetTester tester) async {
    const mockUser = UserModel(
      id: 'test_id',
      name: 'Sunita Marandi',
      email: 'test@example.org',
      phoneNumber: '+91 98765 43210',
      aadhaarLast4: '4829',
      tribe: 'Santhal',
      state: 'Odisha',
      district: 'Mayurbhanj',
      familyAnnualIncome: 180000.0,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          connectivityStreamProvider.overrideWith((ref) => Stream.value([ConnectivityResult.wifi])),
          isOnlineProvider.overrideWithValue(true),
          currentUserStreamProvider.overrideWith((ref) => Stream.value(mockUser)),
          currentUserProvider.overrideWithValue(mockUser),
        ],
        child: const UsmaApp(),
      ),
    );

    expect(find.text('USMA'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump();
  });
}
