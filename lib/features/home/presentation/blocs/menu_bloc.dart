import 'package:equatable/equatable.dart';
import 'package:mona_coffee/features/home/data/entities/menu_item.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mona_coffee/features/home/data/repositories/menu_repository.dart';

abstract class MenuState extends Equatable {
  const MenuState();

  @override
  List<Object> get props => [];
}

class MenuInitial extends MenuState {}

class MenuLoading extends MenuState {}

class MenuLoaded extends MenuState {
  final List<MenuItem> items;

  const MenuLoaded(this.items);

  @override
  List<Object> get props => [items];
}

class MenuItemLoaded extends MenuState {
  final MenuItem item;

  const MenuItemLoaded(this.item);

  @override
  List<Object> get props => [item];
}

class MenuError extends MenuState {
  final String message;

  const MenuError(this.message);

  @override
  List<Object> get props => [message];
}

abstract class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object> get props => [];
}

class LoadMenuByCategory extends MenuEvent {
  final String category;

  const LoadMenuByCategory(this.category);

  @override
  List<Object> get props => [category];
}

class LoadMenuItem extends MenuEvent {
  final String id;

  const LoadMenuItem(this.id);

  @override
  List<Object> get props => [id];
}

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final MenuRepository _repository;

  MenuBloc(this._repository) : super(MenuInitial()) {
    on<LoadMenuByCategory>(_onLoadMenuByCategory);
    on<LoadMenuItem>(_onLoadMenuItem);
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

  Future<void> _onLoadMenuItem(
    LoadMenuItem event,
    Emitter<MenuState> emit,
  ) async {
    emit(MenuLoading());
    try {
      final item = await _repository.getMenuItem(event.id);
      emit(MenuItemLoaded(item));
    } catch (e) {
      emit(MenuError(e.toString()));
    }
  }
}
