import 'package:flutter/material.dart';
import '../controllers/map_data_controller.dart';

class PurchasesScreen extends StatefulWidget {
  final MapDataController dataController;
  const PurchasesScreen({super.key, required this.dataController});

  @override
  State<PurchasesScreen> createState() => PurchasesScreenState();
}

class PurchasesScreenState extends State<PurchasesScreen> {
  String filterStatus = 'All';

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

  void cancelPurchase(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Purchase'),
        content: const Text('Are you sure you want to cancel this purchase?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              widget.dataController.purchasedItems[index].status = 'Cancelled';
              widget.dataController.notifyListeners();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Purchase cancelled.'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final purchases = widget.dataController.purchasedItems;

    final filteredPurchases = purchases.where((item) {
      if (filterStatus == 'All') return true;
      if (filterStatus == 'Pending') return item.status == 'In Progress';
      if (filterStatus == 'Completed') return item.status == 'Completed';
      if (filterStatus == 'Cancelled') return item.status == 'Cancelled';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFCBE3E7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Purchases',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F382C)),
              ),
              const SizedBox(height: 12),

              Container(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterChip('All'),
                    _buildFilterChip('Pending'),
                    _buildFilterChip('Completed'),
                    _buildFilterChip('Cancelled'),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              Text(
                '${filteredPurchases.length} purchase${filteredPurchases.length != 1 ? 's' : ''}',
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: filteredPurchases.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 60,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        filterStatus == 'All'
                            ? 'You haven\'t bought anything yet.'
                            : 'No ${filterStatus.toLowerCase()} purchases.',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  itemCount: filteredPurchases.length,
                  itemBuilder: (context, index) {
                    final originalIndex = purchases.indexOf(filteredPurchases[index]);
                    final item = filteredPurchases[index];
                    final isCompleted = item.status == 'Completed';
                    final isCancelled = item.status == 'Cancelled';
                    final isPending = item.status == 'In Progress';

                    Color statusColor;
                    IconData statusIcon;
                    String statusText;

                    if (isCompleted) {
                      statusColor = Colors.green;
                      statusIcon = Icons.check_circle;
                      statusText = 'Completed';
                    } else if (isCancelled) {
                      statusColor = Colors.red;
                      statusIcon = Icons.cancel;
                      statusText = 'Cancelled';
                    } else {
                      statusColor = Colors.orange;
                      statusIcon = Icons.hourglass_top;
                      statusText = 'Pending';
                    }

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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: statusColor.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        statusIcon,
                                        color: statusColor,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        statusText,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: statusColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            Text(
                              '${item.quantityTons.toStringAsFixed(1)} Tons',
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              'Total: RM ${item.totalPaid.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1CB026),
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Payment: ${item.paymentMethod}',
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Delivery: ${item.deliveryAddress}',
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Seller: ${item.repName} (${item.repPhone})',
                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Date: ${item.purchaseDate.toString().substring(0, 16)}',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),

                            if (isPending) ...[
                              const Divider(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.red),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                    ),
                                    onPressed: () => cancelPurchase(originalIndex),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1CB026),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                    ),
                                    onPressed: () {
                                      widget.dataController.completePurchase(originalIndex);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Purchase marked as completed!'),
                                          backgroundColor: Color(0xFF1CB026),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Complete',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            if (isCompleted) ...[
                              const Divider(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF1CB026),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Delivery Completed',
                                    style: TextStyle(
                                      color: Color(0xFF1CB026),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            if (isCancelled) ...[
                              const Divider(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Purchase Cancelled',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = filterStatus == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              filterStatus = label;
            });
          }
        },
        selectedColor: const Color(0xFF0F382C),
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF0F382C),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? const Color(0xFF0F382C) : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
}