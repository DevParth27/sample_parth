import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login.dart';
import 'edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? username;
  String? email;
  String? phone;
  String? address;
  String? bio;
  String? institution;
  String? degree;
  String? fieldOfStudy;
  String? graduationYear;
  String? cgpa;
  String? avatarPath;
  String? resumePath;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
      email = prefs.getString('email');
      phone = prefs.getString('phone');
      address = prefs.getString('address');
      bio = prefs.getString('bio');
      institution = prefs.getString('institution');
      degree = prefs.getString('degree');
      fieldOfStudy = prefs.getString('fieldOfStudy');
      graduationYear = prefs.getString('graduationYear');
      cgpa = prefs.getString('cgpa');
      avatarPath = prefs.getString('avatarPath');
      resumePath = prefs.getString('resumePath');
    });
  }

  Future<void> _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );
    
    if (result == true) {
      _loadUserData();
    }
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  bool _hasEducationInfo() {
    return (institution != null && institution!.isNotEmpty) ||
           (degree != null && degree!.isNotEmpty) ||
           (fieldOfStudy != null && fieldOfStudy!.isNotEmpty) ||
           (graduationYear != null && graduationYear!.isNotEmpty) ||
           (cgpa != null && cgpa!.isNotEmpty);
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: avatarPath != null 
                        ? FileImage(File(avatarPath!))
                        : null,
                    child: avatarPath == null
                        ? const Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.grey,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: _navigateToEditProfile,
                        icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                        constraints: const BoxConstraints(
                          minWidth: 35,
                          minHeight: 35,
                        ),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Personal Information',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    if (username != null && username!.isNotEmpty) 
                      _buildInfoRow(Icons.person, 'Username', username!),
                    if (email != null && email!.isNotEmpty) 
                      _buildInfoRow(Icons.email, 'Email', email!),
                    if (phone != null && phone!.isNotEmpty) 
                      _buildInfoRow(Icons.phone, 'Phone', phone!),
                    if (address != null && address!.isNotEmpty) 
                      _buildInfoRow(Icons.location_on, 'Address', address!),
                    if (bio != null && bio!.isNotEmpty) 
                      _buildInfoRow(Icons.info, 'Bio', bio!),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            if (_hasEducationInfo()) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Educational Information',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      if (institution != null && institution!.isNotEmpty) 
                        _buildInfoRow(Icons.school, 'Institution', institution!),
                      if (degree != null && degree!.isNotEmpty) 
                        _buildInfoRow(Icons.book, 'Degree', degree!),
                      if (fieldOfStudy != null && fieldOfStudy!.isNotEmpty) 
                        _buildInfoRow(Icons.subject, 'Field of Study', fieldOfStudy!),
                      if (graduationYear != null && graduationYear!.isNotEmpty) 
                        _buildInfoRow(Icons.calendar_today, 'Graduation Year', graduationYear!),
                      if (cgpa != null && cgpa!.isNotEmpty) 
                        _buildInfoRow(Icons.grade, 'CGPA/Percentage', cgpa!),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (resumePath != null && resumePath!.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resume',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          const Icon(Icons.description, color: Colors.grey),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              resumePath!.split('/').last,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                            },
                            icon: const Icon(Icons.visibility),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _navigateToEditProfile,
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}