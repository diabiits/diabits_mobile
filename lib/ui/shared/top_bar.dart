import 'package:diabits_mobile/domain/auth/auth_state_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A custom app bar widget for the application.
///
/// This widget displays the app's wordmark in the center and
/// provides a logout button on the right.
class TopBar extends StatelessWidget implements PreferredSizeWidget {
  const TopBar({super.key});

  /// Builds the UI for the top bar.
  ///
  /// It includes the app's wordmark and a logout button that shows a
  /// confirmation dialog before logging out the user.
  @override
  Widget build(BuildContext context) {
    final authManager = context.read<AuthStateManager>();

    return AppBar(
      title: Image.asset("assets/wordmark_red.png", height: 40),
      backgroundColor: Theme.of(context).colorScheme.secondary,
      scrolledUnderElevation: 0,
      centerTitle: true,
      actions: [
        /// Logout button
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Log out',
          onPressed: () async {
            final shouldLogout = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Log out?'),
                content: const Text('Are you sure you want to log out?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Log out'),
                  ),
                ],
              ),
            );

            if (shouldLogout == true) {
              await authManager.logout();
            }
          },
        ),
      ],
    );
  }

  /// The preferred size of the app bar.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
