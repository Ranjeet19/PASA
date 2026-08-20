import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

class FileSaverPage extends StatefulWidget {
  const FileSaverPage({super.key});

  @override
  State<FileSaverPage> createState() => _FileSaverPageState();
}

class _FileSaverPageState extends State<FileSaverPage> {
  static const String _boxName = 'important_file_saver_box';

  Box? _box;

  bool _loading = true;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final ImagePicker _imagePicker = ImagePicker();

  final List<Map<String, dynamic>> _defaultCategories = [
    {
      'name': 'PDFs',
      'icon': Icons.picture_as_pdf_rounded,
    },
    {
      'name': 'CVs',
      'icon': Icons.badge_rounded,
    },
    {
      'name': 'Driving Licences',
      'icon': Icons.directions_car_rounded,
    },
    {
      'name': 'Photos',
      'icon': Icons.photo_camera_rounded,
    },
    {
      'name': 'Citizenship Docs',
      'icon': Icons.credit_card_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        _box = await Hive.openBox(_boxName);
      } else {
        _box = Hive.box(_boxName);
      }
    } catch (e) {
      debugPrint('Hive open error: $e');

      try {
        _box = await Hive.openBox(_boxName);
      } catch (e2) {
        debugPrint('Second Hive open attempt failed: $e2');
      }
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  // ============================================================
  // DATA
  // ============================================================

  List<Map<String, dynamic>> get _files {
    if (_box == null) return [];

    final result = <Map<String, dynamic>>[];

    for (final dynamic value in _box!.values) {
      if (value is Map) {
        result.add(
          Map<String, dynamic>.from(value),
        );
      }
    }

    result.sort((a, b) {
      final aDate = _dateFromValue(a['createdAt']);
      final bDate = _dateFromValue(b['createdAt']);

      return bDate.compareTo(aDate);
    });

    return result;
  }

  List<String> get _customCategories {
    if (_box == null) return [];

    final raw = _box!.get('custom_categories');

    if (raw is List) {
      return raw
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList();
    }

    return [];
  }

  List<String> get _allCategories {
    final names = <String>[
      'PDFs',
      'CVs',
      'Driving Licences',
      'Photos',
      'Citizenship Docs',
    ];

    for (final category in _customCategories) {
      if (!names.contains(category)) {
        names.add(category);
      }
    }

    return names;
  }

  DateTime _dateFromValue(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }

    return DateTime.now();
  }

  List<Map<String, dynamic>> get _filteredFiles {
    List<Map<String, dynamic>> result = _files;

    if (_selectedCategory != 'All') {
      result = result.where((file) {
        return file['category']?.toString() == _selectedCategory;
      }).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();

      result = result.where((file) {
        final name = file['name']?.toString().toLowerCase() ?? '';
        final category =
            file['category']?.toString().toLowerCase() ?? '';

        return name.contains(query) || category.contains(query);
      }).toList();
    }

    return result;
  }

  // ============================================================
  // UPLOAD FILE
  // ============================================================

  Future<void> _pickFile({
    String? category,
  }) async {
    try {
      final selectedCategory = category ??
          await _showCategorySelector(
            title: 'Select file category',
          );

      if (selectedCategory == null) {
        return;
      }

      if (!mounted) return;

      _showLoading();

      // IMPORTANT:
      // This uses the new file_picker API.
      // pickFile() returns PlatformFile directly.
      final PlatformFile? pickedFile =
          await FilePicker.pickFile();

      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();

      if (pickedFile == null) {
        return;
      }

      final Uint8List bytes =
          await pickedFile.readAsBytes();

      if (bytes.isEmpty) {
        _showMessage(
          'The selected file is empty.',
          isError: true,
        );
        return;
      }

      await _saveFile(
        name: pickedFile.name,
        bytes: bytes,
        category: selectedCategory,
        mimeType: _mimeTypeFromName(pickedFile.name),
      );

      if (mounted) {
        setState(() {});
      }

      _showMessage(
        '${pickedFile.name} saved successfully.',
      );
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).maybePop();
      }

      debugPrint('Pick file error: $e');

      _showMessage(
        'Unable to save the file.\n$e',
        isError: true,
      );
    }
  }

  // ============================================================
  // CAMERA
  // ============================================================

  Future<void> _takePhoto({
    String? category,
  }) async {
    try {
      final selectedCategory = category ??
          await _showCategorySelector(
            title: 'Save photo in',
          );

      if (selectedCategory == null) {
        return;
      }

      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (photo == null) {
        return;
      }

      final Uint8List bytes = await photo.readAsBytes();

      if (bytes.isEmpty) {
        _showMessage(
          'Unable to read the photo.',
          isError: true,
        );
        return;
      }

      final timestamp =
          DateTime.now().millisecondsSinceEpoch;

      final name = 'Important_Photo_$timestamp.jpg';

      await _saveFile(
        name: name,
        bytes: bytes,
        category: selectedCategory,
        mimeType: 'image/jpeg',
      );

      if (mounted) {
        setState(() {});
      }

      _showMessage(
        'Photo saved successfully.',
      );
    } catch (e) {
      debugPrint('Camera error: $e');

      _showMessage(
        'Unable to take photo.\n$e',
        isError: true,
      );
    }
  }

  // ============================================================
  // SAVE TO HIVE
  // ============================================================

  Future<void> _saveFile({
    required String name,
    required Uint8List bytes,
    required String category,
    required String mimeType,
  }) async {
    if (_box == null) {
      throw Exception('Storage is not ready.');
    }

    final id =
        '${DateTime.now().microsecondsSinceEpoch}_${name.hashCode}';

    final data = <String, dynamic>{
      'id': id,
      'name': name,
      'category': category,
      'mimeType': mimeType,
      'size': bytes.length,
      'bytes': bytes,
      'createdAt': DateTime.now(),
      'favorite': false,
    };

    await _box!.put(id, data);
  }

  // ============================================================
  // CATEGORY
  // ============================================================

  Future<String?> _showCategorySelector({
    String title = 'Select category',
  }) async {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF7F7F7),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ..._allCategories.map(
                    (category) {
                      return ListTile(
                        leading: _categoryIcon(
                          category,
                          size: 42,
                        ),
                        title: Text(
                          category,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                        ),
                        onTap: () {
                          Navigator.pop(
                            context,
                            category,
                          );
                        },
                      );
                    },
                  ),
                  ListTile(
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                    title: const Text(
                      'Add new category',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(context);

                      final newCategory =
                          await _addCategory();

                      if (newCategory != null &&
                          mounted) {
                        final selected =
                            await _showCategorySelector(
                          title: title,
                        );

                        if (selected != null &&
                            mounted) {
                          // Intentionally no automatic
                          // action here.
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<String?> _addCategory() async {
    final controller = TextEditingController();

    final result =
        await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Add category',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization:
                TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'e.g. Bank Documents',
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                final name =
                    controller.text.trim();

                if (name.isEmpty) {
                  return;
                }

                if (_allCategories.contains(name)) {
                  Navigator.pop(context);
                  _showMessage(
                    'That category already exists.',
                    isError: true,
                  );
                  return;
                }

                final categories =
                    List<String>.from(
                  _customCategories,
                );

                categories.add(name);

                await _box?.put(
                  'custom_categories',
                  categories,
                );

                if (mounted) {
                  setState(() {});
                }

                Navigator.pop(
                  context,
                  name,
                );
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    return result;
  }

  // ============================================================
  // FILE ACTIONS
  // ============================================================

  Future<void> _deleteFile(
    Map<String, dynamic> file,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete file?',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${file['name']}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    final id = file['id'];

    if (id != null) {
      await _box?.delete(id);
    }

    if (mounted) {
      setState(() {});
    }

    _showMessage(
      'File deleted.',
    );
  }

  Future<void> _toggleFavorite(
    Map<String, dynamic> file,
  ) async {
    final id = file['id'];

    if (id == null || _box == null) {
      return;
    }

    final updated =
        Map<String, dynamic>.from(file);

    updated['favorite'] =
        !(file['favorite'] == true);

    await _box!.put(id, updated);

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _renameFile(
    Map<String, dynamic> file,
  ) async {
    final controller = TextEditingController(
      text: file['name']?.toString() ?? '',
    );

    final newName =
        await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Rename file',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'File name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final name =
                    controller.text.trim();

                if (name.isNotEmpty) {
                  Navigator.pop(
                    context,
                    name,
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (newName == null ||
        newName.trim().isEmpty) {
      return;
    }

    final id = file['id'];

    if (id == null || _box == null) {
      return;
    }

    final updated =
        Map<String, dynamic>.from(file);

    updated['name'] = newName.trim();

    await _box!.put(
      id,
      updated,
    );

    if (mounted) {
      setState(() {});
    }

    _showMessage(
      'File renamed.',
    );
  }

  Future<void> _changeCategory(
    Map<String, dynamic> file,
  ) async {
    final category =
        await _showCategorySelector(
      title: 'Move file to',
    );

    if (category == null) {
      return;
    }

    final id = file['id'];

    if (id == null || _box == null) {
      return;
    }

    final updated =
        Map<String, dynamic>.from(file);

    updated['category'] = category;

    await _box!.put(
      id,
      updated,
    );

    if (mounted) {
      setState(() {});
    }

    _showMessage(
      'File moved to $category.',
    );
  }

  // ============================================================
  // SHARE / USE FILE
  // ============================================================

  Future<void> _shareFile(
    Map<String, dynamic> file,
  ) async {
    try {
      final bytes =
          _bytesFromFile(file);

      if (bytes == null ||
          bytes.isEmpty) {
        _showMessage(
          'File data is unavailable.',
          isError: true,
        );
        return;
      }

      final name =
          file['name']?.toString() ??
              'important_file';

      final mime =
          file['mimeType']?.toString() ??
              'application/octet-stream';

      final xFile = XFile.fromData(
        bytes,
        name: name,
        mimeType: mime,
      );

      await SharePlus.instance.share(
        ShareParams(
          files: [xFile],
          fileNameOverrides: [name],
          subject: name,
          title: 'Important File',
          downloadFallbackEnabled: true,
        ),
      );
    } catch (e) {
      debugPrint('Share error: $e');

      _showMessage(
        'Unable to use/share this file.\n$e',
        isError: true,
      );
    }
  }

  // ============================================================
  // FILE DETAILS
  // ============================================================

  Future<void> _showFileDetails(
    Map<String, dynamic> file,
  ) async {
    final bytes =
        _bytesFromFile(file);

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(
              22,
              14,
              22,
              28,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    _fileIcon(
                      file,
                      size: 58,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        file['name']?.toString() ??
                            'Unknown file',
                        maxLines: 2,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _detailRow(
                  'Category',
                  file['category']
                          ?.toString() ??
                      'Unknown',
                ),
                _detailRow(
                  'Type',
                  _extension(
                    file['name']
                            ?.toString() ??
                        '',
                  ).toUpperCase(),
                ),
                _detailRow(
                  'Size',
                  _formatBytes(
                    bytes?.length ??
                        int.tryParse(
                          file['size']
                                  ?.toString() ??
                              '0',
                        ) ??
                        0,
                  ),
                ),
                _detailRow(
                  'Added',
                  _formatDate(
                    _dateFromValue(
                      file['createdAt'],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.black,
                      foregroundColor:
                          Colors.white,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _shareFile(file);
                    },
                    icon: const Icon(
                      Icons.ios_share_rounded,
                    ),
                    label: const Text(
                      'USE / SHARE FILE',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PREVIEW
  // ============================================================

  void _previewFile(
    Map<String, dynamic> file,
  ) {
    final bytes =
        _bytesFromFile(file);

    if (bytes == null ||
        bytes.isEmpty) {
      _showMessage(
        'File data unavailable.',
        isError: true,
      );
      return;
    }

    final name =
        file['name']?.toString() ?? '';

    final extension =
        _extension(name).toLowerCase();

    if (_isImage(extension)) {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor:
                Colors.black,
            insetPadding:
                const EdgeInsets.all(16),
            child: Stack(
              children: [
                InteractiveViewer(
                  child: Image.memory(
                    bytes,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    style:
                        IconButton.styleFrom(
                      backgroundColor:
                          Colors.white,
                    ),
                    onPressed: () =>
                        Navigator.pop(
                      context,
                    ),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );

      return;
    }

    _showFileDetails(file);
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F3),
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.black,
                ),
              )
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildHeader(),
                  ),
                  SliverToBoxAdapter(
                    child: _buildSearch(),
                  ),
                  SliverToBoxAdapter(
                    child: _buildCategorySection(),
                  ),
                  SliverToBoxAdapter(
                    child: _buildUploadButtons(),
                  ),
                  SliverToBoxAdapter(
                    child: _buildRecentTitle(),
                  ),
                  _buildFileList(),
                  const SliverPadding(
                    padding:
                        EdgeInsets.only(bottom: 30),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        22,
        22,
        22,
        14,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'IMPORTANT',
                  style: TextStyle(
                    fontSize: 30,
                    height: .95,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.2,
                  ),
                ),
                const Text(
                  'FILE SAVER',
                  style: TextStyle(
                    fontSize: 30,
                    height: .95,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${_files.length} saved '
                  '${_files.length == 1 ? 'file' : 'files'}',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_horiz_rounded,
              size: 28,
            ),
            onSelected: (value) async {
              if (value == 'category') {
                await _addCategory();

                if (mounted) {
                  setState(() {});
                }
              }

              if (value == 'favorites') {
                _showFavorites();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'category',
                child: Row(
                  children: [
                    Icon(Icons.create_new_folder),
                    SizedBox(width: 10),
                    Text('Add category'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'favorites',
                child: Row(
                  children: [
                    Icon(Icons.star_rounded),
                    SizedBox(width: 10),
                    Text('Favorites'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search your files...',
          prefixIcon: const Icon(
            Icons.search_rounded,
          ),
          suffixIcon: _searchQuery.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                  ),
                ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    final categories = [
      'All',
      ..._allCategories,
    ];

    return SizedBox(
      height: 64,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(
          22,
          16,
          22,
          8,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category =
              categories[index];

          final selected =
              category == _selectedCategory;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory =
                    category;
              });
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.black
                    : Colors.white,
                borderRadius:
                    BorderRadius.circular(30),
                border: Border.all(
                  color: selected
                      ? Colors.black
                      : Colors.black12,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                category,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : Colors.black,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUploadButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        22,
        12,
        22,
        18,
      ),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton.icon(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _pickFile(
                category:
                    _selectedCategory == 'All'
                        ? null
                        : _selectedCategory,
              ),
              icon: const Icon(
                Icons.upload_file_rounded,
              ),
              label: const Text(
                'UPLOAD A NEW FILE',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  letterSpacing: .4,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              style:
                  OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(
                  color: Colors.black26,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _takePhoto(
                category:
                    _selectedCategory == 'All'
                        ? null
                        : _selectedCategory,
              ),
              icon: const Icon(
                Icons.camera_alt_rounded,
                size: 19,
              ),
              label: const Text(
                'OR SNAP A PHOTO',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        22,
        2,
        22,
        10,
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'RECENTLY ADDED FILES',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: .6,
              ),
            ),
          ),
          if (_filteredFiles.isNotEmpty)
            Text(
              '${_filteredFiles.length}',
              style: const TextStyle(
                color: Colors.black45,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFileList() {
    final files = _filteredFiles;

    if (files.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            22,
            25,
            22,
            50,
          ),
          child: Container(
            padding:
                const EdgeInsets.all(35),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(22),
              border: Border.all(
                color: Colors.black12,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.folder_open_rounded,
                    color: Colors.white,
                    size: 35,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'No files found'
                      : 'No important files yet',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'Try another search.'
                      : 'Upload your CV, driving licence, PDF, citizenship document, photos or any other important file.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _pickFile(),
                  child: const Text(
                    'UPLOAD FILE',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
      ),
      sliver: SliverList(
        delegate:
            SliverChildBuilderDelegate(
          (context, index) {
            final file = files[index];

            return Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 9,
              ),
              child: _fileTile(file),
            );
          },
          childCount: files.length,
        ),
      ),
    );
  }

  Widget _fileTile(
    Map<String, dynamic> file,
  ) {
    final favorite =
        file['favorite'] == true;

    return Material(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(16),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(16),
        onTap: () => _previewFile(file),
        child: Container(
          padding:
              const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(16),
            border: Border.all(
              color: Colors.black12,
            ),
          ),
          child: Row(
            children: [
              _fileIcon(
                file,
                size: 50,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      file['name']
                              ?.toString() ??
                          'Unknown file',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          file['category']
                                  ?.toString() ??
                              'Other',
                          style:
                              const TextStyle(
                            fontSize: 12,
                            color:
                                Colors.black54,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                        const Text(
                          '  •  ',
                          style:
                              TextStyle(
                            color:
                                Colors.black26,
                          ),
                        ),
                        Text(
                          _formatBytes(
                            _bytesFromFile(
                                      file,
                                    )
                                    ?.length ??
                                0,
                          ),
                          style:
                              const TextStyle(
                            fontSize: 12,
                            color:
                                Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatDate(
                        _dateFromValue(
                          file['createdAt'],
                        ),
                      ),
                      style:
                          const TextStyle(
                        fontSize: 11,
                        color:
                            Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Favorite',
                onPressed: () =>
                    _toggleFavorite(file),
                icon: Icon(
                  favorite
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: favorite
                      ? Colors.black
                      : Colors.black38,
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'use':
                      _shareFile(file);
                      break;
                    case 'details':
                      _showFileDetails(file);
                      break;
                    case 'rename':
                      _renameFile(file);
                      break;
                    case 'category':
                      _changeCategory(file);
                      break;
                    case 'delete':
                      _deleteFile(file);
                      break;
                  }
                },
                itemBuilder:
                    (context) => const [
                  PopupMenuItem(
                    value: 'use',
                    child: Row(
                      children: [
                        Icon(
                          Icons
                              .ios_share_rounded,
                        ),
                        SizedBox(width: 10),
                        Text('Use / Share'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'details',
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                        ),
                        SizedBox(width: 10),
                        Text('Details'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'rename',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined),
                        SizedBox(width: 10),
                        Text('Rename'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'category',
                    child: Row(
                      children: [
                        Icon(
                          Icons.folder_outlined,
                        ),
                        SizedBox(width: 10),
                        Text('Move category'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                        ),
                        SizedBox(width: 10),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FAVORITES
  // ============================================================

  void _showFavorites() {
    final favorites = _files.where(
      (file) => file['favorite'] == true,
    ).toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Container(
            height:
                MediaQuery.of(context)
                        .size
                        .height *
                    .75,
            decoration:
                const BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'FAVORITE FILES',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: favorites.isEmpty
                      ? const Center(
                          child: Text(
                            'No favorite files yet.',
                            style: TextStyle(
                              color:
                                  Colors.black54,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 20,
                          ),
                          itemCount:
                              favorites.length,
                          itemBuilder:
                              (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets
                                      .only(
                                bottom: 8,
                              ),
                              child:
                                  _fileTile(
                                favorites[index],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  Uint8List? _bytesFromFile(
    Map<String, dynamic> file,
  ) {
    final value = file['bytes'];

    if (value is Uint8List) {
      return value;
    }

    if (value is List) {
      return Uint8List.fromList(
        value.cast<int>(),
      );
    }

    return null;
  }

  String _extension(String name) {
    final index = name.lastIndexOf('.');

    if (index == -1 ||
        index == name.length - 1) {
      return '';
    }

    return name.substring(index + 1);
  }

  String _mimeTypeFromName(
    String name,
  ) {
    final extension =
        _extension(name).toLowerCase();

    switch (extension) {
      case 'pdf':
        return 'application/pdf';

      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';

      case 'png':
        return 'image/png';

      case 'gif':
        return 'image/gif';

      case 'webp':
        return 'image/webp';

      case 'txt':
        return 'text/plain';

      case 'csv':
        return 'text/csv';

      case 'json':
        return 'application/json';

      case 'doc':
        return 'application/msword';

      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';

      case 'xls':
        return 'application/vnd.ms-excel';

      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

      case 'ppt':
        return 'application/vnd.ms-powerpoint';

      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';

      case 'zip':
        return 'application/zip';

      default:
        return 'application/octet-stream';
    }
  }

  bool _isImage(
    String extension,
  ) {
    return [
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
      'bmp',
    ].contains(extension);
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) {
      return '0 B';
    }

    const units = [
      'B',
      'KB',
      'MB',
      'GB',
    ];

    double size = bytes.toDouble();
    int unit = 0;

    while (size >= 1024 &&
        unit < units.length - 1) {
      size /= 1024;
      unit++;
    }

    if (unit == 0) {
      return '${size.toInt()} ${units[unit]}';
    }

    return '${size.toStringAsFixed(1)} ${units[unit]}';
  }

  String _formatDate(
    DateTime date,
  ) {
    final day =
        date.day.toString().padLeft(2, '0');

    final month =
        date.month.toString().padLeft(2, '0');

    final hour =
        date.hour.toString().padLeft(2, '0');

    final minute =
        date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year} • '
        '$hour:$minute';
  }

  IconData _iconForExtension(
    String extension,
  ) {
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf_rounded;

      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
      case 'bmp':
        return Icons.image_rounded;

      case 'doc':
      case 'docx':
        return Icons.article_rounded;

      case 'xls':
      case 'xlsx':
        return Icons.table_chart_rounded;

      case 'ppt':
      case 'pptx':
        return Icons.slideshow_rounded;

      case 'zip':
      case 'rar':
      case '7z':
        return Icons.folder_zip_rounded;

      case 'txt':
        return Icons.text_snippet_rounded;

      default:
        return Icons.insert_drive_file_rounded;
    }
  }

  Widget _fileIcon(
    Map<String, dynamic> file, {
    double size = 50,
  }) {
    final extension =
        _extension(
          file['name']?.toString() ?? '',
        ).toLowerCase();

    final bytes =
        _bytesFromFile(file);

    if (_isImage(extension) &&
        bytes != null &&
        bytes.isNotEmpty) {
      return ClipRRect(
        borderRadius:
            BorderRadius.circular(13),
        child: SizedBox(
          width: size,
          height: size,
          child: Image.memory(
            bytes,
            fit: BoxFit.cover,
            errorBuilder:
                (_, __, ___) {
              return _fileIconContainer(
                _iconForExtension(
                  extension,
                ),
                size,
              );
            },
          ),
        ),
      );
    }

    return _fileIconContainer(
      _iconForExtension(extension),
      size,
    );
  }

  Widget _fileIconContainer(
    IconData icon,
    double size,
  ) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius:
            BorderRadius.circular(
          size * .24,
        ),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: size * .48,
      ),
    );
  }

  Widget _categoryIcon(
    String category, {
    double size = 44,
  }) {
    IconData icon = Icons.folder_rounded;

    final lower =
        category.toLowerCase();

    if (lower.contains('pdf')) {
      icon =
          Icons.picture_as_pdf_rounded;
    } else if (lower.contains('cv')) {
      icon = Icons.badge_rounded;
    } else if (lower.contains('driving') ||
        lower.contains('licence') ||
        lower.contains('license')) {
      icon =
          Icons.directions_car_rounded;
    } else if (lower.contains('photo')) {
      icon = Icons.photo_camera_rounded;
    } else if (lower.contains('citizenship')) {
      icon = Icons.credit_card_rounded;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius:
            BorderRadius.circular(
          size * .25,
        ),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: size * .48,
      ),
    );
  }

  void _showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(22),
              child: SizedBox(
                width: 28,
                height: 28,
                child:
                    CircularProgressIndicator(
                  color: Colors.black,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError
                  ? Colors.black
                  : const Color(0xFF222222),
          behavior:
              SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(12),
          ),
        ),
      );
  }

  @override
  void dispose() {
    super.dispose();
  }
}