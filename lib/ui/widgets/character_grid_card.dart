import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/model/character_model.dart';
import '../../core/provider/character_provider.dart';
import '../../core/constant/app_constants.dart';

class CharacterGridCard extends StatelessWidget {
  final Character character;
  final VoidCallback onTap;

  const CharacterGridCard({
    required this.character,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: AppConstants.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppConstants.borderRadius),
                topRight: Radius.circular(AppConstants.borderRadius),
              ),
              child: CachedNetworkImage(
                imageUrl: character.image,
                width: double.infinity,
                height: 140,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    color: Colors.white,
                    width: double.infinity,
                    height: 140,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  height: 140,
                  child: Icon(Icons.error),
                ),
              ),
            ),
            // Information section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name with edit icon
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          character.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (character.isEdited)
                        Icon(Icons.edit, size: 12, color: Colors.orange),
                    ],
                  ),
                  SizedBox(height: 2),
                  // Species and Status
                  Text(
                    character.species,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  Text(
                    character.status,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 2),
                  // Favorite button
                  SizedBox(
                    width: double.infinity,
                    height: 24,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: IconButton(
                        icon: Icon(
                          character.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: character.isFavorite ? Colors.red : null,
                          size: 16,
                        ),
                        onPressed: () {
                          Provider.of<CharacterProvider>(context, listen: false)
                              .toggleFavorite(character);
                        },
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
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
}
