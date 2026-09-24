class Vehicle {
  Vehicle({
    required this.id,
    required this.userId,
    required this.title,
    required this.brand,
    required this.model,
    required this.year,
    required this.mileage,
    required this.price,
    required this.condition,
    required this.fuel,
    required this.transmission,
    required this.bodyType,
    required this.city,
    required this.description,
    required this.imageUrl,
    required this.images,
    required this.listingType,
    required this.status,
    required this.createdAt,
    this.sellerName,
    this.sellerVerified = false,
    this.sellerPhone,
    this.sellerWhatsapp,
    this.sellerEmail,
    this.isFavorite = false,
    this.activeOffersCount,
    this.showWhatsapp = true,
    this.acceptLowerOffers = true,
    this.minOfferPercent,
  });

  final int id;
  final String userId;
  final String title;
  final String brand;
  final String model;
  final int year;
  final int mileage;
  final double price;
  final String condition;
  final String fuel;
  final String transmission;
  final String bodyType;
  final String city;
  final String description;
  final String imageUrl;
  final List<String> images;
  final String listingType;
  final String status;
  final String createdAt;
  final String? sellerName;
  final bool sellerVerified;
  final String? sellerPhone;
  final String? sellerWhatsapp;
  final String? sellerEmail;
  final bool isFavorite;
  final int? activeOffersCount;
  final bool showWhatsapp;
  final bool acceptLowerOffers;
  final double? minOfferPercent;

  factory Vehicle.fromJson(Map<String, dynamic> j) {
    final imagesRaw = j['images'];
    List<String> images = [];
    if (imagesRaw is List) {
      images = imagesRaw.map((e) => e.toString()).toList();
    }
    final imageUrl = (j['imageUrl'] ?? j['image_url'] ?? (images.isNotEmpty ? images.first : '')).toString();

    return Vehicle(
      id: _asInt(j['id']),
      userId: (j['userId'] ?? j['user_id'] ?? '').toString(),
      title: (j['title'] ?? '').toString(),
      brand: (j['brand'] ?? '').toString(),
      model: (j['model'] ?? '').toString(),
      year: _asInt(j['year']),
      mileage: _asInt(j['mileage']),
      price: _asDouble(j['price']),
      condition: (j['condition'] ?? '').toString(),
      fuel: (j['fuel'] ?? '').toString(),
      transmission: (j['transmission'] ?? '').toString(),
      bodyType: (j['bodyType'] ?? j['body_type'] ?? '').toString(),
      city: (j['city'] ?? '').toString(),
      description: (j['description'] ?? '').toString(),
      imageUrl: imageUrl,
      images: images.isEmpty && imageUrl.isNotEmpty ? [imageUrl] : images,
      listingType: (j['listingType'] ?? j['listing_type'] ?? '').toString(),
      status: (j['status'] ?? '').toString(),
      createdAt: (j['createdAt'] ?? j['created_at'] ?? '').toString(),
      sellerName: j['sellerName']?.toString() ?? j['seller_name']?.toString(),
      sellerVerified: j['sellerVerified'] == true || j['seller_verified'] == true,
      sellerPhone: j['sellerPhone']?.toString() ?? j['seller_phone']?.toString(),
      sellerWhatsapp: j['sellerWhatsapp']?.toString() ?? j['seller_whatsapp']?.toString(),
      sellerEmail: j['sellerEmail']?.toString() ?? j['seller_email']?.toString(),
      isFavorite: j['isFavorite'] == true,
      activeOffersCount: j['activeOffersCount'] != null ? _asInt(j['activeOffersCount']) : null,
      showWhatsapp: j['showWhatsapp'] != false,
      acceptLowerOffers: j['acceptLowerOffers'] != false,
      minOfferPercent: j['minOfferPercent'] != null ? _asDouble(j['minOfferPercent']) : null,
    );
  }

  static int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  static double _asDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}
