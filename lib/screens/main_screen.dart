import 'package:flutter/material.dart';
import '../models/character.dart';
import '../services/api_service.dart';
import '../services/local_service.dart';
import '../widgets/character_card.dart';
import 'detail_screen.dart';
import 'episode_screen.dart';

class MainScreen extends StatefulWidget {
  final VoidCallback onLogout;
  const MainScreen({super.key, required this.onLogout});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;
  String selectedStatus = '';
  String searchText = '';
  final searchController = TextEditingController();
  late Future<List<Character>> characterFuture;
  List<int> favoriteIds = [];
  String username = 'Pengguna';

  @override
  void initState() {
    super.initState();
    characterFuture = ApiService.getCharacters();
    loadLocalData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> loadLocalData() async {
    final ids = await LocalService.getFavorites();
    final name = await LocalService.getUsername();
    if (mounted) {
      setState(() {
        favoriteIds = ids;
        username = name;
      });
    }
  }

  void loadCharacters() {
    setState(() {
      characterFuture = ApiService.getCharacters(
        status: selectedStatus,
        name: searchText,
      );
    });
  }

  Future<void> toggleFavorite(int id) async {
    setState(() {
      if (favoriteIds.contains(id)) {
        favoriteIds.remove(id);
      } else {
        favoriteIds.add(id);
      }
    });
    await LocalService.saveFavorites(favoriteIds);
  }

  Future<void> openDetail(Character character) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailScreen(
          characterId: character.id,
          isFavorite: favoriteIds.contains(character.id),
          onFavoriteChanged: toggleFavorite,
        ),
      ),
    );
    loadLocalData();
  }

  Future<void> logout() async {
    await LocalService.logout();
    widget.onLogout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedIndex == 0 ? 'Explore Characters' : 'My Favorites'),
        actions: [
          IconButton(
            tooltip: 'Episode',
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const EpisodeScreen())),
            icon: const Icon(Icons.movie_outlined),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle_outlined),
            onSelected: (value) {
              if (value == 'logout') logout();
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                  value: 'username', enabled: false, child: Text(username)),
              const PopupMenuItem(
                  value: 'logout',
                  child: Row(children: [
                    Icon(Icons.logout, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ])),
            ],
          ),
        ],
      ),
      body: selectedIndex == 0 ? buildHome() : buildFavorites(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() => selectedIndex = index);
          loadLocalData();
        },
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home'),
          NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: 'Favorite'),
        ],
      ),
    );
  }

  Widget buildHome() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: TextField(
            controller: searchController,
            onChanged: (value) {
              searchText = value;
              loadCharacters();
            },
            decoration: InputDecoration(
              hintText: 'Cari nama karakter...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                onPressed: () {
                  searchController.clear();
                  searchText = '';
                  loadCharacters();
                },
                icon: const Icon(Icons.close),
              ),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              filterChip('All', ''),
              filterChip('Alive', 'alive'),
              filterChip('Dead', 'dead'),
              filterChip('Unknown', 'unknown'),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Character>>(
            future: characterFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                    child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                      const SizedBox(height: 10),
                      const Text(
                          'Gagal memuat karakter. Periksa koneksi internet.'),
                      const SizedBox(height: 10),
                      FilledButton.icon(
                        onPressed: loadCharacters,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ));
              }
              final characters = snapshot.data ?? [];
              if (characters.isEmpty) {
                return const Center(child: Text('Karakter tidak ditemukan.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: characters.length,
                itemBuilder: (context, index) {
                  final character = characters[index];
                  return CharacterCard(
                    character: character,
                    isFavorite: favoriteIds.contains(character.id),
                    onTap: () => openDetail(character),
                    onFavorite: () => toggleFavorite(character.id),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget filterChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label),
        selected: selectedStatus == value,
        onSelected: (_) {
          selectedStatus = value;
          loadCharacters();
        },
      ),
    );
  }

  Widget buildFavorites() {
    if (favoriteIds.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text('Belum ada karakter favorit.'),
          ],
        ),
      );
    }
    return FutureBuilder<List<Character>>(
      future: Future.wait(
          favoriteIds.map((id) => ApiService.getCharacterDetail(id))),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Gagal memuat daftar favorit.'),
              ElevatedButton(
                onPressed: () => setState(() {}),
                child: const Text('Coba Lagi'),
              ),
            ],
          ));
        }
        final characters = snapshot.data ?? [];
        if (characters.isEmpty) {
          return const Center(child: Text('Belum ada karakter favorit.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(14),
          itemCount: characters.length,
          itemBuilder: (context, index) {
            final character = characters[index];
            return Dismissible(
              key: ValueKey(character.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 22),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) async {
                await toggleFavorite(character.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('${character.name} dihapus dari favorit')),
                  );
                }
              },
              child: CharacterCard(
                character: character,
                isFavorite: true,
                onTap: () => openDetail(character),
                onFavorite: () async {
                  await toggleFavorite(character.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content:
                              Text('${character.name} dihapus dari favorit')),
                    );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
