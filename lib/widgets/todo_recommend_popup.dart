import 'dart:async';
import 'package:flutter/material.dart';

import '../theme/palette.dart';

class TodoRecommendPopup extends StatefulWidget {
  final String recommendationText;
  final VoidCallback onAdd;
  final VoidCallback onEdit;
  final VoidCallback onDismiss;

  const TodoRecommendPopup({
    super.key,
    required this.recommendationText,
    required this.onAdd,
    required this.onEdit,
    required this.onDismiss,
  });

  @override
  State<TodoRecommendPopup> createState() => _TodoRecommendPopupState();
}

class _TodoRecommendPopupState extends State<TodoRecommendPopup> {
  @override
  void initState() {
    super.initState();

    // 5초 뒤 자동 닫힘
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 100, right: 20),
        child: Material(
          elevation: 5,
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  widget.recommendationText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Palette.black,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 추가할게요 버튼
                    ElevatedButton(
                      onPressed: widget.onAdd,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Palette.mainRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text("추가"),
                    ),

                    // 수정할게요 버튼
                    OutlinedButton(
                      onPressed: widget.onEdit,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Palette.mainRed,
                        side: const BorderSide(color: Palette.mainRed),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text("수정"),
                    ),

                    // 필요없어요 버튼
                    OutlinedButton(
                      onPressed: widget.onDismiss,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Palette.greyText,
                        side: const BorderSide(color: Palette.greyBorder),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text("필요없음"),
                    ),
                  ],
                )
              ],
            )

          ),
        ),
      ),
    );
  }
}
