import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mona_coffee/core/utils/common.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: mDarkBrown,
            ),
            onPressed: () {
              context.goNamed('login');
            },
          ),
        ],
        title: const Text(
          ' My Profile',
          style: TextStyle(
            color: mDarkBrown,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            const Center(
              child: CircleAvatar(
                radius: 100,
                backgroundImage: NetworkImage(
                  'https://via.placeholder.com/150',
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Name',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: mDarkBrown,
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'Lorenzo',
                contentPadding: const EdgeInsets.all(0),
                filled: true,
                fillColor: Colors.transparent,
                hintStyle: TextStyle(
                  color: Colors.black.withOpacity(0.4),
                  fontSize: 14,
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromARGB(255, 58, 58, 58)),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: mBrown),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Email',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: mDarkBrown,
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: 'lorenzo123@gmail.com',
                contentPadding: const EdgeInsets.all(0),
                filled: true,
                fillColor: Colors.transparent,
                hintStyle: TextStyle(
                  color: Colors.black.withOpacity(0.4),
                  fontSize: 14,
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromARGB(255, 58, 58, 58)),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: mBrown),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Phone Number',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: mDarkBrown,
              ),
            ),
            TextField(
              decoration: InputDecoration(
                labelText: '0812434355',
                contentPadding: const EdgeInsets.all(0),
                filled: true,
                fillColor: Colors.transparent,
                hintStyle: TextStyle(
                  color: Colors.black.withOpacity(0.4),
                  fontSize: 14,
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromARGB(255, 58, 58, 58)),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: mBrown),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: SizedBox(
                width: 180,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // Add logic to save changes
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mBrown,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
