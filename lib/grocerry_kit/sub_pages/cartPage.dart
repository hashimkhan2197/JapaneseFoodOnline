import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:japfooduser/grocerry_kit/sub_pages/loyalty.dart';
import 'package:japfooduser/providers/collection_names.dart';
import 'package:japfooduser/providers/user.dart';
import 'package:japfooduser/widgets/custom_image_picker.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';

import '../../style_functions.dart';
import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  StyleFunctions formFieldStyle = StyleFunctions();
  TextEditingController _couponCodeController = TextEditingController();
  TextEditingController _extraStuffController = TextEditingController();
  bool promoCodeChecker = true;
  double _discountPercentage = 0;
  double _discount = 0;
  double _deliveryCharges = 0;
  double _subtotal = 0;
  double _total = 0;
  Color _cartItemColor = Colors.white70;

  @override
  void dispose() {
    _couponCodeController.dispose();
    _extraStuffController.dispose();
    super.dispose();
  }

  bool _prefloading = false;
  String currentUserId;

  @override
  void initState() {
    Future.delayed(Duration.zero).then((_) async {
      setState(() {
        _prefloading = true;
      });
      FirebaseUser authResult = await FirebaseAuth.instance.currentUser();
      setState(() {
        currentUserId = authResult.uid;
        _prefloading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
//        centerTitle: true,
          brightness: Brightness.dark,
          elevation: 0,
          automaticallyImplyLeading: true,
          backgroundColor: Theme.of(context).buttonColor,
//        backgroundColor: Hexcolor('#0644e3'),

          title: Text('\tReview Basket',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w500)),
          actions: <Widget>[
//          GestureDetector(
//              onTap: () {
//                Navigator.push(context, MaterialPageRoute(builder: (context) {
//                  return AddCategoryPage();
//                }));
//              },
//              child: Row(
//                children: <Widget>[
//                  Padding(
//                    padding: const EdgeInsets.only(right: 8.0),
//                    child: Text("Add Category",
//                        style: TextStyle(color: Colors.white)),
//                  )
//                ],
//              ))
          ],
        ),
        backgroundColor: Colors.white,
        body: _prefloading == true
            ? Center(child: CircularProgressIndicator())
            : StreamBuilder(
                stream: Firestore.instance
                    .collection(users_collection)
                    .document(currentUserId)
                    .collection('cart')
                    .snapshots(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final snapShotData = snapshot.data.documents;
                  if (snapShotData.length == 0) {
                    return Center(
                      child: Text("Cart is empty.",
                          style: TextStyle(
                              color: Colors.deepOrange, fontSize: 30)),
                    );
                  }
                  if (snapShotData.length > 0) {
                    _subtotal = 0;
                    snapShotData.forEach((element) {
                      _subtotal +=
                          element.data['price'] * element.data['quantity'];
                    });

                    if (_subtotal < 0.001) {
                      _deliveryCharges = 0;
                    } else if (_subtotal < 12) {
                      _deliveryCharges = 2;
                    } else{
                      _deliveryCharges = 0;
                    }

                    _total =
                        _subtotal - (_subtotal * _discountPercentage * 0.01);
                    _discount = _subtotal - _total;
                    _total = _total + _deliveryCharges;
                  }
                  return SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),

//                    ///List of Products
//                    Container(
//                      alignment: Alignment.centerLeft,
//                      padding: EdgeInsets.only(left: 16, top: 4),
//                      child: Text(
//                        "Cart Products",
//                        style: TextStyle(
//                          fontSize: 22,
//                          fontWeight: FontWeight.bold,
//                        ),
//                      ),
//                    ),
                        Container(
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
//                          border: Border.all(color: Colors.grey, width: 2),
//                          borderRadius: BorderRadius.circular(8),
                              color: Colors.white70),
                          height: MediaQuery.of(context).size.height * .55,
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8),
                          child: ListView.separated(
                            separatorBuilder: (context, index) {
                              return Divider(
                                color: Colors.grey,
                                thickness: 1.0,
                              );
                            },
                            shrinkWrap: true,
                            itemCount: snapShotData.length,
                            itemBuilder: (context, index) {
                              return _listItem(snapShotData[index]);
                            },
                          ),
                        ),

                        Divider(
                          color: Colors.black87,
                          thickness: 1.5,
                        ),

                        Container(
                            margin: EdgeInsets.only(
                                left: 20, right: 20, top: 4, bottom: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  "Delivery Charges",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  "£" + _deliveryCharges.toStringAsFixed(2),
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).primaryColor),
                                ),
                              ],
                            )),

                        SizedBox(height: 6,),
                        Container(
                            margin: EdgeInsets.only(
                                left: 20, right: 20, top: 4, bottom: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  "Total",
                                  style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  "£" + _total.toStringAsFixed(2),
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Theme.of(context).primaryColor),
                                ),
                              ],
                            )),

                        SizedBox(height: 6,),
                        Container(
                          margin: EdgeInsets.only(
                              left: 20, right: 20, top: 4, bottom: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "Promo Code",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.grey
                                ),
                              ),
                              Container(
                                color: Colors.white,
                                height: 50,
                                width: MediaQuery.of(context).size.width * .4,
//                      padding: EdgeInsets.only(
//                          left: 16, right: 16, top: 8, bottom: 8),
                                child: TextField(
                                  controller: _couponCodeController,
                                  keyboardType: TextInputType.text,
                                  style: TextStyle(fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: 'Enter Code',
                                    hintStyle: TextStyle(color: Colors.grey,fontSize: 18,),

                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide:
                                            BorderSide(color: Colors.grey)),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide:
                                            BorderSide(color: Colors.grey)),
                                  ),
                                ),
                              ),
                              FlatButton(
                                onPressed: () {
                                  if (_couponCodeController.text
                                      .trim()
                                      .isNotEmpty) {
                                    Firestore.instance
                                        .collection(discount_coupons_collection)
                                        .where('promoCode',
                                            isEqualTo: _couponCodeController
                                                .text
                                                .trim())
                                        .getDocuments()
                                        .then((value) {
                                      if (value.documents.length > 0) {
                                        setState(() {
                                          _discountPercentage = double.parse(
                                              value.documents[0]
                                                  .data['discPercentage']);
                                          promoCodeChecker = true;
                                          _couponCodeController.clear();
                                        });
                                      } else {
                                        setState(() {
                                          promoCodeChecker = false;
                                          _couponCodeController.clear();
                                        });
                                      }
                                    });
                                  }
                                },
                                child: Text(
                                  "ADD",
                                  style: TextStyle(color: Theme.of(context).accentColor,fontSize: 20),
                                ),
                              )
                            ],
                          ),
                        ),

                        SizedBox(
                          height: 8,
                        ),
                        if (promoCodeChecker == false)
                          Text(
                            "No such promo code available",
                            style: TextStyle(color: Colors.red),
                          ),
                        if(promoCodeChecker == false)
                        SizedBox(
                          height: 6,
                        ),

                        Divider(
                          color: Colors.grey,
                          thickness: 1,
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              left: 20, right: 20, ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                "Loyalty Order points",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey
                                ),
                              ),

                              FlatButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context){
                                    return Loyalty();
                                  }));
                                },
                                child: Text(
                                  "VIEW",
                                  style: TextStyle(color: Theme.of(context).accentColor,fontSize: 18,fontWeight: FontWeight.w400),
                                ),
                              )
                            ],
                          ),
                        ),

//                        Divider(
//                          color: Colors.black87,
//                          thickness: 1.5,
//                        ),


                        Container(
                          margin: EdgeInsets.only(top: 16, bottom: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).accentColor,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          width: 250,
                          child: FlatButton(
                            child: Row(
                              children: <Widget>[
                                Text('Proceed To Checkout',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white)),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: 20,
                                )
                              ],
                            ),
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return CheckoutPage(
                                  deliveryCharges: _deliveryCharges,
                                  discountPercentage: _discount,
                                  subtotal: _subtotal,
                                  total: _total,
                                );
                              }));
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),
      ),
    );
  }

  ///An item in Cart
  Widget _listItem(DocumentSnapshot item) {
    UserModel userProfile =
        Provider.of<User>(context, listen: false).userProfile;
    var cartItem = item.data;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8),
          color: Colors.white70),
      height: 120,
      child: Row(children: <Widget>[
        Container(
          alignment: Alignment.centerLeft,
          width: 100,
          height: 100,
          //margin: EdgeInsets.only(left: 5),
          child: CircleAvatar(
            maxRadius: 50,
            backgroundColor: Colors.grey[300],
            backgroundImage: NetworkImage(cartItem['image']),
          ),
        ),
        SizedBox(
          width: 18,
        ),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                cartItem['name'],
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                children: <Widget>[
                  Text(
                    "Quantity: ",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    '1 x ' + cartItem['quantity'].toString(),
                    style: TextStyle(
                      fontSize: 19,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    softWrap: true,
                  )
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "£" +
                          (cartItem['price'] * cartItem['quantity']).toString(),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).primaryColor),
                    ),
                  ),
                  Container(
//                    width: 122,
//                  height: 40,
//                    decoration: BoxDecoration(border: Border.all(color: Colors.black54,width: 1),
//                    borderRadius: BorderRadius.circular(8)
//                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        IconButton(
//                          splashColor: Colors.red,
                          alignment: Alignment.centerLeft,
                          onPressed: () {
                            //cartItem['quantity']+=1;

                            if (cartItem['quantity'] > 1) {
                              Firestore.instance
                                  .collection(users_collection)
                                  .document(currentUserId)
                                  .collection('cart')
                                  .document(item.documentID)
                                  .updateData(
                                      {'quantity': cartItem['quantity'] - 1});
                            } else {
                              Firestore.instance
                                  .collection(users_collection)
                                  .document(currentUserId)
                                  .collection('cart')
                                  .document(item.documentID)
                                  .delete();
                            }
                          },
                          icon: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.5),
                                border:
                                    Border.all(color: Colors.black54, width: 1),
                                borderRadius: BorderRadius.circular(4)),
                            child: Icon(
                              Icons.remove,
                              color: Colors.black,
                              size: 25,
                            ),
                          ),
                        ),
                        Text(
                          cartItem['quantity'].toString(),
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black45,
                            fontWeight: FontWeight.bold,
                          ),
                          softWrap: true,
                        ),
                        IconButton(
//                          splashColor: Colors.green,
                          alignment: Alignment.centerRight,

                          onPressed: () {
                            Firestore.instance
                                .collection(users_collection)
                                .document(currentUserId)
                                .collection('cart')
                                .document(item.documentID)
                                .updateData(
                                    {'quantity': cartItem['quantity'] + 1});
                          },
                          icon: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.5),
                                border:
                                    Border.all(color: Colors.black54, width: 1),
                                borderRadius: BorderRadius.circular(4)),
                            child: Icon(
                              Icons.add,
                              color: Colors.black,
                              size: 25,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
//                  GestureDetector(
//                  onTap: (){
//                  Firestore.instance.collection(users_collection).document(currentUserId)
//                      .collection('cart').document(item.documentID)
//                      .delete();
//                  },
//                    child: Container(
//                        decoration: BoxDecoration(
//                            color: Theme.of(context).accentColor,
//                            borderRadius: BorderRadius.circular(8)
//                        ),
////                                      RoundedRectangleBorder(
////                                          borderRadius: BorderRadius.circular(30.0)),
//                        alignment: Alignment.center,
//                        height: 32,
//                        width: 65,
//                        child: Text(
//                          'DEL',
//
//                          style: TextStyle(letterSpacing: 1.1,
//                              fontSize: 18,
//                              color:
//                              Colors.white,fontWeight: FontWeight.w400),
//                        )),
//                  )
                ],
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
