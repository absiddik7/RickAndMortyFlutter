import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/character_model.dart';
import '../db/database_helper.dart';
import '../constant/app_constants.dart';

class CharacterRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Character>> fetchCharacters(int page) async {
    try {
      final response = await http.get(Uri.parse('${AppConstants.characterEndpoint}?page=$page'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];
        List<Character> apiCharacters = results.map((json) => Character.fromJson(json)).toList();

        // Cache the base data from API
        await _dbHelper.insertCharacters(apiCharacters);

        return await _mergeWithLocalData(apiCharacters);
      } else {
        throw Exception('Failed to load characters');
      }
    } catch (e) {
      // Offline fallback: get cached data from local DB
      final cachedMaps = await _dbHelper.getCachedCharacters();
      if (cachedMaps.isNotEmpty) {
        List<Character> cachedCharacters = cachedMaps.map((map) => Character.fromJson(map)).toList();
        return await _mergeWithLocalData(cachedCharacters);
      }
      rethrow;
    }
  }

  Future<List<Character>> _mergeWithLocalData(List<Character> baseCharacters) async {
    final favoriteIds = await _dbHelper.getFavoriteIds();
    final overrideMaps = await _dbHelper.getOverrides();
    final Map<int, Map<String, dynamic>> overrides = {
      for (var map in overrideMaps) map['id'] as int: map
    };

    return baseCharacters.map((char) {
      bool isFavorite = favoriteIds.contains(char.id);
      var override = overrides[char.id];

      if (override != null) {
        return char.copyWith(
          name: override['name'],
          status: override['status'],
          species: override['species'],
          type: override['type'],
          gender: override['gender'],
          originName: override['originName'],
          locationName: override['locationName'],
          isFavorite: isFavorite,
          isEdited: true,
        );
      }
      return char.copyWith(isFavorite: isFavorite);
    }).toList();
  }

  Future<void> toggleFavorite(int id, bool isFavorite) async {
    await _dbHelper.toggleFavorite(id, isFavorite);
  }

  Future<void> saveEdit(Character char) async {
    await _dbHelper.saveOverride(char);
  }

  Future<void> resetEdit(int id) async {
    await _dbHelper.deleteOverride(id);
  }

  Future<List<Character>> getFavorites() async {
    final favoriteIds = await _dbHelper.getFavoriteIds();
    final cachedMaps = await _dbHelper.getCachedCharacters();
    final overrideMaps = await _dbHelper.getOverrides();

    final Map<int, Map<String, dynamic>> overrides = {
      for (var map in overrideMaps) map['id'] as int: map
    };

    List<Character> favorites = [];
    for (var map in cachedMaps) {
      int id = map['id'];
      if (favoriteIds.contains(id)) {
        var char = Character.fromJson(map);
        var override = overrides[id];
        if (override != null) {
          char = char.copyWith(
            name: override['name'],
            status: override['status'],
            species: override['species'],
            type: override['type'],
            gender: override['gender'],
            originName: override['originName'],
            locationName: override['locationName'],
            isFavorite: true,
            isEdited: true,
          );
        } else {
          char = char.copyWith(isFavorite: true);
        }
        favorites.add(char);
      }
    }
    return favorites;
  }
}
