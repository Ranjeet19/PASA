import 'package:flutter/material.dart';
import 'package:my_assist/utils/colors.dart';

class PinPad extends StatelessWidget {
  final String pin;
  final ValueChanged<String> onChanged;

  const PinPad({
    super.key,
    required this.pin,
    required this.onChanged,
  });

  void _press(String value) {
    if (value == 'back') {
      if (pin.isNotEmpty) {
        onChanged(pin.substring(0, pin.length - 1));
      }
      return;
    }

    if (pin.length >= 4) return;
    onChanged('$pin$value');
  }

  Widget _button(String value) {
    if (value.isEmpty) {
      return const SizedBox(width: 84, height: 60);
    }

    return SizedBox(
      width: 84,
      height: 60,
      child: Material(
        color: mobileSearchColor,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _press(value),
          child: Center(
            child: value == 'back'
                ? const Icon(
                    Icons.backspace_outlined,
                    color: primaryColor,
                  )
                : Text(
                    value,
                    style: const TextStyle(
                      color: primaryColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'back'],
    ];

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 330),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final row in rows) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map(_button).toList(),
            ),
            if (row != rows.last) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
