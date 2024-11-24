import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mona_coffee/features/blocs/favorite/favorite_event.dart';
import 'package:mona_coffee/features/blocs/favorite/favorite_state.dart';
import 'package:mona_coffee/features/repositories/favorite_repository.dart';
import 'package:mona_coffee/models/favorite_coffee.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  final FavoriteRepository _repository;

  FavoriteBloc({required FavoriteRepository repository})
      : _repository = repository,
        super(FavoriteInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<AddToFavorites>(_onAddToFavorites);
    on<RemoveFromFavorites>(_onRemoveFromFavorites);
    on<CheckFavoriteStatus>(_onCheckFavoriteStatus);
  }

  void _onLoadFavorites(LoadFavorites event, Emitter<FavoriteState> emit) {
    emit(FavoriteLoading());
    try {
      final favoritesStream = _repository.getFavorites();
      emit.forEach(
        favoritesStream,
        onData: (List<FavoriteCoffee> favorites) => FavoritesLoaded(favorites),
        onError: (error, stackTrace) => FavoriteError(error.toString()),
      );
    } catch (e) {
      emit(FavoriteError(e.toString()));
    }
  }

  Future<void> _onAddToFavorites(
    AddToFavorites event,
    Emitter<FavoriteState> emit,
  ) async {
    try {
      await _repository.addToFavorites(event.name, event.type, event.image);
      emit(const FavoriteStatus(true));
    } catch (e) {
      emit(FavoriteError(e.toString()));
    }
  }

  Future<void> _onRemoveFromFavorites(
    RemoveFromFavorites event,
    Emitter<FavoriteState> emit,
  ) async {
    try {
      await _repository.removeFromFavorites(event.documentId);
      emit(const FavoriteStatus(false));
    } catch (e) {
      emit(FavoriteError(e.toString()));
    }
  }

  Future<void> _onCheckFavoriteStatus(
    CheckFavoriteStatus event,
    Emitter<FavoriteState> emit,
  ) async {
    try {
      final isFavorite = await _repository.isFavorite(event.name, event.type);
      emit(FavoriteStatus(isFavorite));
    } catch (e) {
      emit(FavoriteError(e.toString()));
    }
  }
}
