import 'package:flutter/material.dart';
import '../controllers/supabase_controller.dart';
import 'map_screen.dart';
import 'listings_screen.dart';
import 'post_listing_screen.dart';
import 'purchases_screen.dart';
import 'profile_screen.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  int currentIndex = 0;
  final SupabaseController sharedDataController = SupabaseController();

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      MapMarketplaceScreen(dataController: sharedDataController),
      ListingsScreen(
        dataController: sharedDataController,
        onNavigateToPurchases: () => setState(() => currentIndex = 3),
      ),
      PostListingScreen(
        dataController: sharedDataController,
        onListingPublished: () => setState(() => currentIndex = 1),
      ),
      PurchasesScreen(dataController: sharedDataController),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F382C),
        elevation: 0,
        title: const Text(
          'Simbiosis',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (sharedDataController.isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
      body: IndexedStack(index: currentIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF0F382C),
        unselectedItemColor: Colors.black45,
        onTap: (index) => setState(() => currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Waste Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            label: 'Listings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Sell Waste',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'My Purchases',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}