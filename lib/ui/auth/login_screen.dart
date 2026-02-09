import 'package:diabits_mobile/ui/auth/register_screen.dart';
import 'package:diabits_mobile/ui/shared/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../shared/field_validators.dart';
import 'login_view_model.dart';

/// Provides a user interface for authenticating existing users.
///
/// This screen displays a login form and coordinates with the [LoginViewModel]
/// to process credentials and handle navigation to registration.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/// Manages the local UI state for the login form, including input controllers and form validation.
class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _usernameController = TextEditingController();
  late final _passwordController = TextEditingController();

  /// Builds the layout for the login form.
  ///
  /// Observes [LoginViewModel] for state changes such as loading status and messages.
  /// Includes a [Hero] animation shared between [LoginScreen] and [RegisterScreen] for branding consistency.
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
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 32),

                      /// Username
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Username'
                        ),
                        validator: FieldValidators.requiredValidator,
                        autofillHints: const [AutofillHints.username],
                        textInputAction: .next,
                        onChanged: (_) => vm.clearSnack(),
                      ),
                      const SizedBox(height: 16),

                      /// Password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: vm.passwordHidden,
                        decoration: InputDecoration(
                          labelText: 'Password',
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
                        onChanged: (_) => vm.clearSnack(),
                      ),
                      const SizedBox(height: 24),

                      /// Login Button
                      PrimaryButton(
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
                        child: Row(
                          mainAxisSize: .min,
                          children: [
                            const Text("Create new account"),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
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

  /// Validates the form and triggers the login process.
  /// Extracts text from local controllers and passes them to the [LoginViewModel].
  Future<void> _submit(LoginViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) return;

    await viewModel.submit(
      username: _usernameController.text,
      password: _passwordController.text,
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
