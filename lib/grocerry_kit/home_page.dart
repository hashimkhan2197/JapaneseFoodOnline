import 'package:flutter/material.dart';
import 'package:japfooduser/grocerry_kit/sub_pages/admin_settings_page.dart';
import 'package:japfooduser/grocerry_kit/sub_pages/cartPage.dart';
import 'package:japfooduser/grocerry_kit/sub_pages/category_all_pager.dart';
import 'package:japfooduser/grocerry_kit/sub_pages/order_history.dart';

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  static const routeName = "/storeHomepage";
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  //NavigationBarFunctions navigationBarFunctions = NavigationBarFunctions();
//  List<Widget> _widgetList ;
//  @override
//  void initState() {
//    _widgetList = [
//    HomeList(),
//    OrderHistory(),
//    FeedbackPage(),
//    CouponDeliveryPage(),];
//    super.initState();
//  }

final controller = PageController(
  initialPage: 0,keepPage: true
);
//  int _index = 0;


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      //appBar: _buildAppBar(),
      //bottomNavigationBar: _buildBottomNavigationBar(),
      body:PageView(controller: controller,
      children: <Widget>[CategoryPager(),CartPage(),
        OrderHistory(),
        CouponDeliveryPage()],),
    );
  }

//  Widget _buildBottomNavigationBar(){
//
//    return BottomNavigationBar(
//      selectedItemColor: Theme.of(context).primaryColor,
//      unselectedItemColor: Colors.black,
//      type: BottomNavigationBarType.shifting,
//      currentIndex: _index,
//      onTap: (index) {
//        setState(() {
//          _index = index;
//        });
//      },
//      items: [
//        BottomNavigationBarItem(
//            icon: Icon(
//              CartIcons.home,
//              color: Colors.black,
//            ),
//            title: Text('History', style: TextStyle())),
//        BottomNavigationBarItem(
//            icon: Icon(
//              Icons.history,
//            ),
//            title: Text('My Cart', style: TextStyle())),
//        BottomNavigationBarItem(
//            icon: Icon(
//              Icons.feedback,
//            ),
//            title: Text('Help', style: TextStyle())),
//        BottomNavigationBarItem(
//            icon: Icon(
//              CartIcons.account,
//            ),
//            title: Text(
//              'My Account',
//              style: TextStyle(),
//            ))
//      ],
//    );
//  }
}
