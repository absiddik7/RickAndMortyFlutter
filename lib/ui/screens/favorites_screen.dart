import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/provider/character_provider.dart';
import '../../core/constant/app_constants.dart';
import '../widgets/character_card.dart';
import 'character_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CharacterProvider>(context, listen: false).fetchFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.favoritesTab),
      ),
      body: Consumer<CharacterProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.favorites.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          if (provider.favorites.isEmpty) {
            return Center(child: Text(AppConstants.noFavorites));
          }

          return ListView.builder(
            itemCount: provider.favorites.length,
            itemBuilder: (context, index) {
              final character = provider.favorites[index];
              return CharacterCard(
                character: character,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CharacterDetailScreen(character: character),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
