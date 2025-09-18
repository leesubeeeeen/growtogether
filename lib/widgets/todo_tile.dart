/// file: lib/widgets/todo_tile.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme/palette.dart';
import '../theme/fonts.dart';
import '../providers/todo_provider.dart';

/// 하나의 투두를 시간/제목과 함께 표시하고,
/// - 완료 토글
/// - 삭제
/// 를 지원하는 위젯.
///
/// 사용처에서:
///   TodoTile(todo: todoMap, ownerUid: uid)
class TodoTile extends StatelessWidget {
  final Map<String, dynamic> todo;
  final String ownerUid;

  const TodoTile({
    super.key,
    required this.todo,
    required this.ownerUid,
  });

  String _formatHmOrEmpty(DateTime? dt) {
    if (dt == null) return '';
    return DateFormat.Hm().format(dt);
  }

  Future<void> _toggleDone(BuildContext context, bool done) async {
    final provider = context.read<TodoProvider>();
    final String? id = todo['id']?.toString();

    if (id == null || id.isEmpty) {
      // Firestore 문서 id가 없으면 서버 반영 불가 → 전체 새로고침만 시도
      await provider.refreshForUser(ownerUid);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('동기화 후 다시 시도해 주세요.')),
        );
      }
      return;
    }

    try {
      // Firestore 업데이트
      await FirebaseFirestore.instance
          .collection('users')
          .doc(ownerUid)
          .collection('todos')
          .doc(id)
          .update({
        'done': done,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 서버 권위로 재로딩
      await provider.refreshForUser(ownerUid);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('완료 상태 변경 실패: $e')),
        );
      }
    }
  }

  Future<void> _deleteTodo(BuildContext context) async {
    final provider = context.read<TodoProvider>();
    final String? id = todo['id']?.toString();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('삭제할까요?'),
        content: const Text('이 할 일은 되돌릴 수 없어요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('삭제', style: TextStyle(color: Palette.mainRed)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    if (id == null || id.isEmpty) {
      // 문서 id가 없으면 서버 삭제 불가 → 전체 새로고침만 시도
      await provider.refreshForUser(ownerUid);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('동기화 후 다시 시도해 주세요.')),
        );
      }
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(ownerUid)
          .collection('todos')
          .doc(id)
          .delete();

      await provider.refreshForUser(ownerUid);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('삭제했어요.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime? when = todo['date'] as DateTime?;
    final String timeText = _formatHmOrEmpty(when);
    final String title = (todo['title'] ?? '제목 없음').toString();
    final bool done = (todo['done'] ?? false) as bool;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 시간
        SizedBox(
          width: 64,
          child: Text(
            timeText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w300,
              fontFamily: AppFonts.primaryFont,
              color: Palette.greyText,
            ),
          ),
        ),
        // 카드
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Palette.greyBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목 + 완료 체크 + 삭제
                Row(
                  children: [
                    // 완료 체크
                    Checkbox(
                      value: done,
                      activeColor: Palette.mainRed,
                      onChanged: (v) {
                        if (v == null) return;
                        _toggleDone(context, v);
                      },
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.primaryFont,
                          color: done ? Palette.greyText : Palette.black,
                          decoration:
                          done ? TextDecoration.lineThrough : TextDecoration.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: Palette.greyText),
                      onPressed: () => _deleteTodo(context),
                      tooltip: '삭제',
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  // NOTE: 필요 시 todo['assignedTo'] 로 문구 분기 가능
                  '사용자가 직접 추가한 일정',
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: AppFonts.primaryFont,
                    color: Palette.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '장소 없음 · 나',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: AppFonts.primaryFont,
                    color: Palette.greyText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
