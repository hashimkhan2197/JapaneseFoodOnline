import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:japfooduser/grocerry_kit/product_grid_view_page.dart';
import 'package:japfooduser/providers/category.dart';
import 'package:japfooduser/providers/collection_names.dart';
import 'package:provider/provider.dart';

import 'category_products_package/add_category.dart';

class CategoryGridView extends StatefulWidget {
  @override
  _CategoryGridViewState createState() => _CategoryGridViewState();
}

class _CategoryGridViewState extends State<CategoryGridView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

//      appBar: AppBar(
////        centerTitle: true,
//        brightness: Brightness.dark,
//        elevation: 0,
//        automaticallyImplyLeading: true,
//        backgroundColor: Theme.of(context).accentColor,
////        backgroundColor: Hexcolor('#0644e3'),
//
//        title: Text('All Categories',
//            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500)),
//        actions: <Widget>[
////          GestureDetector(
////              onTap: () {
////                Navigator.push(context, MaterialPageRoute(builder: (context) {
////                  return AddCategoryPage();
////                }));
////              },
////              child: Row(
////                children: <Widget>[
////                  Padding(
////                    padding: const EdgeInsets.only(right: 8.0),
////                    child: Text("Add Category",
////                        style: TextStyle(color: Colors.white)),
////                  )
////                ],
////              ))
//        ],
//      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 8,vertical: 20),
        child: categoryItems(),
      ),
    );
  }

  Widget categoryItems() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: StreamBuilder(
          stream: Firestore.instance
              .collection(category_collection)
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
            return GridView.builder(
                itemCount: snapShotData.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.65,
                ),
                itemBuilder: (context, index) {
                  var data = snapShotData[index];
                  var category = Provider.of<Category>(context)
                      .convertToCategoryModel(data);
                  return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return ProductGridView(
                                  category.categoryDocId,
                                  category.categoryName);
                            }));
                          },
                          child: CircleAvatar(
                            maxRadius: 85,
                            backgroundColor: Colors.grey[300],
                            backgroundImage:
                                NetworkImage(category.categoryImageRef),
                          ),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          category.categoryName,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: TextStyle(
                              fontSize: 20,
//                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor),
                        ),
//                          Container(
//                            alignment: Alignment.centerRight,
//                            child: GestureDetector(
//                              onTap: () {
//                                Navigator.push(context,
//                                    MaterialPageRoute(builder: (context) {
//                                  return UpdateCategoryPage(
//                                    categoryModel: category,
//                                  );
//                                }));
//                              },
//                              child: Icon(
//                                Icons.edit,
//                                size: 22,
//                              ),
//                            ),
//                          )
                      ]);
                });
          }),
    );
  }
}
