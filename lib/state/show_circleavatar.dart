import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ShowCircleAvatar extends StatelessWidget {
  
  final String url;

  ShowCircleAvatar({
    Key? key,
    required this.url,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      width: 48,
      height: 48,
      child: CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(url),
      ),
    );
  }
}
