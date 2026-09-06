// Supabase versions of your data models

import 'data_models.dart';

class SupabaseListing {
  final int? id;
  final String title;
  final double latitude;
  final double longitude;
  final String sector;
  final String state;
  final String address;
  final double pricePerKg;
  final double quantityTons;
  final String repName;
  final String repPhone;
  final List<String> images;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SupabaseListing({
    this.id,
    required this.title,
    required this.latitude,
    required this.longitude,
    required this.sector,
    required this.state,
    required this.address,
    required this.pricePerKg,
    required this.quantityTons,
    required this.repName,
    required this.repPhone,
    this.images = const [],
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory SupabaseListing.fromJson(Map<String, dynamic> json) {
    return SupabaseListing(
      id: json['id'] as int?,
      title: json['title'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      sector: json['sector'] as String,
      state: json['state'] as String,
      address: json['address'] as String,
      pricePerKg: (json['price_per_kg'] as num).toDouble(),
      quantityTons: (json['quantity_tons'] as num).toDouble(),
      repName: json['rep_name'] as String,
      repPhone: json['rep_phone'] as String,
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : [],
      userId: json['user_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'latitude': latitude,
      'longitude': longitude,
      'sector': sector,
      'state': state,
      'address': address,
      'price_per_kg': pricePerKg,
      'quantity_tons': quantityTons,
      'rep_name': repName,
      'rep_phone': repPhone,
      'images': images,
      'user_id': userId,
    };
  }

  // Convert to your existing OpenDataPoint
  OpenDataPoint toOpenDataPoint() {
    return OpenDataPoint(
      id: id?.toString() ?? 'supabase_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      latitude: latitude,
      longitude: longitude,
      sector: sector,
      state: state,
      address: address,
      pricePerKg: pricePerKg,
      quantityTons: quantityTons,
      repName: repName,
      repPhone: repPhone,
      images: images,
    );
  }
}

class SupabasePurchase {
  final int? id;
  final String listingId;
  final String title;
  final String sector;
  final double quantityTons;
  final double itemPriceTotal;
  final double deliveryFee;
  final double totalPaid;
  final String deliveryAddress;
  final String deliveryState;
  final double distanceKm;
  final String paymentMethod;
  final String repName;
  final String repPhone;
  final String status;
  final String? userId;
  final DateTime? purchaseDate;
  final DateTime? updatedAt;

  SupabasePurchase({
    this.id,
    required this.listingId,
    required this.title,
    required this.sector,
    required this.quantityTons,
    required this.itemPriceTotal,
    required this.deliveryFee,
    required this.totalPaid,
    required this.deliveryAddress,
    required this.deliveryState,
    required this.distanceKm,
    required this.paymentMethod,
    required this.repName,
    required this.repPhone,
    this.status = 'In Progress',
    this.userId,
    this.purchaseDate,
    this.updatedAt,
  });

  factory SupabasePurchase.fromJson(Map<String, dynamic> json) {
    return SupabasePurchase(
      id: json['id'] as int?,
      listingId: json['listing_id'] as String,
      title: json['title'] as String,
      sector: json['sector'] as String,
      quantityTons: (json['quantity_tons'] as num).toDouble(),
      itemPriceTotal: (json['item_price_total'] as num).toDouble(),
      deliveryFee: (json['delivery_fee'] as num).toDouble(),
      totalPaid: (json['total_paid'] as num).toDouble(),
      deliveryAddress: json['delivery_address'] as String,
      deliveryState: json['delivery_state'] as String,
      distanceKm: (json['distance_km'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String,
      repName: json['rep_name'] as String,
      repPhone: json['rep_phone'] as String,
      status: json['status'] as String? ?? 'In Progress',
      userId: json['user_id'] as String?,
      purchaseDate: json['purchase_date'] != null
          ? DateTime.parse(json['purchase_date'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listing_id': listingId,
      'title': title,
      'sector': sector,
      'quantity_tons': quantityTons,
      'item_price_total': itemPriceTotal,
      'delivery_fee': deliveryFee,
      'total_paid': totalPaid,
      'delivery_address': deliveryAddress,
      'delivery_state': deliveryState,
      'distance_km': distanceKm,
      'payment_method': paymentMethod,
      'rep_name': repName,
      'rep_phone': repPhone,
      'status': status,
      'user_id': userId,
    };
  }

  // Convert to your existing PurchasedItem
  PurchasedItem toPurchasedItem() {
    return PurchasedItem(
      id: listingId,
      title: title,
      sector: sector,
      quantityTons: quantityTons,
      itemPriceTotal: itemPriceTotal,
      deliveryFee: deliveryFee,
      totalPaid: totalPaid,
      deliveryAddress: deliveryAddress,
      deliveryState: deliveryState,
      distanceKm: distanceKm,
      paymentMethod: paymentMethod,
      repName: repName,
      repPhone: repPhone,
      purchaseDate: purchaseDate ?? DateTime.now(),
      status: status,
    );
  }
}

class UserProfile {
  final String id;
  final String? companyName;
  final String? repName;
  final String? phone;
  final String? addrLine1;
  final String? addrLine2;
  final String? addrLine3;
  final String? addrLine4;
  final String? state;
  final String? address;
  final String? companyLogoPath;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    this.companyName,
    this.repName,
    this.phone,
    this.addrLine1,
    this.addrLine2,
    this.addrLine3,
    this.addrLine4,
    this.state,
    this.address,
    this.companyLogoPath,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      companyName: json['company_name'] as String?,
      repName: json['rep_name'] as String?,
      phone: json['phone'] as String?,
      addrLine1: json['addr_line1'] as String?,
      addrLine2: json['addr_line2'] as String?,
      addrLine3: json['addr_line3'] as String?,
      addrLine4: json['addr_line4'] as String?,
      state: json['state'] as String?,
      address: json['address'] as String?,
      companyLogoPath: json['company_logo_path'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_name': companyName,
      'rep_name': repName,
      'phone': phone,
      'addr_line1': addrLine1,
      'addr_line2': addrLine2,
      'addr_line3': addrLine3,
      'addr_line4': addrLine4,
      'state': state,
      'address': address,
      'company_logo_path': companyLogoPath,
    };
  }
}
