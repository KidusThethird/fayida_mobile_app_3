import 'package:flutter/material.dart';

class NetworkImageSection extends StatelessWidget {
  final String imageUrl;

  NetworkImageSection({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) {
          return Text('Failed to load image');
        },
      ),
    );
  }
}
