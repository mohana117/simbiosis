import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/map_data_controller.dart';
import '../models/data_models.dart';
import '../utils/helpers.dart';

class ListingsScreen extends StatefulWidget {
  final MapDataController dataController;
  final VoidCallback onNavigateToPurchases;

  const ListingsScreen({
    super.key,
    required this.dataController,
    required this.onNavigateToPurchases,
  });

  @override
  State<ListingsScreen> createState() => ListingsScreenState();
}

class ListingsScreenState extends State<ListingsScreen> {
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    widget.dataController.addListener(onDataUpdated);
  }

  @override
  void dispose() {
    widget.dataController.removeListener(onDataUpdated);
    super.dispose();
  }

  void onDataUpdated() {
    if (mounted) setState(() {});
  }

  // Helper to build image for web compatibility
  Widget _buildListingImage(String imagePath) {
    // Check if it's a data URL (base64) or blob URL
    if (imagePath.startsWith('data:image') || imagePath.startsWith('blob:')) {
      return Image.network(
        imagePath,
        width: 140,
        height: 120,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 140,
            height: 120,
            color: Colors.grey.shade300,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 140,
            height: 120,
            color: Colors.grey.shade300,
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      );
    }
    // For regular network URLs
    else if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        width: 140,
        height: 120,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 140,
            height: 120,
            color: Colors.grey.shade300,
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 140,
            height: 120,
            color: Colors.grey.shade300,
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      );
    }
    // Fallback for other cases
    else {
      return Container(
        width: 140,
        height: 120,
        color: Colors.grey.shade300,
        child: const Icon(Icons.image_not_supported, color: Colors.grey),
      );
    }
  }

  void showPaymentModal(OpenDataPoint item) async {
    final prefs = await SharedPreferences.getInstance();

    final String userSavedAddress = prefs.getString('address') ?? 'Primary Recycling Hub Facility';
    final String userSavedState = prefs.getString('state') ?? 'Selangor';

    final LatLng buyerCoords = stateCoordinates[userSavedState] ?? const LatLng(3.0738, 101.5183);
    const Distance distanceCalc = Distance();
    final double computedDistanceKm = distanceCalc.as(LengthUnit.Kilometer, LatLng(item.latitude, item.longitude), buyerCoords);

    String selectedMethod = 'FPX Online Banking';

    double selectedTons = item.quantityTons >= 0.5 ? 0.5 : item.quantityTons;
    final double maxTons = item.quantityTons;

    final List<String> methods = ['FPX Online Banking', 'Credit / Debit Card', 'e-Wallet (Touch n Go / Grab)'];

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final double deliveryFee = 50.0 + (computedDistanceKm * 2.5) + (selectedTons * 15.0);
            final double itemPriceTotal = item.pricePerKg * selectedTons * 1000;
            final double finalGrandTotal = itemPriceTotal + deliveryFee;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Purchase & Delivery Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F382C))),
                    const SizedBox(height: 8),
                    Text('Listing: ${item.title}', style: const TextStyle(fontWeight: FontWeight.bold)),

                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Select Quantity:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${selectedTons.toStringAsFixed(1)} / ${maxTons.toStringAsFixed(1)} Tonnes', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F382C))),
                      ],
                    ),
                    Slider(
                      value: selectedTons,
                      min: 0.5,
                      max: maxTons,
                      divisions: maxTons > 0.5 ? ((maxTons - 0.5) * 2).round().clamp(1, 1000) : 1,
                      activeColor: const Color(0xFF1CB026),
                      label: '${selectedTons.toStringAsFixed(1)} Tons',
                      onChanged: (val) {
                        setModalState(() {
                          selectedTons = double.parse(val.toStringAsFixed(1));
                        });
                      },
                    ),

                    const Divider(height: 16),
                    const Text('Destination Details (Auto-detected)', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Address: $userSavedAddress', style: const TextStyle(fontSize: 13)),
                          Text('Region: $userSavedState', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          Text('Calculated Route: ~${computedDistanceKm.toStringAsFixed(0)} km away', style: const TextStyle(fontSize: 13, color: Color(0xFF0F382C))),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Material Price (${selectedTons.toStringAsFixed(1)} T)'),
                              Text('RM ${itemPriceTotal.toStringAsFixed(2)}'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Delivery Fee (${computedDistanceKm.toStringAsFixed(0)} km distance)'),
                              Text('RM ${deliveryFee.toStringAsFixed(2)}', style: const TextStyle(color: Colors.deepOrange)),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Grand Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              Text('RM ${finalGrandTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1CB026))),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                    const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...methods.map((method) => RadioListTile<String>(
                      title: Text(method, style: const TextStyle(fontSize: 13)),
                      value: method,
                      groupValue: selectedMethod,
                      dense: true,
                      onChanged: (val) => setModalState(() => selectedMethod = val!),
                    )),

                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1CB026),
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: () {
                        final purchase = PurchasedItem(
                          id: item.id,
                          title: item.title,
                          sector: item.sector,
                          quantityTons: selectedTons,
                          itemPriceTotal: itemPriceTotal,
                          deliveryFee: deliveryFee,
                          totalPaid: finalGrandTotal,
                          deliveryAddress: userSavedAddress,
                          deliveryState: userSavedState,
                          distanceKm: computedDistanceKm,
                          paymentMethod: selectedMethod,
                          repName: item.repName,
                          repPhone: item.repPhone,
                          purchaseDate: DateTime.now(),
                          status: 'In Progress',
                        );

                        widget.dataController.addPurchase(purchase, selectedTons);
                        Navigator.pop(ctx);
                        widget.onNavigateToPurchases();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Payment Successful! Order placed in My Purchases.'), backgroundColor: Color(0xFF0F382C)),
                        );
                      },
                      child: const Text('Confirm Purchase & Pay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final validListings = widget.dataController.openDataPoints.where((item) {
      return item.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.sector.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFCBE3E7),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (val) => setState(() => searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search waste type or title...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF0F382C)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: validListings.isEmpty
                  ? const Center(child: Text('No listings found.'))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: validListings.length,
                itemBuilder: (context, index) {
                  final item = validListings[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Images
                          if (item.images.isNotEmpty) ...[
                            SizedBox(
                              height: 120,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: item.images.length,
                                itemBuilder: (ctx, imgIdx) => Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: _buildListingImage(item.images[imgIdx]),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                          // Title and Price
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${item.sector} Material',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'RM ${item.pricePerKg.toStringAsFixed(2)}/kg',
                                style: const TextStyle(
                                  color: Color(0xFF1CB026),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${item.quantityTons.toStringAsFixed(1)} Tonnes Available • ${item.address}',
                          ),
                          const Divider(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.person, size: 16, color: Colors.black54),
                              const SizedBox(width: 4),
                              Text(
                                'Rep: ${item.repName}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1CB026),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                ),
                                onPressed: () => showPaymentModal(item),
                                child: const Text(
                                  'Buy',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}