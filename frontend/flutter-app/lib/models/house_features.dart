class HouseFeatures {
  final int bedrooms;
  final int bathrooms;
  final int toilets;
  final int parkingSpace;
  final String town;
  final String title;

  const HouseFeatures({
    required this.bedrooms,
    required this.bathrooms,
    required this.toilets,
    required this.parkingSpace,
    required this.town,
    required this.title,
  });

  Map<String, dynamic> toJson() => {
        'bedrooms': bedrooms,
        'bathrooms': bathrooms,
        'toilets': toilets,
        'parking_space': parkingSpace,
        'town': town,
        'title': title,
      };
}
