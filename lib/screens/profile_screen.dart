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

  // Text controllers
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
        const SnackBar(content: Text("Profile updated")),
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
        title: const Text("Profile"),
        actions: [
          if (!_editing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _editing = true),
            )
        ],
      ),

      /// =========== PROFILE UI ==============
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// USER ICON
            const Icon(Icons.person, size: 120, color: Colors.grey),

            const SizedBox(height: 20),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  _textField("First Name", firstNameC, enabled: _editing),
                  _textField("Last Name", lastNameC, enabled: _editing),
                  _textField("Email", emailC, enabled: _editing),
                  _textField("Phone", phoneC, enabled: _editing),
                  _textField("Preferred Sports", sportsC, enabled: _editing),

                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: newsletter,
                        onChanged: _editing
                            ? (v) => setState(() => newsletter = v!)
                            : null,
                      ),
                      const Text("Subscribe to newsletter"),
                    ],
                  ),

                  const SizedBox(height: 20),

                  if (_editing)
                    ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text("Save Changes"),
                    ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  /// Reusable text fields
  Widget _textField(String label, TextEditingController controller,
      {bool enabled = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
