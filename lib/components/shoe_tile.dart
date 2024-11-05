// import 'package:flutter/material.dart';
// import 'package:shoelab/models/shoe.dart';
//
// class ShoeTile extends StatelessWidget {
//   Shoe shoe;
//   void Function()? onTap;
//   void Function()? onShoePage;
//
//
//   ShoeTile({
//     super.key,
//     required this.shoe,
//     required this.onTap,
//     required this.onShoePage,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Stack(
//         children: [
//           //card
//           Padding(
//             padding: const EdgeInsets.all(25.0),
//             child: Container(
//               height: 400,
//               width: 250,
//
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(52),
//               ),
//
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       //name
//                       Padding(
//                         padding: const EdgeInsets.only(left: 15.0, top: 30),
//                         child: Text(
//                           shoe.name,
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 18),
//                         ),
//                       ),
//                       //des
//                       Padding(
//                         padding: const EdgeInsets.only(left: 15, right: 50),
//                         child: Text(
//                           shoe.description,
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 14),
//                         ),
//                       ),
//                       //background logo
//                       Padding(
//                         padding: const EdgeInsets.only(left: 15, right: 15),
//                         child: Text(
//                           shoe.name.toUpperCase(),
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 80,
//                               color: Colors.grey.shade200),
//                         ),
//                       ),
//                     ],
//                   ),
//
//                   //button
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.only(right: 15.0,bottom: 15),
//                         child: Text(
//                           'Rs.${shoe.price}',
//                           style: TextStyle(
//                             color: Colors.lightGreenAccent.shade700,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 25,
//                           ),
//                         ),
//                       ),
//                       // GestureDetector(
//                       //   onTap: onTap ,
//                       //   child: Container(
//                       //     padding: EdgeInsets.all(26),
//                       //     decoration: BoxDecoration(
//                       //       color: Colors.lightGreenAccent.shade100,
//                       //       borderRadius: BorderRadius.only(
//                       //         topLeft: Radius.circular(30),
//                       //         bottomRight: Radius.circular(52),
//                       //       ),
//                       //     ),
//                       //     child: Icon(Icons.add),
//                       //   ),
//                       // ),
//                     ],
//                   )
//                 ],
//               ),
//             ),
//           ),
//           //shoes image
//           Positioned(
//               top: 100,
//               right: 0,
//               child: GestureDetector(
//                 onTap: onShoePage,
//                 child: Image.asset(
//                   shoe.imagePath,
//                   width: 250,
//                 ),
//               )),
//         ],
//       ),
//     );
//   }
// }
