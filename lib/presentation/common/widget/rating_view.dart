import 'package:flutter/material.dart';

class RatingView extends StatelessWidget {
  final num rating;
  final num maxRating;
  final Color color;
  final int count;
  final double iconSize;

  const RatingView({
    required this.rating,
    required this.maxRating,
    this.color = Colors.amber,
    this.count = 5,
    this.iconSize = 16.0,
    Key? key,
  })  : assert(rating >= 0, 'Rating cannot be negative'),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> stars = List.generate(count, (index) {
      int starIndex = index + 1;

      num starRating = rating / maxRating * count;

      IconData starIcon;
      if (starIndex <= starRating) {
        starIcon = Icons.star;
      } else if (starIndex > starRating && starIndex - starRating < 1) {
        starIcon = Icons.star_half;
      } else {
        starIcon = Icons.star_border;
      }
      return Icon(
        starIcon,
        color: color,
        size: iconSize,
      );
    });

    return Row(children: stars);
  }
}
