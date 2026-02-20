import 'package:flutter_riverpod/legacy.dart';

/// A simple provider to manage the global tab index.
/// This allows us to jump to specific tabs (like the Profile tab)
/// from anywhere in the app.

final navigationProvider = StateProvider<int>((ref) => 0);
