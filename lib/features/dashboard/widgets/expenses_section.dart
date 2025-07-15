// import 'package:flutter/material.dart';
// // تأكد من أن هذا السطر موجود تماماً كما هو
// import 'package:treemap/treemap.dart';

// class ExpensesSection extends StatelessWidget {
//   const ExpensesSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // بيانات افتراضية مع قيم عددية للإنفاق
//     final expensesData = [
//       {'name': 'طعام', 'value': 85000.0, 'color': Colors.blue.shade300},
//       {'name': 'مواصلات', 'value': 40000.0, 'color': Colors.orange.shade300},
//       {'name': 'فواتير', 'value': 30000.0, 'color': Colors.purple.shade300},
//       {'name': 'ترفيه', 'value': 25000.0, 'color': Colors.teal.shade300},
//       {'name': 'تسوق', 'value': 55000.0, 'color': Colors.red.shade300},
//     ];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'خريطة النفقات',
//           style: TextStyle(
//               color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 16),
//         Card(
//           color: const Color(0xff161b22),
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           clipBehavior: Clip.antiAlias,
//           child: SizedBox(
//             height: 200,
//             width: double.infinity,
//             child: Treemap(
//               data: expensesData,
//               valueMapper: (item) => item['value'] as double,
//               builder: (context, item, isLeaf) {
//                 return Container(
//                   decoration: BoxDecoration(
//                     color: item['color'] as Color,
//                     border:
//                         Border.all(color: const Color(0xff0d1117), width: 2),
//                   ),
//                   child: Center(
//                     child: Padding(
//                       padding: const EdgeInsets.all(4.0),
//                       child: Text(
//                         item['name'] as String,
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14,
//                           shadows: [
//                             Shadow(
//                               blurRadius: 4.0,
//                               color: Colors.black54,
//                               offset: Offset(1.0, 1.0),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
