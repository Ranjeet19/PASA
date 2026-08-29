import 'dart:async';
import 'package:flutter/material.dart';

// -------------------------------------------------------------
// 1. DATA MODEL & IN-MEMORY STORE
// -------------------------------------------------------------
class MemoryPhoto {
  final String id;
  final String imageUrl;
  final String caption;

  MemoryPhoto({
    required this.id,
    required this.imageUrl,
    required this.caption,
  });
}

class PhotoStore {
  static final List<MemoryPhoto> favoritePhotos = [
    MemoryPhoto(
      id: '1',
      imageUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=800',
      caption: 'Mountain Sunrise',
    ),
    MemoryPhoto(
      id: '2',
      imageUrl: 'https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=800',
      caption: 'Friends Reunion',
    ),
    MemoryPhoto(
      id: '3',
      imageUrl: 'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?w=800',
      caption: 'Evening Nature',
    ),
  ];

  static void addPhoto(String url, String caption) {
    favoritePhotos.insert(
      0,
      MemoryPhoto(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imageUrl: url,
        caption: caption.isEmpty ? 'Favorite Memory' : caption,
      ),
    );
  }

  static void deletePhoto(String id) {
    favoritePhotos.removeWhere((p) => p.id == id);
  }
}

// -------------------------------------------------------------
// 2. EMBEDDABLE SLIDER BANNER (Place this anywhere on your home page)
// -------------------------------------------------------------
class FavoriteSliderView extends StatefulWidget {
  final double height;
  final EdgeInsetsGeometry margin;

  const FavoriteSliderView({
    super.key,
    this.height = 200,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
  });

  @override
  State<FavoriteSliderView> createState() => _FavoriteSliderViewState();
}

class _FavoriteSliderViewState extends State<FavoriteSliderView> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer?.cancel();
    if (PhotoStore.favoritePhotos.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (_pageController.hasClients) {
          _currentPage = (_currentPage + 1) % PhotoStore.favoritePhotos.length;
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOutCubic,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final photos = PhotoStore.favoritePhotos;

    return GestureDetector(
      onTap: () async {
        // Navigates directly to the full gallery page
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const FavoriteMemoriesPage(),
          ),
        );
        setState(() {});
        _startAutoSlide();
      },
      child: Container(
        // height: widget.height,
        // margin: widget.margin,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: const Color(0xFF1B1E2B),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: photos.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, size: 42, color: Colors.white54),
                    SizedBox(height: 8),
                    Text(
                      'Tap to add favorite memories',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              )
            : Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: photos.length,
                    onPageChanged: (index) => _currentPage = index,
                    itemBuilder: (context, index) {
                      final item = photos[index];
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            item.imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) {
                              return progress == null
                                  ? child
                                  : const Center(child: CircularProgressIndicator());
                            },
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.85),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 14,
                            left: 14,
                            right: 14,
                            child: Text(
                              item.caption,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  // Positioned(
                  //   top: 12,
                  //   right: 12,
                  //   child: Container(
                  //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  //     decoration: BoxDecoration(
                  //       color: Colors.black.withValues(alpha: 0.6),
                  //       borderRadius: BorderRadius.circular(16),
                  //     ),
                  //     child: const Row(
                  //       mainAxisSize: MainAxisSize.min,
                  //       children: [
                  //         // Icon(Icons.grid_view_rounded, size: 13, color: Colors.white),
                  //         // SizedBox(width: 5),
                  //         // Text(
                  //         //   '',
                  //         //   style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                  //         // ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
      ),
    );
  }
}

// -------------------------------------------------------------
// 3. FAVORITE MEMORIES PAGE (Full Grid View, Add, Delete)
// -------------------------------------------------------------
class FavoriteMemoriesPage extends StatefulWidget {
  const FavoriteMemoriesPage({super.key});

  @override
  State<FavoriteMemoriesPage> createState() => _FavoriteMemoriesPageState();
}

class _FavoriteMemoriesPageState extends State<FavoriteMemoriesPage> {
  void _showAddPhotoDialog() {
    final urlController = TextEditingController();
    final captionController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B1E2B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Add Favorite Memory', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: urlController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Image URL',
                labelStyle: TextStyle(color: Colors.white70),
                hintText: 'https://...',
                hintStyle: TextStyle(color: Colors.white24),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: captionController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Caption (Optional)',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (urlController.text.trim().isNotEmpty) {
                PhotoStore.addPhoto(
                  urlController.text.trim(),
                  captionController.text.trim(),
                );
                setState(() {});
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B1E2B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Remove Memory', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Remove this photo from your favorites?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              PhotoStore.deletePhoto(id);
              setState(() {});
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photos = PhotoStore.favoritePhotos;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 64),
                Expanded(
                  child: photos.isEmpty
                      ? Center(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurpleAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            onPressed: _showAddPhotoDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('Add First Photo'),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: photos.length,
                          itemBuilder: (context, index) {
                            final photo = photos[index];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FullScreenViewer(photo: photo),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: const Color(0xFF1B1E2B),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      photo.imageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.8),
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 10,
                                      left: 10,
                                      right: 10,
                                      child: Text(
                                        photo.caption,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () => _confirmDelete(photo.id),
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.6),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),

            // Top Floating Controls
            Positioned(
              top: 10,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildFloatingCircleButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Favorite Memories',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildFloatingCircleButton(
                    icon: Icons.add,
                    onTap: _showAddPhotoDialog,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingCircleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1E2B).withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// -------------------------------------------------------------
// 4. FULL-SCREEN PINCH-TO-ZOOM VIEWER
// -------------------------------------------------------------
class FullScreenViewer extends StatelessWidget {
  final MemoryPhoto photo;

  const FullScreenViewer({super.key, required this.photo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                photo.imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SafeArea(
            child: Positioned(
              top: 16,
              left: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                photo.caption,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}