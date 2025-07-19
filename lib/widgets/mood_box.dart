import 'package:flutter/material.dart';
import '../theme/palette.dart';
import '../providers/emotion_provider.dart';
import 'package:provider/provider.dart';


class MoodBox extends StatefulWidget {
  const MoodBox({super.key});

  @override
  State<MoodBox> createState() => _MoodBoxState();
}

class _MoodBoxState extends State<MoodBox> {
  final List<String> emojis = ['🤪', '😊', '😐', '☹️', '😭', '😮', '😡'];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EmotionProvider>(context);
    final selectedEmoji = provider.feeling;
    final fatigueValue = provider.fatigue;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Palette.lightRed,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            '오늘의 상태를 알려주세요',
            style: TextStyle(fontWeight: FontWeight.w300),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: emojis.map((emoji) {
              final isSelected = emoji == selectedEmoji;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    provider.setFeeling(emoji);
                  },
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                        isSelected ? Palette.mainRed : Colors.transparent,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        emoji,
                        style: TextStyle(
                          fontSize: 24,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Slider(
            value: fatigueValue,
            onChanged: (value) {
              provider.setFatigue(value);
            },
            activeColor: Palette.calmYellow,
            inactiveColor: Palette.greyBorder,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.bolt, color: Palette.calmYellow, size: 20),
              const SizedBox(width: 6),
              Text('${(fatigueValue * 100).toInt()}%',
                  style: const TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              provider.saveTodayEmotion();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("오늘 감정이 저장되었습니다")),
              );
            },
            child: const Text('저장하기'),
          ),
        ],
      ),
    );
  }
}
