import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'details.dart'; 

class CategoryItemsPage extends StatelessWidget {
  final String categoryName;

  const CategoryItemsPage({Key? key, required this.categoryName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection(categoryName).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No items found'),
            );
          }

          return GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            padding: EdgeInsets.all(16),
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data = document.data() as Map<String, dynamic>;
              String imageUrl = data['image_url'];
              String productName = data['name'];
              String description = data['description'];
              double productPrice = double.parse(data['price']);

              return GestureDetector(
                onTap: () {
                  // Navigate to DetailScreen when item is tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(
                        category: categoryName,
                        documentId: document.id,
                      ),
                    ),
                  );
                },
                child: Card(
                  color: Colors.blue, // Customize card color as per your design
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product image loaded from Firebase Storage
                      Image.network(
                        imageUrl,
                        width: double.infinity,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: EdgeInsets.all(7),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product name
                            Text(
                              productName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            // Product price
                            Text(
                              '\$$productPrice',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                            // Product description
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
