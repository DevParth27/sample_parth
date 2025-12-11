import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _institutionController = TextEditingController();
  final TextEditingController _degreeController = TextEditingController();
  final TextEditingController _fieldOfStudyController = TextEditingController();
  final TextEditingController _graduationYearController = TextEditingController();
  final TextEditingController _cgpaController = TextEditingController();

  String? _avatarPath;
  String? _resumePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _usernameController.text = prefs.getString('username') ?? '';
      _emailController.text = prefs.getString('email') ?? '';
      _phoneController.text = prefs.getString('phone') ?? '';
      _addressController.text = prefs.getString('address') ?? '';
      _bioController.text = prefs.getString('bio') ?? '';
      _institutionController.text = prefs.getString('institution') ?? '';
      _degreeController.text = prefs.getString('degree') ?? '';
      _fieldOfStudyController.text = prefs.getString('fieldOfStudy') ?? '';
      _graduationYearController.text = prefs.getString('graduationYear') ?? '';
      _cgpaController.text = prefs.getString('cgpa') ?? '';
      _avatarPath = prefs.getString('avatarPath');
      _resumePath = prefs.getString('resumePath');
    });
  }

  Future<void> _pickAvatar() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 85,
      );

      if (image != null) {
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String newPath = '${appDir.path}/$fileName';
        
        await File(image.path).copy(newPath);
        
        setState(() {
          _avatarPath = newPath;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _pickResume() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
 
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName = 'resume_${DateTime.now().millisecondsSinceEpoch}.${result.files.single.extension}';
        final String newPath = '${appDir.path}/$fileName';
        
        await File(result.files.single.path!).copy(newPath);
        
        setState(() {
          _resumePath = newPath;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', _usernameController.text);
      await prefs.setString('email', _emailController.text);
      await prefs.setString('phone', _phoneController.text);
      await prefs.setString('address', _addressController.text);
      await prefs.setString('bio', _bioController.text);
      await prefs.setString('institution', _institutionController.text);
      await prefs.setString('degree', _degreeController.text);
      await prefs.setString('fieldOfStudy', _fieldOfStudyController.text);
      await prefs.setString('graduationYear', _graduationYearController.text);
      await prefs.setString('cgpa', _cgpaController.text);
    
      if (_avatarPath != null) {
        await prefs.setString('avatarPath', _avatarPath!);
      }
      if (_resumePath != null) {
        await prefs.setString('resumePath', _resumePath!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickAvatar,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _avatarPath != null 
                            ? FileImage(File(_avatarPath!))
                            : null,
                        child: _avatarPath == null
                            ? const Icon(Icons.camera_alt, size: 30)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _pickAvatar,
                      child: const Text('Change Avatar'),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              const Text(
                'Personal Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),              
              const SizedBox(height: 16),             
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
              ),              
              const SizedBox(height: 16),            
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                maxLines: 3,
              ),             
              const SizedBox(height: 16),             
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.info),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 30),
              const Text(
                'Educational Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _institutionController,
                decoration: const InputDecoration(
                  labelText: 'Institution/University',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school),
                ),
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _degreeController,
                decoration: const InputDecoration(
                  labelText: 'Degree',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.book),
                ),
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _fieldOfStudyController,
                decoration: const InputDecoration(
                  labelText: 'Field of Study',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.subject),
                ),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _graduationYearController,
                      decoration: const InputDecoration(
                        labelText: 'Graduation Year',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cgpaController,
                      decoration: const InputDecoration(
                        labelText: 'CGPA/Percentage',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.grade),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              const Text(
                'Resume',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Icon(
                      _resumePath != null ? Icons.description : Icons.upload_file,
                      size: 48,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _resumePath != null 
                          ? 'Resume uploaded'
                          : 'Upload Resume (PDF, DOC, DOCX)',
                      textAlign: TextAlign.center,
                    ),
                    if (_resumePath != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _resumePath!.split('/').last,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _pickResume,
                      child: Text(_resumePath != null ? 'Change Resume' : 'Upload Resume'),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    _institutionController.dispose();
    _degreeController.dispose();
    _fieldOfStudyController.dispose();
    _graduationYearController.dispose();
    _cgpaController.dispose();
    super.dispose();
  }
}