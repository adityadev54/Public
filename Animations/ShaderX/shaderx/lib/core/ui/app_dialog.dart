import 'package:flutter/material.dart';
import 'package:kin_ui/kin_ui.dart';

Future<T?> showAppDialog<T>(BuildContext context, Widget child) =>
    showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss dialog',
      barrierColor: Colors.black54,
      transitionDuration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondary) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: SingleChildScrollView(
                child: KinDialog(title: '', contentOnly: true, content: child),
              ),
            ),
          ),
        ),
      ),
      transitionBuilder: (context, a, b, child) =>
          FadeTransition(opacity: a, child: child),
    );
Future<String?> askName(BuildContext context, String current) async {
  final controller = TextEditingController(text: current);
  final result = await showAppDialog<String>(
    context,
    Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Name your composition',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            KinTextField(
              controller: controller,
              autofocus: true,
              maxLength: 64,
              decoration: const InputDecoration(labelText: 'Composition name'),
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  Navigator.pop(context, value.trim());
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      Navigator.pop(context, controller.text.trim());
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  // The route retains its text field through the exit transition.
  Future<void>.delayed(const Duration(milliseconds: 300), controller.dispose);
  return result;
}
