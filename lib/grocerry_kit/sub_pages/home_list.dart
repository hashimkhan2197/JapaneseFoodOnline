import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:japfooduser/grocerry_kit/category_products_package/add_product.dart';
import 'package:japfooduser/grocerry_kit/sub_pages/cartPage.dart';
import 'package:japfooduser/providers/category.dart';
import 'package:japfooduser/providers/collection_names.dart';
import 'package:japfooduser/providers/product.dart';
import 'package:japfooduser/providers/user.dart';
import 'package:provider/provider.dart';

import '../category_grid_view_Page.dart';
import '../product_grid_view_page.dart';

class HomeList extends StatefulWidget {
  final String currentUserId;
  HomeList(this.currentUserId);
  @override
  _HomeListState createState() => _HomeListState();
}

class _HomeListState extends State<HomeList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
            margin: EdgeInsets.only(bottom: 40),
//              color: const Color(0xffF4F7FA),
            child: ListView(
              children: <Widget>[
//            _buildCategoryList(),
                _buildCategoryList2()
              ],
            ),
          ),
    );
  }

  Widget _buildCategoryList2() {
    //var items = addItems();
    return StreamBuilder(
        stream: Firestore.instance.collection(category_collection).snapshots(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator(),);
              break;
            default:
              return snapshot.data.documents.length == 0
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text("No categories added."),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: ClampingScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, index) {
                        var data = snapshot.data.documents[index];
                        var category = Provider.of<Category>(context)
                            .convertToCategoryModel(data);
                        return Column(
                          children: <Widget>[
                            SizedBox(
                              height: 16,
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
//                        decoration: BoxDecoration(
//                          color: Colors.grey.withOpacity(.5),
//                          border: Border.symmetric(vertical:BorderSide(color: Colors.grey,width: 1.5,))
//                        ),
                              padding: EdgeInsets.only(
                                  left: 16, top: 10, bottom: 10),
                              child: Text(
                                category.categoryName,
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            categoryItems(category.categoryDocId)
                          ],
                        );
                      },
                    );
          }
        });
  }

  Widget categoryItems(categoryDocid) {
    return Container(
      height: 400,
      margin: EdgeInsets.only(top: 8),
      //padding: const EdgeInsets.symmetric(horizontal: 20),
      child: StreamBuilder(
          stream: Firestore.instance
              .collection(category_collection)
              .document(categoryDocid)
              .collection(products_collection)
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
                child: Text("No products added"),
              );
            }
            return ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: snapShotData.length,
                itemBuilder: (context, index) {
                  var data = snapshot.data.documents[index];
                  ProductModel product =
                      Provider.of<Product>(context).convertToProductModel(data);
                  return buildItem(
                      product.productName,
                      product.productDescription,
                      product.productImageRef,
                      product.productPrice);
                });
          }),
    );
  }

  Container buildItem(
      String title, String description, String url, String productPrice) {
    print(MediaQuery.of(context).size.width * 0.65);
    return Container(
      width: 295,
      margin: EdgeInsets.symmetric(vertical: 12.0, horizontal: 12),
//      padding: EdgeInsets.only(left: 22),
      child: Column(
        children: <Widget>[
          Container(
            width: 275,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              border: Border.all(color: Colors.grey),
                image: DecorationImage(
                  image: NetworkImage(url),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0),
                ),
              ),
          ),
          Container(
              width: 275,
              height: 175,
              padding: EdgeInsets.all(25.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10.0),
                      bottomRight: Radius.circular(10.0)),
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 2.0, spreadRadius: 1.0, color: Colors.grey)
                  ]),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      softWrap: true,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).primaryColor),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      description,
                      maxLines: 2,
                      softWrap: true,
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(
                      height: 17,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          "£" + productPrice,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context).primaryColor),
                        ),
                        GestureDetector(
                          onTap: () async{
                            double price = double.parse(productPrice);
                            QuerySnapshot cartdocs = await Firestore.instance.collection(users_collection)
                            .document(widget.currentUserId).collection('cart')
                            .where('name',isEqualTo: title)
                            .getDocuments();
                            if(cartdocs.documents.length>0){
                              Firestore.instance
                                  .collection(users_collection)
                                  .document(widget.currentUserId)
                                  .collection('cart').document(cartdocs.documents[0].documentID)
                                  .updateData({
                                'quantity': cartdocs.documents[0]['quantity']+1
                              }).then((value) {
                                Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                    "Item added to cart",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  backgroundColor: Theme.of(context).accentColor,
                                  duration: Duration(milliseconds: 1000),
                                ));
                              }).catchError((e) {
                                Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                    "Error. Please Check your internet connection.",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  backgroundColor: Theme.of(context).errorColor,
                                  duration: Duration(milliseconds: 1000),
                                ));
                              });
                            }
                            else{
                              Firestore.instance
                                  .collection(users_collection)
                                  .document(widget.currentUserId)
                                  .collection('cart')
                                  .add({
                                'price': price,
                                'image': url,
                                'name': title,
                                'quantity': 1,
                                'subtotal': price
                              }).then((value) {
                                Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                    "Item added to cart",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  backgroundColor: Theme.of(context).accentColor,
                                  duration: Duration(milliseconds: 1000),
                                ));
                              }).catchError((e) {
                                Scaffold.of(context).showSnackBar(SnackBar(
                                  content: Text(
                                    "Error. Please Check your internet connection.",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  backgroundColor: Theme.of(context).errorColor,
                                  duration: Duration(milliseconds: 1000),
                                ));
                              });
                            }


                          },
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Theme.of(context).accentColor,
                                  borderRadius: BorderRadius.circular(8)),
//                                      RoundedRectangleBorder(
//                                          borderRadius: BorderRadius.circular(30.0)),
                              alignment: Alignment.center,
                              height: 32,
                              width: 65,
                              child: Text(
                                'BUY',
                                style: TextStyle(
                                    letterSpacing: 1.1,
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400),
                              )),
                        )
                      ],
                    )
                  ])),
        ],
      ),
    );
  }
}

class PriceContainer extends StatefulWidget {
  PriceContainer(this.product, this.userDocId);

  final ProductModel product;
  final String userDocId;

  @override
  _PriceContainerState createState() => _PriceContainerState();
}

class _PriceContainerState extends State<PriceContainer> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 130,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                " " + widget.product.productPrice + " SEK",
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 130,
          child: Row(
            //mainAxisSize: MainAxisSize.,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              IconButton(
                onPressed: () {
                  setState(() {
                    _quantity -= 1;
                  });
                },
                icon: Icon(
                  Icons.remove,
                  color: Colors.red,
                  size: 30,
                ),
              ),
              Text(
                _quantity.toString(),
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black45,
                  fontWeight: FontWeight.bold,
                ),
                softWrap: true,
              ),
              IconButton(
                //alignment: Alignment.center,

                onPressed: () {
                  setState(() {
                    _quantity += 1;
                  });
                },
                icon: Icon(
                  Icons.add,
                  color: Theme.of(context).primaryColor,
                  size: 30,
                ),
              )
            ],
          ),
        ),
        Container(
            width: 130,
            child: GestureDetector(
              onTap: () {
                double price = double.parse(widget.product.productPrice);
                Firestore.instance
                    .collection(users_collection)
                    .document(widget.userDocId)
                    .collection('cart')
                    .add({
                  'price': price,
                  'image': widget.product.productImageRef,
                  'name': widget.product.productName,
                  'quantity': _quantity,
                  'subtotal': _quantity * price
                }).then((value) {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text(
                      "Item added to cart",
                      style: TextStyle(fontSize: 18),
                    ),
                    backgroundColor: Hexcolor('#0644e3'),
                    duration: Duration(milliseconds: 1000),
                  ));
                }).catchError((e) {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text(
                      "Error. Please Check your internet connection.",
                      style: TextStyle(fontSize: 18),
                    ),
                    backgroundColor: Theme.of(context).errorColor,
                    duration: Duration(milliseconds: 1000),
                  ));
                });
              },
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 5),
                padding: EdgeInsets.only(top: 4, bottom: 4, left: 5, right: 5),
                //color: Theme.of(context).primaryColor,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Buy",
                  style: TextStyle(
                    fontSize: 19,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ))
      ],
    );
  }
}
