import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isEditing = false;
  bool isDarkTheme = false;

  // Controllers for editable fields
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController ageController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController cityController;
  late TextEditingController countryController;

  final Color primaryPurple = const Color(0xFF6A1B9A);
  final Color accentGold = const Color(0xFFFFD700);
  final Color lightPurple = const Color(0xFFE1BEE7);

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadThemePreference();
  }
  
  Future<void> _loadUserData() async {
    final authBox = Hive.box('auth');
    final currentUserEmail = authBox.get('currentUserEmail');
    if (currentUserEmail != null) {
      final usersBox = Hive.box('users');
      setState(() {
        userData = Map<String, dynamic>.from(usersBox.get(currentUserEmail));
        firstNameController = TextEditingController(text: userData!['firstName']);
        lastNameController = TextEditingController(text: userData!['lastName']);
        ageController = TextEditingController(text: userData!['age'].toString());
        emailController = TextEditingController(text: userData!['email']);
        phoneController = TextEditingController(text: userData!['phone']);
        cityController = TextEditingController(text: userData!['city']);
        countryController = TextEditingController(text: userData!['country']);
      });
    }
  }
  
  Future<void> _loadThemePreference() async {
    final settingsBox = Hive.box('settings');
    setState(() {
      isDarkTheme = settingsBox.get('isDarkTheme', defaultValue: false);
    });
  }
  
  Future<void> _toggleTheme(bool value) async {
    final settingsBox = Hive.box('settings');
    setState(() {
      isDarkTheme = value;
    });
    await settingsBox.put('isDarkTheme', value);
    // Optionally, notify the app's theme provider to rebuild the UI.
  }
  
  void _toggleEditing() {
    setState(() {
      isEditing = !isEditing;
    });
  }
  
  Future<void> _saveProfile() async {
    if (userData == null) return;
    final usersBox = Hive.box('users');
    final authBox = Hive.box('auth');
    final currentUserEmail = authBox.get('currentUserEmail');
    final updatedData = {
      'firstName': firstNameController.text,
      'lastName': lastNameController.text,
      'age': ageController.text,
      'email': emailController.text,
      'phone': phoneController.text,
      'city': cityController.text,
      'country': countryController.text,
    };
    await usersBox.put(currentUserEmail, updatedData);
    setState(() {
      userData = updatedData;
      isEditing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully!')),
    );
  }
  
  void _logout() {
    final authBox = Hive.box('auth');
    authBox.put('isLoggedIn', false);
    authBox.delete('currentUserEmail');
    Navigator.pushReplacementNamed(context, '/login');
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'My Profile',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: primaryPurple,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.check : Icons.edit, color: Colors.white),
            onPressed: () {
              if (isEditing) {
                _saveProfile();
              } else {
                _toggleEditing();
              }
            },
          ),
        ],
      ),
      body: userData == null
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryPurple),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile header with avatar and name
                  Container(
                    decoration: BoxDecoration(
                      color: primaryPurple,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: accentGold, width: 4),
                            shape: BoxShape.circle,
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: lightPurple,
                            child: Text(
                              "${userData!['firstName'][0]}${userData!['lastName'][0]}",
                              style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: primaryPurple),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        isEditing
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: TextField(
                                      controller: firstNameController,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: TextField(
                                      controller: lastNameController,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                "${userData!['firstName']} ${userData!['lastName']}",
                                style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                        const SizedBox(height: 4),
                        isEditing
                            ? TextField(
                                controller: cityController,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(fontSize: 16, color: Colors.white.withOpacity(0.9)),
                              )
                            : Text(
                                "${userData!['city']}, ${userData!['country']}",
                                style: GoogleFonts.poppins(fontSize: 16, color: Colors.white.withOpacity(0.9)),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Personal details with editable fields
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Personal Details", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: primaryPurple)),
                        const SizedBox(height: 16),
                        _buildDetailCard(Icons.email, "Email", emailController.text, isEditable: isEditing, controller: emailController),
                        _buildDetailCard(Icons.phone, "Phone", phoneController.text, isEditable: isEditing, controller: phoneController),
                        _buildDetailCard(Icons.cake, "Age", ageController.text, isEditable: isEditing, controller: ageController),
                        _buildDetailCard(Icons.location_city, "City", cityController.text, isEditable: isEditing, controller: cityController),
                        _buildDetailCard(Icons.flag, "Country", countryController.text, isEditable: isEditing, controller: countryController),
                        const SizedBox(height: 30),
                        // Theme toggle
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Dark Theme", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: primaryPurple)),
                            Switch(
                              value: isDarkTheme,
                              activeColor: accentGold,
                              onChanged: (value) => _toggleTheme(value),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        // Logout button
                        Center(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: _logout,
                            icon: const Icon(Icons.logout, color: Colors.white),
                            label: Text("Logout", style: GoogleFonts.roboto(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
  
  Widget _buildDetailCard(IconData icon, String label, String value, {bool isEditable = false, TextEditingController? controller}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: lightPurple.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: primaryPurple,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: isEditable && controller != null
                  ? TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        labelText: label,
                        border: InputBorder.none,
                      ),
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600])),
                        const SizedBox(height: 2),
                        Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
                      ],
                    ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}
