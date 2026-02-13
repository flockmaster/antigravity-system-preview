/// ============================================================================
/// 📄 Model 模板文件
/// ============================================================================
///
/// 用途: 创建新数据模型时的标准参考模板
/// 规则: 必须使用 @JsonSerializable() 进行序列化 (规范 5.3)
///
/// 使用方法:
/// 1. 复制此文件到 lib/core/models/ 目录
/// 2. 重命名文件和类名
/// 3. 运行 flutter pub run build_runner build --delete-conflicting-outputs
/// ============================================================================

import 'package:json_annotation/json_annotation.dart';
import 'package:equatable/equatable.dart';

// 生成的序列化代码文件
// 运行 build_runner 后会自动生成此文件
part 'model_template.g.dart';

/// [ExampleModel] - 示例数据模型
///
/// 代表: [描述此模型代表的业务实体，如"商品信息"、"用户资料"等]
///
/// 对应接口: GET /api/v1/examples/{id}
///
/// 备注:
/// - 所有字段必须有中文备注说明业务含义 (铁律 #10)
/// - 可空字段必须使用 ? 标记
/// - 使用 @JsonKey 处理字段名映射
@JsonSerializable()
class ExampleModel extends Equatable {
  /// 唯一标识符
  /// 由后端生成，无法修改
  @JsonKey(name: 'id')
  final String id;

  /// 名称/标题
  /// 用于列表展示和详情页标题
  @JsonKey(name: 'name')
  final String name;

  /// 描述信息
  /// 可选字段，详细说明此项目的用途
  @JsonKey(name: 'description')
  final String? description;

  /// 状态
  /// 0: 草稿, 1: 已发布, 2: 已下架
  @JsonKey(name: 'status')
  final int status;

  /// 价格 (分)
  /// 后端以分为单位存储，前端展示时需要转换为元
  /// 示例: 1990 表示 19.90 元
  @JsonKey(name: 'price')
  final int price;

  /// 原价 (分)
  /// 用于显示划线价，可为空表示无优惠
  @JsonKey(name: 'original_price')
  final int? originalPrice;

  /// 图片 URL 列表
  /// 第一张为主图，用于列表展示
  @JsonKey(name: 'images', defaultValue: [])
  final List<String> images;

  /// 标签列表
  /// 用于筛选和分类展示
  @JsonKey(name: 'tags', defaultValue: [])
  final List<String> tags;

  /// 创建时间
  /// Unix 时间戳 (毫秒)
  /// 使用 TimeUtils 转换为相对时间展示 (规范 5.4)
  @JsonKey(name: 'created_at')
  final int createdAt;

  /// 更新时间
  /// Unix 时间戳 (毫秒)
  @JsonKey(name: 'updated_at')
  final int? updatedAt;

  /// 是否收藏
  /// 当前用户是否已收藏此项目
  @JsonKey(name: 'is_favorited', defaultValue: false)
  final bool isFavorited;

  /// 关联用户信息
  /// 嵌套模型示例，可为空
  @JsonKey(name: 'author')
  final AuthorInfo? author;

  // ============================================================================
  // 构造函数
  // ============================================================================

  const ExampleModel({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    required this.price,
    this.originalPrice,
    this.images = const [],
    this.tags = const [],
    required this.createdAt,
    this.updatedAt,
    this.isFavorited = false,
    this.author,
  });

  // ============================================================================
  // JSON 序列化 (由 build_runner 生成)
  // ============================================================================

  /// 从 JSON Map 创建实例
  factory ExampleModel.fromJson(Map<String, dynamic> json) =>
      _$ExampleModelFromJson(json);

  /// 转换为 JSON Map
  Map<String, dynamic> toJson() => _$ExampleModelToJson(this);

  // ============================================================================
  // 计算属性 (Computed Properties)
  // ============================================================================

  /// 价格展示文本 (元)
  /// 示例: "19.90"
  String get priceDisplay => (price / 100).toStringAsFixed(2);

  /// 原价展示文本 (元)
  /// 如果没有原价，返回空字符串
  String get originalPriceDisplay =>
      originalPrice != null ? (originalPrice! / 100).toStringAsFixed(2) : '';

  /// 是否有折扣
  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  /// 折扣百分比
  /// 示例: 原价 100，现价 80，返回 "8折"
  String get discountLabel {
    if (!hasDiscount) return '';
    final discount = (price / originalPrice! * 10).toStringAsFixed(1);
    return '$discount折';
  }

  /// 主图 URL
  /// 返回第一张图片，如果没有图片则返回 null
  String? get mainImage => images.isNotEmpty ? images.first : null;

  /// 状态文本
  String get statusText {
    switch (status) {
      case 0:
        return '草稿';
      case 1:
        return '已发布';
      case 2:
        return '已下架';
      default:
        return '未知';
    }
  }

  // ============================================================================
  // Equatable 实现 (用于比较和去重)
  // ============================================================================

  @override
  List<Object?> get props => [id, name, status, price, createdAt];

  // ============================================================================
  // copyWith 方法 (用于创建修改后的副本)
  // ============================================================================

  ExampleModel copyWith({
    String? id,
    String? name,
    String? description,
    int? status,
    int? price,
    int? originalPrice,
    List<String>? images,
    List<String>? tags,
    int? createdAt,
    int? updatedAt,
    bool? isFavorited,
    AuthorInfo? author,
  }) {
    return ExampleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      images: images ?? this.images,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorited: isFavorited ?? this.isFavorited,
      author: author ?? this.author,
    );
  }
}

// ============================================================================
// 嵌套模型示例
// ============================================================================

/// [AuthorInfo] - 作者信息
///
/// 用于展示项目/文章的作者基本信息
@JsonSerializable()
class AuthorInfo extends Equatable {
  /// 用户 ID
  @JsonKey(name: 'id')
  final String id;

  /// 用户昵称
  @JsonKey(name: 'nickname')
  final String nickname;

  /// 头像 URL
  @JsonKey(name: 'avatar')
  final String? avatar;

  const AuthorInfo({
    required this.id,
    required this.nickname,
    this.avatar,
  });

  factory AuthorInfo.fromJson(Map<String, dynamic> json) =>
      _$AuthorInfoFromJson(json);

  Map<String, dynamic> toJson() => _$AuthorInfoToJson(this);

  @override
  List<Object?> get props => [id, nickname];
}
