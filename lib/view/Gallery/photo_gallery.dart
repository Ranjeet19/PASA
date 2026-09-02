import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';

// -------------------------------------------------------------
// 1. DATA MODEL & LOCAL HIVE STORE
// -------------------------------------------------------------
class MemoryPhoto {
  final String id;
  final Uint8List imageBytes;
  final String caption;

  MemoryPhoto({
    required this.id,
    required this.imageBytes,
    required this.caption,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'imageBytes': imageBytes,
        'caption': caption,
      };

  factory MemoryPhoto.fromMap(Map<dynamic, dynamic> map) {
    return MemoryPhoto(
      id: map['id'] as String,
      imageBytes: Uint8List.fromList(
        List<int>.from(map['imageBytes'] as List),
      ),
      caption: map['caption'] as String,
    );
  }
}

class PhotoStore {
  static const String _boxName = 'galleryPhotos';
  static final List<MemoryPhoto> favoritePhotos = [];
  static Box<dynamic>? _box;
  static bool _loaded = false;

  static Future<void> initialize() async {
    if (_loaded) return;

    _box = Hive.isBoxOpen(_boxName)
        ? Hive.box<dynamic>(_boxName)
        : await Hive.openBox<dynamic>(_boxName);

    favoritePhotos
      ..clear()
      ..addAll(
        _box!.values.map(
          (value) => MemoryPhoto.fromMap(
            Map<dynamic, dynamic>.from(value as Map),
          ),
        ),
      );

    _loaded = true;
  }

  static Future<void> addPhoto(Uint8List imageBytes, String caption) async {
    await initialize();

    final photo = MemoryPhoto(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      imageBytes: imageBytes,
      caption: caption.isEmpty ? 'Favorite Memory' : caption,
    );

    favoritePhotos.insert(0, photo);
    await _box!.put(photo.id, photo.toMap());
  }

  static Future<void> deletePhoto(String id) async {
    await initialize();
    favoritePhotos.removeWhere((photo) => photo.id == id);
    await _box!.delete(id);
  }
}

// -------------------------------------------------------------
// 2. EMBEDDABLE SLIDER BANNER
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    await PhotoStore.initialize();
    if (!mounted) return;

    setState(() => _isLoading = false);
    _startAutoSlide();
  }

  void _startAutoSlide() {
    _timer?.cancel();

    if (PhotoStore.favoritePhotos.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (!mounted || !_pageController.hasClients) return;

        _currentPage =
            (_currentPage + 1) % PhotoStore.favoritePhotos.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOutCubic,
        );
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
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const FavoriteMemoriesPage(),
          ),
        );

        if (!mounted) return;
        setState(() {
          if (_currentPage >= photos.length) {
            _currentPage = 0;
          }
        });
        _startAutoSlide();
      },
      child: Container(
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : photos.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 42,
                          color: Colors.white54,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap to add favorite memories',
                          style:
                              TextStyle(color: Colors.white70, fontSize: 13),
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
                              Image.memory(
                                item.imageBytes,
                                fit: BoxFit.cover,
                                gaplessPlayback: true,
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
                    ],
                  ),
      ),
    );
  }
}

// -------------------------------------------------------------
// 3. FAVORITE MEMORIES PAGE (Grid View, Add, Delete)
// -------------------------------------------------------------
class FavoriteMemoriesPage extends StatefulWidget {
  const FavoriteMemoriesPage({super.key});

  @override
  State<FavoriteMemoriesPage> createState() =>
      _FavoriteMemoriesPageState();
}

class _FavoriteMemoriesPageState extends State<FavoriteMemoriesPage> {
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    await PhotoStore.initialize();
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  void _showAddPhotoDialog() {
    final captionController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B1E2B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text(
          'Add Favorite Memory',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: captionController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Caption (Optional)',
                labelStyle: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _pickAndSavePhoto(
                      ctx,
                      ImageSource.gallery,
                      captionController.text.trim(),
                    ),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Gallery'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurpleAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _pickAndSavePhoto(
                      ctx,
                      ImageSource.camera,
                      captionController.text.trim(),
                    ),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Camera'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
        ],
      ),
    ).whenComplete(captionController.dispose);
  }

  Future<void> _pickAndSavePhoto(
    BuildContext dialogContext,
    ImageSource source,
    String caption,
  ) async {
    try {
      final XFile? selectedPhoto = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 2000,
      );

      if (selectedPhoto == null) return;

      final imageBytes = await selectedPhoto.readAsBytes();
      await PhotoStore.addPhoto(imageBytes, caption);

      if (!mounted) return;
      if (dialogContext.mounted) {
        Navigator.pop(dialogContext);
      }
      setState(() {});
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to open the camera or gallery. Please check permissions.',
          ),
        ),
      );
    }
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B1E2B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text(
          'Remove Memory',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Remove this photo from your favorites?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () async {
              await PhotoStore.deletePhoto(id);
              if (!mounted) return;
              setState(() {});
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
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
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : photos.isEmpty
                          ? Center(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.deepPurpleAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                ),
                                onPressed: _showAddPhotoDialog,
                                icon: const Icon(Icons.add),
                                label: const Text('Add First Photo'),
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
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
                                        builder: (_) =>
                                            FullScreenViewer(photo: photo),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(16),
                                      color: const Color(0xFF1B1E2B),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.memory(
                                          photo.imageBytes,
                                          fit: BoxFit.cover,
                                          gaplessPlayback: true,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withValues(
                                                  alpha: 0.8,
                                                ),
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
                                            overflow:
                                                TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: GestureDetector(
                                            onTap: () =>
                                                _confirmDelete(photo.id),
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withValues(alpha: 0.6),
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

  Widget _buildFloatingCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1E2B).withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
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
              child: Image.memory(
                photo.imageBytes,
                fit: BoxFit.contain,
                gaplessPlayback: true,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 16, left: 16),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  photo.caption,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
