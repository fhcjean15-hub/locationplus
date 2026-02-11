import 'package:flutter/material.dart';

class ListingDetailScreen extends StatelessWidget {
  final String listingId;

  const ListingDetailScreen({
    super.key,
    required this.listingId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Annonce $listingId"),
      ),
      body: const Center(
        child: Text("Détails de l’annonce"),
      ),
    );
  }
}
