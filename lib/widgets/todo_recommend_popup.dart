import 'dart:async';
import 'package:flutter/material.dart';

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
              children: [
                Text(
                  widget.recommendationText,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: widget.onAdd,
                      child: const Text("추가할게요"),
                    ),
                    OutlinedButton(
                      onPressed: widget.onEdit,
                      child: const Text("수정할게요"),
                    ),
                    TextButton(
                      onPressed: widget.onDismiss,
                      child: const Text("필요없어요"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
