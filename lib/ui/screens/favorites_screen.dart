import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rick_morty/core/utils/constant/app_constants.dart';
import 'package:rick_morty/core/provider/character_provider.dart';
import 'package:rick_morty/ui/screens/character_detail_screen.dart';
import 'package:rick_morty/ui/widgets/character_grid_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(AppConstants.favoritesTab,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: Consumer<CharacterProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.favorites.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.favorites.isEmpty) {
            return const Center(child: Text(AppConstants.noFavorites));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.73,
              crossAxisSpacing: AppConstants.paddingMedium,
              mainAxisSpacing: AppConstants.paddingMedium,
            ),
            itemCount: provider.favorites.length,
            itemBuilder: (context, index) {
              final character = provider.favorites[index];
              return CharacterGridCard(
                character: character,
                showFavoriteButton: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CharacterDetailScreen(character: character),
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
