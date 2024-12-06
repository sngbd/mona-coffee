import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mona_coffee/core/utils/common.dart';
import 'package:mona_coffee/core/utils/helper.dart';
import 'package:mona_coffee/core/widgets/flasher.dart';
import 'package:mona_coffee/features/accounts/presentations/pages/item_detail_screen.dart';
import 'package:mona_coffee/features/home/data/entities/favorite_coffee.dart';
import 'package:mona_coffee/features/home/data/entities/menu_option.dart';
import 'package:mona_coffee/features/home/presentation/blocs/favorite_bloc.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with WidgetsBindingObserver {
  late FavoriteBloc _favoriteBloc;

  @override
  void initState() {
    super.initState();
    _favoriteBloc = context.read<FavoriteBloc>();
    WidgetsBinding.instance.addObserver(this);
    _loadFavorites();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadFavorites();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentRoute = ModalRoute.of(context);
    if (currentRoute != null && currentRoute.isCurrent) {
      _loadFavorites();
    }
  }

  void _loadFavorites() {
    _favoriteBloc.add(LoadFavorites());
  }

  Future<void> _onRefresh() async {
    _loadFavorites();
    await Future.delayed(const Duration(seconds: 1));
  }

  Widget _buildContent(BuildContext context, FavoriteState state) {
    if (state is FavoriteLoading) {
      return const Center(
          child: CircularProgressIndicator(
        color: mDarkBrown,
      ));
    }

    if (state is FavoriteError) {
      return Center(child: Text('Error: ${state.message}'));
    }

    if (state is FavoritesLoaded) {
      final favorites = state.favorites;

      if (favorites.isEmpty) {
        return const Center(
          child: Text(
            'No favorites yet',
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: _onRefresh,
        color: mDarkBrown,
        backgroundColor: Colors.white,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: favorites.length,
          itemBuilder: (context, index) => _buildFavoriteItem(
            context,
            favorites[index],
          ),
        ),
      );
    }

    return const Center(child: Text('Loading favorites...'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Favorite',
          style: TextStyle(
            color: mDarkBrown,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<FavoriteBloc, FavoriteState>(
        listener: (context, state) {
          if (state is FavoriteError &&
              state.message.contains('User not logged in')) {
            Flasher.showSnackBar(
              context,
              'Error',
              'Please log in to access favorites',
              Icons.error_outline,
              Colors.red,
            );
          }
        },
        builder: (context, state) => _buildContent(context, state),
      ),
    );
  }

  Widget _buildFavoriteItem(BuildContext context, FavoriteCoffee coffee) {
    MenuOption menuOption = MenuOption(type: coffee.type, size: coffee.size);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ItemDetailScreen(item: coffee.item, option: menuOption),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.network(
                  coffee.image,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[300],
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: mDarkBrown,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Helper().toTitleCase(coffee.name),
                      style: const TextStyle(
                        color: mBrown,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      coffee.type,
                      style: const TextStyle(color: mBrown),
                    ),
                    Text(
                      coffee.size,
                      style: const TextStyle(color: mBrown),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.brown),
                onPressed: () => context.read<FavoriteBloc>().add(
                      RemoveFromFavorites(coffee.id),
                    ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
