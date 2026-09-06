import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/map_data_controller.dart';
import '../models/data_models.dart';

class PostListingScreen extends StatefulWidget {
  final MapDataController dataController;
  final VoidCallback onListingPublished;

  const PostListingScreen({
    super.key,
    required this.dataController,
    required this.onListingPublished,
  });

  @override
  State<PostListingScreen> createState() => PostListingScreenState();
}

class PostListingScreenState extends State<PostListingScreen> {
  final titleController = TextEditingController();
  final addressController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();
  final repNameController = TextEditingController();
  final repPhoneController = TextEditingController();

  List<String> listingImages = [];
  final ImagePicker picker = ImagePicker();

  String selectedSector = 'Plastic';
  String selectedState = 'Selangor';

  final List<String> categories = [
    'Plastic', 'Metal', 'Cardboard', 'Textile', 'Glass',
    'Organic', 'Electronics', 'Chemical', 'Paper', 'Rubber', 'Wood'
  ];
  final List<String> malaysianStates = [
    'Johor', 'Kedah', 'Kelantan', 'Melaka', 'Negeri Sembilan',
    'Pahang', 'Penang', 'Perak', 'Perlis', 'Sabah', 'Sarawak',
    'Selangor', 'Terengganu', 'W.P. Kuala Lumpur'
  ];

  @override
  void initState() {
    super.initState();
    loadProfileRepInfo();
  }

  @override
  void dispose() {
    titleController.dispose();
    addressController.dispose();
    quantityController.dispose();
    priceController.dispose();
    repNameController.dispose();
    repPhoneController.dispose();
    super.dispose();
  }

  Future<void> loadProfileRepInfo() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('isLoggedIn') ?? false) {
      setState(() {
        repNameController.text = prefs.getString('repName') ?? '';
        repPhoneController.text = prefs.getString('phone') ?? '';
        addressController.text = prefs.getString('address') ?? '';
        selectedState = prefs.getString('state') ?? 'Selangor';
      });
    }
  }

  void showImageSourceModal() {
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
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_open, color: Color(0xFF0F382C)),
              title: const Text('Upload from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                pickMultipleImagesFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await picker.pickImage(source: source, imageQuality: 80);
      if (image != null) {
        setState(() {
          listingImages.add(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not access camera: $e')),
        );
      }
    }
  }

  Future<void> pickMultipleImagesFromGallery() async {
    try {
      final List<XFile> images = await picker.pickMultiImage(imageQuality: 80);
      if (images.isNotEmpty) {
        setState(() {
          listingImages.addAll(images.map((img) => img.path));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open gallery: $e')),
        );
      }
    }
  }

  void removeImage(int index) {
    setState(() {
      listingImages.removeAt(index);
    });
  }

  Widget _buildImagePreview(String imagePath) {
    return Image.network(
      imagePath,
      width: 100,
      height: 100,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: 100,
          height: 100,
          color: Colors.grey.shade300,
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 100,
          height: 100,
          color: Colors.grey.shade300,
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
      },
    );
  }

  void publishWaste() {
    if (titleController.text.isEmpty || quantityController.text.isEmpty || priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    final newListing = OpenDataPoint(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      title: titleController.text.trim(),
      latitude: 3.0738 + (math.Random().nextDouble() * 0.05),
      longitude: 101.5183 + (math.Random().nextDouble() * 0.05),
      sector: selectedSector,
      state: selectedState,
      address: addressController.text.trim().isEmpty ? '$selectedState, Malaysia' : addressController.text.trim(),
      pricePerKg: double.tryParse(priceController.text) ?? 1.0,
      quantityTons: double.tryParse(quantityController.text) ?? 5.0,
      repName: repNameController.text.trim().isEmpty ? 'Representative' : repNameController.text.trim(),
      repPhone: repPhoneController.text.trim().isEmpty ? '+60 12-000 0000' : repPhoneController.text.trim(),
      images: listingImages,
    );

    widget.dataController.addListing(newListing);

    titleController.clear();
    quantityController.clear();
    priceController.clear();
    setState(() {
      listingImages.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Listing published successfully!'),
        backgroundColor: Color(0xFF1CB026),
      ),
    );

    widget.onListingPublished();
  }

  InputDecoration buildInputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCBE3E7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sell Waste Material',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F382C)),
              ),
              const SizedBox(height: 20),


              const Text(
                'Upload Material Pictures',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F382C)),
              ),
              const SizedBox(height: 8),

              if (listingImages.isNotEmpty)
                Container(
                  height: 100,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: listingImages.length,
                    itemBuilder: (context, index) {
                      final imagePath = listingImages[index];
                      return Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF0F382C), width: 1),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _buildImagePreview(imagePath),
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 12,
                            child: GestureDetector(
                              onTap: () => removeImage(index),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

              Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F382C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: showImageSourceModal,
                    icon: const Icon(Icons.add_a_photo, color: Colors.white),
                    label: const Text(
                      'Add Photo',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${listingImages.length} image${listingImages.length != 1 ? 's' : ''} selected',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              DropdownButtonFormField<String>(
                value: selectedSector,
                decoration: buildInputDecoration('Waste Category'),
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => selectedSector = val!),
              ),
              const SizedBox(height: 18),

              TextField(
                controller: titleController,
                decoration: buildInputDecoration('Title / Item Name'),
              ),
              const SizedBox(height: 18),

              TextField(
                controller: addressController,
                decoration: buildInputDecoration('Facility Address'),
              ),
              const SizedBox(height: 18),

              DropdownButtonFormField<String>(
                value: selectedState,
                decoration: buildInputDecoration('Facility State'),
                items: malaysianStates.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => selectedState = val!),
              ),
              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: quantityController,
                      keyboardType: TextInputType.number,
                      decoration: buildInputDecoration('Quantity (Tons)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: buildInputDecoration('Price (RM/kg)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),


              TextField(
                controller: repNameController,
                decoration: buildInputDecoration('Representative Name'),
              ),
              const SizedBox(height: 18),

              TextField(
                controller: repPhoneController,
                decoration: buildInputDecoration('Representative Phone'),
              ),

              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1CB026),
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: publishWaste,
                child: const Text(
                  'Publish Waste Listing',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}