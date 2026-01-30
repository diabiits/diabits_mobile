import 'package:diabits_mobile/ui/auth/register_screen.dart';
import 'package:diabits_mobile/ui/shared/animated_button.dart';
import 'package:diabits_mobile/ui/shared/error_snack_listener.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/auth/field_validators.dart';
import 'login_view_model.dart';

/// This widget provides a form with username and password fields, along
/// with a login button and a link to the registration screen.
/// It communicates with a [LoginViewModel] to handle the authentication logic.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/// This class manages the form state, text editing controllers, and user
/// interactions like submitting the form.
class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _usernameController = TextEditingController();
  late final _passwordController = TextEditingController();

  /// Builds the UI for the login screen.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<LoginViewModel>(
        builder: (context, vm, _) {
          if (vm.snackMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(vm.snackMessage!)));
              vm.clearSnack();
            });
          }
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  autovalidateMode: .onUnfocus,
                  child: Column(
                    mainAxisSize: .min,
                    children: [
                      /// Decorative wordmark
                      Hero(
                        tag: 'logo',
                        child: Image.asset(
                          'assets/wordmark_red.png',
                          height: 70,
                        ),
                      ),
                      const SizedBox(height: 8),

                      Text(
                        'Connecting the Dots',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 32),

                      /// Username
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                        validator: FieldValidators.requiredValidator,
                        autofillHints: const [AutofillHints.username],
                        textInputAction: .next,
                        onChanged: (_) => vm.clearSnack(), //TODO Necessary?
                      ),
                      const SizedBox(height: 16),

                      /// Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: vm.passwordHidden,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(
                              vm.passwordHidden
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: vm.togglePasswordVisibility,
                          ),
                        ),
                        validator: FieldValidators.requiredValidator,
                        autofillHints: const [AutofillHints.password],
                        textInputAction: .done,
                        onFieldSubmitted: (_) => _submit(vm),
                        onChanged: (_) => vm.clearSnack(),  //TODO Necessary?
                      ),
                      const SizedBox(height: 24),

                      /// Login Button
                      AnimatedButton(
                        onPressed: vm.isLoading ? null : () => _submit(vm),
                        isLoading: vm.isLoading,
                        text: 'Login',
                      ),

                      const SizedBox(height: 12),

                      /// Register Button
                      TextButton(
                        onPressed: vm.isLoading
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const RegisterScreen(),
                                  ),
                                );
                              },
                        child: const Text("Create new account"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Handles the form submission.
  /// If the form is valid, it calls the view model to log in the user.
  Future<void> _submit(LoginViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;

    await vm.submit(
      username: _usernameController.text,
      password: _passwordController.text,
    );
  }

  /// Disposes the text editing controllers when the widget is removed from the tree.
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
