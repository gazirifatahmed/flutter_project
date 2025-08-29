class MenuItem {
final int id;
final String name;
final String description;
final double price;
final String imageUrl;
final double rating; // ⭐ Average rating
final int ratingCount; // ⭐ Total ratings


MenuItem({
required this.id,
required this.name,
required this.description,
required this.price,
required this.imageUrl,
required this.rating,
required this.ratingCount,
});


factory MenuItem.fromJson(Map<String, dynamic> json) {
return MenuItem(
id: json['id'],
name: json['name'],
description: json['description'] ?? '',
price: (json['price'] ?? 0).toDouble(),
imageUrl: json['image'] ?? '',
rating: (json['rating'] ?? 0.0).toDouble(),
ratingCount: (json['ratingCount'] ?? 0),
);
}
}