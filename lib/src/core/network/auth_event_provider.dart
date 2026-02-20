import 'package:flutter_riverpod/legacy.dart';

/// A simple provider to signal that a 401 Unauthorized response was received.
/// Incrementing this value triggers a signal that can be listened to by AuthProvider.
final unauthorizedEventProvider = StateProvider<int>((ref) => 0);
