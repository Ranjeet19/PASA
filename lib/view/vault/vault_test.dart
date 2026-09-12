
// import 'dart:convert';
// import 'dart:math';

// import 'package:crypto/crypto.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:hive_flutter/hive_flutter.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await VaultStore.init();
//   runApp(const VaultApp());
// }

// /* =========================
//    SECURE LOCAL STORAGE
//    ========================= */

// class VaultStore {
//   static const _boxName = 'pasa_vault';
//   static const _keyName = 'pasa_vault_key';
//   static const _pinName = 'pasa_vault_pin';
//   static const _saltName = 'pasa_vault_salt';

//   static const _secure = FlutterSecureStorage();
//   static Box<Map>? _box;

//   static Future<void> init() async {
//     await Hive.initFlutter();

//     var key = await _secure.read(key: _keyName);

//     if (key == null) {
//       final r = Random.secure();
//       final bytes = List<int>.generate(32, (_) => r.nextInt(256));
//       key = base64UrlEncode(bytes);
//       await _secure.write(key: _keyName, value: key);
//     }

//     _box = await Hive.openBox<Map>(
//       _boxName,
//       encryptionCipher: HiveAesCipher(base64Url.decode(key)),
//     );
//   }

//   static Box<Map> get box => _box!;

//   static Future<bool> hasPin() async =>
//       (await _secure.read(key: _pinName)) != null;

//   static String _hash(String pin, String salt) =>
//       sha256.convert(utf8.encode('$salt:$pin')).toString();

//   static Future<void> createPin(String pin) async {
//     final r = Random.secure();
//     final salt = base64UrlEncode(
//       List<int>.generate(32, (_) => r.nextInt(256)),
//     );
//     await _secure.write(key: _saltName, value: salt);
//     await _secure.write(
//       key: _pinName,
//       value: _hash(pin, salt),
//     );
//   }

//   static Future<bool> verifyPin(String pin) async {
//     final salt = await _secure.read(key: _saltName);
//     final saved = await _secure.read(key: _pinName);
//     if (salt == null || saved == null) return false;
//     return _hash(pin, salt) == saved;
//   }

//   static Future<void> changePin(
//     String oldPin,
//     String newPin,
//   ) async {
//     if (!await verifyPin(oldPin)) {
//       throw Exception('Current PIN is incorrect.');
//     }
//     await createPin(newPin);
//   }

//   static Future<void> save(Map<String, dynamic> data) async {
//     final id =
//         '${DateTime.now().microsecondsSinceEpoch}_${Random().nextInt(99999)}';
//     data['id'] = id;
//     data['createdAt'] = DateTime.now().toIso8601String();
//     await box.put(id, data);
//   }

//   static List<Map<String, dynamic>> get(String type) {
//     final result = box.values
//         .map((e) => Map<String, dynamic>.from(e))
//         .where((e) => e['type'] == type)
//         .toList();

//     result.sort(
//       (a, b) => b['createdAt']
//           .toString()
//           .compareTo(a['createdAt'].toString()),
//     );
//     return result;
//   }

//   static Future<void> remove(String id) => box.delete(id);

//   static Future<void> clear() => box.clear();
// }

// /* =========================
//    APP
//    ========================= */

// class VaultApp extends StatelessWidget {
//   const VaultApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'PASA Vault',
//       theme: ThemeData(
//         useMaterial3: true,
//         scaffoldBackgroundColor: const Color(0xFFF7F7F7),
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: Colors.black,
//           brightness: Brightness.light,
//         ),
//       ),
//       home: const DemoHome(),
//     );
//   }
// }

// /* =========================
//    DEMO HOME
//    ========================= */

// class DemoHome extends StatelessWidget {
//   const DemoHome({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'PASA',
//           style: TextStyle(fontWeight: FontWeight.w900),
//         ),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 88,
//               height: 88,
//               decoration: BoxDecoration(
//                 color: Colors.black,
//                 borderRadius: BorderRadius.circular(28),
//               ),
//               child: const Icon(
//                 Icons.lock_rounded,
//                 color: Colors.white,
//                 size: 42,
//               ),
//             ),
//             const SizedBox(height: 22),
//             const Text(
//               'Secure Vault',
//               style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.w900,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Passwords, notes, cards and private details',
//               style: TextStyle(color: Colors.grey.shade600),
//             ),
//             const SizedBox(height: 28),
//             SizedBox(
//               width: 230,
//               height: 54,
//               child: FilledButton(
//                 style: FilledButton.styleFrom(
//                   backgroundColor: Colors.black,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(17),
//                   ),
//                 ),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (_) => const VaultGate(),
//                     ),
//                   );
//                 },
//                 child: const Text(
//                   'Open Vault',
//                   style: TextStyle(fontWeight: FontWeight.w800),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /* =========================
//    GATE
//    ========================= */

// class VaultGate extends StatefulWidget {
//   const VaultGate({super.key});

//   @override
//   State<VaultGate> createState() => _VaultGateState();
// }

// class _VaultGateState extends State<VaultGate> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) => open());
//   }

//   Future<void> open() async {
//     final hasPin = await VaultStore.hasPin();

//     if (!mounted) return;

//     final ok = await Navigator.push<bool>(
//       context,
//       MaterialPageRoute(
//         builder: (_) => PinPage(setup: !hasPin),
//       ),
//     );

//     if (!mounted) return;

//     if (ok == true) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (_) => const VaultPage(),
//         ),
//       );
//     } else {
//       Navigator.pop(context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) =>
//       const Scaffold(
//         body: Center(
//           child: CircularProgressIndicator(
//             color: Colors.black,
//           ),
//         ),
//       );
// }

// /* =========================
//    PIN
//    ========================= */

// class PinPage extends StatefulWidget {
//   final bool setup;

//   const PinPage({super.key, required this.setup});

//   @override
//   State<PinPage> createState() => _PinPageState();
// }

// class _PinPageState extends State<PinPage> {
//   String pin = '';
//   String first = '';
//   String error = '';

//   bool get confirming =>
//       widget.setup && first.length == 4;

//   String get shown => widget.setup ? (confirming ? pin : first) : pin;

//   void add(String n) {
//     if (widget.setup) {
//       if (confirming) {
//         if (pin.length < 4) pin += n;
//       } else if (first.length < 4) {
//         first += n;
//       }
//     } else if (pin.length < 4) {
//       pin += n;
//     }

//     setState(() => error = '');

//     if (!widget.setup && pin.length == 4) verify();
//     if (widget.setup && confirming && pin.length == 4) create();
//   }

//   void backspace() {
//     setState(() {
//       if (confirming && pin.isNotEmpty) {
//         pin = pin.substring(0, pin.length - 1);
//       } else if (widget.setup && first.isNotEmpty) {
//         first = first.substring(0, first.length - 1);
//       } else if (!widget.setup && pin.isNotEmpty) {
//         pin = pin.substring(0, pin.length - 1);
//       }
//     });
//   }

//   Future<void> verify() async {
//     if (await VaultStore.verifyPin(pin)) {
//       if (mounted) Navigator.pop(context, true);
//     } else {
//       setState(() {
//         pin = '';
//         error = 'Incorrect PIN';
//       });
//     }
//   }

//   Future<void> create() async {
//     if (pin != first) {
//       setState(() {
//         pin = '';
//         error = 'PINs do not match';
//       });
//       return;
//     }

//     await VaultStore.createPin(first);

//     if (mounted) Navigator.pop(context, true);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F7F7),
//       appBar: AppBar(
//         title: const Text(
//           'Vault',
//           style: TextStyle(fontWeight: FontWeight.w900),
//         ),
//         leading: IconButton(
//           onPressed: () => Navigator.pop(context, false),
//           icon: const Icon(Icons.close_rounded),
//         ),
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             const Spacer(),
//             Container(
//               width: 76,
//               height: 76,
//               decoration: BoxDecoration(
//                 color: Colors.black,
//                 borderRadius: BorderRadius.circular(25),
//               ),
//               child: const Icon(
//                 Icons.lock_rounded,
//                 color: Colors.white,
//                 size: 34,
//               ),
//             ),
//             const SizedBox(height: 22),
//             Text(
//               widget.setup
//                   ? (confirming ? 'Confirm PIN' : 'Create PIN')
//                   : 'Enter PIN',
//               style: const TextStyle(
//                 fontSize: 26,
//                 fontWeight: FontWeight.w900,
//               ),
//             ),
//             const SizedBox(height: 7),
//             Text(
//               widget.setup
//                   ? (confirming
//                       ? 'Enter the same 4 digits again'
//                       : 'Choose a 4-digit PIN for your vault')
//                   : 'Enter your 4-digit vault PIN',
//               style: TextStyle(color: Colors.grey.shade600),
//             ),
//             const SizedBox(height: 24),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: List.generate(
//                 4,
//                 (i) => Container(
//                   margin: const EdgeInsets.all(7),
//                   width: 13,
//                   height: 13,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: i < shown.length
//                         ? Colors.black
//                         : Colors.white,
//                     border: Border.all(color: Colors.black),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: 22,
//               child: Text(
//                 error,
//                 style: const TextStyle(
//                   color: Colors.red,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ),
//             const Spacer(),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 42),
//               child: GridView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: 12,
//                 gridDelegate:
//                     const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 3,
//                   mainAxisSpacing: 12,
//                   crossAxisSpacing: 12,
//                   childAspectRatio: 1.3,
//                 ),
//                 itemBuilder: (_, i) {
//                   const numbers = [
//                     '1',
//                     '2',
//                     '3',
//                     '4',
//                     '5',
//                     '6',
//                     '7',
//                     '8',
//                     '9',
//                     '',
//                     '0',
//                     '⌫',
//                   ];

//                   final value = numbers[i];

//                   if (value.isEmpty) return const SizedBox();

//                   return _Pad(
//                     text: value,
//                     icon: value == '⌫'
//                         ? Icons.backspace_outlined
//                         : null,
//                     onTap: value == '⌫'
//                         ? backspace
//                         : () => add(value),
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 35),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /* =========================
//    VAULT
//    ========================= */

// class VaultPage extends StatefulWidget {
//   const VaultPage({super.key});

//   @override
//   State<VaultPage> createState() => _VaultPageState();
// }

// class _VaultPageState extends State<VaultPage>
//     with WidgetsBindingObserver {
//   int tab = 0;
//   bool locked = false;

//   final names = ['Accounts', 'Notes', 'Cards', 'Custom'];
//   final types = ['account', 'note', 'card', 'custom'];

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.paused ||
//         state == AppLifecycleState.inactive) {
//       locked = true;
//     }
//   }

//   Future<bool> unlock() async {
//     if (!locked) return true;

//     final ok = await Navigator.push<bool>(
//       context,
//       MaterialPageRoute(
//         builder: (_) => const PinPage(setup: false),
//       ),
//     );

//     if (ok == true) {
//       locked = false;
//       return true;
//     }
//     return false;
//   }

//   Future<void> addItem() async {
//     if (!await unlock() || !mounted) return;

//     Widget page;

//     switch (tab) {
//       case 0:
//         page = const AddAccount();
//         break;
//       case 1:
//         page = const AddNote();
//         break;
//       case 2:
//         page = const AddCard();
//         break;
//       default:
//         page = const AddCustom();
//     }

//     await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => page),
//     );

//     setState(() {});
//   }

//   Future<void> settings() async {
//     if (!await unlock() || !mounted) return;

//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => const VaultSettings(),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         locked = true;
//         return true;
//       },
//       child: Scaffold(
//         backgroundColor: const Color(0xFFF7F7F7),
//         appBar: AppBar(
//           automaticallyImplyLeading: false,
//           title: const Text(
//             'Vault',
//             style: TextStyle(
//               fontSize: 23,
//               fontWeight: FontWeight.w900,
//             ),
//           ),
//           actions: [
//             IconButton(
//               tooltip: 'Lock',
//               onPressed: () {
//                 locked = true;
//                 Navigator.pop(context);
//               },
//               icon: const Icon(Icons.lock_outline_rounded),
//             ),
//             IconButton(
//               tooltip: 'Settings',
//               onPressed: settings,
//               icon: const Icon(Icons.settings_outlined),
//             ),
//             const SizedBox(width: 6),
//           ],
//         ),
//         body: Column(
//           children: [
//             const SizedBox(height: 8),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 13),
//               child: Row(
//                 children: List.generate(
//                   names.length,
//                   (i) => Expanded(
//                     child: Padding(
//                       padding:
//                           const EdgeInsets.symmetric(horizontal: 3),
//                       child: GestureDetector(
//                         onTap: () => setState(() => tab = i),
//                         child: AnimatedContainer(
//                           duration: const Duration(milliseconds: 180),
//                           padding:
//                               const EdgeInsets.symmetric(vertical: 11),
//                           decoration: BoxDecoration(
//                             color:
//                                 tab == i ? Colors.black : Colors.white,
//                             borderRadius: BorderRadius.circular(13),
//                             border: Border.all(
//                               color: tab == i
//                                   ? Colors.black
//                                   : const Color(0xFFE4E4E4),
//                             ),
//                           ),
//                           child: Center(
//                             child: Text(
//                               names[i],
//                               style: TextStyle(
//                                 fontSize: 11,
//                                 fontWeight: FontWeight.w800,
//                                 color: tab == i
//                                     ? Colors.white
//                                     : Colors.black,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 14),
//             Expanded(
//               child: VaultList(
//                 type: types[tab],
//                 refresh: () => setState(() {}),
//               ),
//             ),
//           ],
//         ),
//         floatingActionButton: FloatingActionButton(
//           backgroundColor: Colors.black,
//           foregroundColor: Colors.white,
//           onPressed: addItem,
//           child: const Icon(Icons.add_rounded),
//         ),
//       ),
//     );
//   }
// }

// /* =========================
//    LIST
//    ========================= */

// class VaultList extends StatelessWidget {
//   final String type;
//   final VoidCallback refresh;

//   const VaultList({
//     super.key,
//     required this.type,
//     required this.refresh,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final items = VaultStore.get(type);

//     if (items.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 82,
//               height: 82,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(27),
//                 border: Border.all(
//                   color: const Color(0xFFE4E4E4),
//                 ),
//               ),
//               child: Icon(
//                 type == 'account'
//                     ? Icons.key_rounded
//                     : type == 'note'
//                         ? Icons.notes_rounded
//                         : type == 'card'
//                             ? Icons.credit_card_rounded
//                             : Icons.tune_rounded,
//                 size: 32,
//               ),
//             ),
//             const SizedBox(height: 18),
//             Text(
//               'No ${type == 'account' ? 'accounts' : '$type items'} saved',
//               style: const TextStyle(
//                 fontWeight: FontWeight.w800,
//               ),
//             ),
//             const SizedBox(height: 6),
//             Text(
//               'Tap + to securely add one',
//               style: TextStyle(
//                 color: Colors.grey.shade600,
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.fromLTRB(14, 0, 14, 100),
//       itemCount: items.length,
//       itemBuilder: (_, i) => VaultItem(
//         item: items[i],
//         refresh: refresh,
//       ),
//     );
//   }
// }

// class VaultItem extends StatefulWidget {
//   final Map<String, dynamic> item;
//   final VoidCallback refresh;

//   const VaultItem({
//     super.key,
//     required this.item,
//     required this.refresh,
//   });

//   @override
//   State<VaultItem> createState() => _VaultItemState();
// }

// class _VaultItemState extends State<VaultItem> {
//   bool expanded = false;
//   bool visible = false;

//   String get type => widget.item['type'].toString();

//   String get title {
//     switch (type) {
//       case 'account':
//         return widget.item['service'] ?? 'Account';
//       case 'note':
//         return widget.item['title'] ?? 'Note';
//       case 'card':
//         return widget.item['cardholder'] ?? 'Card';
//       default:
//         return widget.item['title'] ?? 'Custom';
//     }
//   }

//   String get subtitle {
//     switch (type) {
//       case 'account':
//         return widget.item['identifier'] ?? '';
//       case 'note':
//         return 'Secure note';
//       case 'card':
//         return '•••• ${widget.item['lastFour'] ?? '----'}';
//       default:
//         return 'Custom details';
//     }
//   }

//   IconData get icon {
//     switch (type) {
//       case 'account':
//         return Icons.key_rounded;
//       case 'note':
//         return Icons.notes_rounded;
//       case 'card':
//         return Icons.credit_card_rounded;
//       default:
//         return Icons.tune_rounded;
//     }
//   }

//   Future<void> copy(String value) async {
//     await Clipboard.setData(ClipboardData(text: value));
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Copied to clipboard'),
//         duration: Duration(seconds: 1),
//       ),
//     );
//   }

//   Future<void> delete() async {
//     await VaultStore.remove(widget.item['id'].toString());
//     widget.refresh();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 11),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: const Color(0xFFE3E3E3)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(.025),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           InkWell(
//             borderRadius: BorderRadius.circular(20),
//             onTap: () => setState(() => expanded = !expanded),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 13,
//                 vertical: 11,
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 46,
//                     height: 46,
//                     decoration: BoxDecoration(
//                       color: Colors.black,
//                       borderRadius: BorderRadius.circular(15),
//                     ),
//                     child: Icon(
//                       icon,
//                       color: Colors.white,
//                       size: 21,
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           title,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w900,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           subtitle,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             fontSize: 12,
//                             color: Colors.grey.shade600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: delete,
//                     icon: const Icon(
//                       Icons.delete_outline_rounded,
//                       size: 20,
//                     ),
//                   ),
//                   Icon(
//                     expanded
//                         ? Icons.keyboard_arrow_up_rounded
//                         : Icons.keyboard_arrow_down_rounded,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           if (expanded)
//             Padding(
//               padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
//               child: details(),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget details() {
//     switch (type) {
//       case 'account':
//         return Column(
//           children: [
//             field('Email / ID', widget.item['identifier'] ?? ''),
//             if ((widget.item['username'] ?? '')
//                 .toString()
//                 .isNotEmpty)
//               field('Username', widget.item['username']),

//             if ((widget.item['additionalInfo'] ?? '')
//                 .toString()
//                 .trim()
//                 .isNotEmpty)
//               field(
//                 'Additional Information',
//                 widget.item['additionalInfo'],
//               ),

//             Container(
//               margin: const EdgeInsets.only(top: 8),
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 12,
//                 vertical: 8,
//               ),
//               decoration: BoxDecoration(
//                 color: const Color(0xFFF4F4F4),
//                 borderRadius: BorderRadius.circular(13),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment:
//                           CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'PASSWORD',
//                           style: TextStyle(
//                             fontSize: 9,
//                             fontWeight: FontWeight.w900,
//                             color: Colors.grey.shade600,
//                           ),
//                         ),
//                         const SizedBox(height: 5),
//                         Text(
//                           visible
//                               ? widget.item['password']
//                               : '••••••••••••',
//                           style: const TextStyle(
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: () =>
//                         setState(() => visible = !visible),
//                     icon: Icon(
//                       visible
//                           ? Icons.visibility_off_outlined
//                           : Icons.visibility_outlined,
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: () =>
//                         copy(widget.item['password']),
//                     icon: const Icon(Icons.copy_outlined),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         );

//       case 'note':
//         return field(
//           'SECURE NOTE',
//           widget.item['content'] ?? '',
//         );

//       case 'card':
//         return Column(
//           children: [
//             field('CARDHOLDER', widget.item['cardholder'] ?? ''),
//             field('LAST 4', widget.item['lastFour'] ?? ''),
//             field('EXPIRY', widget.item['expiry'] ?? ''),
//             field('TYPE', widget.item['cardType'] ?? ''),
//           ],
//         );

//       default:
//         final map = Map<String, dynamic>.from(
//           widget.item['fields'] ?? {},
//         );
//         return Column(
//           children: map.entries
//               .map((e) => field(e.key, e.value.toString()))
//               .toList(),
//         );
//     }
//   }

//   Widget field(String label, String value) {
//     return Container(
//       width: double.infinity,
//       margin: const EdgeInsets.only(top: 8),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF4F4F4),
//         borderRadius: BorderRadius.circular(13),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label.toUpperCase(),
//                   style: TextStyle(
//                     fontSize: 9,
//                     fontWeight: FontWeight.w900,
//                     color: Colors.grey.shade600,
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 SelectableText(
//                   value,
//                   style: const TextStyle(
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           IconButton(
//             onPressed: () => copy(value),
//             icon: const Icon(
//               Icons.copy_outlined,
//               size: 17,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /* =========================
//    ADD FORMS
//    ========================= */

// class AddAccount extends StatefulWidget {
//   const AddAccount({super.key});

//   @override
//   State<AddAccount> createState() => _AddAccountState();
// }

// class _AddAccountState extends State<AddAccount> {
//   final service = TextEditingController();
//   final identifier = TextEditingController();
//   final username = TextEditingController();
//   final password = TextEditingController();

//   // Optional field for recovery codes, backup keys, 2FA details,
//   // recovery email, security questions, or anything else.
//   final additionalInfo = TextEditingController();

//   bool hide = true;

//   @override
//   void dispose() {
//     service.dispose();
//     identifier.dispose();
//     username.dispose();
//     password.dispose();
//     additionalInfo.dispose();
//     super.dispose();
//   }

//   Future<void> save() async {
//     if (service.text.trim().isEmpty ||
//         identifier.text.trim().isEmpty ||
//         password.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text(
//             'Service, email/ID and password are required.',
//           ),
//         ),
//       );
//       return;
//     }

//     await VaultStore.save({
//       'type': 'account',
//       'service': service.text.trim(),
//       'identifier': identifier.text.trim(),
//       'username': username.text.trim(),
//       'password': password.text,
//       'additionalInfo': additionalInfo.text.trim(),
//     });

//     if (mounted) Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FormPage(
//       title: 'Add Account',
//       children: [
//         label('SERVICE / APP NAME'),
//         TextField(
//           controller: service,
//           textInputAction: TextInputAction.next,
//           decoration: input('Instagram', Icons.apps_rounded),
//         ),

//         label('NAME OR EMAIL / IDENTIFIER'),
//         TextField(
//           controller: identifier,
//           keyboardType: TextInputType.emailAddress,
//           textInputAction: TextInputAction.next,
//           decoration:
//               input('name@example.com', Icons.email_outlined),
//         ),

//         label('USERNAME / UID'),
//         TextField(
//           controller: username,
//           textInputAction: TextInputAction.next,
//           decoration:
//               input('username', Icons.person_outline_rounded),
//         ),

//         label('PASSWORD'),
//         TextField(
//           controller: password,
//           obscureText: hide,
//           textInputAction: TextInputAction.next,
//           decoration: input(
//             'Password',
//             Icons.lock_outline_rounded,
//           ).copyWith(
//             suffixIcon: IconButton(
//               onPressed: () => setState(() => hide = !hide),
//               icon: Icon(
//                 hide
//                     ? Icons.visibility_outlined
//                     : Icons.visibility_off_outlined,
//               ),
//             ),
//           ),
//         ),

//         // Extra field requested for account-specific information.
//         label('ADDITIONAL INFORMATION (OPTIONAL)'),
//         TextField(
//           controller: additionalInfo,
//           minLines: 3,
//           maxLines: 7,
//           keyboardType: TextInputType.multiline,
//           decoration: input(
//             'Recovery code, backup key, 2FA details, recovery email, '
//             'security question, or anything else...',
//             Icons.note_alt_outlined,
//           ),
//         ),

//         const SizedBox(height: 8),

//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(14),
//             border: Border.all(
//               color: const Color(0xFFE3E3E3),
//             ),
//           ),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Icon(Icons.info_outline_rounded, size: 18),
//               const SizedBox(width: 9),
//               Expanded(
//                 child: Text(
//                   'Optional: use this field for any extra private '
//                   'information related to this account.',
//                   style: TextStyle(
//                     fontSize: 11,
//                     height: 1.4,
//                     color: Colors.grey.shade700,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),

//         const SizedBox(height: 25),
//         button('Save Account', save),
//       ],
//     );
//   }
// }

// class AddNote extends StatefulWidget {
//   const AddNote({super.key});

//   @override
//   State<AddNote> createState() => _AddNoteState();
// }

// class _AddNoteState extends State<AddNote> {
//   final title = TextEditingController();
//   final content = TextEditingController();

//   Future<void> save() async {
//     if (title.text.trim().isEmpty) return;

//     await VaultStore.save({
//       'type': 'note',
//       'title': title.text.trim(),
//       'content': content.text,
//     });

//     if (mounted) Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FormPage(
//       title: 'Add Secure Note',
//       children: [
//         label('NOTE TITLE'),
//         TextField(
//           controller: title,
//           decoration:
//               input('Personal note', Icons.title_rounded),
//         ),
//         label('SECURE CONTENT'),
//         TextField(
//           controller: content,
//           minLines: 9,
//           maxLines: 15,
//           decoration:
//               input('Write anything private here...'),
//         ),
//         const SizedBox(height: 25),
//         button('Save Note', save),
//       ],
//     );
//   }
// }

// class AddCard extends StatefulWidget {
//   const AddCard({super.key});

//   @override
//   State<AddCard> createState() => _AddCardState();
// }

// class _AddCardState extends State<AddCard> {
//   final holder = TextEditingController();
//   final last4 = TextEditingController();
//   final expiry = TextEditingController();
//   String type = 'VISA';

//   Future<void> save() async {
//     if (holder.text.trim().isEmpty ||
//         last4.text.trim().isEmpty) {
//       return;
//     }

//     await VaultStore.save({
//       'type': 'card',
//       'cardholder': holder.text.trim(),
//       'lastFour': last4.text.trim(),
//       'expiry': expiry.text.trim(),
//       'cardType': type,
//     });

//     if (mounted) Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FormPage(
//       title: 'Add Card',
//       children: [
//         label('CARDHOLDER NAME'),
//         TextField(
//           controller: holder,
//           decoration:
//               input('John Doe', Icons.person_outline_rounded),
//         ),
//         label('CARD NUMBER — LAST 4'),
//         TextField(
//           controller: last4,
//           keyboardType: TextInputType.number,
//           maxLength: 4,
//           decoration: input(
//             '1234',
//             Icons.credit_card_outlined,
//           ).copyWith(counterText: ''),
//         ),
//         label('EXPIRY DATE'),
//         TextField(
//           controller: expiry,
//           decoration:
//               input('MM/YY', Icons.date_range_outlined),
//         ),
//         label('CARD TYPE'),
//         Wrap(
//           spacing: 7,
//           children: ['VISA', 'MASTERCARD', 'AMEX', 'OTHER']
//               .map(
//                 (x) => ChoiceChip(
//                   label: Text(x),
//                   selected: type == x,
//                   selectedColor: Colors.black,
//                   labelStyle: TextStyle(
//                     color:
//                         type == x ? Colors.white : Colors.black,
//                     fontWeight: FontWeight.w800,
//                     fontSize: 10,
//                   ),
//                   onSelected: (_) => setState(() => type = x),
//                 ),
//               )
//               .toList(),
//         ),
//         const SizedBox(height: 25),
//         button('Save Card', save),
//       ],
//     );
//   }
// }

// class AddCustom extends StatefulWidget {
//   const AddCustom({super.key});

//   @override
//   State<AddCustom> createState() => _AddCustomState();
// }

// class _AddCustomState extends State<AddCustom> {
//   final title = TextEditingController();
//   final fields = <List<TextEditingController>>[];

//   void addField() {
//     setState(() {
//       fields.add([
//         TextEditingController(),
//         TextEditingController(),
//       ]);
//     });
//   }

//   Future<void> save() async {
//     if (title.text.trim().isEmpty) return;

//     final data = <String, String>{};

//     for (final pair in fields) {
//       final name = pair[0].text.trim();
//       if (name.isNotEmpty) data[name] = pair[1].text;
//     }

//     await VaultStore.save({
//       'type': 'custom',
//       'title': title.text.trim(),
//       'fields': data,
//     });

//     if (mounted) Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FormPage(
//       title: 'Custom Item',
//       children: [
//         label('ITEM NAME'),
//         TextField(
//           controller: title,
//           decoration: input(
//             'e.g. Netflix Recovery',
//             Icons.bookmark_outline_rounded,
//           ),
//         ),
//         const SizedBox(height: 18),
//         ...fields.asMap().entries.map(
//           (entry) {
//             final i = entry.key;
//             final pair = entry.value;

//             return Container(
//               margin: const EdgeInsets.only(bottom: 10),
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 border: Border.all(
//                   color: const Color(0xFFE3E3E3),
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       controller: pair[0],
//                       decoration: const InputDecoration(
//                         hintText: 'Field name',
//                         border: InputBorder.none,
//                       ),
//                     ),
//                   ),
//                   Container(
//                     width: 1,
//                     height: 34,
//                     color: const Color(0xFFE3E3E3),
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: TextField(
//                       controller: pair[1],
//                       decoration: const InputDecoration(
//                         hintText: 'Value',
//                         border: InputBorder.none,
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: () =>
//                         setState(() => fields.removeAt(i)),
//                     icon: const Icon(Icons.close_rounded),
//                   ),
//                 ],
//               ),
//             );
//           },
//         ),
//         OutlinedButton.icon(
//           onPressed: addField,
//           icon: const Icon(Icons.add_rounded),
//           label: const Text(
//             'Add Custom Field',
//             style: TextStyle(fontWeight: FontWeight.w800),
//           ),
//           style: OutlinedButton.styleFrom(
//             foregroundColor: Colors.black,
//             minimumSize: const Size.fromHeight(50),
//             side: const BorderSide(color: Colors.black),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(15),
//             ),
//           ),
//         ),
//         const SizedBox(height: 20),
//         button('Save Custom Item', save),
//       ],
//     );
//   }
// }

// /* =========================
//    SETTINGS / CHANGE PIN
//    ========================= */

// class VaultSettings extends StatelessWidget {
//   const VaultSettings({super.key});

//   Future<void> changePin(BuildContext context) async {
//     final oldPin = await Navigator.push<String>(
//       context,
//       MaterialPageRoute(
//         builder: (_) => const SimplePinPage(
//           title: 'Current PIN',
//           subtitle: 'Enter your existing PIN',
//         ),
//       ),
//     );

//     if (oldPin == null) return;

//     if (!await VaultStore.verifyPin(oldPin)) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Current PIN is incorrect.')),
//         );
//       }
//       return;
//     }

//     final newPin = await Navigator.push<String>(
//       context,
//       MaterialPageRoute(
//         builder: (_) => const SimplePinPage(
//           title: 'New PIN',
//           subtitle: 'Create your new 4-digit PIN',
//         ),
//       ),
//     );

//     if (newPin == null) return;

//     final confirm = await Navigator.push<String>(
//       context,
//       MaterialPageRoute(
//         builder: (_) => const SimplePinPage(
//           title: 'Confirm PIN',
//           subtitle: 'Enter your new PIN again',
//         ),
//       ),
//     );

//     if (confirm == null) return;

//     if (newPin != confirm) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('PINs do not match.')),
//         );
//       }
//       return;
//     }

//     await VaultStore.changePin(oldPin, newPin);

//     if (context.mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('PIN changed successfully.')),
//       );
//     }
//   }

//   Future<void> clear(BuildContext context) async {
//     final yes = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text(
//           'Delete all vault data?',
//           style: TextStyle(fontWeight: FontWeight.w900),
//         ),
//         content: const Text(
//           'All accounts, notes, cards and custom details will be deleted.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text(
//               'Cancel',
//               style: TextStyle(color: Colors.black),
//             ),
//           ),
//           FilledButton(
//             style: FilledButton.styleFrom(
//               backgroundColor: Colors.black,
//             ),
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Delete'),
//           ),
//         ],
//       ),
//     );

//     if (yes == true) {
//       await VaultStore.clear();
//       if (context.mounted) {
//         Navigator.pop(context);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F7F7),
//       appBar: AppBar(
//         title: const Text(
//           'Vault Settings',
//           style: TextStyle(fontWeight: FontWeight.w900),
//         ),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           setting(
//             icon: Icons.password_rounded,
//             title: 'Change PIN',
//             subtitle: 'Update your 4-digit vault PIN',
//             onTap: () => changePin(context),
//           ),
//           const SizedBox(height: 12),
//           setting(
//             icon: Icons.delete_sweep_outlined,
//             title: 'Delete all vault data',
//             subtitle: 'Permanently remove everything',
//             danger: true,
//             onTap: () => clear(context),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget setting({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required VoidCallback onTap,
//     bool danger = false,
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(19),
//         border: Border.all(color: const Color(0xFFE3E3E3)),
//       ),
//       child: ListTile(
//         onTap: onTap,
//         leading: Container(
//           width: 45,
//           height: 45,
//           decoration: BoxDecoration(
//             color: danger
//                 ? const Color(0xFFFFEEEE)
//                 : const Color(0xFFF0F0F0),
//             borderRadius: BorderRadius.circular(14),
//           ),
//           child: Icon(
//             icon,
//             color: danger ? Colors.red : Colors.black,
//           ),
//         ),
//         title: Text(
//           title,
//           style: TextStyle(
//             fontWeight: FontWeight.w900,
//             color: danger ? Colors.red : Colors.black,
//           ),
//         ),
//         subtitle: Text(
//           subtitle,
//           style: TextStyle(
//             color: Colors.grey.shade600,
//             fontSize: 12,
//           ),
//         ),
//         trailing: const Icon(Icons.chevron_right_rounded),
//       ),
//     );
//   }
// }

// class SimplePinPage extends StatefulWidget {
//   final String title;
//   final String subtitle;

//   const SimplePinPage({
//     super.key,
//     required this.title,
//     required this.subtitle,
//   });

//   @override
//   State<SimplePinPage> createState() => _SimplePinPageState();
// }

// class _SimplePinPageState extends State<SimplePinPage> {
//   String pin = '';

//   void add(String x) {
//     if (pin.length >= 4) return;
//     setState(() => pin += x);
//     if (pin.length == 4) Navigator.pop(context, pin);
//   }

//   void back() {
//     if (pin.isEmpty) return;
//     setState(() {
//       pin = pin.substring(0, pin.length - 1);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F7F7),
//       appBar: AppBar(title: const Text('Security')),
//       body: Column(
//         children: [
//           const Spacer(),
//           const Icon(Icons.lock_rounded, size: 48),
//           const SizedBox(height: 20),
//           Text(
//             widget.title,
//             style: const TextStyle(
//               fontSize: 25,
//               fontWeight: FontWeight.w900,
//             ),
//           ),
//           const SizedBox(height: 7),
//           Text(
//             widget.subtitle,
//             style: TextStyle(color: Colors.grey.shade600),
//           ),
//           const SizedBox(height: 24),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: List.generate(
//               4,
//               (i) => Container(
//                 margin: const EdgeInsets.all(7),
//                 width: 13,
//                 height: 13,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: i < pin.length
//                       ? Colors.black
//                       : Colors.white,
//                   border: Border.all(color: Colors.black),
//                 ),
//               ),
//             ),
//           ),
//           const Spacer(),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 42),
//             child: GridView.count(
//               shrinkWrap: true,
//               crossAxisCount: 3,
//               mainAxisSpacing: 12,
//               crossAxisSpacing: 12,
//               childAspectRatio: 1.3,
//               children: [
//                 for (int i = 1; i <= 9; i++)
//                   _Pad(
//                     text: '$i',
//                     onTap: () => add('$i'),
//                   ),
//                 const SizedBox(),
//                 _Pad(
//                   text: '0',
//                   onTap: () => add('0'),
//                 ),
//                 _Pad(
//                   icon: Icons.backspace_outlined,
//                   onTap: back,
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 35),
//         ],
//       ),
//     );
//   }
// }

// /* =========================
//    SHARED UI
//    ========================= */

// class FormPage extends StatelessWidget {
//   final String title;
//   final List<Widget> children;

//   const FormPage({
//     super.key,
//     required this.title,
//     required this.children,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF7F7F7),
//       appBar: AppBar(
//         title: Text(
//           title,
//           style: const TextStyle(fontWeight: FontWeight.w900),
//         ),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
//         children: children,
//       ),
//     );
//   }
// }

// Widget label(String text) => Padding(
//       padding: const EdgeInsets.only(top: 17, bottom: 7),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: 9,
//           fontWeight: FontWeight.w900,
//           letterSpacing: .5,
//           color: Colors.grey.shade700,
//         ),
//       ),
//     );

// InputDecoration input(String hint, [IconData? icon]) =>
//     InputDecoration(
//       hintText: hint,
//       prefixIcon: icon == null ? null : Icon(icon),
//       filled: true,
//       fillColor: Colors.white,
//       contentPadding: const EdgeInsets.symmetric(
//         horizontal: 15,
//         vertical: 16,
//       ),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(15),
//         borderSide:
//             const BorderSide(color: Color(0xFFE3E3E3)),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(15),
//         borderSide:
//             const BorderSide(color: Color(0xFFE3E3E3)),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(15),
//         borderSide:
//             const BorderSide(color: Colors.black, width: 1.3),
//       ),
//     );

// Widget button(String text, VoidCallback onPressed) =>
//     SizedBox(
//       height: 54,
//       child: FilledButton(
//         style: FilledButton.styleFrom(
//           backgroundColor: Colors.black,
//           foregroundColor: Colors.white,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//         ),
//         onPressed: onPressed,
//         child: Text(
//           text,
//           style: const TextStyle(fontWeight: FontWeight.w900),
//         ),
//       ),
//     );

// class _Pad extends StatelessWidget {
//   final String? text;
//   final IconData? icon;
//   final VoidCallback onTap;

//   const _Pad({
//     this.text,
//     this.icon,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(20),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(20),
//         onTap: onTap,
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(20),
//             border: Border.all(
//               color: const Color(0xFFE3E3E3),
//             ),
//           ),
//           child: Center(
//             child: icon != null
//                 ? Icon(icon, size: 20)
//                 : Text(
//                     text ?? '',
//                     style: const TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//           ),
//         ),
//       ),
//     );
//   }
// }
