class UserProfile {
  const UserProfile({
    required this.userId,
    required this.styleMode,
    this.region = 'India',
    this.climatePreference,
    this.skinTone,
    this.bodyShape,
    this.preferences = const [],
    this.modestyPreference,
    this.budgetConscious = true,
  });

  final String userId;
  final String styleMode;
  final String region;
  final String? climatePreference;
  final String? skinTone;
  final String? bodyShape;
  final List<String> preferences;
  final String? modestyPreference;
  final bool budgetConscious;

  UserProfile copyWith({
    String? userId,
    String? styleMode,
    String? region,
    String? climatePreference,
    String? skinTone,
    String? bodyShape,
    List<String>? preferences,
    String? modestyPreference,
    bool? budgetConscious,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      styleMode: styleMode ?? this.styleMode,
      region: region ?? this.region,
      climatePreference: climatePreference ?? this.climatePreference,
      skinTone: skinTone ?? this.skinTone,
      bodyShape: bodyShape ?? this.bodyShape,
      preferences: preferences ?? this.preferences,
      modestyPreference: modestyPreference ?? this.modestyPreference,
      budgetConscious: budgetConscious ?? this.budgetConscious,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'style_mode': styleMode,
      'region': region,
      'climate_preference': climatePreference,
      'skin_tone': skinTone,
      'body_shape': bodyShape,
      'preferences': preferences,
      'modesty_preference': modestyPreference,
      'budget_conscious': budgetConscious,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id']?.toString() ?? 'demo_user',
      styleMode: json['style_mode']?.toString() ?? 'mixed',
      region: json['region']?.toString() ?? 'India',
      climatePreference: json['climate_preference']?.toString(),
      skinTone: json['skin_tone']?.toString(),
      bodyShape: json['body_shape']?.toString(),
      preferences: _stringList(json['preferences']),
      modestyPreference: json['modesty_preference']?.toString(),
      budgetConscious: json['budget_conscious'] == true,
    );
  }
}

class WardrobeItem {
  const WardrobeItem({
    required this.userId,
    this.itemId,
    this.styleMode = 'mixed',
    this.name,
    required this.category,
    this.subcategory,
    required this.color,
    this.hexColor,
    this.secondaryColors = const [],
    this.pattern = 'solid',
    this.fabric,
    this.fit,
    this.sleeve,
    this.neckline,
    this.length,
    this.formality = 5,
    this.styleTags = const [],
    this.occasionTags = const [],
    this.seasonTags = const [],
    this.climateTags = const [],
    this.indiaTags = const [],
    this.localImageRef,
  });

  final String userId;
  final String? itemId;
  final String styleMode;
  final String? name;
  final String category;
  final String? subcategory;
  final String color;
  final String? hexColor;
  final List<String> secondaryColors;
  final String? pattern;
  final String? fabric;
  final String? fit;
  final String? sleeve;
  final String? neckline;
  final String? length;
  final int formality;
  final List<String> styleTags;
  final List<String> occasionTags;
  final List<String> seasonTags;
  final List<String> climateTags;
  final List<String> indiaTags;
  final String? localImageRef;

  String get displayName {
    if (name != null && name!.trim().isNotEmpty) return name!;
    return '$color $category';
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      if (itemId != null && itemId!.isNotEmpty) 'item_id': itemId,
      'style_mode': styleMode,
      'name': name,
      'category': category,
      'subcategory': subcategory,
      'color': color,
      'hex_color': hexColor,
      'secondary_colors': secondaryColors,
      'pattern': pattern,
      'fabric': fabric,
      'fit': fit,
      'sleeve': sleeve,
      'neckline': neckline,
      'length': length,
      'formality': formality,
      'style_tags': styleTags,
      'occasion_tags': occasionTags,
      'season_tags': seasonTags,
      'climate_tags': climateTags,
      'india_tags': indiaTags,
      'local_image_ref': localImageRef,
      'feature_vector_summary': <String, dynamic>{},
    };
  }

  factory WardrobeItem.fromJson(Map<String, dynamic> json) {
    return WardrobeItem(
      userId: json['user_id']?.toString() ?? '',
      itemId: json['item_id']?.toString(),
      styleMode: json['style_mode']?.toString() ?? 'mixed',
      name: json['name']?.toString(),
      category: json['category']?.toString() ?? '',
      subcategory: json['subcategory']?.toString(),
      color: json['color']?.toString() ?? '',
      hexColor: json['hex_color']?.toString(),
      secondaryColors: _stringList(json['secondary_colors']),
      pattern: json['pattern']?.toString(),
      fabric: json['fabric']?.toString(),
      fit: json['fit']?.toString(),
      sleeve: json['sleeve']?.toString(),
      neckline: json['neckline']?.toString(),
      length: json['length']?.toString(),
      formality: _intValue(json['formality'], fallback: 5),
      styleTags: _stringList(json['style_tags']),
      occasionTags: _stringList(json['occasion_tags']),
      seasonTags: _stringList(json['season_tags']),
      climateTags: _stringList(json['climate_tags']),
      indiaTags: _stringList(json['india_tags']),
      localImageRef: json['local_image_ref']?.toString(),
    );
  }
}

class ScoreBreakdown {
  const ScoreBreakdown(this.values);

  final Map<String, double> values;

  factory ScoreBreakdown.fromJson(Map<String, dynamic> json) {
    return ScoreBreakdown(
      json.map((key, value) => MapEntry(key, _doubleValue(value))),
    );
  }
}

class OutfitRecommendation {
  const OutfitRecommendation({
    required this.outfitId,
    required this.title,
    required this.itemIds,
    required this.score,
    required this.scoreBreakdown,
    required this.why,
    required this.stylingTips,
    required this.avoid,
    required this.source,
  });

  final String outfitId;
  final String title;
  final List<String> itemIds;
  final double score;
  final ScoreBreakdown scoreBreakdown;
  final String why;
  final List<String> stylingTips;
  final List<String> avoid;
  final String source;

  factory OutfitRecommendation.fromJson(Map<String, dynamic> json) {
    return OutfitRecommendation(
      outfitId: json['outfit_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Recommended outfit',
      itemIds: _stringList(json['item_ids']),
      score: _doubleValue(json['score']),
      scoreBreakdown: ScoreBreakdown.fromJson(
        (json['score_breakdown'] as Map?)?.cast<String, dynamic>() ?? const {},
      ),
      why: json['why']?.toString() ?? '',
      stylingTips: _stringList(json['styling_tips']),
      avoid: _stringList(json['avoid']),
      source: json['source']?.toString() ?? 'rule_engine',
    );
  }
}

List<String> splitTags(String text) {
  return text
      .split(',')
      .map((value) => value.trim().toLowerCase())
      .where((value) => value.isNotEmpty)
      .toSet()
      .toList()
    ..sort();
}

List<String> _stringList(dynamic value) {
  if (value is List) {
    return value.map((item) => item.toString()).where((item) => item.isNotEmpty).toList();
  }
  return const [];
}

int _intValue(dynamic value, {required int fallback}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

double _doubleValue(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
