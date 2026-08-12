import '../../domain/entities/promo_banner.dart';

/// Serialisable [PromoBanner] for the data layer.
class PromoBannerModel extends PromoBanner {
  const PromoBannerModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.tag,
    required super.imageUrl,
  });

  factory PromoBannerModel.fromMap(Map<String, dynamic> map) =>
      PromoBannerModel(
        id: map['id'] as String,
        title: map['title'] as String,
        subtitle: map['subtitle'] as String,
        tag: map['tag'] as String,
        imageUrl: map['imageUrl'] as String,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'tag': tag,
        'imageUrl': imageUrl,
      };
}
