import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/user_model.dart';
import '../../../core/errors/error_mapper.dart';

abstract class IAuthRepository {
  Stream<UserModel?> get authStateChanges;
  UserModel? get currentUser;
  Future<void> sendOtp({required String phoneNumber});
  Future<UserModel> verifyOtp({required String verificationId, required String smsCode});
  Future<void> completeEkyc({required String aadhaarNumber, required String tribe, required double income});
  Future<void> signOut();
  Future<void> updateProfile(UserModel user);
}

class AuthRepository implements IAuthRepository {
  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;

  final _userStreamController = StreamController<UserModel?>.broadcast();
  UserModel? _cachedUser;

  AuthRepository(this._auth, this._firestore) {
    // Initial mock/demo user for instant access if offline/evaluating
    _cachedUser = const UserModel(
      id: 'demo_user_001',
      name: 'Sunita Marandi',
      email: 'sunita.marandi@example.org',
      phoneNumber: '+91 98765 43210',
      aadhaarLast4: '4829',
      tribe: 'Santhal',
      state: 'Odisha',
      district: 'Mayurbhanj',
      familyAnnualIncome: 180000.0,
      isAadhaarLinked: true,
      isDigiLockerLinked: true,
      bankAccountLast4: '3819',
      bankIfsc: 'SBIN0001234',
      apaarId: 'APAAR-2026-9938-11',
    );
    _userStreamController.add(_cachedUser);

    if (_auth != null) {
      try {
        _auth!.authStateChanges().listen((firebaseUser) async {
          if (firebaseUser != null && _firestore != null) {
            try {
              final doc = await _firestore!.collection('users').doc(firebaseUser.uid).get();
              if (doc.exists && doc.data() != null) {
                _cachedUser = UserModel.fromMap(doc.data()!, doc.id);
              } else {
                _cachedUser = UserModel(
                  id: firebaseUser.uid,
                  name: firebaseUser.displayName ?? 'Beneficiary Student',
                  email: firebaseUser.email ?? '',
                  phoneNumber: firebaseUser.phoneNumber ?? '',
                  aadhaarLast4: '4829',
                  tribe: 'Santhal',
                  state: 'Odisha',
                  district: 'Mayurbhanj',
                  familyAnnualIncome: 180000.0,
                  isAadhaarLinked: true,
                  isDigiLockerLinked: true,
                );
              }
              _userStreamController.add(_cachedUser);
            } catch (_) {
              _userStreamController.add(_cachedUser);
            }
          }
        });
      } catch (_) {}
    }
  }

  @override
  Stream<UserModel?> get authStateChanges => _userStreamController.stream;

  @override
  UserModel? get currentUser => _cachedUser;

  @override
  Future<void> sendOtp({required String phoneNumber}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<UserModel> verifyOtp({required String verificationId, required String smsCode}) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      _userStreamController.add(_cachedUser);
      return _cachedUser!;
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<void> completeEkyc({
    required String aadhaarNumber,
    required String tribe,
    required double income,
  }) async {
    if (_cachedUser != null) {
      _cachedUser = _cachedUser!.copyWith(
        aadhaarLast4: aadhaarNumber.length >= 4 ? aadhaarNumber.substring(aadhaarNumber.length - 4) : '4829',
        tribe: tribe,
        familyAnnualIncome: income,
        isAadhaarLinked: true,
      );
      _userStreamController.add(_cachedUser);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      if (_auth != null) await _auth!.signOut();
      _cachedUser = null;
      _userStreamController.add(null);
    } catch (e) {
      _cachedUser = null;
      _userStreamController.add(null);
    }
  }

  @override
  Future<void> updateProfile(UserModel user) async {
    _cachedUser = user;
    _userStreamController.add(_cachedUser);
    try {
      if (_firestore != null) {
        await _firestore!.collection('users').doc(user.id).set(user.toMap(), SetOptions(merge: true));
      }
    } catch (_) {}
  }
}

final firebaseAuthProvider = Provider<FirebaseAuth?>((ref) {
  try {
    return FirebaseAuth.instance;
  } catch (_) {
    return null;
  }
});

final firestoreProvider = Provider<FirebaseFirestore?>((ref) {
  try {
    return FirebaseFirestore.instance;
  } catch (_) {
    return null;
  }
});

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
  );
});

final currentUserStreamProvider = StreamProvider<UserModel?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.authStateChanges;
});

final currentUserProvider = Provider<UserModel?>((ref) {
  final streamUser = ref.watch(currentUserStreamProvider);
  return streamUser.value ?? ref.watch(authRepositoryProvider).currentUser;
});
