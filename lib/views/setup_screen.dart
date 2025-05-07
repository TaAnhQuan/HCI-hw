// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../controllers/record_controller.dart';
// import '../main.dart';
//
// class FinalSetupScreen extends StatelessWidget {
//   const FinalSetupScreen({super.key, this.controller});
//   final RecordScreenController? controller;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: const Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20.0),
//               child: Text(
//                 'Just a few simple steps to complete your setup.',
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//             )
//           ],
//         ),
//       ),
//       floatingActionButton: Align(
//         alignment: Alignment.bottomRight,
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: FloatingActionButton(
//             onPressed: () async {
//               final prefs = await SharedPreferences.getInstance();
//               await prefs.setBool("isFirstLaunch", false);
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (context) => MyHomePage(controller: controller,)),
//               );
//             },
//             shape: CircleBorder(),
//             backgroundColor: Color(0xFF2ABCC7),
//             child: Icon(
//               Icons.arrow_forward_ios,
//               color: Colors.white,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
