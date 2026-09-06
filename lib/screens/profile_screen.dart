import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  Map<String, String> userData = {};
  bool isLoggedIn = false;
  String? logoPath;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('isLoggedIn') ?? false;

    setState(() {
      isLoggedIn = loggedIn;
      logoPath = prefs.getString('companyLogoPath');
      userData = {
        'companyName': prefs.getString('companyName') ?? 'Not Set',
        'repName': prefs.getString('repName') ?? 'Guest User',
        'phone': prefs.getString('phone') ?? 'Not Set',
        'address': prefs.getString('address') ?? 'Not Set',
        'state': prefs.getString('state') ?? 'Not Set',
        'email': prefs.getString('email') ?? 'Not Set',
        'addrLine1': prefs.getString('addrLine1') ?? '',
        'addrLine2': prefs.getString('addrLine2') ?? '',
        'addrLine3': prefs.getString('addrLine3') ?? '',
        'addrLine4': prefs.getString('addrLine4') ?? '',
      };
    });
  }

  Future<void> handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (route) => false,
    );
  }

  // Helper for logo image - web compatible
  Widget _buildLogoImage() {
    if (logoPath != null && logoPath!.isNotEmpty) {
      return Image.network(
        logoPath!,
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
    return const Icon(Icons.person, size: 55, color: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCBE3E7),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Picture
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF0F382C),
                    child: ClipOval(
                      child: _buildLogoImage(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    isLoggedIn ? (userData['repName'] ?? 'User') : 'Guest User',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  if (isLoggedIn) ...[
                    const SizedBox(height: 4),
                    Text(
                      userData['email'] ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    // Edit Profile Button
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF0F382C)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        );
                        if (result == true) {
                          loadUserData();
                        }
                      },
                      icon: const Icon(Icons.edit, color: Color(0xFF0F382C), size: 18),
                      label: const Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: Color(0xFF0F382C),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Guest Card
                  if (!isLoggedIn)
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Text(
                              'You are currently browsing as a Guest.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1CB026),
                                minimumSize: const Size.fromHeight(44),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              ),
                              child: const Text(
                                'Log In',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(44),
                                side: const BorderSide(color: Color(0xFF0F382C), width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              ),
                              child: const Text(
                                'Register Account',
                                style: TextStyle(
                                  color: Color(0xFF0F382C),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    // Profile Details Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.business, color: Color(0xFF0F382C)),
                            title: const Text('Company Name'),
                            subtitle: Text(userData['companyName']!),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.person, color: Color(0xFF0F382C)),
                            title: const Text('Representative'),
                            subtitle: Text(userData['repName']!),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.phone, color: Color(0xFF0F382C)),
                            title: const Text('Phone'),
                            subtitle: Text(userData['phone']!),
                          ),
                          const Divider(height: 1),
                          // Address with formatted display
                          ListTile(
                            leading: const Icon(Icons.location_on, color: Color(0xFF0F382C)),
                            title: const Text('Address'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (userData['addrLine1']!.isNotEmpty)
                                  Text(userData['addrLine1']!),
                                if (userData['addrLine2']!.isNotEmpty)
                                  Text(userData['addrLine2']!),
                                if (userData['addrLine3']!.isNotEmpty)
                                  Text(userData['addrLine3']!),
                                if (userData['addrLine4']!.isNotEmpty)
                                  Text(userData['addrLine4']!),
                                if (userData['state']!.isNotEmpty)
                                  Text(userData['state']!),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Logout Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: handleLogout,
                      child: const Text(
                        'Log Out',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
