import 'package:flutter/material.dart';

class MarketplaceScreen extends StatefulWidget {
  final String? filter;
  const MarketplaceScreen({super.key, this.filter});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    // If a filter is passed (e.g., 'Fungicide'), select it automatically
    _selectedCategory = widget.filter ?? 'All Products';
  }

  @override
  Widget build(BuildContext context) {
    // Mock products
    final allProducts = [
      {
        'name': 'Mancozeb Fungicide',
        'price': '₹450',
        'category': 'Fungicide',
        'desc': 'Effective against Late Blight and Early Blight.'
      },
      {
        'name': 'Neem Oil (Organic)',
        'price': '₹280',
        'category': 'Pesticide',
        'desc': 'Natural solution for pest control.'
      },
      {
        'name': 'NPK Fertilizer',
        'price': '₹1,200',
        'category': 'Fertilizer',
        'desc': 'Provides nitrogen, phosphorus, and potassium.'
      },
      {
        'name': 'Urea (Bag)',
        'price': '₹266',
        'category': 'Fertilizer',
        'desc': 'Promotes green leafy growth.'
      },
      {
        'name': 'Copper Fungicide',
        'price': '₹520',
        'category': 'Fungicide',
        'desc': 'Broad-spectrum fungicide for crops.'
      },
    ];

    final filteredProducts = _selectedCategory == 'All Products'
        ? allProducts
        : allProducts.where((p) => p['category'] == _selectedCategory).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agriculture Store', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Professional Category Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildFilterChip('All Products'),
                _buildFilterChip('Fungicide'),
                _buildFilterChip('Pesticide'),
                _buildFilterChip('Fertilizer'),
                _buildFilterChip('Seeds'),
              ],
            ),
          ),
          
          Expanded(
            child: filteredProducts.isEmpty 
              ? const Center(child: Text('No products found in this category'))
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return _buildProductCard(context, product);
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final bool isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.green : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Map<String, String> product) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: const Icon(Icons.shopping_bag, size: 50, color: Colors.green),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['category']!,
                  style: TextStyle(color: Colors.green.shade700, fontSize: 10, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  product['name']!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product['price']!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Add to Cart'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
