import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../widgets/calendar_box.dart';
import '../widgets/mood_box.dart';
import '../theme/palette.dart';
import '../theme/fonts.dart';
import 'todo_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 2;

  String? _partnerFeeling;
  int? _partnerFatigue;

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  DateTime? _dday;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const TodoPage()),
      );
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Future<void> _loadUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final Timestamp? ts = doc.data()?['dday'];
    if (ts != null) {
      setState(() {
        _dday = ts.toDate();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.background,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Palette.mainRed,
        unselectedItemColor: Palette.greyText,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.check_box), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDdaySection(),
              const SizedBox(height: 16),
              CalendarBox(
                initialFocusedDay: _focusedDay,
                initialSelectedDay: _selectedDay,
              ),
              const SizedBox(height: 20),
              const MoodBox(),
              const SizedBox(height: 24),
              _buildPlantImage(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDdaySection() {
    final days = _dday != null
        ? DateTime.now().difference(_dday!).inDays
        : null;

    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: AppFonts.primaryFont,
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: Palette.black,
              ),
              children: [
                const TextSpan(text: '엄마 아빠 함께한지 '),
                TextSpan(
                  text: days != null ? '+$days일' : 'D-day 없음',
                  style: const TextStyle(color: Palette.mainRed),
                ),
              ],
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 4),
          Text(
            '튼튼이와 함께한지 +100일',
            style: const TextStyle(
              fontFamily: AppFonts.primaryFont,
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: Palette.greyText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlantImage() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _showPartnerPopup,
            child: const Icon(Icons.mail_outline, size: 28),
          ),
          const SizedBox(height: 12),
          Image.asset(
            'assets/images/plant.png',
            height: 100,
          ),
        ],
      ),
    );
  }

  Future<void> _showPartnerPopup() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final spouseUid = userDoc.data()?['spouseUid'];

      if (spouseUid == null) {
        _showDialog(
          title: '연동되지 않음',
          content: '아직 배우자와 연동되지 않았습니다.\n연동 설정으로 이동하시겠습니까?',
        );
        return;
      }

      final todayKey = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final emotionDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(spouseUid)
          .collection('emotions')
          .doc(todayKey)
          .get();

      if (!emotionDoc.exists) {
        _showDialog(title: '데이터 없음', content: '배우자의 오늘 감정이 없습니다.');
        return;
      }

      final data = emotionDoc.data()!;
      final feeling = data['feeling'] ?? '😐';
      final rawFatigue = data['fatigue'] ?? 0.0;
      final fatigue = (rawFatigue).toInt();

      _showDialog(
        title: '배우자의 감정',
        content: '오늘의 감정: $feeling\n피로도: $fatigue%',
      );
    } catch (e) {
      _showDialog(title: '오류', content: '데이터를 불러오는 중 오류가 발생했습니다: $e');
    }
  }

  void _showDialog({required String title, required String content}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          )
        ],
      ),
    );
  }
}
