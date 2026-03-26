import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/model/character_model.dart';
import '../../core/provider/character_provider.dart';
import '../../core/constant/app_constants.dart';

class CharacterCard extends StatelessWidget {
  final Character character;
  final VoidCallback onTap;

  const CharacterCard({
    required this.character,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppConstants.cardElevation,
      margin: EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(AppConstants.paddingSmall),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          child: CachedNetworkImage(
            imageUrl: character.image,
            width: AppConstants.characterImageSize,
            height: AppConstants.characterImageSize,
            fit: BoxFit.cover,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                character.name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            if (character.isEdited)
              Icon(Icons.edit, size: 16, color: Colors.orange),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${character.species} - ${character.status}'),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            character.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: character.isFavorite ? Colors.red : null,
          ),
          onPressed: () {
            Provider.of<CharacterProvider>(context, listen: false)
                .toggleFavorite(character);
          },
        ),
        onTap: onTap,
      ),
    );
  }
}
