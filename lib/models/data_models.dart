class OpenDataPoint {
  final String id;
  final String title;
  final double latitude;
  final double longitude;
  final String sector;
  final String state;
  final String address;
  final double pricePerKg;
  double quantityTons;
  final String repName;
  final String repPhone;
  final List<String> images;

  OpenDataPoint({
    required this.id,
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
  });
}

class PurchasedItem {
  final String id;
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
  final DateTime purchaseDate;
  String status;

  PurchasedItem({
    required this.id,
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
    required this.purchaseDate,
    this.status = 'In Progress',
  });
}