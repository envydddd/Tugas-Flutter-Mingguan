import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Post {
  final int id;
  final String title;
  final String body;

  const Post({
    required this.id,
    required this.title,
    required this.body,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }
}

class Komentar {
  final int id;
  final String name;
  final String email;
  final String body;

  const Komentar({
    required this.id,
    required this.name,
    required this.email,
    required this.body,
  });

  factory Komentar.fromJson(Map<String, dynamic> json) {
    return Komentar(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      body: json['body'] as String,
    );
  }
}

Future<List<Post>> ambilPosts() async {
  final uri = Uri.parse('https://jsonplaceholder.typicode.com/posts');
  final response = await http.get(uri).timeout(const Duration(seconds: 10));

  if (response.statusCode != 200) {
    throw Exception('Gagal memuat postingan (kode ${response.statusCode})');
  }

  final List<dynamic> data = jsonDecode(response.body);
  return data.map((e) => Post.fromJson(e as Map<String, dynamic>)).toList();
}

Future<List<Komentar>> ambilKomentar(int postId) async {
  final uri = Uri.parse('https://jsonplaceholder.typicode.com/posts/$postId/comments');
  final response = await http.get(uri).timeout(const Duration(seconds: 10));

  if (response.statusCode != 200) {
    throw Exception('Gagal memuat komentar (kode ${response.statusCode})');
  }

  final List<dynamic> data = jsonDecode(response.body);
  return data.map((e) => Komentar.fromJson(e as Map<String, dynamic>)).toList();
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Postingan',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const PostPage(),
    );
  }
}

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  late Future<List<Post>> _future;

  @override
  void initState() {
    super.initState();
    _future = ambilPosts();
  }

  Future<void> _muatUlang() async {
    setState(() {
      _future = ambilPosts();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Postingan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _muatUlang,
          ),
        ],
      ),
      body: FutureBuilder<List<Post>>(
        future: _future,
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
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 8),
                    Text(
                      'Terjadi kesalahan:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _muatUlang,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _muatUlang,
            child: ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, i) {
                final post = data[i];
                return ListTile(
                  title: Text(
                    post.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    post.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailPostPage(post: post),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class DetailPostPage extends StatefulWidget {
  final Post post;
  const DetailPostPage({super.key, required this.post});

  @override
  State<DetailPostPage> createState() => _DetailPostPageState();
}

class _DetailPostPageState extends State<DetailPostPage> {
  late Future<List<Komentar>> _futureKomentar;

  @override
  void initState() {
    super.initState();
    _futureKomentar = ambilKomentar(widget.post.id);
  }

  void _muatUlangKomentar() {
    setState(() {
      _futureKomentar = ambilKomentar(widget.post.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Postingan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.post.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.post.body,
              style: const TextStyle(fontSize: 16),
            ),
            const Divider(height: 32),
            const Text(
              'Komentar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            FutureBuilder<List<Komentar>>(
              future: _futureKomentar,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      children: [
                        Text('Gagal memuat komentar: ${snapshot.error}'),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _muatUlangKomentar,
                          child: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  );
                }

                final komentarList = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: komentarList.length,
                  itemBuilder: (context, i) {
                    final k = komentarList[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        title: Text(k.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              k.email,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(k.body),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}