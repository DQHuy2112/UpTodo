import 'package:flutter/material.dart';
import 'package:uptodo/data/settings_service.dart';

import '../../data/settings_controller.dart'; // settingsController

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _palette = [
    Color(0xFF8E7CFF), Color(0xFF56CCF2), Color(0xFF2D9CDB),
    Color(0xFF6FCF97), Color(0xFFF2C94C), Color(0xFFF2994A),
    Color(0xFFEB5757), Color(0xFFBB6BD9), Color(0xFF27AE60),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: settingsController,
      builder: (_, __) {
        final theme = Theme.of(context);
        final cs = theme.colorScheme;
        final s = settingsController.state;

        return Scaffold(
          // KHÔNG set backgroundColor cứng → dùng màu theo theme
          appBar: AppBar(title: const Text('Cài đặt')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            children: [
              _section(context, 'Giao diện'),
              // Màu nhấn
              _tile(
                context,
                leading: Icons.color_lens,
                title: 'Màu nhấn',
                trailing: Wrap(
                  spacing: 8,
                  children: _palette.map((c) {
                    final sel = s.accentColor == c.value;
                    return GestureDetector(
                      onTap: () => settingsController.update((st) => st.accentColor = c.value),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: sel ? cs.onSurface : cs.outlineVariant,
                            width: sel ? 2 : 1,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              // Chủ đề
              _dropdown<ThemeChoice>(
                context,
                icon: Icons.brightness_6,
                title: 'Chủ đề',
                value: s.theme,
                items: const {
                  ThemeChoice.system: 'Theo hệ thống',
                  ThemeChoice.light : 'Sáng',
                  ThemeChoice.dark  : 'Tối',
                },
                onChanged: (v) => settingsController.update((st) => st.theme = v),
              ),

              _section(context, 'Hiển thị & sắp xếp'),
              _dropdown<DefaultSort>(
                context,
                icon: Icons.sort,
                title: 'Sắp xếp mặc định',
                value: s.defaultSort,
                items: const {
                  DefaultSort.newest  : 'Mới nhất',
                  DefaultSort.priority: 'Ưu tiên',
                },
                onChanged: (v) => settingsController.update((st) => st.defaultSort = v),
              ),
              _switch(
                context,
                icon: Icons.done_all,
                title: 'Hiện việc đã hoàn thành',
                value: s.showCompleted,
                onChanged: (v) => settingsController.update((st) => st.showCompleted = v),
              ),
              _switch(
                context,
                icon: Icons.schedule,
                title: 'Định dạng 24 giờ',
                value: s.use24hTime,
                onChanged: (v) => settingsController.update((st) => st.use24hTime = v),
              ),



              _section(context, 'Giới thiệu'),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.info, color: cs.onSurface),
                title: Text('UpTodo (bản demo)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                    )),
                subtitle: Text('v1.0.0',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    )),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===== Helpers (theo theme) =====
  Widget _section(BuildContext context, String t) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 8),
      child: Text(
        t,
        style: theme.textTheme.titleSmall?.copyWith(
          color: cs.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _tile(
      BuildContext context, {
        required IconData leading,
        required String title,
        Widget? trailing,
        VoidCallback? onTap,
      }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(leading, color: cs.onSurface),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: cs.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: trailing ?? Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
      onTap: onTap,
    );
  }

  Widget _switch(
      BuildContext context, {
        required IconData icon,
        required String title,
        required bool value,
        required ValueChanged<bool> onChanged,
      }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icon, color: cs.onSurface),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: cs.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      activeColor: cs.primary,
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _dropdown<T>(
      BuildContext context, {
        required IconData icon,
        required String title,
        required T value,
        required Map<T, String> items,
        required ValueChanged<T> onChanged,
      }) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: cs.onSurface),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: cs.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          dropdownColor: cs.surface,
          style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurface),
          items: items.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}
