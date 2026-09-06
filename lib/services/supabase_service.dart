import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/supabase_models.dart';
import '../models/data_models.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  SupabaseClient get client => Supabase.instance.client;

  // ==================== LISTINGS CRUD ====================

  // Get all listings
  Future<List<SupabaseListing>> getListings() async {
    try {
      final response = await client
          .from('listings')
          .select('*')
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => SupabaseListing.fromJson(item))
          .toList();
    } catch (e) {
      print('Error fetching listings: $e');
      return [];
    }
  }

  // Get listings by state
  Future<List<SupabaseListing>> getListingsByState(String state) async {
    try {
      final response = await client
          .from('listings')
          .select('*')
          .eq('state', state)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => SupabaseListing.fromJson(item))
          .toList();
    } catch (e) {
      print('Error fetching listings by state: $e');
      return [];
    }
  }

  // Get listings by sector/category
  Future<List<SupabaseListing>> getListingsBySector(String sector) async {
    try {
      final response = await client
          .from('listings')
          .select('*')
          .eq('sector', sector)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => SupabaseListing.fromJson(item))
          .toList();
    } catch (e) {
      print('Error fetching listings by sector: $e');
      return [];
    }
  }

  // Insert a new listing
  Future<SupabaseListing?> insertListing(OpenDataPoint listing) async {
    try {
      final supabaseListing = SupabaseListing(
        title: listing.title,
        latitude: listing.latitude,
        longitude: listing.longitude,
        sector: listing.sector,
        state: listing.state,
        address: listing.address,
        pricePerKg: listing.pricePerKg,
        quantityTons: listing.quantityTons,
        repName: listing.repName,
        repPhone: listing.repPhone,
        images: listing.images,
        userId: client.auth.currentUser?.id,
      );

      final response = await client
          .from('listings')
          .insert(supabaseListing.toJson())
          .select();

      if (response.isNotEmpty) {
        return SupabaseListing.fromJson(response.first);
      }
      return null;
    } catch (e) {
      print('Error inserting listing: $e');
      return null;
    }
  }

  // Update a listing
  Future<SupabaseListing?> updateListing(SupabaseListing listing) async {
    if (listing.id == null) return null; // Ensure ID is present

    try {
      final response = await client
          .from('listings')
          .update(listing.toJson())
          .eq('id', listing.id!) // Safely pass non-null int
          .select();

      if (response.isNotEmpty) {
        return SupabaseListing.fromJson(response.first);
      }
      return null;
    } catch (e) {
      print('Error updating listing: $e');
      return null;
    }
  }

  // Delete a listing
  Future<bool> deleteListing(int id) async {
    try {
      await client
          .from('listings')
          .delete()
          .eq('id', id);
      return true;
    } catch (e) {
      print('Error deleting listing: $e');
      return false;
    }
  }

  // ==================== PURCHASES CRUD ====================

  // Get all purchases
  Future<List<SupabasePurchase>> getPurchases() async {
    try {
      final response = await client
          .from('purchases')
          .select('*')
          .order('purchase_date', ascending: false);

      return (response as List)
          .map((item) => SupabasePurchase.fromJson(item))
          .toList();
    } catch (e) {
      print('Error fetching purchases: $e');
      return [];
    }
  }

  // Get purchases by status
  Future<List<SupabasePurchase>> getPurchasesByStatus(String status) async {
    try {
      final response = await client
          .from('purchases')
          .select('*')
          .eq('status', status)
          .order('purchase_date', ascending: false);

      return (response as List)
          .map((item) => SupabasePurchase.fromJson(item))
          .toList();
    } catch (e) {
      print('Error fetching purchases by status: $e');
      return [];
    }
  }

  // Insert a new purchase
  Future<SupabasePurchase?> insertPurchase(PurchasedItem item) async {
    try {
      final supabasePurchase = SupabasePurchase(
        listingId: item.id,
        title: item.title,
        sector: item.sector,
        quantityTons: item.quantityTons,
        itemPriceTotal: item.itemPriceTotal,
        deliveryFee: item.deliveryFee,
        totalPaid: item.totalPaid,
        deliveryAddress: item.deliveryAddress,
        deliveryState: item.deliveryState,
        distanceKm: item.distanceKm,
        paymentMethod: item.paymentMethod,
        repName: item.repName,
        repPhone: item.repPhone,
        status: item.status,
        userId: client.auth.currentUser?.id,
      );

      final response = await client
          .from('purchases')
          .insert(supabasePurchase.toJson())
          .select();

      if (response.isNotEmpty) {
        return SupabasePurchase.fromJson(response.first);
      }
      return null;
    } catch (e) {
      print('Error inserting purchase: $e');
      return null;
    }
  }

  // Update purchase status
  Future<bool> updatePurchaseStatus(int id, String status) async {
    try {
      await client
          .from('purchases')
          .update({'status': status})
          .eq('id', id);
      return true;
    } catch (e) {
      print('Error updating purchase status: $e');
      return false;
    }
  }

  // ==================== USER PROFILES CRUD ====================

  // Get user profile
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      final response = await client
          .from('user_profiles')
          .select('*')
          .eq('id', userId);

      if (response.isNotEmpty) {
        return UserProfile.fromJson(response.first);
      }
      return null;
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // Insert or update user profile (UPSERT)
  Future<UserProfile?> upsertUserProfile(Map<String, dynamic> profileData) async {
    try {
      final userId = client.auth.currentUser?.id;
      if (userId == null) return null;

      final data = {
        'id': userId,
        ...profileData,
      };

      final response = await client
          .from('user_profiles')
          .upsert(data)
          .select();

      if (response.isNotEmpty) {
        return UserProfile.fromJson(response.first);
      }
      return null;
    } catch (e) {
      print('Error upserting user profile: $e');
      return null;
    }
  }

  // ==================== AUTHENTICATION ====================

  // Sign up
  Future<AuthResponse> signUp(String email, String password) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }

  // Sign in
  Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return client.auth.currentUser;
  }

  // Check if user is authenticated
  bool isAuthenticated() {
    return client.auth.currentUser != null;
  }
}
