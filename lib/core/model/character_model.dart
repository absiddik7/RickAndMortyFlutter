class Character {
  final int id;
  final String name;
  final String status;
  final String species;
  final String type;
  final String gender;
  final String originName;
  final String locationName;
  final String image;
  final bool isFavorite;
  final bool isEdited;

  Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.gender,
    required this.originName,
    required this.locationName,
    required this.image,
    this.isFavorite = false,
    this.isEdited = false,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      species: json['species'],
      type: json['type'] ?? '',
      gender: json['gender'],
      originName: json['origin'] != null ? json['origin']['name'] : (json['originName'] ?? ''),
      locationName: json['location'] != null ? json['location']['name'] : (json['locationName'] ?? ''),
      image: json['image'],
      isFavorite: json['isFavorite'] == 1 || json['isFavorite'] == true,
      isEdited: json['isEdited'] == 1 || json['isEdited'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'species': species,
      'type': type,
      'gender': gender,
      'originName': originName,
      'locationName': locationName,
      'image': image,
      'isFavorite': isFavorite ? 1 : 0,
      'isEdited': isEdited ? 1 : 0,
    };
  }

  Character copyWith({
    String? name,
    String? status,
    String? species,
    String? type,
    String? gender,
    String? originName,
    String? locationName,
    bool? isFavorite,
    bool? isEdited,
  }) {
    return Character(
      id: id,
      name: name ?? this.name,
      status: status ?? this.status,
      species: species ?? this.species,
      type: type ?? this.type,
      gender: gender ?? this.gender,
      originName: originName ?? this.originName,
      locationName: locationName ?? this.locationName,
      image: image,
      isFavorite: isFavorite ?? this.isFavorite,
      isEdited: isEdited ?? this.isEdited,
    );
  }
}
