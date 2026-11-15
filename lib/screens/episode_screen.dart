import 'package:flutter/material.dart';
import '../models/episode.dart';
import '../services/api_service.dart';

class EpisodeScreen extends StatefulWidget {
  const EpisodeScreen({super.key});

  @override
  State<EpisodeScreen> createState() => _EpisodeScreenState();
}

class _EpisodeScreenState extends State<EpisodeScreen> {
  late Future<List<Episode>> episodeFuture;

  @override
  void initState() {
    super.initState();
    episodeFuture = ApiService.getEpisodes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Episode')),
      body: FutureBuilder<List<Episode>>(
        future: episodeFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Tidak dapat memuat episode. Periksa koneksi internet.'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => setState(() {
                    episodeFuture = ApiService.getEpisodes();
                  }),
                  child: const Text('Muat Ulang'),
                ),
              ],
            ));
          }
          final episodes = snapshot.data ?? [];
          return ListView.builder(
            itemCount: episodes.length,
            itemBuilder: (context, index) {
              final episode = episodes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(child: Text('${episode.id}')),
                  title: Text(episode.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${episode.episodeCode} • ${episode.airDate}'),
                  trailing: const Icon(Icons.movie_outlined),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
