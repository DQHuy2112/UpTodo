import 'package:flutter/material.dart';
import '../../data/category_dao.dart';
import 'create_category_screen.dart';

class CategoryScreen extends StatefulWidget {
  final String? selectedCategory;
  final ValueChanged<String>? onCategorySelected;

  const CategoryScreen({
    super.key,
    this.selectedCategory,
    this.onCategorySelected,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final _dao = CategoryDao();
  List<CategoryEntity> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final rows = await _dao.getAll();
    setState(() {
      _items = rows;
      _loading = false;
    });
  }

  void _select(String name) {
    widget.onCategorySelected?.call(name);
    Navigator.pop(context, name);
  }

  Future<void> _addCategory() async {
    final createdName = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const CreateCategoryScreen()),
    );
    if (createdName != null) {
      await _load();         // reload từ DB để thấy item mới
      _select(createdName);  // chọn luôn danh mục vừa tạo
    }
  }

  Future<void> _confirmDelete(CategoryEntity e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Xoá danh mục', style: TextStyle(color: Colors.white)),
        content: Text(
          'Bạn có chắc muốn xoá “${e.name}”?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xoá', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (ok == true && e.id != null) {
      await _dao.delete(e.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xoá “${e.name}”')),
        );
        _load();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = _loading
        ? const Center(child: CircularProgressIndicator())
        : _items.isEmpty
        ? _EmptyState(onAdd: _addCategory)
        : Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        itemCount: _items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: .95,
        ),
        itemBuilder: (_, i) {
          final e = _items[i];
          final icon = IconData(
            e.iconCodePoint ?? Icons.category_outlined.codePoint,
            fontFamily: 'MaterialIcons',
          );
          final color = Color(e.bgColor ?? const Color(0xFF8E7CFF).value);
          final selected = widget.selectedCategory == e.name;

          return _CategoryTile(
            name: e.name,
            icon: icon,
            color: color,
            isSelected: selected,
            onTap: () => _select(e.name),
            onLongPress: () => _confirmDelete(e), // giữ lâu để xoá
          );
        },
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Chọn danh mục'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(child: body),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _addCategory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8E7CFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Thêm danh mục',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_outlined, size: 64, color: Colors.white24),
            const SizedBox(height: 16),
            const Text(
              'Chưa có danh mục nào',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tạo danh mục đầu tiên để sắp xếp công việc dễ hơn.',
              style: TextStyle(color: Colors.white60),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8E7CFF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Tạo danh mục', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _CategoryTile({
    required this.name,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color.withOpacity(.18);
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.white10,
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
