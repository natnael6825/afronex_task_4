import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentPage extends StatefulWidget {
  final double amountFromCart;
  final List<Map<String, dynamic>> cart;

  const PaymentPage({
    Key? key,
    required this.amountFromCart,
    required this.cart,
  }) : super(key: key);

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController amountController;
  TextEditingController emailController = TextEditingController();
  TextEditingController cardnumbercontroller = TextEditingController();

  String publicKey = 'pk_test_4cadff7a902c5d4130c3e66029b482d39223679e';
  late final PaystackPlugin _plugin = PaystackPlugin();
  String message = '';

  late final User? _user = FirebaseAuth.instance.currentUser;

  bool _useSavedCard = false;
  late PaymentCard _selectedCard = PaymentCard(
    number: '',
    expiryMonth: 1,
    expiryYear: 24,
    cvc: '',
  );

  @override
  void initState() {
    super.initState();
    amountController =
        TextEditingController(text: widget.amountFromCart.toString());
    _initializePaystack();
    _loadCurrentUserEmail();
  }

  Future<void> _initializePaystack() async {
    await _plugin.initialize(publicKey: publicKey);
  }

  Future<void> _loadCurrentUserEmail() async {
    if (_user != null) {
      setState(() {
        emailController.text = _user!.email ?? '';
      });
    }
  }

  void makePayment() async {
    int price = (widget.amountFromCart * 100).toInt();
    Charge charge = Charge()
      ..amount = price
      ..reference = 'ref_${DateTime.now()}'
      ..email = emailController.text
      ..currency = 'NGN'
      ..card = _selectedCard;

    try {
      final response = await _plugin.checkout(
        context,
        method: CheckoutMethod.card,
        charge: charge,
      );
      setState(() {
        message = 'Payment was successful. Ref: ${response.reference}';
      });
      if (response.status == true) {
        _handlePaymentSuccess();
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        message = 'Payment failed: $e';
      });
    }
  }

  Future<void> _addCardAndMakePayment() async {
    if (_formKey.currentState!.validate()) {
      if (_useSavedCard) {
        makePayment();
      } else {
        final existingCards = await FirebaseFirestore.instance
            .collection('cards')
            .where('userId', isEqualTo: _user!.uid)
            .where('cardNumber', isEqualTo: cardnumbercontroller.text)
            .get();

        if (existingCards.docs.isEmpty) {
          String expiryDate =
              _selectedCard.expiryMonth.toString().padLeft(2, '0') +
                  '/' +
                  _selectedCard.expiryYear.toString();

          await FirebaseFirestore.instance.collection('cards').add({
            'userId': _user.uid,
            'cardNumber': cardnumbercontroller.text,
            'expireDate': expiryDate,
          });
        }

        makePayment();
      }
    }
  }

  Widget _buildSavedCardOption() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('cards')
          .where('userId', isEqualTo: _user!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError || snapshot.data == null) {
          return Text('Error fetching data');
        }
        final cardDocs = snapshot.data!.docs;
        if (cardDocs.isNotEmpty) {
          return Column(
            children: [
              Text('Select a Saved Card:'),
              ...cardDocs.map((doc) {
                final cardData = doc.data() as Map;
                if (cardData == null) return SizedBox();
                String cardNumber = cardData['cardNumber'];
                String expireDate = cardData['expireDate'];
                if (cardNumber == null || expireDate == null) return SizedBox();
                return ListTile(
                  title: Row(
                    children: [
                      Expanded(
                        child: Text('Card ending in ${cardNumber.substring(12)}'),
                      ),
                      IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _showDeleteConfirmationDialog(cardNumber);
                        },
                      ),
                    ],
                  ),
                  subtitle: Text('Expires: $expireDate'),
                  onTap: () {
                    _handleSavedCardSelection(cardNumber, expireDate);
                    makePayment(); // Make payment directly
                  },
                );
              }).toList(),
            ],
          );
        } else {
          return SizedBox();
        }
      },
    );
  }

  void _showDeleteConfirmationDialog(String cardNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Saved Card'),
        content: Text('Are you sure you want to delete this saved card?'),
        actions: [
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('cards')
                  .where('userId', isEqualTo: _user!.uid)
                  .where('cardNumber', isEqualTo: cardNumber)
                  .get()
                  .then((snapshot) {
                for (DocumentSnapshot doc in snapshot.docs) {
                  doc.reference.delete();
                }
              });
              Navigator.pop(context);
            },
            child: Text('Yes'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('No'),
          ),
        ],
      ),
    );
  }

 Future<void> _handlePaymentSuccess() async {
  try {
    // Save items to sold collection
    await FirebaseFirestore.instance.collection('sold').add({
      'userId': _user!.uid,
      'items': widget.cart,
      'timestamp': Timestamp.now(),
    });

    // Remove items from cart collection
    await FirebaseFirestore.instance
        .collection('cart')
        .where('userId', isEqualTo: _user!.uid)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.docs) {
        doc.reference.delete();
      }
    });

    // Save category ID and item ID to sold collection
    
    setState(() {
      message = 'Payment was successful. Cart items removed.';
    });
  } catch (e) {
    setState(() {
      message = 'Payment successful, but failed to remove cart items: $e';
    });
  }
}


  void _handleSavedCardSelection(String cardNumber, String expireDate) {
    setState(() {
      _useSavedCard = true;
      _selectedCard = PaymentCard(
        number: cardNumber,
        expiryMonth: int.parse(expireDate.split('/')[0]),
        expiryYear: int.parse(expireDate.split('/')[1]),
        cvc: '',
      );
    });
  }

  Widget _buildAddNewCardOption() {
    List<int> months = List.generate(12, (index) => index + 1);
    List<int> years = List.generate(12, (index) => index + 24);

    return Column(
      children: [
        ListTile(
          title: Text('Use New Card'),
          leading: Radio<bool>(
            value: false,
            groupValue: _useSavedCard,
            onChanged: (value) {
              setState(() {
                _useSavedCard = value ?? false;
              });
            },
          ),
        ),
        if (!_useSavedCard)
          Container(
            padding: EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: cardnumbercontroller,
                  decoration: InputDecoration(
                    labelText: 'Card Number',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter card number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelText: 'Expiry Month',
                        ),
                        value: _selectedCard.expiryMonth,
                        items: months.map((int month) {
                          return DropdownMenuItem<int>(
                            value: month,
                            child: Text('$month'),
                          );
                        }).toList(),
                        onChanged: (int? value) {
                          setState(() {
                            _selectedCard = PaymentCard(
                              number: cardnumbercontroller.text,
                              expiryMonth: value ?? 1,
                              expiryYear: _selectedCard.expiryYear,
                              cvc: '',
                            );
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 10.0),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelText: 'Expiry Year',
                        ),
                        value: _selectedCard.expiryYear,
                        items: years.map((int year) {
                          return DropdownMenuItem<int>(
                            value: year,
                            child: Text('$year'),
                          );
                        }).toList(),
                        onChanged: (int? value) {
                          setState(() {
                            _selectedCard = PaymentCard(
                              number: cardnumbercontroller.text,
                              expiryMonth: _selectedCard.expiryMonth,
                              expiryYear: value ?? 24,
                              cvc: '',
                            );
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'CVC',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter CVC';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _selectedCard = PaymentCard(
                        number: cardnumbercontroller.text,
                        expiryMonth: _selectedCard.expiryMonth,
                        expiryYear: _selectedCard.expiryYear,
                        cvc: value,
                      );
                    });
                  },
                ),
              ],
            ),
          ),
        SizedBox(height: 10.0),
        ElevatedButton(
          onPressed: () async {
            bool saveCard = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Save Card'),
                content: Text(
                  'Do you want to save this card for future use?',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                      _addCardAndMakePayment();
                    },
                    child: Text('Yes'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                      makePayment();
                    },
                    child: Text('No'),
                  ),
                ],
              ),
            );
          },
          child: Text('Pay'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                if (_user != null) ...[
                  _buildSavedCardOption(),
                  _buildAddNewCardOption(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
