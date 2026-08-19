import 'dart:async';
import 'dart:typed_data';

import 'package:app_blocker/app_blocker.dart';
import 'package:flutter/material.dart';

class SelfLockPage extends StatefulWidget {
  const SelfLockPage({super.key});

  @override
  State<SelfLockPage> createState() => _SelfLockPageState();
}

class _SelfLockPageState extends State<SelfLockPage>
    with WidgetsBindingObserver {
  final AppBlocker _blocker = AppBlocker.instance;

  // ------------------------------------------------------------
  // APP DATA
  // ------------------------------------------------------------

  List<dynamic> _apps = <dynamic>[];

  final Set<String> _selectedApps = <String>{};

  // ------------------------------------------------------------
  // STATE
  // ------------------------------------------------------------

  BlockerPermissionStatus _permission =
      BlockerPermissionStatus.denied;

  bool _loading = true;
  bool _loadingApps = false;
  bool _requestingPermission = false;
  bool _startingLock = false;

  String _searchText = '';

  int _selectedDuration = 30;

  DateTime? _lockEndTime;

  Duration _remaining = Duration.zero;

  Timer? _timer;

  // ------------------------------------------------------------
  // DURATIONS
  // ------------------------------------------------------------

  final List<int> _durations = <int>[
    15,
    30,
    60,
    120,
  ];

  // ------------------------------------------------------------
  // COLORS
  // ------------------------------------------------------------

  static const Color background =
      Color(0xFF000000);

  static const Color card =
      Color(0xFF121212);

  static const Color blue =
      Color(0xFF0095F6);

  static const Color textSecondary =
      Color(0xFF888888);

  static const Color border =
      Color(0xFF242424);

  // ------------------------------------------------------------
  // INIT
  // ------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _initialize();
  }

  // ------------------------------------------------------------
  // LIFECYCLE
  // ------------------------------------------------------------

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    if (state == AppLifecycleState.resumed) {
      _refreshPermission();
    }
  }

  // ------------------------------------------------------------
  // INITIALIZE
  // ------------------------------------------------------------

  Future<void> _initialize() async {
    await _refreshPermission();

    if (_permission ==
        BlockerPermissionStatus.granted) {
      await _loadApps();
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _loading = false;
    });
  }

  // ------------------------------------------------------------
  // CHECK PERMISSION
  // ------------------------------------------------------------

  Future<void> _refreshPermission() async {
    try {
      final BlockerPermissionStatus status =
          await _blocker.checkPermission();

      if (!mounted) {
        return;
      }

      setState(() {
        _permission = status;
      });

      debugPrint(
        'PASA Self Lock permission: ${status.name}',
      );

      if (status ==
          BlockerPermissionStatus.granted) {
        if (_apps.isEmpty) {
          await _loadApps();
        }
      }
    } catch (e) {
      debugPrint(
        'Permission check error: $e',
      );
    }
  }

  // ------------------------------------------------------------
  // REQUEST PERMISSION
  // ------------------------------------------------------------

  Future<void> _requestPermission() async {
    if (_requestingPermission) {
      return;
    }

    setState(() {
      _requestingPermission = true;
    });

    try {
      debugPrint(
        'PASA: requesting permission...',
      );

      final BlockerPermissionStatus status =
          await _blocker.requestPermission();

      debugPrint(
        'PASA: permission result = ${status.name}',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _permission = status;
      });

      if (status ==
          BlockerPermissionStatus.granted) {
        await _loadApps();

        _showMessage(
          'Permission granted.',
        );
      } else {
        _showPermissionInstructions(
          status,
        );
      }
    } catch (e, stackTrace) {
      debugPrint(
        'PASA permission error: $e',
      );

      debugPrint(
        stackTrace.toString(),
      );

      if (!mounted) {
        return;
      }

      _showPermissionError(
        e.toString(),
      );
    } finally {
      if (mounted) {
        setState(() {
          _requestingPermission = false;
        });
      }
    }
  }

  // ------------------------------------------------------------
  // PERMISSION INSTRUCTIONS
  // ------------------------------------------------------------

  void _showPermissionInstructions(
    BlockerPermissionStatus status,
  ) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: card,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),
          title: const Text(
            'One More Step',
            style: TextStyle(
              color: Colors.white,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          content: Text(
            'Android may require more than one '
            'permission for Self Lock.\n\n'
            'If Settings opened, enable PASA '
            'under Accessibility and return to '
            'this screen.\n\n'
            'Then press "Grant Permission" again.',
            style: const TextStyle(
              color: textSecondary,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(
                  color: blue,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // PERMISSION ERROR
  // ------------------------------------------------------------

  void _showPermissionError(
    String error,
  ) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: card,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),
          title: const Text(
            'Permission Error',
            style: TextStyle(
              color: Colors.white,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Android did not complete the '
                  'permission request.',
                  style: TextStyle(
                    color: textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(12),
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(0xFF1C1C1C),
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),
                  child: Text(
                    error,
                    style: const TextStyle(
                      color:
                          Color(0xFFCCCCCC),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop();
              },
              child: const Text(
                'CLOSE',
                style: TextStyle(
                  color: blue,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------
  // LOAD INSTALLED APPS
  // ------------------------------------------------------------

  Future<void> _loadApps() async {
    if (_loadingApps) {
      return;
    }

    if (_permission !=
        BlockerPermissionStatus.granted) {
      return;
    }

    setState(() {
      _loadingApps = true;
    });

    try {
      final List<dynamic> result =
          await _blocker.getApps();

      if (!mounted) {
        return;
      }

      setState(() {
        _apps = result;
      });

      debugPrint(
        'PASA: ${result.length} apps loaded',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Load apps error: $e',
      );

      debugPrint(
        stackTrace.toString(),
      );

      if (mounted) {
        _showMessage(
          'Could not load installed apps.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingApps = false;
        });
      }
    }
  }

  // ------------------------------------------------------------
  // APP NAME
  // ------------------------------------------------------------

  String _getAppName(
    dynamic app,
  ) {
    try {
      return app.appName?.toString() ??
          'Unknown App';
    } catch (_) {
      return 'Unknown App';
    }
  }

  // ------------------------------------------------------------
  // PACKAGE NAME
  // ------------------------------------------------------------

  String _getPackageName(
    dynamic app,
  ) {
    try {
      return app.packageName?.toString() ??
          '';
    } catch (_) {
      return '';
    }
  }

  // ------------------------------------------------------------
  // APP ICON
  // ------------------------------------------------------------

  Uint8List? _getIcon(
    dynamic app,
  ) {
    try {
      final dynamic icon = app.icon;

      if (icon is Uint8List) {
        return icon;
      }

      if (icon is List<int>) {
        return Uint8List.fromList(
          icon,
        );
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  // ------------------------------------------------------------
  // FILTER APPS
  // ------------------------------------------------------------

  List<dynamic> get _filteredApps {
    final String query =
        _searchText.trim().toLowerCase();

    if (query.isEmpty) {
      return _apps;
    }

    return _apps.where(
      (dynamic app) {
        final String name =
            _getAppName(app)
                .toLowerCase();

        final String packageName =
            _getPackageName(app)
                .toLowerCase();

        return name.contains(query) ||
            packageName.contains(query);
      },
    ).toList();
  }

  // ------------------------------------------------------------
  // SELECT APP
  // ------------------------------------------------------------

  void _toggleApp(
    dynamic app,
  ) {
    final String packageName =
        _getPackageName(app);

    if (packageName.isEmpty) {
      return;
    }

    setState(() {
      if (_selectedApps.contains(
        packageName,
      )) {
        _selectedApps.remove(
          packageName,
        );
      } else {
        _selectedApps.add(
          packageName,
        );
      }
    });
  }

  // ------------------------------------------------------------
  // DURATION
  // ------------------------------------------------------------

  void _selectDuration(
    int minutes,
  ) {
    setState(() {
      _selectedDuration = minutes;
    });
  }

  // ------------------------------------------------------------
  // START LOCK
  // ------------------------------------------------------------

  Future<void> _startLock() async {
    if (_selectedApps.isEmpty) {
      _showMessage(
        'Select at least one app.',
      );
      return;
    }

    if (_permission !=
        BlockerPermissionStatus.granted) {
      _showMessage(
        'Please grant permission first.',
      );
      return;
    }

    final bool confirmed =
        await _confirmStart();

    if (!confirmed) {
      return;
    }

    setState(() {
      _startingLock = true;
    });

    try {
      // --------------------------------------------------------
      // Configure block screen
      // --------------------------------------------------------

      await _blocker.setBlockScreenConfig(
        const BlockScreenConfig(
          title: 'Self Lock Active',
          subtitle: 'PASA',
          message:
              'This application is locked by your '
              'Self Lock session.\n\n'
              'Stay focused and come back later.',
          backgroundColor:
              Color(0xF5000000),
        ),
      );

      // --------------------------------------------------------
      // Block apps
      // --------------------------------------------------------

      await _blocker.blockApps(
        _selectedApps.toList(),
      );

      // --------------------------------------------------------
      // Create timer
      // --------------------------------------------------------

      final DateTime end =
          DateTime.now().add(
        Duration(
          minutes: _selectedDuration,
        ),
      );

      setState(() {
        _lockEndTime = end;
        _remaining =
            end.difference(
          DateTime.now(),
        );
      });

      _startTimer();

      _showMessage(
        'Self Lock started.',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Start lock error: $e',
      );

      debugPrint(
        stackTrace.toString(),
      );

      _showMessage(
        'Could not start Self Lock.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _startingLock = false;
        });
      }
    }
  }

  // ------------------------------------------------------------
  // TIMER
  // ------------------------------------------------------------

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) async {
        if (_lockEndTime == null) {
          timer.cancel();
          return;
        }

        final Duration remaining =
            _lockEndTime!.difference(
          DateTime.now(),
        );

        if (remaining.inSeconds <= 0) {
          timer.cancel();

          await _finishLock();

          return;
        }

        if (!mounted) {
          return;
        }

        setState(() {
          _remaining = remaining;
        });
      },
    );
  }

  // ------------------------------------------------------------
  // FINISH LOCK
  // ------------------------------------------------------------

  Future<void> _finishLock() async {
    try {
      await _blocker.unblockApps(
        _selectedApps.toList(),
      );
    } catch (e) {
      debugPrint(
        'Unblock error: $e',
      );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _lockEndTime = null;
      _remaining = Duration.zero;
    });

    await _showFinishedDialog();
  }

  // ------------------------------------------------------------
  // CONFIRM START
  // ------------------------------------------------------------

  Future<bool> _confirmStart() async {
    final bool? result =
        await showDialog<bool>(
      context: context,
      builder:
          (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: card,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),
          title: const Text(
            'Start Self Lock?',
            style: TextStyle(
              color: Colors.white,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          content: Text(
            '${_selectedApps.length} app(s) '
            'will be locked for '
            '$_selectedDuration minutes.',
            style: const TextStyle(
              color: textSecondary,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'CANCEL',
              ),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor: blue,
                foregroundColor:
                    Colors.white,
              ),
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                'START',
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  // ------------------------------------------------------------
  // FINISHED DIALOG
  // ------------------------------------------------------------

  Future<void> _showFinishedDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: card,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Container(
                width: 75,
                height: 75,
                decoration:
                    BoxDecoration(
                  shape:
                      BoxShape.circle,
                  color:
                      blue.withValues(
                    alpha: .12,
                  ),
                  border:
                      Border.all(
                    color: blue,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.check,
                  color: blue,
                  size: 40,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Self Lock Complete',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Your selected applications '
                'are available again.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  color: textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        blue,
                    foregroundColor:
                        Colors.white,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 14,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(
                      dialogContext,
                    ).pop();
                  },
                  child: const Text(
                    'DONE',
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // MESSAGE
  // ------------------------------------------------------------

  void _showMessage(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    if (_loading) {
      return _buildLoading();
    }

    if (_permission !=
        BlockerPermissionStatus.granted) {
      return _buildPermissionPage();
    }

    if (_lockEndTime != null) {
      return _buildActivePage();
    }

    return _buildMainPage();
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoading() {
    return const Scaffold(
      backgroundColor: background,
      body: Center(
        child:
            CircularProgressIndicator(
          color: blue,
        ),
      ),
    );
  }

  // ============================================================
  // PERMISSION PAGE
  // ============================================================

  Widget _buildPermissionPage() {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Self Lock',
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Container(
                width: 95,
                height: 95,
                decoration:
                    BoxDecoration(
                  shape:
                      BoxShape.circle,
                  color:
                      blue.withValues(
                    alpha: .12,
                  ),
                  border:
                      Border.all(
                    color: blue,
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: blue,
                  size: 45,
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Permission Required',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'PASA needs Android permission to '
                'detect and block the applications '
                'you choose.',
                textAlign:
                    TextAlign.center,
                style: TextStyle(
                  color: textSecondary,
                  height: 1.5,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(15),
                decoration:
                    BoxDecoration(
                  color:
                      const Color(0xFF101010),
                  borderRadius:
                      BorderRadius.circular(
                    13,
                  ),
                  border:
                      Border.all(
                    color: border,
                  ),
                ),
                child: const Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      'Android setup',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 9),
                    Text(
                      '1. Press Grant Permission.\n'
                      '2. Android Settings will open.\n'
                      '3. Enable PASA under Accessibility.\n'
                      '4. Return to PASA.\n'
                      '5. Press Grant Permission again '
                      'if required.',
                      style: TextStyle(
                        color:
                            textSecondary,
                        height: 1.55,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor: blue,
                    foregroundColor:
                        Colors.white,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        13,
                      ),
                    ),
                  ),
                  onPressed:
                      _requestingPermission
                          ? null
                          : _requestPermission,
                  child:
                      _requestingPermission
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color:
                                    Colors.white,
                              ),
                            )
                          : const Text(
                              'GRANT PERMISSION',
                              style:
                                  TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                ),
              ),

              const SizedBox(height: 12),

              TextButton(
                onPressed:
                    _refreshPermission,
                child: const Text(
                  'CHECK PERMISSION AGAIN',
                  style: TextStyle(
                    color: blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MAIN PAGE
  // ============================================================

  Widget _buildMainPage() {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Self Lock',
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadApps,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding:
                  const EdgeInsets.only(
                bottom: 10,
              ),
              children: [
                _buildHeader(),

                _buildAppsSection(),

                _buildDurationSection(),
              ],
            ),
          ),

          _buildStartButton(),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      margin:
          const EdgeInsets.fromLTRB(
        20,
        8,
        20,
        20,
      ),
      padding:
          const EdgeInsets.all(20),
      decoration:
          BoxDecoration(
        color: card,
        borderRadius:
            BorderRadius.circular(18),
        border:
            Border.all(
          color: border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration:
                BoxDecoration(
              color: blue,
              borderRadius:
                  BorderRadius.circular(
                16,
              ),
            ),
            child: const Icon(
              Icons.lock,
              color: Colors.white,
              size: 28,
            ),
          ),

          const SizedBox(width: 15),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  'Stay Focused',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Choose apps and lock them '
                  'for a period of time.',
                  style: TextStyle(
                    color:
                        textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // APPS SECTION
  // ============================================================

  Widget _buildAppsSection() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
            children: [
              const Text(
                'Applications',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              Text(
                '${_selectedApps.length} selected',
                style: const TextStyle(
                  color: blue,
                  fontSize: 12,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _buildSearch(),

          const SizedBox(height: 12),

          _buildAppList(),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearch() {
    return Container(
      height: 46,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      decoration:
          BoxDecoration(
        color: card,
        borderRadius:
            BorderRadius.circular(12),
        border:
            Border.all(
          color: border,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            color:
                Color(0xFF666666),
            size: 20,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: TextField(
              onChanged:
                  (String value) {
                setState(() {
                  _searchText =
                      value;
                });
              },
              style:
                  const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
              cursorColor: blue,
              decoration:
                  const InputDecoration(
                border:
                    InputBorder.none,
                hintText:
                    'Search apps...',
                hintStyle:
                    TextStyle(
                  color:
                      Color(0xFF666666),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // APP LIST
  // ============================================================

  Widget _buildAppList() {
    if (_loadingApps) {
      return Container(
        padding:
            const EdgeInsets.all(35),
        child: const Center(
          child:
              CircularProgressIndicator(
            color: blue,
          ),
        ),
      );
    }

    final List<dynamic> apps =
        _filteredApps;

    if (apps.isEmpty) {
      return Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(30),
        decoration:
            BoxDecoration(
          color:
              const Color(0xFF0D0D0D),
          borderRadius:
              BorderRadius.circular(16),
          border:
              Border.all(
            color: border,
          ),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.apps_outlined,
              color:
                  Color(0xFF555555),
              size: 40,
            ),
            SizedBox(height: 12),
            Text(
              'No applications found.',
              style: TextStyle(
                color:
                    textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration:
          BoxDecoration(
        color:
            const Color(0xFF0D0D0D),
        borderRadius:
            BorderRadius.circular(16),
        border:
            Border.all(
          color: border,
        ),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(),
        itemCount: apps.length,
        itemBuilder:
            (
          BuildContext context,
          int index,
        ) {
          return _buildAppTile(
            apps[index],
            index,
            apps.length,
          );
        },
      ),
    );
  }

  // ============================================================
  // APP TILE
  // ============================================================

  Widget _buildAppTile(
    dynamic app,
    int index,
    int total,
  ) {
    final String packageName =
        _getPackageName(app);

    final bool selected =
        _selectedApps.contains(
      packageName,
    );

    final Uint8List? icon =
        _getIcon(app);

    return InkWell(
      onTap: () {
        _toggleApp(app);
      },
      child: Container(
        height: 70,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        decoration:
            BoxDecoration(
          color: selected
              ? const Color(0xFF101A20)
              : Colors.transparent,
          border: index <
                  total - 1
              ? const Border(
                  bottom:
                      BorderSide(
                    color:
                        Color(0xFF1C1C1C),
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            _buildIcon(icon),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    _getAppName(app),
                    maxLines: 1,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(
                    height: 3,
                  ),

                  Text(
                    packageName,
                    maxLines: 1,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        const TextStyle(
                      color:
                          Color(0xFF777777),
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            Container(
              width: 23,
              height: 23,
              decoration:
                  BoxDecoration(
                color: selected
                    ? blue
                    : Colors
                        .transparent,
                borderRadius:
                    BorderRadius
                        .circular(
                  7,
                ),
                border:
                    Border.all(
                  color: selected
                      ? blue
                      : const Color(
                          0xFF555555,
                        ),
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check,
                      color:
                          Colors.white,
                      size: 15,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ICON
  // ============================================================

  Widget _buildIcon(
    Uint8List? icon,
  ) {
    if (icon != null &&
        icon.isNotEmpty) {
      return ClipRRect(
        borderRadius:
            BorderRadius.circular(12),
        child: Image.memory(
          icon,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder:
              (
            BuildContext context,
            Object error,
            StackTrace? stackTrace,
          ) {
            return _defaultIcon();
          },
        ),
      );
    }

    return _defaultIcon();
  }

  Widget _defaultIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration:
          BoxDecoration(
        color:
            const Color(0xFF222222),
        borderRadius:
            BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.apps,
        color: Colors.white,
      ),
    );
  }

  // ============================================================
  // DURATION
  // ============================================================

  Widget _buildDurationSection() {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        20,
        22,
        20,
        10,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Lock Duration',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          SingleChildScrollView(
            scrollDirection:
                Axis.horizontal,
            child: Row(
              children:
                  _durations.map(
                (int minutes) {
                  final bool selected =
                      _selectedDuration ==
                          minutes;

                  final String text =
                      minutes < 60
                          ? '$minutes min'
                          : '${minutes ~/ 60} hour';

                  return Padding(
                    padding:
                        const EdgeInsets.only(
                      right: 8,
                    ),
                    child:
                        GestureDetector(
                      onTap: () {
                        _selectDuration(
                          minutes,
                        );
                      },
                      child:
                          AnimatedContainer(
                        duration:
                            const Duration(
                          milliseconds: 150,
                        ),
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 17,
                          vertical: 11,
                        ),
                        decoration:
                            BoxDecoration(
                          color: selected
                              ? blue
                              : card,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            11,
                          ),
                          border:
                              Border.all(
                            color: selected
                                ? blue
                                : border,
                          ),
                        ),
                        child: Text(
                          text,
                          style:
                              TextStyle(
                            color: selected
                                ? Colors
                                    .white
                                : const Color(
                                    0xFFAAAAAA,
                                  ),
                            fontWeight:
                                selected
                                    ? FontWeight
                                        .w600
                                    : FontWeight
                                        .normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // START BUTTON
  // ============================================================

  Widget _buildStartButton() {
    return SafeArea(
      child: Container(
        color: background,
        padding:
            const EdgeInsets.fromLTRB(
          20,
          10,
          20,
          18,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  _selectedApps.isEmpty
                      ? const Color(
                          0xFF333333,
                        )
                      : blue,
              foregroundColor:
                  Colors.white,
              elevation: 0,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  13,
                ),
              ),
            ),
            onPressed:
                _startingLock ||
                        _selectedApps
                            .isEmpty
                    ? null
                    : _startLock,
            child: _startingLock
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                      color:
                          Colors.white,
                    ),
                  )
                : Text(
                    _selectedApps.isEmpty
                        ? 'SELECT AN APP'
                        : '🔒 START SELF LOCK',
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ACTIVE LOCK PAGE
  // ============================================================

  Widget _buildActivePage() {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.all(24),
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(25),
              decoration:
                  BoxDecoration(
                color: card,
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
                border:
                    Border.all(
                  color: border,
                ),
              ),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration:
                        BoxDecoration(
                      shape:
                          BoxShape.circle,
                      color:
                          blue.withValues(
                        alpha: .12,
                      ),
                      border:
                          Border.all(
                        color: blue,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.lock,
                      color: blue,
                      size: 35,
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  const Text(
                    'Self Lock Active',
                    style: TextStyle(
                      color:
                          Colors.white,
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 7,
                  ),

                  const Text(
                    'Stay away from your '
                    'selected applications.',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      color:
                          textSecondary,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  Text(
                    _formatDuration(
                      _remaining,
                    ),
                    style:
                        const TextStyle(
                      color:
                          Colors.white,
                      fontSize: 52,
                      fontWeight:
                          FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(
                    height: 22,
                  ),

                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      vertical: 13,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFF1B1B1B,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                    child: Text(
                      '${_selectedApps.length} '
                      'application(s) locked',
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        color:
                            Color(0xFFAAAAAA),
                        fontSize: 13,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 25,
                  ),

                  const Text(
                    'Focus on what matters. 💪',
                    style:
                        TextStyle(
                      color: blue,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FORMAT TIME
  // ============================================================

  String _formatDuration(
    Duration duration,
  ) {
    final int hours =
        duration.inHours;

    final int minutes =
        duration.inMinutes % 60;

    final int seconds =
        duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _timer?.cancel();

    WidgetsBinding.instance
        .removeObserver(this);

    super.dispose();
  }
}