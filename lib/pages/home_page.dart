import 'package:flutter/material.dart';
import 'package:presence_app/pages/widget/history_tile.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'sign_in_page.dart';
import '../models/attendance.dart';
import '../providers/auth_provider.dart';
import '../providers/attendance_provider.dart';
import '../providers/clock_provider.dart';
import '../services/firestore_service.dart';
import 'package:presence_app/theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _uid;
  Stream<Attendance?>? _latestStream;
  Stream<List<Attendance>>? _historyStream;

  // cache snapshot
  List<Attendance>? _lastHistory;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    if (_uid != user.uid) {
      _uid = user.uid;
      final fs = context.read<FirestoreService>();

      _latestStream = fs.streamLatestCheck(_uid!);
      _historyStream = fs.streamHistory(_uid!);
      _lastHistory = null;
    }
  }

  Widget _timeBox(String text, {double size = 36, double minWidth = 72}) {
    return Container(
      constraints: BoxConstraints(minWidth: minWidth, minHeight: minWidth),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: primaryColor50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        // border: Border.all(color: Colors.black12),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: size,
            fontWeight: bold,
            height: 1.0,
            color: primaryColor800,
          ),
        ),
      ),
    );
  }

  Widget _sep() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Text(
      ':',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: subtitle1TextColor,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (user == null) {
      Future.microtask(() {
        if (!context.mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SignInPage()),
        );
      });
      return const Scaffold(body: Center());
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor800,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(user.photoURL ?? ''),
              radius: 20,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Halo ${user.displayName?.split(' ').first ?? 'User'}!",
                  style: TextStyle(
                    color: whiteColor,
                    fontWeight: bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email ?? '',
                  style: TextStyle(fontSize: 12, color: whiteColor),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            style: IconButton.styleFrom(
              padding: EdgeInsets.zero,
              foregroundColor: whiteColor,
              backgroundColor: whiteColor.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => context.read<AuthProvider>().signOut(),
            icon: const Icon(Icons.logout, size: 20),
            tooltip: 'Logout',
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              color: primaryColor800,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ),
          Column(
            children: [
              // ===== CLOCK + BUTTON CARD =====
              Container(
                margin: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x19000000),
                      blurRadius: 24,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Consumer<ClockProvider>(
                      builder:
                          (_, clock, __) => Column(
                            children: [
                              Text(
                                DateFormat(
                                  'EEE, dd MMM yyyy',
                                ).format(clock.nowWIB),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: semibold,
                                  color: subtitle1TextColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _timeBox(
                                    DateFormat('HH').format(clock.nowWIB),
                                  ),
                                  _sep(),
                                  _timeBox(
                                    DateFormat('mm').format(clock.nowWIB),
                                  ),
                                  _sep(),
                                  _timeBox(
                                    DateFormat('ss').format(clock.nowWIB),
                                  ),
                                ],
                              ),
                            ],
                          ),
                    ),
                    const SizedBox(height: 12),

                    StreamBuilder<Attendance?>(
                      stream: _latestStream,
                      builder: (context, snapLatest) {
                        final latest = snapLatest.data; // bisa null
                        final isActive =
                            latest != null && latest.checkOutAt == null;

                        return Selector<
                          AttendanceProvider,
                          ({bool isLoading, String? error})
                        >(
                          selector:
                              (_, provider) => (
                                isLoading: provider.isLoading,
                                error: provider.error,
                              ),
                          builder: (context, s, _) {
                            final canCheckIn = !s.isLoading && !isActive;
                            final canCheckOut = !s.isLoading && isActive;

                            return Column(
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    minimumSize: Size(
                                      MediaQuery.of(context).size.width,
                                      36,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    side: BorderSide(
                                      color:
                                          canCheckIn
                                              ? Colors.orange
                                              : canCheckOut
                                              ? Colors.red
                                              : disabledColor,
                                    ),
                                    backgroundColor:
                                        canCheckIn
                                            ? Colors.orange
                                            : canCheckOut
                                            ? Colors.red
                                            : whiteColor,
                                  ),
                                  onPressed:
                                      canCheckIn
                                          ? () => context
                                              .read<AttendanceProvider>()
                                              .checkIn(user.uid)
                                          : canCheckOut
                                          ? () => context
                                              .read<AttendanceProvider>()
                                              .checkOut(user.uid)
                                          : null,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (s.isLoading)
                                        SizedBox(
                                          height: 15,
                                          width: 15,
                                          child: CircularProgressIndicator(
                                            color: disabledColor,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      else
                                        Icon(
                                          canCheckIn
                                              ? Icons
                                                  .arrow_circle_right_outlined
                                              : Icons.door_back_door_outlined,
                                          color: whiteColor,
                                        ),
                                      const SizedBox(width: 5),
                                      Text(
                                        s.isLoading
                                            ? 'Loading...'
                                            : (canCheckIn
                                                ? 'Check-in'
                                                : 'Check-out'),
                                        style: TextStyle(
                                          color:
                                              s.isLoading
                                                  ? disabledColor
                                                  : whiteColor,
                                          fontWeight: semibold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (s.error != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    s.error!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ],
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              // ===== HISTORY =====
              Expanded(
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'History',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: semibold,
                            color: subtitle1TextColor,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Expanded(
                          child: StreamBuilder<List<Attendance>>(
                            stream: _historyStream,

                            initialData: _lastHistory,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                _lastHistory = snapshot.data;
                              }

                              final isLoading = context
                                  .select<AttendanceProvider, bool>(
                                    (provider) => provider.isLoading,
                                  );

                              // Tentukan data yang ditampilkan
                              final items =
                                  snapshot.data ??
                                  _lastHistory ??
                                  const <Attendance>[];

                              // First load
                              final isFirstLoad =
                                  snapshot.connectionState ==
                                      ConnectionState.waiting &&
                                  _lastHistory == null;

                              if (isFirstLoad) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (items.isEmpty) {
                                if (isLoading) {
                                  return const SizedBox.shrink();
                                }
                                return const Center(
                                  child: Text('Belum ada riwayat'),
                                );
                              }

                              return ListView.separated(
                                padding: EdgeInsets.symmetric(vertical: 6),
                                itemCount: items.length,
                                separatorBuilder:
                                    (context, i) => const SizedBox(height: 10),
                                itemBuilder:
                                    (context, i) => HistoryTile(item: items[i]),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
