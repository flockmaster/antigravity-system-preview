import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:confetti/confetti.dart';
import 'package:word_assistant/core/theme/app_colors.dart';
import '../../common/app_dimensions.dart';
import '../../common/app_typography.dart';
import '../../widgets/premium_card.dart';
import '../../../core/components/baic_ui_kit.dart';
import 'calendar_view_model.dart';
import 'widgets/calendar_widgets.dart';
import 'widgets/reward_modal.dart';

class CalendarView extends StackedView<CalendarViewModel> {
  const CalendarView({super.key});

  @override
  Widget builder(
    BuildContext context,
    CalendarViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Main Content
          Column(
            children: [
              // Sticky Header Area
              _buildHeader(context, viewModel),
              
              // Scrollable Body
              Expanded(
                child: viewModel.selectedTabIndex == 0
                    ? _buildCheckInTab(context, viewModel)
                    : _buildShopTab(context, viewModel),
              ),
            ],
          ),

          // 3. Ticket Redemption Dialog (Overlay)
          if (viewModel.redeemedItem != null)
            _buildTicketOverlay(context, viewModel),

          // 4. Streak Reward Modal (Existing)
          if (viewModel.selectedReward != null)
            RewardModal(
              reward: viewModel.selectedReward!,
              onClose: () => viewModel.setSelectedReward(null),
            ),

          // 5. Confetti Overlay (On Top)
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: viewModel.confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ... (Header and other methods remain the same) ...

  // Fast forward to _showPasswordDialog
  void _showPointsRules(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Icon(LucideIcons.scroll, color: AppColors.amber500),
             SizedBox(width: 8),
             Text('赚积分秘籍', style: AppTypography.h3),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRuleItem('每日登录', '+10', LucideIcons.calendarCheck, AppColors.blue500),
            const SizedBox(height: 12),
            _buildRuleItem('完成每日练习', '+50', LucideIcons.penTool, AppColors.violet500, subtitle: '含阶梯学习或强化听写'),
            const SizedBox(height: 12),
            _buildRuleItem('金牌打卡 (全对)', '+20', LucideIcons.medal, AppColors.orange500),
            const SizedBox(height: 12),
            _buildRuleItem('消灭错词', '+5 /词', LucideIcons.eraser, AppColors.red500),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('我记住了', style: TextStyle(color: AppColors.slate500, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String title, String points, IconData icon, Color color, {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.slate900)),
                if (subtitle != null)
                   Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.slate500)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(points, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  void _showPasswordDialog(BuildContext context, CalendarViewModel viewModel) {
    final TextEditingController pinController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('家长确认', textAlign: TextAlign.center, style: AppTypography.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '请输入 PIN 码以确认兑换',
              style: TextStyle(color: AppColors.slate500, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              autofocus: true,
              obscureText: true,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 4,
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: AppColors.slate50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
              style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('取消', style: TextStyle(color: AppColors.slate400)),
          ),
          TextButton(
            onPressed: () async {
              if (pinController.text == '1234') { // Default PIN
                Navigator.pop(context); // Close Dialog
                await viewModel.confirmRedemption();
                viewModel.clearRedemption(); // Close Ticket Overlay
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('密码错误，请重试')),
                );
              }
            },
            child: const Text('确认', style: TextStyle(color: AppColors.violet600, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showRetroCheckInDialog(BuildContext context, CalendarViewModel viewModel, DateTime date) {
    final dateLabel = '${date.month}月${date.day}日';
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('补签确认', textAlign: TextAlign.center, style: AppTypography.h3),
        content: Text(
          '补签$dateLabel将消耗200积分，是否继续？',
          style: const TextStyle(color: AppColors.slate600, fontSize: 14),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(color: AppColors.slate400)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await viewModel.retroCheckIn(date);
              String message;
              switch (result) {
                case RetroCheckInResult.success:
                  message = '补签成功，连胜已更新';
                  break;
                case RetroCheckInResult.insufficientPoints:
                  message = '积分不足，无法补签';
                  break;
                case RetroCheckInResult.limitReached:
                  message = '本月补签次数已用完';
                  break;
                case RetroCheckInResult.tooOld:
                  message = '超出可补签日期范围';
                  break;
                case RetroCheckInResult.alreadyCheckedIn:
                  message = '该日期已打卡或补签';
                  break;
                case RetroCheckInResult.notEligible:
                  message = '只能补签过去的日期';
                  break;
                case RetroCheckInResult.error:
                  message = '补签失败，请稍后重试';
                  break;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
            },
            child: const Text('确认', style: TextStyle(color: AppColors.violet600, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, CalendarViewModel viewModel) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: AppDimensions.spaceL,
        right: AppDimensions.spaceL,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: AppColors.slate900.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Row: Level & Points
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.orange100,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text(
                  'LEVEL 3 单词学徒',
                  style: TextStyle(
                    color: AppColors.orange600,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              // Points Capsule
              GestureDetector(
                onTap: () => _showPointsRules(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.amber100,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: AppColors.amber200),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.coins, size: 14, color: AppColors.amber600),
                      const SizedBox(width: 4),
                      Text(
                        '${viewModel.userPoints}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppColors.amber700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 14, height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.amber600.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.helpCircle, size: 10, color: AppColors.amber700),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
                  const SizedBox(height: 16),
          
          // Title & Segmented Control
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '成长与收获',
                style: AppTypography.h1,
              ),
              // Tiny Segmented Switch
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  children: [
                    _buildSegmentBtn(
                      title: '足迹',
                      icon: LucideIcons.footprints,
                      isActive: viewModel.selectedTabIndex == 0,
                      onTap: () => viewModel.setTabIndex(0),
                    ),
                    _buildSegmentBtn(
                      title: '心愿',
                      icon: LucideIcons.store,
                      isActive: viewModel.selectedTabIndex == 1,
                      onTap: () => viewModel.setTabIndex(1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentBtn({
    required String title,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? AppColors.slate900 : AppColors.slate500,
            ),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive ? AppColors.slate900 : AppColors.slate500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Tab 1: Check-in (Original View)
  // ===========================================================================

  Widget _buildCheckInTab(BuildContext context, CalendarViewModel viewModel) {
    return ListView(
      padding: const EdgeInsets.only(
        left: AppDimensions.spaceL,
        right: AppDimensions.spaceL,
        top: 24,
        bottom: 120, // Space for FloatingTabBar
      ),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildStreakCard(viewModel),
        const SizedBox(height: 24),
        _buildRewardsSection(viewModel),
        const SizedBox(height: 24),
        _buildCalendarCard(viewModel),
      ],
    );
  }

  // ... (Existing _buildStreakCard, _buildRewardsSection, _buildCalendarCard methods)
  // Reuse the exact code from previous implementation
  
  Widget _buildStreakCard(CalendarViewModel viewModel) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF97316), Color(0xFFEF4444)], 
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF97316).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            Positioned(
              bottom: -40, left: -40,
              child: Container(
                width: 160, height: 160,
                decoration: BoxDecoration(
                  color: Colors.yellow.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.yellow.withValues(alpha: 0.2), blurRadius: 60, spreadRadius: 10)
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '连续坚持',
                        style: TextStyle(
                          color: Color(0xFFFFEDD5), 
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${viewModel.streakDays} ',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -1,
                              ),
                            ),
                            const TextSpan(
                              text: '天',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Text(
                          '坚持就是胜利！',
                          style: TextStyle(
                            color: Colors.white, 
                            fontSize: 13, 
                            fontWeight: FontWeight.w600
                          ),
                        ),
                      ),
                    ],
                  ),
                  const PulsingFlame(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardsSection(CalendarViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Row(
            children: [
              Icon(LucideIcons.medal, size: 20, color: AppColors.slate900),
              SizedBox(width: 8),
              Text(
                '里程碑',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.slate900,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          clipBehavior: Clip.none,
          child: Row(
            children: viewModel.streakRewards.map((reward) => RewardCard(
              reward: reward, 
              onTap: () => viewModel.setSelectedReward(reward),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarCard(CalendarViewModel viewModel) {
    final statusMap = viewModel.daysStatus;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    
    return PremiumCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 32,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '${viewModel.currentDate.year}年 ${viewModel.currentDate.month}月',
                    style: const TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.w900, 
                      color: AppColors.slate900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildNavButton(LucideIcons.chevronLeft, viewModel.prevMonth),
                  const SizedBox(width: 4),
                  _buildNavButton(LucideIcons.chevronRight, viewModel.nextMonth),
                ],
              ),
              Text(
                '打卡 ${viewModel.doneCount} 天',
                style: const TextStyle(
                  fontSize: 12, 
                  fontWeight: FontWeight.bold, 
                  color: AppColors.slate600
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Calendar Grid Header
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['一', '二', '三', '四', '五', '六', '日'].map((d) => 
                SizedBox(
                  width: 32,
                  child: Center(
                    child: Text(
                      d,
                      style: const TextStyle(
                        fontSize: 13, 
                        fontWeight: FontWeight.w900, 
                        color: AppColors.slate600,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                )
              ).toList(),
            ),
          ),
          // Calendar Grid Items
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 0,
              crossAxisSpacing: 4,
              childAspectRatio: 0.75, // Further reduced from 1.0 to accommodate 'Today' cell height
            ),
            itemCount: statusMap.length + (DateTime(viewModel.currentDate.year, viewModel.currentDate.month, 1).weekday - 1),
            itemBuilder: (context, index) {
              final firstWeekday = DateTime(viewModel.currentDate.year, viewModel.currentDate.month, 1).weekday;
              final startOffset = firstWeekday - 1;
              if (index < startOffset) return const SizedBox();
              final day = index - startOffset + 1;
              if (day > statusMap.length) return const SizedBox();
              final date = DateTime(viewModel.currentDate.year, viewModel.currentDate.month, day);
              final dayStatus = statusMap[day] ?? const DayCellStatus(status: 'future', isRetro: false);
              final isPast = date.isBefore(todayDate);
              final canRetro = dayStatus.status == 'missed' && isPast;
              return _buildDayCell(
                day,
                dayStatus,
                onTap: canRetro
                    ? () {
                        if (!viewModel.isWithinRetroRange(date)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('只能补签最近30天内的日期')),
                          );
                          return;
                        }
                        _showRetroCheckInDialog(context, viewModel, date);
                      }
                    : null,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap) {
    return BaicBounceButton(
      onPressed: onTap,
      child: Container(
        width: 24, height: 24,
        decoration: const BoxDecoration(
          color: AppColors.slate100,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 14, color: AppColors.slate400),
      ),
    );
  }

  Widget _buildDayCell(int day, DayCellStatus status, {VoidCallback? onTap}) {
    Color? bgColor;
    Color textColor = AppColors.slate300;
    Widget? content;
    List<BoxShadow>? shadows;
    if (status.status == 'gold') {
      bgColor = const Color(0xFFFDE047); 
      textColor = const Color(0xFF854D0E); 
      content = const Icon(LucideIcons.trophy, size: 16, color: Colors.white);
      shadows = [
        BoxShadow(
          color: const Color(0xFFFDE047).withValues(alpha: 0.4),
          blurRadius: 10, offset: const Offset(0, 4),
        )
      ];
    } else if (status.status == 'done') {
      bgColor = const Color(0xFFDCFCE7);
      textColor = const Color(0xFF16A34A); 
      content = const Icon(LucideIcons.check, size: 14, color: Color(0xFF16A34A));
    } else if (status.status == 'today') {
      bgColor = AppColors.slate900;
      textColor = Colors.white;
      content = Text('$day', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12));
      shadows = [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))
      ];
    } else if (status.status == 'missed') {
      bgColor = AppColors.slate50;
      textColor = AppColors.slate600;
      content = Text('$day', style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 12));
    } else {
      textColor = AppColors.slate300;
      content = Text('$day', style: TextStyle(color: textColor, fontWeight: FontWeight.w900, fontSize: 12));
    }
    final circle = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            boxShadow: shadows,
          ),
          child: Center(child: content),
        ),
        if (status.isRetro)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: AppColors.slate900,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '补',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );

    final cell = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        circle,
        if (status.status == 'today') ...[
          const SizedBox(height: 4),
          Container(
            width: 4, height: 4, 
            decoration: const BoxDecoration(color: AppColors.slate900, shape: BoxShape.circle),
          ),
        ]
      ],
    );
    if (onTap == null) return cell;
    return GestureDetector(onTap: onTap, child: cell);
  }

  // ===========================================================================
  // Tab 2: Wish Shop
  // ===========================================================================

  Widget _buildShopTab(BuildContext context, CalendarViewModel viewModel) {
    return GridView.builder(
      padding: const EdgeInsets.only(
        left: AppDimensions.spaceL,
        right: AppDimensions.spaceL,
        top: 24,
        bottom: 120, 
      ),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.70, // Adjusted from 0.8 to prevent overflow
      ),
      itemCount: viewModel.shopItems.length,
      itemBuilder: (context, index) {
        final item = viewModel.shopItems[index];
        return _buildShopCard(context, item, viewModel);
      },
    );
  }

  Widget _buildShopCard(BuildContext context, ShopItem item, CalendarViewModel viewModel) {
    final canAfford = viewModel.userPoints >= item.price;
    
    return BaicBounceButton(
      onPressed: () {
        if (!canAfford) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('积分不足，还差 ${item.price - viewModel.userPoints} 积分'),
              backgroundColor: AppColors.slate800,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 100, left: 24, right: 24),
              duration: const Duration(seconds: 2),
            ),
          );
          return;
        }
        viewModel.redeemItem(item);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: canAfford ? Color(item.color).withValues(alpha: 0.2) : AppColors.slate200,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: canAfford 
                  ? Color(item.color).withValues(alpha: 0.15) 
                  : AppColors.slate200.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Image Area
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: canAfford 
                        ? item.gradientColors.map((c) => c.withValues(alpha: 0.2)).toList()
                        : [AppColors.slate100, AppColors.slate50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                ),
                child: Center(
                  child: Container(
                    width: 80, height: 80,
                    padding: item.imagePath != null ? EdgeInsets.zero : const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: canAfford ? Color(item.color).withValues(alpha: 0.2) : Colors.transparent,
                          blurRadius: 12,
                        )
                      ],
                    ),
                    child: item.imagePath != null
                        ? ClipOval(
                            child: Image.asset(
                              item.imagePath!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    item.iconData,
                                    size: 32,
                                    color: canAfford ? Color(item.color) : AppColors.slate400,
                                  ),
                                );
                              },
                            ),
                          )
                        : Icon(
                            item.iconData,
                            size: 32,
                            color: canAfford ? Color(item.color) : AppColors.slate400,
                          ),
                  ),
                ),
              ),
            ),
            // Info Area
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: canAfford ? AppColors.slate900 : AppColors.slate400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.slate400,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    // Price Tag
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: canAfford ? Color(item.color) : AppColors.slate100,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.coins, 
                            size: 10, 
                            color: canAfford ? Colors.white : AppColors.slate400
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.price}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: canAfford ? Colors.white : AppColors.slate500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Ticket Overlay (Redemption)
  // ===========================================================================

  Widget _buildTicketOverlay(BuildContext context, CalendarViewModel viewModel) {
    if (viewModel.redeemedItem == null) return const SizedBox();
    final item = viewModel.redeemedItem!;

    return Stack(
      children: [
        // Backdrop
        GestureDetector(
          onTap: viewModel.clearRedemption, 
          child: Container(
            color: Colors.black.withValues(alpha: 0.8),
          ),
        ),
        
        // Ticket
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Part (Main Ticket)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        '心愿兑换券',
                        style: TextStyle(
                          fontSize: 14,
                          letterSpacing: 4,
                          color: AppColors.slate400,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: 80, height: 80,
                        padding: item.imagePath != null ? EdgeInsets.zero : const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: item.imagePath != null ? Colors.white : Color(item.color).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: item.imagePath != null
                            ? ClipOval(
                                child: Image.asset(
                                  item.imagePath!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Icon(item.iconData, size: 40, color: Color(item.color)),
                                ),
                              )
                            : Icon(item.iconData, size: 40, color: Color(item.color)),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.slate900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '有效期：24小时内有效',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.slate400,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(height: 1, color: AppColors.slate100),
                    ],
                  ),
                ),
                
                // Jagged Edge / Perforation SVG or CSS logic simulation
                // Simplify with dots
                Container(
                  color: Colors.white,
                  child: Row(
                    children: List.generate(20, (index) => Expanded(
                      child: Container(
                        height: 1,
                        color: index % 2 == 0 ? AppColors.slate200 : Colors.white,
                      ),
                    )),
                  ),
                ),

                // Bottom Part (Action)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(LucideIcons.coins, size: 16, color: AppColors.amber500),
                          const SizedBox(width: 8),
                          Text(
                            '-${item.price}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.amber600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _showPasswordDialog(context, viewModel),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.slate900,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            '立即核销',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: viewModel.clearRedemption,
                        child: const Text(
                          '稍后再用',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.slate400,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }



  @override
  void onViewModelReady(CalendarViewModel viewModel) {
    viewModel.init();
  }

  @override
  CalendarViewModel viewModelBuilder(BuildContext context) => CalendarViewModel();
}
