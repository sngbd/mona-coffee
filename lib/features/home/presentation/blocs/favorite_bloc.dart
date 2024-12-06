import 'package:mona_coffee/features/home/data/entities/favorite_coffee.dart';
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mona_coffee/features/home/data/repositories/favorite_repository.dart';

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

abstract class FavoriteEvent {
  const FavoriteEvent();
}

class LoadFavorites extends FavoriteEvent {}

class AddToFavorites extends FavoriteEvent {
  final String name;
  final String type;
  final String image;
  final String size;

  const AddToFavorites({
    required this.name,
    required this.type,
    required this.image,
    required this.size,
  });
}

class RemoveFromFavorites extends FavoriteEvent {
  final String documentId;

  const RemoveFromFavorites(this.documentId);
}

class CheckFavoriteStatus extends FavoriteEvent {
  final String name;
  final String type;
  final String size;

  const CheckFavoriteStatus({
    required this.name,
    required this.type,
    required this.size,
  });
}

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final FavoriteRepository _repository;
  StreamSubscription? _favoritesSubscription;

  FavoriteBloc({required FavoriteRepository repository})
      : _repository = repository,
        super(FavoriteInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<AddToFavorites>(_onAddToFavorites);
    on<RemoveFromFavorites>(_onRemoveFromFavorites);
    on<CheckFavoriteStatus>(_onCheckFavoriteStatus);
  }

  Future<void> _onLoadFavorites(
      LoadFavorites event, Emitter<FavoriteState> emit) async {
    try {
      emit(FavoriteLoading());

      // Cancel existing subscription
      await _favoritesSubscription?.cancel();

      // Get favorites as a single Future instead of Stream if possible
      final favorites = await _repository.getFavorites().first;
      favorites.map((f) async => await _repository.getFavoriteId(f.name, f.type, f.size));
      if (!isClosed) {
        emit(FavoritesLoaded(favorites));
      }
    } catch (e) {
      if (!isClosed) {
        emit(FavoriteError(e.toString()));
      }
    }
  }

  Future<void> _onAddToFavorites(
    AddToFavorites event,
    Emitter<FavoriteState> emit,
  ) async {
    try {
      await _repository.addToFavorites(event.name, event.type, event.size, event.image);
      if (!isClosed) {
        emit(const FavoriteStatus(true));
        // Load favorites directly instead of adding new event
        final favorites = await _repository.getFavorites().first;
        if (!isClosed) {
          emit(FavoritesLoaded(favorites));
        }
      }
    } catch (e) {
      if (!isClosed) {
        emit(FavoriteError(e.toString()));
      }
    }
  }

  Future<void> _onRemoveFromFavorites(
    RemoveFromFavorites event,
    Emitter<FavoriteState> emit,
  ) async {
    try {
      await _repository.removeFromFavorites(event.documentId);
      if (!isClosed) {
        emit(const FavoriteStatus(false));
        // Load favorites directly instead of adding new event
        final favorites = await _repository.getFavorites().first;
        if (!isClosed) {
          emit(FavoritesLoaded(favorites));
        }
      }
    } catch (e) {
      if (!isClosed) {
        emit(FavoriteError(e.toString()));
      }
    }
  }

  Future<void> _onCheckFavoriteStatus(
    CheckFavoriteStatus event,
    Emitter<FavoriteState> emit,
  ) async {
    try {
      final isFavorite = await _repository.isFavorite(event.name, event.type, event.size);
      if (!isClosed) {
        emit(FavoriteStatus(isFavorite));
      }
    } catch (e) {
      if (!isClosed) {
        emit(FavoriteError(e.toString()));
      }
    }
  }

  @override
  Future<void> close() async {
    await _favoritesSubscription?.cancel();
    return super.close();
  }
}
