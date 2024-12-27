import 'dart:convert'; // For decoding JSON
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class Dashboard extends StatefulWidget {
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<dynamic> products = []; // List to store product data
  List<dynamic> cart = []; // Cart to store added products
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  // Function to fetch products from DummyJSON
  Future<void> fetchProducts() async {
    const String productsUrl = "https://dummyjson.com/products";

    try {
      final response = await http.get(Uri.parse(productsUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          products = data['products'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load products: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  // Function to add a product to the cart
  void addToCart(dynamic product) {
    setState(() {
      cart.add(product);
    });
    Get.snackbar(
      "Added to Cart",
      "${product['title']} has been added to your cart.",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // Function to remove a product from the cart
  void removeFromCart(dynamic product) {
    setState(() {
      cart.remove(product);
    });
  }

  // Function to calculate the total price of the cart
  double calculateTotal() {
    return cart.fold(0, (sum, item) => sum + item['price']);
  }

  // Logout function
  void logout() {
    final box = GetStorage();
    box.erase(); // Clear all stored data
    Get.offNamed('/login'); // Redirect to login screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // Navigate to the Cart screen
              showModalBottomSheet(
                context: context,
                builder: (_) {
                  return Cart(
                    cart: cart,
                    removeFromCart: removeFromCart,
                    calculateTotal: calculateTotal,
                  );
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator()) // Show loader while loading
            : GridView.builder(
                padding: const EdgeInsets.all(10.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Number of columns
                  crossAxisSpacing: 10.0, // Spacing between columns
                  mainAxisSpacing: 10.0, // Spacing between rows
                  childAspectRatio: 0.75, // Adjust to match the layout
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return Card(
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(10.0)),
                            child: Image.network(
                              product['thumbnail'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                product['title'],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '\$${product['price']}',
                                style: const TextStyle(color: Colors.green),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              ElevatedButton(
                                onPressed: () {
                                  addToCart(product); // Add product to the cart
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                ),
                                child: const Text('Add to Cart'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}

// Cart Widget
class Cart extends StatelessWidget {
  final List<dynamic> cart;
  final Function(dynamic) removeFromCart;
  final Function calculateTotal;

  const Cart({
    required this.cart,
    required this.removeFromCart,
    required this.calculateTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Your Cart',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          cart.isEmpty
              ? const Text('Your cart is empty!')
              : Expanded(
                  child: ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return ListTile(
                        title: Text(item['title']),
                        subtitle: Text('\$${item['price']}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => removeFromCart(item),
                        ),
                      );
                    },
                  ),
                ),
          const SizedBox(height: 20),
          Text(
            'Total: \$${calculateTotal().toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
