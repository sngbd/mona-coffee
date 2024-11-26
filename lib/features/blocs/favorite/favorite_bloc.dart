import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mona_coffee/features/blocs/favorite/favorite_event.dart';
import 'package:mona_coffee/features/blocs/favorite/favorite_state.dart';
import 'package:mona_coffee/features/repositories/favorite_repository.dart';

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
      await _repository.addToFavorites(event.name, event.type, event.image);
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
      final isFavorite = await _repository.isFavorite(event.name, event.type);
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