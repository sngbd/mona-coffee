import 'package:mona_coffee/models/favorite_coffee.dart';

abstract class FavoriteState {
  const FavoriteState();
}

class FavoriteInitial extends FavoriteState {}

class FavoriteLoading extends FavoriteState {}

class FavoritesLoaded extends FavoriteState {
  final List<FavoriteCoffee> favorites;

  const FavoritesLoaded(this.favorites);
}

class FavoriteError extends FavoriteState {
  final String message;

  const FavoriteError(this.message);
}

class FavoriteStatus extends FavoriteState {
  final bool isFavorite;

  const FavoriteStatus(this.isFavorite);
}
