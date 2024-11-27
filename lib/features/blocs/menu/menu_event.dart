import 'package:equatable/equatable.dart';

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
