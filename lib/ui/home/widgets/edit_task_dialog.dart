import 'package:flutter/material.dart';
import 'package:uptodo/models/task.dart';
import 'package:uptodo/ui/category/category_screen.dart';

class EditTaskDialog extends StatefulWidget {
  final Task initial;
  const EditTaskDialog({super.key, required this.initial});

  @override
  State<EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;

  late String _selectedCategory;
  late TaskPriority _selectedPriority;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  final Color _bg = const Color(0xFF121225);
  final Color _card = const Color(0xFF1B1B2F);
  final Color _purple = const Color(0xFF8E7CFF);

  @override
  void initState() {
    super.initState();
    final t = widget.initial;
    _titleCtrl = TextEditingController(text: t.title);
    _descCtrl  = TextEditingController(text: t.description);
    _selectedCategory = t.category;
    _selectedPriority = t.priority;
    _selectedDate = t.date;
    final parts = (t.time).split(':');
    _selectedTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 8, 6),
                child: Row(
                  children: [
                    const Text('Sửa Công Việc', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, color: Colors.white70)),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _input(controller: _titleCtrl, hint: 'Tiêu đề', fontSize: 16,
                          prefix: const Icon(Icons.edit_outlined, color: Colors.white54),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập tiêu đề' : null,
                        ),
                        const SizedBox(height: 12),
                        _input(controller: _descCtrl, hint: 'Mô tả', maxLines: 3,
                          prefix: const Icon(Icons.notes_rounded, color: Colors.white54),
                        ),
                        const SizedBox(height: 18),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _actionCircle(icon: Icons.access_time, label: 'Thời Gian', onTap: _pickDateTime),
                            _actionCircle(icon: Icons.flag,        label: 'Độ Ưu Tiên', onTap: _pickPriority),
                            _actionCircle(icon: Icons.label,       label: 'Danh Mục',  onTap: _pickCategory),
                            _actionCircle(icon: Icons.save_rounded,label: 'Lưu',       onTap: _save),
                          ],
                        ),
                        const SizedBox(height: 18),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            spacing: 8, runSpacing: 8,
                            children: [
                              _chip(Icons.event, _formatDate(_selectedDate)),
                              _chip(Icons.access_time, _selectedTime.format(context)),
                              _chip(Icons.flag, _priorityLabel(_selectedPriority)),
                              _chip(Icons.label, _selectedCategory),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                child: SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _purple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('LƯU THAY ĐỔI',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: .3)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- helpers (giống AddTaskDialog) ---
  Widget _input({
    required TextEditingController controller,
    required String hint,
    Widget? prefix,
    String? Function(String?)? validator,
    int maxLines = 1,
    double fontSize = 15,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      style: TextStyle(color: Colors.white, fontSize: fontSize),
      decoration: InputDecoration(
        prefixIcon: prefix,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: _card,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _actionCircle({required IconData icon, required String label, required VoidCallback onTap}) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Ink(
            width: 56, height: 56,
            decoration: BoxDecoration(color: _purple.withOpacity(.15), shape: BoxShape.circle),
            child: Icon(icon, color: _purple),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ],
    );
  }

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: _card, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ]),
    );
  }

  Future<void> _pickDateTime() async {
    final d = await showDatePicker(
      context: context, initialDate: _selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2100),
      builder: (c, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.dark(primary: Colors.purple, surface: Color(0xFF1A1A1A), onSurface: Colors.white)),
        child: child!,
      ),
    );
    if (d == null) return;
    final t = await showTimePicker(
      context: context, initialTime: _selectedTime,
      builder: (c, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.dark(primary: Colors.purple, surface: Color(0xFF1A1A1A), onSurface: Colors.white)),
        child: child!,
      ),
    );
    if (t != null) setState(() { _selectedDate = d; _selectedTime = t; });
  }

  Future<void> _pickPriority() async {
    final p = await showDialog<TaskPriority>(
      context: context,
      builder: (_) => SimpleDialog(
        backgroundColor: _card,
        title: const Text('Độ Ưu Tiên', style: TextStyle(color: Colors.white)),
        children: TaskPriority.values.map((e) {
          final selected = e == _selectedPriority;
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, e),
            child: Row(
              children: [
                Icon(Icons.flag, color: selected ? Colors.purple : Colors.white54),
                const SizedBox(width: 8),
                Text(_priorityLabel(e), style: TextStyle(color: selected ? Colors.purple : Colors.white)),
              ],
            ),
          );
        }).toList(),
      ),
    );
    if (p != null) setState(() => _selectedPriority = p);
  }

  Future<void> _pickCategory() async {
    final name = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryScreen(selectedCategory: _selectedCategory, onCategorySelected: (_) {}),
      ),
    );
    if (name != null && name.isNotEmpty) setState(() => _selectedCategory = name);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final t = Task(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      isCompleted: widget.initial.isCompleted,
      category: _selectedCategory,
      priority: _selectedPriority,
      date: _selectedDate,
      time: '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
    );
    Navigator.pop(context, t);
  }

  String _formatDate(DateTime d) => '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

  String _priorityLabel(TaskPriority p) =>
      switch (p) { TaskPriority.high => 'Cao', TaskPriority.medium => 'Trung bình', TaskPriority.low => 'Thấp' };
}
