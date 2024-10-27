class Order {
  final String coffeeName;
  final String orderDate;
  final String type;
  final int quantity;
  final String imageUrl;

  Order({
    required this.coffeeName,
    required this.orderDate,
    required this.type,
    required this.quantity,
    required this.imageUrl,
  });
}

final List<Order> orders = [
  Order(
    coffeeName: 'Mocha Latte',
    orderDate: '2024-10-01',
    type: 'Hot',
    quantity: 1,
    imageUrl: 'assets/images/coffee.png',
  ),
  Order(
    coffeeName: 'Latte',
    orderDate: '2024-10-02',
    type: 'Ice',
    quantity: 2,
    imageUrl: 'assets/images/coffee.png',
  ),
  Order(
    coffeeName: 'Cappuccino',
    orderDate: '2024-10-03',
    type: 'Hot',
    quantity: 1,
    imageUrl: 'assets/images/coffee.png',
  ),
  Order(
    coffeeName: 'Espresso',
    orderDate: '2024-10-04',
    type: 'Hot',
    quantity: 3,
    imageUrl: 'assets/images/coffee.png',
  ),
  Order(
    coffeeName: 'Americano',
    orderDate: '2024-10-05',
    type: 'Hot',
    quantity: 2,
    imageUrl: 'assets/images/coffee.png',
  ),
  Order(
    coffeeName: 'Flat White',
    orderDate: '2024-10-06',
    type: 'Hot',
    quantity: 1,
    imageUrl: 'assets/images/coffee.png',
  ),
  Order(
    coffeeName: 'Cold Brew',
    orderDate: '2024-10-07',
    type: 'Ice',
    quantity: 2,
    imageUrl: 'assets/images/coffee.png',
  ),
  Order(
    coffeeName: 'Macchiato',
    orderDate: '2024-10-08',
    type: 'Hot',
    quantity: 1,
    imageUrl: 'assets/images/coffee.png',
  ),
  Order(
    coffeeName: 'Affogato',
    orderDate: '2024-10-09',
    type: 'Ice',
    quantity: 1,
    imageUrl: 'assets/images/coffee.png',
  ),
  Order(
    coffeeName: 'Turmeric Latte',
    orderDate: '2024-10-10',
    type: 'Hot',
    quantity: 1,
    imageUrl: 'assets/images/coffee.png',
  ),
];

