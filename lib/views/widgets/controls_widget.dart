import 'package:flutter/material.dart';
import '../../viewmodels/gif_viewmodel.dart';

class ControlsWidget extends StatelessWidget {
  final GifViewModel gifViewModel;
  final Function(String) onSearch;
  final VoidCallback onFetchRandom;
  final VoidCallback onFetchTrending;

  const ControlsWidget({
    super.key,
    required this.gifViewModel,
    required this.onSearch,
    required this.onFetchRandom,
    required this.onFetchTrending,
  });

  @override
  Widget build(BuildContext context) {
    final canFetch = !gifViewModel.loading;
    final searchController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: const InputDecoration(
                labelText: 'Procurar por TAG',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (query) => onSearch(query),
            ),
          ),
          const SizedBox(width: 8),
          
          // Language dropdown
          DropdownButton<String>(
            value: gifViewModel.lang,
            onChanged: (v) {
              gifViewModel.setLang(v ?? 'en');
            },
            items: const [
              DropdownMenuItem(value: 'en', child: Text('EN')),
              DropdownMenuItem(value: 'es', child: Text('ES')),
              DropdownMenuItem(value: 'pt', child: Text('PT')),
              DropdownMenuItem(value: 'fr', child: Text('FR')),
              DropdownMenuItem(value: 'de', child: Text('DE')),
            ],
          ),
          const SizedBox(width: 8),
          
          // Rating dropdown
          DropdownButton<String>(
            value: gifViewModel.rating,
            onChanged: (v) {
              gifViewModel.setRating(v ?? 'g');
            },
            items: const [
              DropdownMenuItem(value: 'g', child: Text('G')),
              DropdownMenuItem(value: 'pg', child: Text('PG')),
              DropdownMenuItem(value: 'pg-13', child: Text('PG-13')),
              DropdownMenuItem(value: 'r', child: Text('R')),
            ],
          ),
          const SizedBox(width: 8),
          
          // Random button
          FilledButton.icon(
            onPressed: canFetch ? onFetchRandom : null,
            icon: const Icon(Icons.refresh),
            label: const Text('Novo GIF'),
          ),
          const SizedBox(width: 8),
          
          // Search button
          FilledButton.icon(
            onPressed: canFetch 
                ? () => onSearch(searchController.text) 
                : null,
            icon: const Icon(Icons.search),
            label: const Text('Buscar'),
          ),
          const SizedBox(width: 8),
          
          // Trending button
          FilledButton.icon(
            onPressed: canFetch ? onFetchTrending : null,
            icon: const Icon(Icons.trending_up),
            label: const Text('Trending'),
          ),
        ],
      ),
    );
  }
}
