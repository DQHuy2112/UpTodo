import 'package:flutter/material.dart';
import 'package:uptodo/models/task.dart';
import '../category/category_screen.dart';

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();

  String _selectedCategory = 'Mới';
  TaskPriority _selectedPriority = TaskPriority.medium;

  // NEW: mức ưu tiên dạng số để hiển thị P1..P10
  int _priorityLevel = 5;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 15, minute: 45);

  final Color _bg = const Color(0xFF121225);
  final Color _card = const Color(0xFF1B1B2F);
  final Color _purple = const Color(0xFF8E7CFF);

  @override
  void initState() {
    super.initState();
    // Đồng bộ level ban đầu theo enum đang chọn
    _priorityLevel = switch (_selectedPriority) {
      TaskPriority.high   => 2,
      TaskPriority.medium => 5,
      TaskPriority.low    => 9,
    };
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
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 36, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24, borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 8, 6),
                child: Row(
                  children: [
                    const Text(
                      'Thêm Công Việc',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white70),
                    ),
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
                        _input(
                          controller: _titleCtrl,
                          hint: 'Làm bài tập toán',
                          fontSize: 16,
                          autofocus: true,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _save(),
                          prefix: const Icon(Icons.edit_outlined, color: Colors.white54),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập tiêu đề' : null,
                        ),
                        const SizedBox(height: 12),
                        _input(
                          controller: _descCtrl,
                          hint: 'Mô tả',
                          maxLines: 3,
                          prefix: const Icon(Icons.notes_rounded, color: Colors.white54),
                        ),
                        const SizedBox(height: 18),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _actionCircle(icon: Icons.access_time,            label: 'Thời Gian', onTap: _pickDateTime),
                            _actionCircle(icon: Icons.flag,                   label: 'Độ Ưu Tiên', onTap: _pickPriority),
                            _actionCircle(icon: Icons.label,                  label: 'Danh Mục',  onTap: _pickCategory),
                            _actionCircle(icon: Icons.arrow_forward_rounded,  label: 'Lưu',       onTap: _save),
                          ],
                        ),

                        const SizedBox(height: 18),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            spacing: 8, runSpacing: 8,
                            children: [
                              _infoChip(icon: Icons.event,       text: _formatDate(_selectedDate)),
                              _infoChip(icon: Icons.access_time, text: _selectedTime.format(context)),
                              // HIỂN THỊ P# + label theo level
                              _infoChip(icon: Icons.flag,        text: 'P$_priorityLevel • ${_priorityLabelFromLevel(_priorityLevel)}'),
                              _infoChip(icon: Icons.label,       text: _selectedCategory),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  color: _bg,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(.3), blurRadius: 12, offset: const Offset(0, -4))],
                ),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                child: SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _purple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'LƯU CÔNG VIỆC',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: .3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- UI helpers ----------
  Widget _input({
    required TextEditingController controller,
    required String hint,
    Widget? prefix,
    String? Function(String?)? validator,
    int maxLines = 1,
    double fontSize = 15,
    bool autofocus = false,
    TextInputAction? textInputAction,
    void Function(String)? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      autofocus: autofocus,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
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

  Widget _infoChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _card, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ]),
    );
  }

  // ---------- pickers ----------
  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.purple, surface: Color(0xFF1A1A1A), onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (pickedDate == null) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Colors.purple, surface: Color(0xFF1A1A1A), onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );

    if (pickedTime != null) {
      setState(() {
        _selectedDate = pickedDate;
        _selectedTime = pickedTime;
      });
    }
  }

  // POPUP chọn P1..P10 có Cancel/Save
  Future<void> _pickPriority() async {
    int temp = _priorityLevel;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _card,
        title: const Text('Độ Ưu Tiên', style: TextStyle(color: Colors.white)),
        contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        content: SizedBox(
          width: 320,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5, // 5 cột x 2 hàng = 10 ô
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.2,
            ),
            itemCount: 10,
            itemBuilder: (_, i) {
              final level = i + 1;
              final selected = level == temp;
              return InkWell(
                onTap: () => setState(() => temp = level),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: selected ? _purple : Colors.white10,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: selected ? _purple : Colors.white12),
                  ),
                  child: Center(
                    child: Text(
                      'P$level',
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _purple),
            onPressed: () {
              setState(() => _priorityLevel = temp);
              Navigator.pop(context);
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickCategory() async {
    final name = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryScreen(
          selectedCategory: _selectedCategory,
          onCategorySelected: (_) {},
        ),
      ),
    );
    if (name != null && name.isNotEmpty) {
      setState(() => _selectedCategory = name);
    }
  }

  // ---------- save ----------
  void _save() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    // Map level -> enum để lưu vào Task
    _selectedPriority = _enumFromLevel(_priorityLevel);

    final task = Task(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      isCompleted: false,
      category: _selectedCategory,
      priority: _selectedPriority,
      date: _selectedDate,
      time: '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
    );
    Navigator.pop(context, task);
  }

  // ---------- utils ----------
  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';

  // Label theo level (1..10)
  String _priorityLabelFromLevel(int p) {
    if (p <= 3) return 'Cao';
    if (p <= 7) return 'Trung bình';
    return 'Thấp';
  }

  // Map level -> enum
  TaskPriority _enumFromLevel(int p) {
    if (p <= 3) return TaskPriority.high;
    if (p <= 7) return TaskPriority.medium;
    return TaskPriority.low;
  }
}
