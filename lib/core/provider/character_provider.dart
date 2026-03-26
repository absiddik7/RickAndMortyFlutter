import 'package:flutter/material.dart';
import '../model/character_model.dart';
import '../repository/character_repository.dart';

class CharacterProvider with ChangeNotifier {
  final CharacterRepository _repository = CharacterRepository();

  List<Character> _characters = [];
  List<Character> get characters => _characters;

  List<Character> _favorites = [];
  List<Character> get favorites => _favorites;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  String _selectedStatusFilter = 'All';
  String get selectedStatusFilter => _selectedStatusFilter;

  final List<String> _statusFilters = ['All', 'Alive', 'Dead', 'unknown'];
  List<String> get statusFilters => _statusFilters;

  List<Character> get filteredCharacters {
    return _characters.where((character) {
      final matchesSearch = _searchQuery.isEmpty ||
          character.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          character.species.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus = _selectedStatusFilter == 'All' ||
          character.status.toLowerCase() == _selectedStatusFilter.toLowerCase();

      return matchesSearch && matchesStatus;
    }).toList();
  }

  int _page = 1;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  String? _error;
  String? get error => _error;

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    notifyListeners();
  }

  void setStatusFilter(String filter) {
    _selectedStatusFilter = filter;
    notifyListeners();
  }

  Future<void> fetchCharacters({bool reset = false}) async {
    if (reset) {
      _page = 1;
      _characters = [];
      _hasMore = true;
    }

    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newCharacters = await _repository.fetchCharacters(_page);
      if (newCharacters.isEmpty) {
        _hasMore = false;
      } else {
        _characters.addAll(newCharacters);
        _page++;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchFavorites() async {
    try {
      _favorites = await _repository.getFavorites();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(Character character) async {
    bool newStatus = !character.isFavorite;
    await _repository.toggleFavorite(character.id, newStatus);
    
    // Update character list and favorites list
    int charIndex = _characters.indexWhere((c) => c.id == character.id);
    if (charIndex != -1) {
      _characters[charIndex] = _characters[charIndex].copyWith(isFavorite: newStatus);
    }
    
    await fetchFavorites();
    notifyListeners();
  }

  Future<void> saveEdit(Character editedChar) async {
    await _repository.saveEdit(editedChar);
    
    // Update local state
    int charIndex = _characters.indexWhere((c) => c.id == editedChar.id);
    if (charIndex != -1) {
      _characters[charIndex] = editedChar.copyWith(isEdited: true);
    }
    
    await fetchFavorites();
    notifyListeners();
  }

  Future<void> resetEdit(int id) async {
    await _repository.resetEdit(id);
    // After reset, we need to refresh to get original API data
    await fetchCharacters(reset: true);
    await fetchFavorites();
  }
}
