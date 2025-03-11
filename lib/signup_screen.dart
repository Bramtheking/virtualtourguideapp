import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A0DAD), Color(0xFFFFD700)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: _signupForm(),
          ),
        ),
      ),
    );
  }

  Widget _signupForm() {
    return Card(
      elevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Create Account',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6A0DAD),
                ),
              ),
              const SizedBox(height: 20),
              _buildTextField(_firstNameController, 'First Name', Icons.person),
              const SizedBox(height: 15),
              _buildTextField(_lastNameController, 'Last Name', Icons.person_outline),
              const SizedBox(height: 15),
              _buildTextField(_ageController, 'Age', Icons.cake, isNumber: true),
              const SizedBox(height: 15),
              _buildTextField(_emailController, 'Email', Icons.email),
              const SizedBox(height: 15),
              _buildTextField(_passwordController, 'Password', Icons.lock, isPassword: true),
              const SizedBox(height: 15),
              _buildTextField(_phoneController, 'Phone Number', Icons.phone, isNumber: true),
              const SizedBox(height: 15),
              _buildTextField(_cityController, 'City', Icons.location_city),
              const SizedBox(height: 15),
              _buildTextField(_countryController, 'Country', Icons.public),
              const SizedBox(height: 25),
              _signupButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false, bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFF6A0DAD)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) => value!.isEmpty ? 'Please enter $label' : null,
    );
  }

  Widget _signupButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6A0DAD),
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: _handleSignup,
      child: Text(
        'Sign Up',
        style: GoogleFonts.roboto(
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    );
  }

  void _handleSignup() {
    if (_formKey.currentState!.validate()) {
      final usersBox = Hive.box('users');
      
      if (usersBox.containsKey(_emailController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email already registered')),
        );
      } else {
        usersBox.put(_emailController.text, {
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'age': _ageController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'phone': _phoneController.text,
          'city': _cityController.text,
          'country': _countryController.text,
        });

        Hive.box('auth')
          ..put('isLoggedIn', true)
          ..put('currentUserEmail', _emailController.text);

        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }
}
