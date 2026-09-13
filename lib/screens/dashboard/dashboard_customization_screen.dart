import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../dashboard/widget_registry.dart';
import '../../providers.dart';

/// Screen for customizing dashboard widget visibility and order.
class DashboardCustomizationScreen extends ConsumerStatefulWidget {
  const DashboardCustomizationScreen({super.key});

  @override
  ConsumerState<DashboardCustomizationScreen> createState() =>
      _DashboardCustomizationScreenState();
}

class _DashboardCustomizationScreenState
    extends ConsumerState<DashboardCustomizationScreen> {
  late List<String> _visibleWidgets;
  late List<String> _hiddenWidgets;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(resolvedPreferencesProvider).valueOrNull;
    final dashboardPrefs = prefs?.dashboard;

    _visibleWidgets = List<String>.from(
      dashboardPrefs?.visibleWidgets.isNotEmpty == true
          ? dashboardPrefs!.visibleWidgets
          : DashboardWidgetId.defaultVisible,
    );
    _hiddenWidgets = DashboardWidgetId.allWidgets.keys
        .where((id) => !_visibleWidgets.contains(id))
        .toList();
  }

  Future<void> _savePreferences() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      final prefsService = ref.read(preferencesServiceProvider);
      await prefsService.update(user.uid, {
        'dashboard.visibleWidgets': _visibleWidgets,
        'dashboard.widgetOrder': _visibleWidgets,
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Dashboard updated')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _toggleWidget(String widgetId, bool visible) {
    setState(() {
      if (visible) {
        _visibleWidgets.add(widgetId);
        _hiddenWidgets.remove(widgetId);
      } else {
        _visibleWidgets.remove(widgetId);
        _hiddenWidgets.add(widgetId);
      }
    });
  }

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _visibleWidgets.removeAt(oldIndex);
      _visibleWidgets.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text(
          'CUSTOMIZE DASHBOARD',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            fontSize: 14,
          ),
        ),
        backgroundColor: navy,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _savePreferences,
            child: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'SAVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Visible Widgets',
            style: TextStyle(
              color: (Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : navy),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Drag to reorder. Tap to hide.',
            style: TextStyle(
              color: (Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF78909C)
                  : muted),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _visibleWidgets.length,
            onReorder: _reorder,
            itemBuilder: (context, index) {
              final widgetId = _visibleWidgets[index];
              final label = DashboardWidgetId.allWidgets[widgetId] ?? widgetId;
              return Card(
                key: ValueKey(widgetId),
                child: ListTile(
                  leading: Icon(
                    Icons.drag_handle,
                    color: (Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF78909C)
                        : muted),
                  ),
                  title: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : navy),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.visibility, color: lime),
                    onPressed: () => _toggleWidget(widgetId, false),
                  ),
                ),
              );
            },
          ),
          if (_hiddenWidgets.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Hidden Widgets',
              style: TextStyle(
                color: (Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : navy),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to show on your dashboard.',
              style: TextStyle(
                color: (Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF78909C)
                    : muted),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(_hiddenWidgets.length, (index) {
              final widgetId = _hiddenWidgets[index];
              final label = DashboardWidgetId.allWidgets[widgetId] ?? widgetId;
              return Card(
                child: ListTile(
                  leading: Icon(
                    Icons.visibility_off,
                    color: (Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF78909C)
                        : muted),
                  ),
                  title: Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: (Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF78909C)
                          : muted),
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.add_circle_outline, color: blue),
                    onPressed: () => _toggleWidget(widgetId, true),
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
