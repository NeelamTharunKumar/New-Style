class GarmentFeatureSchema {
  const GarmentFeatureSchema._();

  static const version = 'garment_features_v2';

  static const supportedFields = [
    'category',
    'subcategory',
    'dominant_color_name',
    'dominant_hex_color',
    'secondary_colors',
    'pattern_hint',
    'fabric_hint',
    'fit_hint',
    'sleeve_hint',
    'neckline_hint',
    'formality_hint',
    'occasion_hints',
    'climate_hints',
    'confidence',
    'native_engine',
    'privacy',
  ];
}
