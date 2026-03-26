import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/provider/character_provider.dart';
import '../../core/constant/app_constants.dart';
import '../widgets/character_grid_card.dart';
import 'character_detail_screen.dart';
import 'favorites_screen.dart';

class CharacterListScreen extends StatefulWidget {
  const CharacterListScreen({super.key});

  @override
  _CharacterListScreenState createState() => _CharacterListScreenState();
}

class _CharacterListScreenState extends State<CharacterListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CharacterProvider>(context, listen: false).fetchCharacters();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      Provider.of<CharacterProvider>(context, listen: false).fetchCharacters();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(AppConstants.appTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold)),
          centerTitle: false,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          actions: [
            IconButton(
              icon: const Icon(Icons.favorite),
              color: Colors.red,
              iconSize:  28,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoritesScreen()),
                );
              },
            ),
          ],
        ),
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Consumer<CharacterProvider>(
            builder: (context, provider, child) {
              final filteredCharacters = provider.filteredCharacters;

              // Show shimmer loading effect
              if (provider.isLoading && provider.characters.isEmpty) {
                return _buildLoadingState(provider);
              }

              if (provider.error != null && provider.characters.isEmpty) {
                return Center(child: Text(AppConstants.errorLoading));
              }

              if (provider.characters.isEmpty) {
                return Center(child: Text(AppConstants.noResults));
              }

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.paddingMedium,
                      AppConstants.paddingSmall,
                      AppConstants.paddingMedium,
                      AppConstants.paddingSmall,
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: provider.setSearchQuery,
                      decoration: InputDecoration(
                        hintText: 'Search by name or species',
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: provider.searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  provider.setSearchQuery('');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 46,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.paddingMedium,
                      ),
                      itemCount: provider.statusFilters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final filter = provider.statusFilters[index];
                        final isSelected =
                            filter == provider.selectedStatusFilter;
                        return ChoiceChip(
                          label: Text(
                            filter,
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (_) => provider.setStatusFilter(filter),
                          backgroundColor: Colors.grey[200],
                          selectedColor: Colors.grey[350],
                          elevation: 0,
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            side: BorderSide.none,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Expanded(
                    child: filteredCharacters.isEmpty
                        ? const Center(
                            child: Text('No matching characters found'))
                        : GridView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(
                                AppConstants.paddingMedium),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.73,
                              crossAxisSpacing: AppConstants.paddingMedium,
                              mainAxisSpacing: AppConstants.paddingMedium,
                            ),
                            itemCount: filteredCharacters.length +
                                (provider.hasMore &&
                                        provider.searchQuery.isEmpty
                                    ? 1
                                    : 0),
                            itemBuilder: (context, index) {
                              if (index == filteredCharacters.length) {
                                return Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Card(
                                    elevation: AppConstants.cardElevation,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppConstants.borderRadius,
                                      ),
                                    ),
                                    child: Container(color: Colors.white),
                                  ),
                                );
                              }

                              final character = filteredCharacters[index];
                              return CharacterGridCard(
                                character: character,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CharacterDetailScreen(
                                              character: character),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ));
  }

  Widget _buildLoadingState(CharacterProvider provider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.paddingMedium,
            AppConstants.paddingMedium,
            AppConstants.paddingMedium,
            AppConstants.paddingSmall,
          ),
          child: TextField(
            enabled: false,
            decoration: InputDecoration(
              hintText: 'Search by name or species',
              prefixIcon: Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        SizedBox(
          height: 46,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingMedium),
            itemCount: provider.statusFilters.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) => Chip(
              label: Text(provider.statusFilters[index]),
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.all(AppConstants.paddingMedium),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: AppConstants.paddingMedium,
              mainAxisSpacing: AppConstants.paddingMedium,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Card(
                  elevation: AppConstants.cardElevation,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadius),
                  ),
                  child: Container(color: Colors.white),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
