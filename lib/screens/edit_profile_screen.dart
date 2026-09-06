import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final formKey = GlobalKey<FormState>();

  final companyInput = TextEditingController();
  final repNameInput = TextEditingController();
  final phoneInput = TextEditingController();

  final addrLine1Input = TextEditingController();
  final addrLine2Input = TextEditingController();
  final addrLine3Input = TextEditingController();
  final addrLine4Input = TextEditingController();

  String selectedState = 'Selangor';
  String? companyLogoPath;
  String? currentLogoPath;

  final ImagePicker picker = ImagePicker();

  final List<String> malaysianStates = [
    'Johor', 'Kedah', 'Kelantan', 'Melaka', 'Negeri Sembilan',
    'Pahang', 'Penang', 'Perak', 'Perlis', 'Sabah', 'Sarawak',
    'Selangor', 'Terengganu', 'W.P. Kuala Lumpur'
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    companyInput.dispose();
    repNameInput.dispose();
    phoneInput.dispose();
    addrLine1Input.dispose();
    addrLine2Input.dispose();
    addrLine3Input.dispose();
    addrLine4Input.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      companyInput.text = prefs.getString('companyName') ?? '';
      repNameInput.text = prefs.getString('repName') ?? '';
      phoneInput.text = prefs.getString('phone') ?? '';

      addrLine1Input.text = prefs.getString('addrLine1') ?? '';
      addrLine2Input.text = prefs.getString('addrLine2') ?? '';
      addrLine3Input.text = prefs.getString('addrLine3') ?? '';
      addrLine4Input.text = prefs.getString('addrLine4') ?? '';

      selectedState = prefs.getString('state') ?? 'Selangor';
      currentLogoPath = prefs.getString('companyLogoPath');
    });
  }

  void _pickCompanyLogo() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF0F382C)),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(ctx);
                _getLogoImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_open, color: Color(0xFF0F382C)),
              title: const Text('Upload from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _getLogoImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getLogoImage(ImageSource source) async {
    try {
      final XFile? image = await picker.pickImage(source: source, imageQuality: 80);
      if (image != null) {
        setState(() {
          companyLogoPath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error accessing camera or gallery: $e')),
        );
      }
    }
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegExp = RegExp(r'^(\+?6?01)[0-9]{8,9}$');
    if (!phoneRegExp.hasMatch(value.trim().replaceAll(' ', ''))) {
      return 'Enter a valid Malaysian phone number (e.g., 0123456789)';
    }
    return null;
  }

  String? validatePostalCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Postal code is required';
    }
    final postalRegExp = RegExp(r'^[0-9]{5}$');
    if (!postalRegExp.hasMatch(value.trim())) {
      return 'Enter a valid 5-digit postal code';
    }
    return null;
  }

  Future<void> saveProfile() async {
    if (!formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();

    final fullFormattedAddress =
        '${addrLine1Input.text.trim()}\n'
        '${addrLine2Input.text.trim()}'
        '${addrLine3Input.text.trim().isNotEmpty ? '\n${addrLine3Input.text.trim()}' : ''}\n'
        '${addrLine4Input.text.trim()}\n'
        '$selectedState';

    await prefs.setString('companyName', companyInput.text.trim());
    await prefs.setString('repName', repNameInput.text.trim());
    await prefs.setString('phone', phoneInput.text.trim());

    await prefs.setString('addrLine1', addrLine1Input.text.trim());
    await prefs.setString('addrLine2', addrLine2Input.text.trim());
    await prefs.setString('addrLine3', addrLine3Input.text.trim());
    await prefs.setString('addrLine4', addrLine4Input.text.trim());
    await prefs.setString('address', fullFormattedAddress);
    await prefs.setString('state', selectedState);

    if (companyLogoPath != null) {
      await prefs.setString('companyLogoPath', companyLogoPath!);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully!'),
        backgroundColor: Color(0xFF1CB026),
      ),
    );
    Navigator.pop(context, true);
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    bool isRequired = true,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F382C),
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator ??
                    (v) => isRequired && v!.trim().isEmpty ? '$label is required' : null,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoPreview() {
    if (companyLogoPath != null && companyLogoPath!.isNotEmpty) {
      return Image.network(
        companyLogoPath!,
        fit: BoxFit.cover,
        width: 100,
        height: 100,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Icon(Icons.person, size: 55, color: Colors.white);
        },
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.person, size: 55, color: Colors.white);
        },
      );
    } else if (currentLogoPath != null && currentLogoPath!.isNotEmpty) {
      return Image.network(
        currentLogoPath!,
        fit: BoxFit.cover,
        width: 100,
        height: 100,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Icon(Icons.person, size: 55, color: Colors.white);
        },
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.person, size: 55, color: Colors.white);
        },
      );
    }
    return const Icon(Icons.add_a_photo, color: Colors.grey, size: 35);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCBE3E7),
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0F382C),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickCompanyLogo,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: ClipOval(
                      child: _buildLogoPreview(),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tap to update logo',
                  style: TextStyle(fontSize: 12, color: Color(0xFF0F382C)),
                ),
                const SizedBox(height: 20),

                _buildField(label: 'Company Name *', controller: companyInput),
                _buildField(label: 'Contact Person *', controller: repNameInput),
                _buildField(
                  label: 'Phone Number *',
                  controller: phoneInput,
                  keyboardType: TextInputType.phone,
                  validator: validatePhone,
                ),

                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Structured Address',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F382C),
                      ),
                    ),
                  ),
                ),
                const Text(
                  'This address will be used as your pickup location',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),

                _buildField(
                  label: "Line 1: Recipient's full name or company name *",
                  controller: addrLine1Input,
                ),
                _buildField(
                  label: "Line 2: Building number, street name & unit/apt *",
                  controller: addrLine2Input,
                ),
                _buildField(
                  label: "Line 3: Local area, housing taman, or village (optional)",
                  controller: addrLine3Input,
                  isRequired: false,
                ),
                _buildField(
                  label: "Line 4: 5-digit postal code and city/town *",
                  controller: addrLine4Input,
                  keyboardType: TextInputType.number,
                  validator: validatePostalCode,
                ),


                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Line 5: State or federal territory *',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0F382C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        value: selectedState,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: malaysianStates.map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Text(s),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              selectedState = val;
                            });
                          }
                        },
                        validator: (v) => v == null ? 'Please select a state' : null,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1CB026),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: saveProfile,
                    child: const Text(
                      'Save Profile Changes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
