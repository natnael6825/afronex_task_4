import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'checkout.dart';

class Cards extends StatefulWidget {
  const Cards({Key? key});

  @override
  _CardsState createState() => _CardsState();
}

class _CardsState extends State<Cards> {
  double totalPrice = 0;
  List<Map<String, dynamic>> cartList = [];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle scenario where no user is signed in
      return Material(
        child: Center(
          child: Text('No user signed in.'),
        ),
      );
    }

    return Material(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cart')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final data = snapshot.data;
          if (data == null || data.docs.isEmpty) {
            return Center(
              child: Text('No items in cart.'),
            );
          }

          // Reset totalPrice and cartList before updating
          totalPrice = 0;
          cartList.clear();

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: data.docs.length,
                  itemBuilder: (context, index) {
                    final cartItem = data.docs[index];
                    final category = cartItem['category'];
                    final itemId = cartItem['itemId'];
                    final itemNameFuture = FirebaseFirestore.instance
                        .collection(category)
                        .doc(itemId)
                        .get()
                        .then((value) => value['name']);
                    final itemPriceFuture = FirebaseFirestore.instance
                        .collection(category)
                        .doc(itemId)
                        .get()
                        .then((value) => value['price']);

                    return FutureBuilder(
                      future: Future.wait([itemNameFuture, itemPriceFuture]),
                      builder:
                          (context, AsyncSnapshot<List<dynamic>> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }

                        final itemName = snapshot.data?[0];
                        final itemPrice =
                            double.tryParse(snapshot.data![1].toString()) ??
                                0.0;

                        // Update totalPrice and cartList
                        totalPrice += itemPrice;
                        cartList.add({
                          'name': itemName ?? 'Unknown',
                          'price': itemPrice,
                          'category': category, // Add category
                          'itemId': itemId, // Add item ID
                        });

                        return Card(
                          child: ListTile(
                            title: Text(itemName ?? 'Unknown'),
                            subtitle: Text('\$$itemPrice'),
                            trailing: IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                // Remove item from cart collection
                                FirebaseFirestore.instance
                                    .collection('cart')
                                    .doc(cartItem.id)
                                    .delete();

                                // Update totalPrice and cartList when an item is deleted
                                setState(() {
                                  totalPrice -= itemPrice;
                                  cartList.removeWhere((item) =>
                                      item['name'] == itemName &&
                                      item['price'] == itemPrice);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Show dialog box for checkout
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Checkout'),
                          content: Text(
                              'Do you want to pay \$${totalPrice.toStringAsFixed(2)} for these items?'),
                          actions: [
                            TextButton(
                              onPressed: () {
Navigator.pop(context);

                                // Navigate to PaymentPage with total price, cartList, category, and item ID
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaymentPage(
                                      amountFromCart: totalPrice,
                                      cart: cartList,
                                    ),
                                  ),
                                );
                              },
                              child: Text('Pay'),
                            ),
                            TextButton(
                              onPressed: () {
                                // Add logic for when user cancels payment
                                Navigator.pop(context); // Close dialog
                              },
                              child: Text('Cancel'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('Proceed to Checkout'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
