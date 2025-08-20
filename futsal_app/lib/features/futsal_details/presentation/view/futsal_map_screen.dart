import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class FutsalMapScreen extends StatelessWidget {
  final String name;
  final double latitude;
  final double longitude;

  const FutsalMapScreen({
    super.key,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    final url = Uri.encodeFull(
      'https://www.openstreetmap.org/?mlat=$latitude&mlon=$longitude#map=18/$latitude/$longitude',
    );

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: InAppWebView(initialUrlRequest: URLRequest(url: WebUri(url))),
    );
  }
}
