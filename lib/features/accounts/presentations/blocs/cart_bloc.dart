import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mona_coffee/features/accounts/data/entities/cart_item.dart';
import 'package:mona_coffee/features/accounts/data/entities/cart_item_repo.dart';
import 'package:mona_coffee/features/accounts/data/repositories/cart_repository.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class AddToCart extends CartEvent {
  final CartItemRepo item;

  const AddToCart(this.item);

  @override
  List<Object> get props => [item];
}

class RemoveFromCart extends CartEvent {
  final String id;

  const RemoveFromCart(this.id);

  @override
  List<Object> get props => [id];
}

class LoadCart extends CartEvent {}

class ClearCart extends CartEvent {}

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItem> items;

  const CartLoaded(this.items);

  @override
  List<Object> get props => [items];
}

class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object> get props => [message];
}

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository _cartRepository;

  CartBloc(this._cartRepository) : super(CartInitial()) {
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<ClearCart>(_onClearCart);
    on<LoadCart>(_onLoadCart);
  }

  Future<void> _onAddToCart(AddToCart event, Emitter<CartState> emit) async {
    try {
      emit(CartLoading());
      await _cartRepository.addToCart(event.item);
      final cartItems = await _cartRepository.getCartItems();
      emit(CartLoaded(cartItems));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onRemoveFromCart(
      RemoveFromCart event, Emitter<CartState> emit) async {
    try {
      emit(CartLoading());
      await _cartRepository.removeFromCart(event.id);
      final cartItems = await _cartRepository.getCartItems();
      emit(CartLoaded(cartItems));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onClearCart(ClearCart event, Emitter<CartState> emit) async {
    try {
      emit(CartLoading());
      await _cartRepository.clearCart();
      final cartItems = await _cartRepository.getCartItems();
      emit(CartLoaded(cartItems));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onLoadCart(LoadCart event, Emitter<CartState> emit) async {
    try {
      emit(CartLoading());
      final cartItems = await _cartRepository.getCartItems();
      emit(CartLoaded(cartItems));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }
}
