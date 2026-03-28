import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:rick_morty/core/utils/constant/app_constants.dart';
import 'package:rick_morty/core/model/character_model.dart';
import 'package:rick_morty/core/provider/character_provider.dart';
import 'package:shimmer/shimmer.dart';

class CharacterGridCard extends StatelessWidget {
  final Character character;
  final VoidCallback onTap;
  final bool showFavoriteButton;

  const CharacterGridCard({
    super.key,
    required this.character,
    required this.onTap,
    this.showFavoriteButton = false,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor(String status) {
      switch (status.toLowerCase()) {
        case 'alive':
          return Colors.green.shade100;
        case 'dead':
          return Colors.red.shade100;
        default:
          return Colors.grey.shade300;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section with Hero for smooth transition
            Stack(
              children: [
                Hero(
                  tag: 'character_${character.id}',
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppConstants.borderRadius),
                      topRight: Radius.circular(AppConstants.borderRadius),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: character.image,
                      width: double.infinity,
                      height: 190,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          color: Colors.white,
                          width: double.infinity,
                          height: 190,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        height: 190,
                        child: const Icon(Icons.error),
                      ),
                    ),
                  ),
                ),
                if (showFavoriteButton)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Consumer<CharacterProvider>(
                      builder: (context, prov, _) {
                        final current = prov.characters.firstWhere(
                          (c) => c.id == character.id,
                          orElse: () => character,
                        );
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              prov.toggleFavorite(current);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                current.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: current.isFavorite
                                    ? Colors.red
                                    : Colors.grey.shade600,
                                size: 20,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
            // Information section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Species and Status as pill chips
                  Row(
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor(character.status),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            character.status,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        fit: FlexFit.loose,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            character.species,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
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
