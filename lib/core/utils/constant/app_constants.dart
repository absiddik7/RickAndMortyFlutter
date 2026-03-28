import 'package:flutter/material.dart';

class AppConstants {
  // API URLs
  static const String baseUrl = 'https://rickandmortyapi.com/api';
  static const String characterEndpoint = '$baseUrl/character';

  // UI Strings
  static const String appTitle = 'Rick & Morty Explorer';
  static const String charactersTab = 'Characters';
  static const String favoritesTab = 'Favorites';
  static const String editCharacter = 'Edit Character';
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String resetToOriginal = 'Reset to API Data';
  static const String noFavorites = 'No favorites added yet.';
  static const String noResults = 'No characters found.';
  static const String errorLoading = 'Failed to load characters.';
  static const String offlineMessage = 'You are offline. Showing cached data.';

  // Form Field Labels
  static const String labelName = 'Name';
  static const String labelStatus = 'Status';
  static const String labelSpecies = 'Species';
  static const String labelType = 'Type';
  static const String labelGender = 'Gender';
  static const String labelOrigin = 'Origin';
  static const String labelLocation = 'Location';

  // Dimensions
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;
  static const double characterImageSize = 80.0;
  static const double detailImageHeight = 300.0;

  // Colors
  static const Color primaryColor = Colors.green;
  static const Color accentColor = Colors.blueAccent;
}
