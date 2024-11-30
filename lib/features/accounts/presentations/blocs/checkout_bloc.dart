import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mona_coffee/features/accounts/data/entities/cart_item.dart';
import 'package:mona_coffee/features/accounts/data/repositories/checkout_repository.dart';

// checkout state
abstract class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

class CheckoutInitial extends CheckoutState {}

class CheckoutLoading extends CheckoutState {}

class CheckoutSuccess extends CheckoutState {}

class CheckoutError extends CheckoutState {
  final String message;

  const CheckoutError(this.message);

  @override
  List<Object?> get props => [message];
}

class PaymentMethodSelected extends CheckoutState {
  final String method;
  final String? bankName;
  final String? walletName;
  final String? accountNumber;

  const PaymentMethodSelected({
    required this.method,
    this.bankName,
    this.walletName,
    this.accountNumber,
  });

  @override
  List<Object?> get props => [method, bankName, walletName, accountNumber];
}

// checkout event
abstract class CheckoutEvent extends Equatable {
  const CheckoutEvent();

  @override
  List<Object?> get props => [];
}

class SelectPaymentMethod extends CheckoutEvent {
  final String method;
  final String? bankName;
  final String? walletName;
  final String? accountNumber;

  const SelectPaymentMethod({
    required this.method,
    this.bankName,
    this.walletName,
    this.accountNumber,
  });

  @override
  List<Object?> get props => [method, bankName, walletName, accountNumber];
}

class ConfirmTransaction extends CheckoutEvent {
  final String userName;
  final String address;
  final String timeToCome;
  final String notes;
  final String orderType;
  final List<CartItem> cartItems;
  final double amount;
  final String transferProofPath;
  final String? bankName;
  final String? walletName;

  const ConfirmTransaction({
    required this.userName,
    required this.address,
    required this.timeToCome,
    required this.notes,
    required this.orderType,
    required this.cartItems,
    required this.amount,
    required this.transferProofPath,
    this.bankName,
    this.walletName,
  });

  @override
  List<Object?> get props => [
        userName,
        address,
        timeToCome,
        notes,
        orderType,
        cartItems,
        amount,
        transferProofPath,
        bankName,
        walletName,
      ];
}

// checkout bloc
class CheckoutBloc extends Bloc<CheckoutEvent, CheckoutState> {
  final CheckoutRepository _repository;

  CheckoutBloc({required CheckoutRepository repository})
      : _repository = repository,
        super(CheckoutInitial()) {
    on<SelectPaymentMethod>(_onSelectPaymentMethod);
    on<ConfirmTransaction>(_onConfirmTransaction);
  }

  void _onSelectPaymentMethod(
    SelectPaymentMethod event,
    Emitter<CheckoutState> emit,
  ) {
    emit(PaymentMethodSelected(
      method: event.method,
      bankName: event.bankName,
      walletName: event.walletName,
      accountNumber: event.accountNumber,
    ));
  }

  Future<void> _onConfirmTransaction(
    ConfirmTransaction event,
    Emitter<CheckoutState> emit,
  ) async {
    try {
      emit(CheckoutLoading());

      await _repository.confirmTransaction(
        userName: event.userName,
        address: event.address,
        timeToCome: event.timeToCome,
        notes: event.notes,
        orderType: event.orderType,
        cartItems: event.cartItems,
        amount: event.amount,
        transferProofPath: event.transferProofPath,
        bankName: event.bankName,
        walletName: event.walletName,
      );

      emit(CheckoutSuccess());
    } catch (e) {
      emit(CheckoutError(e.toString()));
    }
  }

}


