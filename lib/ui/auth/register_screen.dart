import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/auth/field_validators.dart';
import '../shared/primary_button.dart';
import 'register_view_model.dart';

/// This widget provides a form for new users to create an account.
/// It includes fields for username, password, email, and an invite code.
/// It communicates with [RegisterViewModel] to handle the registration logic.
///
/// For a user to be able to register they need to have a valid invite code
/// with the corresponding email.
/// Invites can only be created by admins and are stored in the backend.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

/// This class manages the form state, text editing controllers, and user
/// interactions like submitting the form.
class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  final _inviteCodeController = TextEditingController();

  /// Builds the UI for the registration screen.
  ///
  /// It includes a form with fields for username, password, email, and invite
  /// code, along with a register button and a link to go back to the login screen.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RegisterViewModel>(
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
                  crossAxisAlignment: .stretch,
                  children: [
                    Hero(
                      tag: 'logo',
                      child: Image.asset(
                        'assets/wordmark_red.png',
                        height: 70,
                      ),
                    ),
                    const SizedBox(height: 8),

                    /// Title
                    Text(
                      'Create Account',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: .center,
                    ),
                    const SizedBox(height: 32),

                    /// Username
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                      ),
                      validator: FieldValidators.requiredValidator,
                      autofillHints: const [AutofillHints.username],
                      textInputAction: .next,
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
                      validator: FieldValidators.passwordValidator,
                      autofillHints: const [AutofillHints.newPassword],
                      textInputAction: .next,
                      onChanged: (_) => vm.clearSnack(),
                    ),
                    const SizedBox(height: 16),

                    /// Email
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                      ),
                      validator: FieldValidators.requiredValidator,
                      autofillHints: const [AutofillHints.email],
                      keyboardType: .emailAddress,
                      textInputAction: .next,
                      onChanged: (_) => vm.clearSnack(),
                    ),
                    const SizedBox(height: 16),

                    /// Invite Code
                    TextFormField(
                      controller: _inviteCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Invite Code',
                      ),
                      validator: FieldValidators.requiredValidator,
                      textInputAction: .done,
                      onFieldSubmitted: (_) => _submit(vm),
                      onChanged: (_) => vm.clearSnack(),
                    ),
                    const SizedBox(height: 24),

                    /// Register button
                    PrimaryButton(
                      onPressed: vm.isLoading ? null : () => _submit(vm),
                      isLoading: vm.isLoading,
                      text: 'Register',
                    ),

                    const SizedBox(height: 12),

                    /// Back to Login button
                    TextButton(
                      onPressed: vm.isLoading
                          ? null
                          : () => Navigator.pop(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back, size: 18),
                          SizedBox(width: 8),
                          const Text('Back to Login'),
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

  /// Handles the form submission.
  /// If the form is valid, it calls the view model to register the user.
  void _submit(RegisterViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;

    await vm.submit(
      username: _usernameController.text,
      password: _passwordController.text,
      email: _emailController.text,
      inviteCode: _inviteCodeController.text,
    );
  }

  /// Disposes the text editing controllers when the widget is removed from the tree.
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }
}
