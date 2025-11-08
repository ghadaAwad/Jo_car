import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/validators.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../widgets/logo_widget.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  String _selectedType = 'User';
  String _selectedStatus = 'Active';

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _address.dispose();
    _city.dispose();
    _username.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const LogoWidget(),
                Transform.translate(
                  offset: const Offset(0, -100),
                  child: Column(
                    children: [
                      Text(
                        'Create Account',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Please fill your information below',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // ======== FIRST NAME + LAST NAME ========
                      Row(
                        children: [
                          Expanded(
                            child: _buildInput(
                              _firstName,
                              'First Name',
                              (v) => Validators.required(v, 'First Name'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildInput(
                              _lastName,
                              'Last Name',
                              (v) => Validators.required(v, 'Last Name'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // ======== OTHER FIELDS ========
                      _buildInput(
                        _email,
                        'Email',
                        Validators.email,
                        TextInputType.emailAddress,
                      ),
                      _buildInput(
                        _phone,
                        'Phone',
                        (v) => Validators.required(v, 'Phone'),
                        TextInputType.phone,
                      ),
                      _buildInput(
                        _address,
                        'Address',
                        (v) => Validators.required(v, 'Address'),
                      ),
                      _buildInput(
                        _city,
                        'City',
                        (v) => Validators.required(v, 'City'),
                      ),
                      _buildInput(
                        _username,
                        'Username',
                        (v) => Validators.required(v, 'Username'),
                      ),
                      _buildInput(
                        _password,
                        'Password',
                        Validators.password,
                        TextInputType.text,
                        true,
                      ),
                      _buildInput(
                        _confirmPassword,
                        'Confirm Password',
                        (v) => Validators.confirmPassword(v, _password.text),
                        TextInputType.text,
                        true,
                      ),
                      const SizedBox(height: 15),

                      // ======== USER TYPE BUTTONS ========
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildTypeButton('User'),
                          _buildTypeButton('Provider'),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // ======== STATUS DROPDOWN ========
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFFFDD853),
                              width: 2.0,
                            ),
                          ),
                        ),
                        items: ['Active', 'Inactive']
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _selectedStatus = val!),
                      ),
                      const SizedBox(height: 30),

                      // ======== REGISTER BUTTON ========
                      SizedBox(
                        height: 50,
                        width: 300,
                        child: ElevatedButton(
                          onPressed: auth.loading
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    await auth.registerFull({
                                      'firstName': _firstName.text.trim(),
                                      'lastName': _lastName.text.trim(),
                                      'email': _email.text.trim(),
                                      'phone': _phone.text.trim(),
                                      'address': _address.text.trim(),
                                      'city': _city.text.trim(),
                                      'username': _username.text.trim(),
                                      'password': _password.text.trim(),
                                      'type': _selectedType,
                                      'status': _selectedStatus,
                                    });

                                    if (auth.isAuthenticated &&
                                        context.mounted) {
                                      context.go('/home');
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Registration failed. Please try again.',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFDD853),
                            foregroundColor: Colors.black,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: auth.loading
                              ? const CircularProgressIndicator()
                              : const Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // ======== ALREADY HAVE ACCOUNT ========
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account?',
                            style: TextStyle(color: Colors.grey),
                          ),
                          TextButton(
                            onPressed: () => context.push('/login'),
                            child: const Text(
                              'Log In',
                              style: TextStyle(
                                color: Color(0xFFFDD853),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ======== INPUT BUILDER ========
  Widget _buildInput(
    TextEditingController controller,
    String label,
    String? Function(String?) validator, [
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
  ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        validator: validator,
        obscureText: obscure,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFFDD853), width: 2.0),
          ),
        ),
      ),
    );
  }

  // ======== TYPE BUTTON BUILDER ========
  Widget _buildTypeButton(String type) {
    final bool isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFDD853) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFFDD853) : Colors.grey,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            type,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
