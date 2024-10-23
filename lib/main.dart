import 'package:flutter/material.dart';
import 'package:mona_coffee/pages/admin_login.dart';

void main() {
  runApp(const MonaCoffeeApp());
}

class MonaCoffeeApp extends StatelessWidget {
  const MonaCoffeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mona Coffee App',
      theme: ThemeData(
        fontFamily: 'Sora',
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor:
            const Color(0xFFF7D7C9), // Light pink background
      ),
      home: const AdminLogin(),
    );
  }
}

// class MonaCoffeeHomePage extends StatelessWidget {
//   const MonaCoffeeHomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Text(
//                 'Mona Coffee App',
//                 style: TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.brown[800],
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 'Your personal guide to\ndiscovering the perfect coffee.',
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: Colors.brown[600],
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 40),
//               ElevatedButton(
//                 onPressed: () {},
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.brown,
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30),
//                   ),
//                 ),
//                 child: const Text(
//                   'Order Now',
//                   style: TextStyle(fontSize: 18, color: Colors.white),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
