class ShopItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final String affects;
  final double increaseAmount;
  final String imageUrl;
  final bool isTrophy;

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.affects,
    required this.increaseAmount,
    required this.imageUrl,
    required this.isTrophy,
  });

  // Create from PocketBase record
  factory ShopItem.fromJson(Map<String, dynamic> json) {
    return ShopItem(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] ?? 0,
      affects: json['affects'] ?? '',
      increaseAmount: (json['increaseAmount'] ?? 0).toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      isTrophy: json['isTrophy'] ?? false,
    );
  }

  // Convert to JSON for PocketBase
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'affects': affects,
      'increaseAmount': increaseAmount,
      'imageUrl': imageUrl,
      'isTrophy': isTrophy,
    };
  }
}
