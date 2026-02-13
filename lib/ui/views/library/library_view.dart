import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:word_assistant/core/theme/app_colors.dart';
import 'library_view_model.dart';
import '../../../core/models/word.dart';
import '../../views/common/empty_view.dart';

class LibraryView extends StackedView<LibraryViewModel> {
  const LibraryView({super.key});

  @override
  Widget builder(
    BuildContext context,
    LibraryViewModel viewModel,
    Widget? child,
  ) {
    if (viewModel.isBusy) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8F9FC),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      body: CustomScrollView(
        slivers: [
          // 1. App Bar
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFFF8F9FC),
            surfaceTintColor: Colors.transparent, // Prevent color change on scroll
            scrolledUnderElevation: 0, // Prevent elevation shadow color change
            elevation: 0,
            centerTitle: true,
            title: Text(
              viewModel.isSelectionMode ? '已选择 ${viewModel.selectedCount} 个' : '我的词库', 
              style: const TextStyle(color: AppColors.slate900, fontWeight: FontWeight.w900)
            ),
            leading: viewModel.isSelectionMode 
              ? IconButton(
                  icon: const Icon(LucideIcons.x, color: AppColors.slate900),
                  onPressed: viewModel.toggleSelectionMode,
                )
              : null,
            actions: [
               if (!viewModel.isSelectionMode) ...[
                 IconButton(
                    icon: const Icon(LucideIcons.arrowUpDown, color: AppColors.slate600),
                    onPressed: () => _showSortOptions(context, viewModel),
                 ),
                 TextButton(
                   onPressed: viewModel.toggleSelectionMode,
                   child: const Text('多选', style: TextStyle(color: AppColors.indigo600, fontWeight: FontWeight.bold)),
                 ),
                 const SizedBox(width: 8),
               ] else ...[
                 TextButton(
                   onPressed: viewModel.selectAll,
                   child: Text(
                     viewModel.selectedCount == viewModel.words.length ? '全不选' : '全选', 
                     style: const TextStyle(color: AppColors.indigo600, fontWeight: FontWeight.bold)
                   ),
                 ),
                 const SizedBox(width: 8),
               ]
            ],
          ),

          // 3. Pinned Filter Header
          SliverPersistentHeader(
            delegate: _FilterHeaderDelegate(child: _buildFilterBar(viewModel)),
            pinned: true,
          ),

          // 4. Word List
          viewModel.words.isEmpty
            ? SliverToBoxAdapter(child: _buildEmptyState(viewModel))
            : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final word = viewModel.words[index];
                      // In Selection Mode: Disable Dismissible, Change Tap Action
                      if (viewModel.isSelectionMode) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                            onTap: () => viewModel.toggleWordSelection(word),
                            child: _buildWordItem(word, viewModel),
                          ),
                        );
                      }

                      // Normal Mode
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Dismissible(
                          key: Key(word.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            decoration: BoxDecoration(color: AppColors.rose500, borderRadius: BorderRadius.circular(20)),
                            child: const Icon(LucideIcons.trash2, color: Colors.white),
                          ),
                          confirmDismiss: (d) async => await _confirmDelete(context, word),
                          onDismissed: (d) => viewModel.onDeleteWord(word),
                          child: GestureDetector(
                            onLongPress: () => _showEditDialog(context, word, viewModel),
                            child: _buildWordItem(word, viewModel),
                          ),
                        ),
                      );
                    },
                    childCount: viewModel.words.length,
                  ),
                ),
              ),
            
            // Bottom Padding for FAB/BottomBar
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      bottomNavigationBar: viewModel.isSelectionMode 
        ? _buildSelectionBottomBar(viewModel)
        : null,
    );
  }

  // Dashboard methods removed

  Widget _buildSelectionBottomBar(LibraryViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        border: Border(top: BorderSide(color: AppColors.slate200.withValues(alpha: 0.5))),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20, offset: const Offset(0, -5))
        ],
      ),
      child: Row(
        children: [
          // 阶梯学习 (Step Mode)
          Expanded(
            child: GestureDetector(
              onTap: viewModel.selectedCount > 0 ? viewModel.startSelectedReviewLearning : null,
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.slate100, width: 2),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.layers, size: 18, color: Color(0xFFF97316)), // Orange 500
                        SizedBox(width: 4),
                        Text('阶梯学习', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.slate600)),
                      ],
                    ),
                    SizedBox(height: 2),
                    Text('STEP MODE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.slate400, letterSpacing: 0.5)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 强化听写 (Deep Mode)
          Expanded(
            child: GestureDetector(
              onTap: viewModel.selectedCount > 0 ? viewModel.startSelectedReviewDictation : null,
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A), // Slate 900
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.2), blurRadius: 16, offset: const Offset(0, 8))
                  ],
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.penTool, size: 18, color: Color(0xFFC4B5FD)), // Violet 300
                        SizedBox(width: 4),
                        Text('强化听写', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    SizedBox(height: 2),
                    Text('DEEP MODE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.slate400, letterSpacing: 0.5)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSortOptions(BuildContext context, LibraryViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text('排序方式', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.slate900)),
            ),
            _buildSortOption(ctx, viewModel, '最近添加', SortOption.recentlyAdded),
            _buildSortOption(ctx, viewModel, '最近复习', SortOption.recentlyReviewed),
            _buildSortOption(ctx, viewModel, '最久未练 (需复习)', SortOption.longestUnreviewed),
            _buildSortOption(ctx, viewModel, '错误最多 (难点)', SortOption.mostMistakes),
            _buildSortOption(ctx, viewModel, '掌握最弱', SortOption.leastMastered),
            _buildSortOption(ctx, viewModel, 'A-Z', SortOption.alphabetical),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(BuildContext context, LibraryViewModel viewModel, String text, SortOption option) {
    final isSelected = viewModel.currentSort == option;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      title: Text(text, style: TextStyle(
        color: isSelected ? AppColors.indigo600 : AppColors.slate700,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
      )),
      trailing: isSelected ? const Icon(LucideIcons.check, color: AppColors.indigo600) : null,
      onTap: () {
        viewModel.setSortOption(option);
        Navigator.pop(context);
      },
    );
  }

  /// Filter Bar 组件 (Pinned version)
  Widget _buildFilterBar(LibraryViewModel viewModel) {
    return Container(
      color: const Color(0xFFF8F9FC), // Match Scafold
      padding: const EdgeInsets.fromLTRB(24, 0, 0, 12), // Right pad inside scroll
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 24),
        child: Row(
          children: [
              // Clear Filter Icon
              GestureDetector(
                onTap: () => viewModel.setLetterFilter(null),
                child: Container(
                  width: 32, height: 32,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: viewModel.selectedLetter == null ? AppColors.indigo600 : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.slate200),
                  ),
                  child: Icon(LucideIcons.x, size: 14, color: viewModel.selectedLetter == null ? Colors.white : AppColors.slate400),
                ),
              ),
              
              ...viewModel.alphabet.map((letter) {
                final isSelected = viewModel.selectedLetter == letter;
                return GestureDetector(
                  onTap: () => viewModel.setLetterFilter(letter),
                  child: Container(
                    width: 32, height: 32,
                    margin: const EdgeInsets.only(right: 6),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.indigo600 : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: isSelected ? Colors.transparent : AppColors.slate200),
                      boxShadow: isSelected ? [BoxShadow(color: AppColors.indigo600.withValues(alpha: 0.3), blurRadius: 6)] : [],
                    ),
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontSize: 12, 
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : AppColors.slate600
                      ),
                    ),
                  ),
                );
              })
          ],
        ),
      ),
    );
  }

  /// 显示编辑对话框
  void _showEditDialog(BuildContext context, Word word, LibraryViewModel viewModel) {
    final spellingController = TextEditingController(text: word.word);
    final meaningController = TextEditingController(text: word.meaningForDictation);
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('编辑单词'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: spellingController,
              decoration: const InputDecoration(labelText: '拼写'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: meaningController,
              decoration: const InputDecoration(labelText: '释义'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              viewModel.onEditWord(
                word,
                newSpelling: spellingController.text,
                newMeaning: meaningController.text,
              );
              Navigator.of(ctx).pop();
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context, Word word) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除确认'),
        content: Text('确定要删除单词 "${word.word}" 吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), style: TextButton.styleFrom(foregroundColor: AppColors.rose500), child: const Text('删除')),
        ],
      ),
    );
  }

  // --- NEW ITEM DESIGN ---

  Widget _buildWordItem(Word word, LibraryViewModel viewModel) {
    // Recency Logic
    Color recencyColor = const Color(0xFFCBD5E1); // Slate 300 (Default/None)
    String recencyText = '从未练习';
    
    if (word.lastReviewedAt != null) {
      final now = DateTime.now();
      final lastReview = word.lastReviewedAt!;
      
      // Calculate difference in calendar days
      final today = DateTime(now.year, now.month, now.day);
      final reviewDay = DateTime(lastReview.year, lastReview.month, lastReview.day);
      final daysDiff = today.difference(reviewDay).inDays;
      
      if (daysDiff == 0) {
        // Same day
        recencyColor = const Color(0xFF22C55E); // Green
        final diff = now.difference(lastReview);
        if (diff.inMinutes < 1) {
          recencyText = '刚刚复习';
        } else if (diff.inMinutes < 60) {
          recencyText = '复习: ${diff.inMinutes}分前';
        } else {
          recencyText = '复习: ${diff.inHours}小时前';
        }
      } else if (daysDiff == 1) {
        recencyColor = const Color(0xFF22C55E); // Green (Still fresh)
        recencyText = '复习: 昨天';
      } else if (daysDiff < 7) {
        recencyColor = const Color(0xFFEAB308); // Yellow
        recencyText = '复习: $daysDiff天前';
      } else {
        recencyColor = const Color(0xFFEF4444); // Red
        recencyText = '复习: $daysDiff天前'; // or specific date
      }
    }

    final isSelected = viewModel.isSelected(word.id);

    return Container( 
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: (viewModel.isSelectionMode && isSelected) ? AppColors.indigo50 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: (viewModel.isSelectionMode && isSelected) 
          ? Border.all(color: AppColors.indigo600, width: 2)
          : null,
        boxShadow: [
           BoxShadow(
             color: AppColors.slate900.withValues(alpha: 0.03),
             blurRadius: 10,
             offset: const Offset(0, 4),
           )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center, // Center for checkbox alignment
        children: [
            // Checkbox for Selection Mode
            if (viewModel.isSelectionMode) ...[
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Icon(
                  isSelected ? LucideIcons.checkCircle : LucideIcons.circle,
                  color: isSelected ? AppColors.indigo600 : AppColors.slate300,
                  size: 24,
                ),
              ),
            ],

           // Left: Word Info
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                  Row(
                    children: [
                      Text(word.word, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.slate900)),
                      const SizedBox(width: 8),
                      // 播放按钮
                      GestureDetector(
                        onTap: () => viewModel.speakWord(word),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.indigo50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.volume2, size: 14, color: AppColors.indigo600),
                        ),
                      ),
                      if (word.wrongCount > 2) ...[
                        const SizedBox(width: 8),
                        const Icon(LucideIcons.flame, size: 16, color: Color(0xFFEF4444)), // Hot mistake
                      ]
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('/${word.phonetic}/', style: const TextStyle(fontSize: 12, fontFamily: 'RobotoMono', color: AppColors.slate400, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Text(word.meaningForDictation, style: const TextStyle(fontSize: 14, color: AppColors.slate600)),
               ],
             ),
           ),

           // Right: Status Column
           Column(
             crossAxisAlignment: CrossAxisAlignment.end,
             children: [
               // Recency Badge
               Container(
                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                 decoration: BoxDecoration(
                   color: recencyColor.withValues(alpha: 0.1),
                   borderRadius: BorderRadius.circular(4),
                 ),
                 child: Row(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     Icon(LucideIcons.clock, size: 10, color: recencyColor),
                     const SizedBox(width: 4),
                     Text(recencyText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: recencyColor)),
                   ],
                 ),
               ),
               
               // Mistake Count (if any)
               if (word.wrongCount > 0) ...[
                 const SizedBox(height: 6),
                 Text(
                   '${word.wrongCount}次错误', 
                   style: const TextStyle(fontSize: 10, color: AppColors.slate400),
                 ),
               ],
             ],
           )
        ],
      ),
    );
  }

  Widget _buildEmptyState(LibraryViewModel viewModel) {
    if (viewModel.isClean) {
      return const EmptyView(
        imagePath: 'assets/images/img_empty_library.png',
        title: '你的词汇宝库还在建设中',
        subtitle: '不积跬步，无以至千里。\n点击首页"拍照"，存入你的第一笔财富吧！',
      );
    } else {
      return const EmptyView(
        imagePath: 'assets/images/img_empty_library.png',
        title: '没有符合条件的单词',
        subtitle: '尝试切换筛选条件看看',
      );
    }
  }

  @override
  LibraryViewModel viewModelBuilder(BuildContext context) => LibraryViewModel();

  @override
  void onViewModelReady(LibraryViewModel viewModel) => viewModel.init();
}

class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _FilterHeaderDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 60;

  @override
  double get minExtent => 60;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}


