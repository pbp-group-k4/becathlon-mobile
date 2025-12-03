import 'package:becathlon_mobile/utils/styles.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/profile.dart';
import '../utils/constants.dart';
import 'package:flutter/material.dart';

class ProfileService {
  Future<Profile?> fetchProfile(BuildContext context) async {
    final request = context.read<CookieRequest>();

    final response = await request.get(ApiConstants.profileDetailEndpoint);

    if (response != null && response is Map) {
      return Profile.fromJson(Map<String, dynamic>.from(response));
    }

    return null;
  }

  Future<bool> updateProfile(BuildContext context, Profile profile) async {
    final request = context.read<CookieRequest>();

    final response = await request.post(
      ApiConstants.profileUpdateEndpoint,
      profile.toJson(),
    );

    return response['status'] == true;
  }
}


/// PROFILE UI

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileService _service = ProfileService();
  Profile? _profile;
  bool _loading = true;
  bool _editing = false;

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final firstNameC = TextEditingController();
  final lastNameC = TextEditingController();
  final emailC = TextEditingController();
  final phoneC = TextEditingController();
  final sportsC = TextEditingController();

  bool newsletter = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    Profile? p = await _service.fetchProfile(context);

    if (p != null) {
      setState(() {
        _profile = p;
        firstNameC.text = p.firstName;
        lastNameC.text = p.lastName;
        emailC.text = p.email;
        phoneC.text = p.phone;
        sportsC.text = p.preferredSports;
        newsletter = p.newsletterOptIn;
      });
    }

    setState(() => _loading = false);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    _profile!
      ..firstName = firstNameC.text
      ..lastName = lastNameC.text
      ..email = emailC.text
      ..phone = phoneC.text
      ..preferredSports = sportsC.text
      ..newsletterOptIn = newsletter;

    bool ok = await _service.updateProfile(context, _profile!);

    if (ok) {
      setState(() => _editing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        AppWidgets.successSnackBar("Profile updated successfully"),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        AppWidgets.errorSnackBar("Failed to update profile"),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_profile == null) {
      return const Scaffold(
        body: Center(child: Text("Failed to load profile.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile", style: AppTextStyles.appBarTitle),
        actions: [
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _editing = true),
            )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Circular avatar icon
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.grey.shade300,
                child: const Icon(Icons.person, size: 48, color: Colors.black54),
              ),

              const SizedBox(height: 24),

              Text("Personal Information", style: AppTextStyles.headingMedium),
              const SizedBox(height: 16),

              _buildInput(
                label: "First Name",
                controller: firstNameC,
                icon: Icons.person,
                enabled: _editing,
              ),

              _buildInput(
                label: "Last Name",
                controller: lastNameC,
                icon: Icons.person_outline,
                enabled: _editing,
              ),

              _buildInput(
                label: "Email",
                controller: emailC,
                icon: Icons.email,
                enabled: _editing,
                validator: (v) =>
                    v == null || v.isEmpty ? "Email required" : null,
              ),

              _buildInput(
                label: "Phone",
                controller: phoneC,
                icon: Icons.phone,
                enabled: _editing,
              ),

              _buildInput(
                label: "Preferred Sports",
                controller: sportsC,
                icon: Icons.sports,
                enabled: _editing,
              ),

              const SizedBox(height: 16),

              // Newsletter toggle
              SwitchListTile(
                title: Text("Subscribe to newsletter",
                    style: AppTextStyles.bodyPrimary),
                contentPadding: EdgeInsets.zero,
                activeColor: AppColors.accentGold,
                value: newsletter,
                onChanged: _editing
                    ? (v) => setState(() => newsletter = v)
                    : null,
              ),

              const SizedBox(height: 32),

              if (_editing)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Modern input field builder
  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }
}