import 'package:flutter/material.dart';
import 'package:fyp/services/fav_service.dart';

class FavouritesPage extends StatefulWidget {
  @override
  State<FavouritesPage> createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage> {
  final FavouriteService _favouriteService = FavouriteService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourites'),
        backgroundColor: Colors.lightGreenAccent.shade100,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _favouriteService.fetchFavourites(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No favorite items found.'));
          }

          final favourites = snapshot.data!;

          return ListView.builder(
            itemCount: favourites.length,
            itemBuilder: (context, index) {
              final favItem = favourites[index];
              final imagePath = favItem['imagePath'] ?? '';
              final shoeName = favItem['shoeName'] ?? 'Unknown Shoe';
              final price = favItem['price']?.toString() ?? '0.0';

              return ListTile(
                leading: imagePath.isNotEmpty
                    ? Image.network(
                  imagePath,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 50),
                )
                    : const Icon(Icons.image, size: 50),
                title: Text(shoeName),
                subtitle: Text('Rs. $price'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await _favouriteService.toggleFavourite(favItem['shoeId'] ?? '', {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Removed from favourites')),
                    );
                    setState(() {}); // Refresh the list
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
