import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mona_coffee/core/utils/common.dart';
import 'package:mona_coffee/core/utils/helper.dart';
import 'package:mona_coffee/features/admin/presentations/pages/admin_item_detail.dart';
import 'package:mona_coffee/features/admin/presentations/pages/admin_orders_screen.dart';
import 'package:mona_coffee/features/admin/presentations/pages/admin_profile_screen.dart';
import 'package:mona_coffee/features/authentications/presentation/blocs/profile_bloc.dart';
import 'package:mona_coffee/features/home/data/entities/menu_item.dart';
import 'package:mona_coffee/features/home/data/repositories/menu_repository.dart';
import 'package:mona_coffee/features/home/presentation/blocs/menu_bloc.dart';
import 'package:mona_coffee/models/categories_model.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AdminHomeContent(),
    const AdminOrdersScreen(),
    const AdminProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Colors.transparent,
          elevation: 2,
          labelTextStyle: WidgetStateProperty.resolveWith(
            (states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  color: mBrown,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                );
              }
              return const TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              );
            },
          ),
          iconTheme: WidgetStateProperty.resolveWith(
            (states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(color: mBrown);
              }
              return const IconThemeData(color: Colors.grey);
            },
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          backgroundColor: Colors.white,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.coffee),
              label: 'Menu',
            ),
            NavigationDestination(
              icon: Icon(Icons.task),
              label: 'Orders',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_circle),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class AdminHomeContent extends StatefulWidget {
  const AdminHomeContent({super.key});

  @override
  State<AdminHomeContent> createState() => _AdminHomeContentState();
}

class _AdminHomeContentState extends State<AdminHomeContent> {
  late final MenuBloc _menuBloc;
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    _menuBloc = MenuBloc(MenuRepository());
    // Load initial category (Popular)
    _menuBloc.add(const LoadMenuByCategory('Popular'));
  }

  @override
  void dispose() {
    _menuBloc.close();
    super.dispose();
  }

  void _onCategoryTapped(int index) {
    setState(() {
      _selectedCategoryIndex = index;
    });
    _menuBloc.add(LoadMenuByCategory(categories[index]));
  }

  void _onSearchChanged(String query) {
    _menuBloc.add(SearchMenuItems(query));
  }

  @override
  Widget build(BuildContext context) {
    final String? name = context.read<ProfileBloc>().state.name;
    return BlocProvider(
      create: (context) => _menuBloc,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              Text(
                name == null
                    ? Helper().getGreeting()
                    : '${Helper().getGreeting()}, $name',
                style: const TextStyle(
                    color: mDarkBrown,
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 36),
              _buildSearchBar(),
              const SizedBox(height: 50),
              const Text(
                'Categories',
                style: TextStyle(
                  color: mBrown,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              _buildCategoryList(),
              const SizedBox(height: 10),
              _buildMenuGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      onChanged: _onSearchChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: 'Search coffee',
        hintStyle: TextStyle(
          color: Colors.black.withOpacity(0.4),
          fontSize: 14,
        ),
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    return SizedBox(
      height: 36,
      width: double.infinity,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 15),
        itemBuilder: (context, index) {
          bool isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () => _onCategoryTapped(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? mBrown : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                categories[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : mBrown,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem(MenuItem menuItem) {
    return GestureDetector(
      onTap: () {
        
      },
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 4,
        shadowColor: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: SizedBox(
                    height: 80,
                    child: Image.network(
                      menuItem.hotImage,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(child: Icon(Icons.error));
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                toTitleCase(menuItem.name),
                style: const TextStyle(
                  color: mBrown,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                menuItem.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: mBrown,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'From Rp ${menuItem.smallPrice.toString()}',
                style: const TextStyle(
                  color: mBrown,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  // New GestureDetector for the chevron
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminItemDetail(menuItem: menuItem),
                      ),
                    );
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: mBrown,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String toTitleCase(String text) {
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Widget _buildMenuGrid() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('menu').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: mDarkBrown),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No menu items found'),
            );
          }

          // Convert Firestore data to MenuItem list
          final menuItems = snapshot.data!.docs.map((doc) {
            return MenuItem(
              name: doc['name'] ?? '',
              description: doc['description'] ?? '',
              smallPrice: doc['smallPrice'] ?? 0,
              mediumPrice: doc['mediumPrice'] ?? 0,
              largePrice: doc['largePrice'] ?? 0,
              stock: doc['stock'] ?? 0,
              hotImage: doc['hotImage'] ?? '',
              iceImage: doc['iceImage'] ?? '',
              rating: (doc['rating'] ?? 0).toDouble(),
              ratingCount: doc['ratingCount'] ?? 0,
              category: doc['category'] ?? '',
            );
          }).toList();

          // Filter items by selected category
          final filteredItems = menuItems
              .where((item) =>
                  _selectedCategoryIndex == 0 ||
                  item.category.toLowerCase() ==
                      categories[_selectedCategoryIndex].toLowerCase())
              .toList();

          return GridView.builder(
            itemCount: filteredItems.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (context, index) {
              final menuItem = filteredItems[index];
              return _buildMenuItem(menuItem);
            },
          );
        },
      ),
    );
  }
}
