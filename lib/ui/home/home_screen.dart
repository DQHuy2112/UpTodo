import 'package:flutter/material.dart';
import 'package:uptodo/models/task.dart';
import 'package:uptodo/ui/category/category_screen.dart';
import 'package:uptodo/ui/home/widgets/edit_task_dialog.dart';
import 'package:uptodo/ui/home/add_task_dialog.dart'; // nếu đang dùng AddTaskDialog tách riêng

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Task> _tasks = [
    Task(
      title: 'Làm bài tập Toán',
      description: 'Làm chương 2 đến 5 cho tuần tới',
      isCompleted: false,
      category: 'Đại học',
      priority: TaskPriority.high,
      date: DateTime.now(),
      time: '15:45',
    ),
    Task(
      title: 'Dắt chó đi dạo',
      description: 'Dắt chó đi dạo trong công viên',
      isCompleted: false,
      category: 'Mới',
      priority: TaskPriority.medium,
      date: DateTime.now(),
      time: '18:20',
    ),
    Task(
      title: 'Họp kinh doanh với CEO',
      description: 'Thảo luận chiến lược Q4',
      isCompleted: false,
      category: 'Công việc',
      priority: TaskPriority.low,
      date: DateTime.now(),
      time: '08:15',
    ),
    Task(
      title: 'Mua đồ tạp hóa',
      description: 'Sữa, bánh mì, trứng, rau',
      isCompleted: true,
      category: 'Cá nhân',
      priority: TaskPriority.high,
      date: DateTime.now(),
      time: '15:45',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460), Color(0xFF533483)],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _tasks.isEmpty ? _buildEmptyState() : _buildTaskList()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  // ===== UI parts =====
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
      child: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu, color: Colors.white, size: 24),
            ),
          ),
          const Spacer(),
          const Text('Trang Chủ',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const Spacer(),
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: Colors.purple, borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.person, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Icon(Icons.task_alt, size: 100, color: Colors.purple),
          ),
          const SizedBox(height: 40),
          const Text('Bạn muốn làm gì hôm nay?',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          const Text('Nhấn + để thêm công việc',
              style: TextStyle(color: Colors.grey, fontSize: 16), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    final todayTasks = _tasks.where((t) => !t.isCompleted).toList();
    final completedTasks = _tasks.where((t) => t.isCompleted).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        children: [
          if (todayTasks.isNotEmpty) ...[
            _buildSectionHeader('Hôm Nay'),
            ...List.generate(todayTasks.length, (i) {
              final index = _tasks.indexOf(todayTasks[i]);
              return _buildTaskItem(index);
            }),
          ],
          if (completedTasks.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildSectionHeader('Đã Hoàn Thành'),
            ...List.generate(completedTasks.length, (i) {
              final index = _tasks.indexOf(completedTasks[i]);
              return _buildTaskItem(index);
            }),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Text(title,
        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
  );

  // ----- Task card với Dismissible + tap/longPress -----
  Widget _buildTaskItem(int idx) {
    final task = _tasks[idx];
    final secondary = Colors.grey[400];

    return Dismissible(
      key: ValueKey('task_${idx}_${task.title}'),
      background: _swipeBg(alignLeft: true),
      secondaryBackground: _swipeBg(alignLeft: false),
      confirmDismiss: (_) async => await _confirmDelete(idx),
      child: InkWell(
        onTap: () => _editTask(idx),
        onLongPress: () => _showTaskMenu(idx),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: task.isCompleted
                ? Colors.green.withValues(alpha: 0.25)
                : Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // checkbox
              GestureDetector(
                onTap: () => setState(() => task.isCompleted = !task.isCompleted),
                child: Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    color: task.isCompleted ? Colors.green : Colors.transparent,
                    border: Border.all(
                      color: task.isCompleted ? Colors.green : Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: task.isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),
              const SizedBox(width: 12),

              // content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        _priorityBubble(task.priority),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('Hôm nay lúc ${task.time}',
                        style: TextStyle(color: secondary, fontSize: 12)),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        _categoryChip(task.category, onTap: () => _changeCategory(idx)),
                        const SizedBox(width: 8),
                        _levelChip(task.priority),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  // ===== Chips & backgrounds =====
  Widget _categoryChip(String name, {VoidCallback? onTap}) {
    final color = _getCategoryColor(name);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: color.withOpacity(.2), borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.label, size: 14, color: color),
            const SizedBox(width: 4),
            Text(name, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _levelChip(TaskPriority p) {
    final label = switch (p) {
      TaskPriority.high => 'P1',
      TaskPriority.medium => 'P2',
      TaskPriority.low => 'P3',
    };
    final c = _getPriorityColor(p);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: c.withOpacity(.2), borderRadius: BorderRadius.circular(12)),
      child: Text(label, style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  Widget _priorityBubble(TaskPriority p) {
    final c = _getPriorityColor(p);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: c.withOpacity(.15), borderRadius: BorderRadius.circular(10)),
      child: Text(
        switch (p) { TaskPriority.high => 'Cao', TaskPriority.medium => 'TrB', TaskPriority.low => 'Thấp' },
        style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _swipeBg({required bool alignLeft}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(.85),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: alignLeft ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }

  // ===== Actions =====
  Future<void> _showAddTaskDialog() async {
    final task = await showModalBottomSheet<Task>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTaskDialog(),
    );
    if (task != null) setState(() => _tasks.add(task));
  }

  Future<void> _editTask(int index) async {
    final updated = await showModalBottomSheet<Task>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditTaskDialog(initial: _tasks[index]),
    );
    if (updated != null) setState(() => _tasks[index] = updated);
  }

  Future<void> _changeCategory(int index) async {
    final name = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryScreen(
          selectedCategory: _tasks[index].category,
          onCategorySelected: (_) {},
        ),
      ),
    );
    if (name != null && name.isNotEmpty) {
      setState(() => _tasks[index].category = name);
    }
  }

  Future<bool> _confirmDelete(int index) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Xoá công việc', style: TextStyle(color: Colors.white)),
        content: Text('Bạn có chắc muốn xoá "${_tasks[index].title}"?',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xoá', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (ok == true) setState(() => _tasks.removeAt(index));
    return ok ?? false;
  }

  void _showTaskMenu(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white70),
              title: const Text('Sửa', style: TextStyle(color: Colors.white)),
              onTap: () { Navigator.pop(context); _editTask(index); },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title: const Text('Xoá', style: TextStyle(color: Colors.redAccent)),
              onTap: () { Navigator.pop(context); _confirmDelete(index); },
            ),
          ],
        ),
      ),
    );
  }

  // ===== Utils =====
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'đại học': return Colors.blue;
      case 'công việc': return Colors.orange;
      case 'cá nhân': return Colors.green;
      case 'mới': return Colors.purple;
      default: return Colors.grey;
    }
  }

  Color _getPriorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.high: return Colors.red;
      case TaskPriority.medium: return Colors.orange;
      case TaskPriority.low: return Colors.green;
    }
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) => setState(() => _selectedIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang Chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Lịch'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Tập Trung'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ Sơ'),
        ],
      ),
    );
  }
}
