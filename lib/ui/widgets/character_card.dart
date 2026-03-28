import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:rick_morty/core/utils/constant/app_constants.dart';
import 'package:rick_morty/core/model/character_model.dart';
import 'package:rick_morty/core/provider/character_provider.dart';

class CharacterCard extends StatelessWidget {
  final Character character;
  final VoidCallback onTap;

  const CharacterCard({
    super.key,
    required this.character,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppConstants.cardElevation,
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(AppConstants.paddingSmall),
        leading: Hero(
          tag: 'character_${character.id}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            child: CachedNetworkImage(
              imageUrl: character.image,
              width: AppConstants.characterImageSize,
              height: AppConstants.characterImageSize,
              fit: BoxFit.cover,
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                character.name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            if (character.isEdited)
              const Icon(Icons.edit, size: 16, color: Colors.orange),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${character.species} - ${character.status}'),
          ],
        ),
        trailing: Consumer<CharacterProvider>(
          builder: (context, prov, _) {
            final current = prov.characters.firstWhere(
              (c) => c.id == character.id,
              orElse: () => character,
            );
            return IconButton(
              icon: Icon(
                current.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: current.isFavorite ? Colors.red : null,
              ),
              onPressed: () {
                prov.toggleFavorite(current);
              },
            );
          },
        ),
        onTap: onTap,
      ),
    );
  }
}
