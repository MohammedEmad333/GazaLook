import 'package:equatable/equatable.dart';

/// A promotional banner shown in the home carousel.
class PromoBanner extends Equatable {
  const PromoBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.imageUrl,
  });

  final String id;
  final String title;
  final String subtitle;

  /// Small pill label (e.g. "جديدنا", "تريند").
  final String tag;
  final String imageUrl;

  @override
  List<Object?> get props => <Object?>[id, title, subtitle, tag, imageUrl];
}
