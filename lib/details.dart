import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DetailScreen extends StatefulWidget {
  final String category;
  final String documentId;

   DetailScreen({
    required this.category,
    required this.documentId,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection(
                '${widget.category}') // Use the category to construct the collection name
            .doc(widget.documentId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return Center(child: Text('No data found'));
          }

          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          String imageUrl = data['image_url'];
          String productName = data['name'];
          String description = data['description'];
          double productPrice = double.parse(data['price']);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              productName,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '\$$productPrice',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              description,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(
                                height:
                                    20), // Add spacing between description and button
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity, // Make the button width full
                  child:OutlinedButton(
  onPressed: () async {
    // Get current user ID
    final userdata = FirebaseAuth.instance.currentUser;
    if (userdata == null) {
      // Handle scenario where no user is signed in
      return;
    }
    final userId = userdata.uid;

    // Prepare data to be added to the cart
    Map<String, dynamic> cartData = {
      'userId': userId,
      'category': widget.category,
      'itemId': widget.documentId,
      // Add any additional data you want to store in the cart
    };

    try {
      // Add the cart item to the Firestore collection
      await FirebaseFirestore.instance.collection('cart').add(cartData);
      print('Item added to cart successfully!');
    } catch (error) {
      print('Failed to add item to cart: $error');
    }

    // Navigate back to the previous screen
    Navigator.pop(context);
    
  },
  child: Text('Add to Cart'),
  style: OutlinedButton.styleFrom(
    foregroundColor: Colors.red,
    side: BorderSide(
      color: const Color.fromARGB(255, 220, 177, 174),
      width: 2, // Border thickness
    ),
  ),
),

                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
