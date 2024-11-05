import 'package:flutter/material.dart';
import 'package:fyp/services/cart_service.dart';

class CartItems extends StatefulWidget {
  final Map<String, dynamic> cartItem;
  final void Function()? addQuantity;
  final void Function()? subQuantity;

  const CartItems({
  super.key,
  required this.cartItem,
  required this.addQuantity,
  required this.subQuantity,
});

  @override
  State<CartItems> createState() => _CartItemsState();
}

class _CartItemsState extends State<CartItems> {
  @override
  Widget build(BuildContext context) {
    int quantity = widget.cartItem['quantity'] ?? 1;
    String itemId = widget.cartItem['shoeId'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.lightGreenAccent.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      // margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 5),
        leading: Image.network(widget.cartItem['imagePath'] ?? ''),
        title: Text(widget.cartItem['shoeName'] ?? 'Shoe Name'),
        subtitle: Text('Rs. ${widget.cartItem['price'] ?? 'N/A'}'),
        trailing: Container(
          width: 70,
          height: 30,
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(60),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [

              // remove quantity
              GestureDetector(
                  onTap:widget.subQuantity,
                  child: Icon(
                    Icons.remove,
                    color: Colors.white,
                    size: 18,
                  )),

              // quantity value
              Text(
                '$quantity',
                style: const TextStyle(color: Colors.white,fontSize: 18,),
              ),

              //add quantity
              GestureDetector(
                  onTap: widget.addQuantity,
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 18,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
