import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/model/character_model.dart';
import '../../core/provider/character_provider.dart';
import '../../core/constant/app_constants.dart';
import 'edit_character_screen.dart';

class CharacterDetailScreen extends StatelessWidget {
  final Character character;

  const CharacterDetailScreen({required this.character});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(character.name),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditCharacterScreen(character: character),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              character.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: character.isFavorite ? Colors.red : null,
            ),
            onPressed: () {
              Provider.of<CharacterProvider>(context, listen: false)
                  .toggleFavorite(character);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: character.image,
              width: double.infinity,
              height: AppConstants.detailImageHeight,
              fit: BoxFit.cover,
              placeholder: (context, url) => Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(AppConstants.labelName, character.name),
                  _buildDetailRow(AppConstants.labelStatus, character.status),
                  _buildDetailRow(AppConstants.labelSpecies, character.species),
                  _buildDetailRow(AppConstants.labelType, character.type.isEmpty ? 'N/A' : character.type),
                  _buildDetailRow(AppConstants.labelGender, character.gender),
                  _buildDetailRow(AppConstants.labelOrigin, character.originName),
                  _buildDetailRow(AppConstants.labelLocation, character.locationName),
                  
                  if (character.isEdited)
                    Padding(
                      padding: const EdgeInsets.only(top: AppConstants.paddingMedium),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Provider.of<CharacterProvider>(context, listen: false).resetEdit(character.id);
                            Navigator.pop(context);
                          },
                          child: Text(AppConstants.resetToOriginal),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingSmall),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
