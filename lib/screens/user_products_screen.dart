import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/user_product_item.dart';

import '../providers/products.dart';
import 'edit_product_screen.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

  const UserProductsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
              onPressed: () {},
              icon: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.of(context).pushNamed(EditProductScreen.routeName);
                },
              ))
        ],
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: ListView.builder(
            itemBuilder: (_, i) => Column(
                  children: [
                    UserProductItem(
                        productsData.items[i].id,
                        productsData.items[i].title,
                        productsData.items[i].imageUrl),
                    Divider(),
                  ],
                ),
            itemCount: productsData.items.length),
      ),
    );
  }
}
