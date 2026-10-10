import 'package:flutter/material.dart';
import 'package:kin_ui/kin_ui.dart';
import 'package:heroicons_flutter/heroicons_flutter.dart';

class NewCompositionCard extends StatelessWidget {
  final VoidCallback onNew;
  const NewCompositionCard({super.key, required this.onNew});
  @override
  Widget build(BuildContext context) {
    return KinPress(
      buttonSemantics: true,
      onTap: onNew,
      child: Container(
        key: const ValueKey('new-composition-surface'),
        width: double.infinity,
        height: 166 + 40 * (MediaQuery.textScalerOf(context).scale(1) - 1),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFAF4).withValues(
            alpha: Theme.of(context).brightness == Brightness.dark ? .70 : .55,
          ),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: const Color(0xFFEEE8DF).withValues(alpha: .55),
            width: .7,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New composition',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF292820),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    Icon(
                      HeroiconsOutline.plus,
                      size: 22,
                      color: const Color(0xFF52621A),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Image.asset(
                  'assets/illustrations/new-composition.png',
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
