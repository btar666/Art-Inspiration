/// عنصر سلايدر من الباكند
class SliderItemModel {
  const SliderItemModel({
    required this.id,
    required this.title,
    required this.imageUrl,
  });

  final String id;
  final String title;
  final String imageUrl;

  factory SliderItemModel.fromJson(Map<String, dynamic> json) {
    final rawUrl = (json['url'] ?? json['image'] ?? '').toString().trim();
    var imageUrl = rawUrl;
    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      imageUrl = 'https://art-inspiration.com/storage/$imageUrl';
    }

    return SliderItemModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      imageUrl: imageUrl,
    );
  }
}
