import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mona_coffee/features/blocs/menu/menu_event.dart';
import 'package:mona_coffee/features/blocs/menu/menu_state.dart';
import 'package:mona_coffee/features/repositories/menu_repository.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final MenuRepository _repository;

  MenuBloc(this._repository) : super(MenuInitial()) {
    on<LoadMenuByCategory>(_onLoadMenuByCategory);
  }

  Future<void> _onLoadMenuByCategory(
    LoadMenuByCategory event,
    Emitter<MenuState> emit,
  ) async {
    emit(MenuLoading());
    try {
      final items = await _repository.getMenuItems(event.category);
      emit(MenuLoaded(items));
    } catch (e) {
      emit(MenuError(e.toString()));
    }
  }
}
