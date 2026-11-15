import 'package:flutter/material.dart';
import '../models/character.dart';
import '../services/api_service.dart';

class DetailScreen extends StatefulWidget {
  final int characterId;
  final bool isFavorite;
  final Function(int) onFavoriteChanged;

  const DetailScreen({
    super.key,
    required this.characterId,
    required this.isFavorite,
    required this.onFavoriteChanged,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late bool favorite;
  late Future<Character> characterFuture;

  @override
  void initState() {
    super.initState();
    favorite = widget.isFavorite;
    characterFuture = ApiService.getCharacterDetail(widget.characterId);
  }

  void toggleFavorite() {
    setState(() => favorite = !favorite);
    widget.onFavoriteChanged(widget.characterId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(favorite
          ? 'Karakter ditambahkan ke favorit'
          : 'Karakter dihapus dari favorit')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Karakter')),
      body: FutureBuilder<Character>(
        future: characterFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Gagal memuat detail karakter.'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => setState(() {
                    characterFuture = ApiService.getCharacterDetail(widget.characterId);
                  }),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ));
          }
          final character = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.network(character.image, height: 280, fit: BoxFit.cover),
              ),
              const SizedBox(height: 18),
              Text(character.name, textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              Card(
                child: Column(children: [
                  detailRow('Status', character.status),
                  detailRow('Species', character.species),
                  detailRow('Gender', character.gender),
                  detailRow('Origin', character.origin),
                  detailRow('Location', character.location),
                ]),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: toggleFavorite,
                icon: Icon(favorite ? Icons.favorite : Icons.favorite_border),
                label: Text(favorite ? 'Hapus dari Favorit' : 'Tambah ke Favorit'),
                style: FilledButton.styleFrom(
                  backgroundColor: favorite ? Colors.red : const Color(0xFF247A58),
                  padding: const EdgeInsets.all(15),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget detailRow(String title, String value) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      subtitle: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
