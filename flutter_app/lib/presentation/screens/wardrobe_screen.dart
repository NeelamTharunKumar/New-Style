import 'package:flutter/material.dart';

import '../../core/design_tokens.dart';

import '../../data/app_models.dart';
import '../../data/local_feature_extractor.dart';
import '../../data/local_image_service.dart';
import '../../state/app_state.dart';
import '../widgets/app_components.dart';
import '../widgets/local_wardrobe_image.dart';
import '../widgets/status_banner.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  @override
  void initState() {
    super.initState();
    widget.appState.addListener(_refresh);
    WidgetsBinding.instance.addPostFrameCallback((_) => widget.appState.loadWardrobe());
  }

  @override
  void dispose() {
    widget.appState.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  Future<void> _openAddItem() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddWardrobeItemScreen(appState: widget.appState)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;
    return AppGradientScaffold(
      appBar: AppBar(
        title: const Text('Your Wardrobe'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: state.isBusy ? null : () => state.loadWardrobe(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddItem,
        icon: const Icon(Icons.add),
        label: const Text('Add item'),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          StatusBanner(error: state.error, message: state.statusMessage, isBusy: state.isBusy),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'Structured wardrobe', subtitle: 'Add items manually or pick a local photo to prefill color and pattern hints.'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: state.isBusy ? null : () => state.addDemoWardrobe(),
                        icon: const Icon(Icons.auto_fix_high_outlined),
                        label: const Text('Add demo set'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _openAddItem,
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Manual item'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (state.wardrobeItems.isEmpty)
                  EmptyState(
                    icon: Icons.checkroom_outlined,
                    title: 'No wardrobe items yet',
                    subtitle: 'Add a demo set or create your first local wardrobe item. Photos remain on-device.',
                    action: ElevatedButton.icon(
                      onPressed: state.isBusy ? null : () => state.addDemoWardrobe(),
                      icon: const Icon(Icons.auto_fix_high_outlined),
                      label: const Text('Add demo wardrobe'),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.78,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: state.wardrobeItems.length,
                    itemBuilder: (context, index) => _WardrobeGridCard(
                      item: state.wardrobeItems[index],
                      onDelete: () => state.deleteWardrobeItem(state.wardrobeItems[index]),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AddWardrobeItemScreen extends StatefulWidget {
  const AddWardrobeItemScreen({super.key, required this.appState});

  final AppState appState;

  @override
  State<AddWardrobeItemScreen> createState() => _AddWardrobeItemScreenState();
}

class _AddWardrobeItemScreenState extends State<AddWardrobeItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController(text: 'shirt');
  final _subcategoryController = TextEditingController();
  final _colorController = TextEditingController(text: 'light blue');
  final _hexController = TextEditingController();
  final _patternController = TextEditingController(text: 'solid');
  final _fabricController = TextEditingController(text: 'cotton');
  final _fitController = TextEditingController(text: 'regular');
  final _styleTagsController = TextEditingController(text: 'smart casual, minimal');
  final _occasionTagsController = TextEditingController(text: 'office');
  final _climateTagsController = TextEditingController(text: 'hot_humid');
  final _localRefController = TextEditingController(text: '');
  final _localImageService = const LocalImageService();
  late final LocalFeatureExtractor _featureExtractor;
  Map<String, dynamic> _featureSummary = const {};
  String _styleMode = 'mixed';
  int _formality = 5;

  @override
  void initState() {
    super.initState();
    _featureExtractor = LocalFeatureExtractor(imageService: _localImageService);
    _styleMode = widget.appState.profile.styleMode;
    if (_styleMode == 'mixed') _styleMode = 'menswear';
  }

  @override
  void dispose() {
    _itemIdController.dispose();
    _nameController.dispose();
    _categoryController.dispose();
    _subcategoryController.dispose();
    _colorController.dispose();
    _hexController.dispose();
    _patternController.dispose();
    _fabricController.dispose();
    _fitController.dispose();
    _styleTagsController.dispose();
    _occasionTagsController.dispose();
    _climateTagsController.dispose();
    _localRefController.dispose();
    super.dispose();
  }

  Future<void> _pickAndExtractImage() async {
    try {
      final hint = _emptyToNull(_itemIdController.text) ?? _emptyToNull(_nameController.text) ?? _categoryController.text;
      final extracted = await _featureExtractor.pickCopyAndExtract(itemIdHint: hint);
      if (extracted == null) return;
      setState(() {
        _localRefController.text = extracted.localImageRef;
        _hexController.text = extracted.hexColor;
        _colorController.text = extracted.colorName;
        _patternController.text = extracted.patternHint;
        _featureSummary = extracted.toStructuredSummary();
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Extracted ${extracted.colorName} (${extracted.hexColor}) locally. Photo was not uploaded.')),
      );
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Local extraction failed: $err')));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final item = WardrobeItem(
      userId: widget.appState.userId,
      itemId: _emptyToNull(_itemIdController.text),
      styleMode: _styleMode,
      name: _emptyToNull(_nameController.text),
      category: _categoryController.text.trim().toLowerCase(),
      subcategory: _emptyToNull(_subcategoryController.text),
      color: _colorController.text.trim().toLowerCase(),
      hexColor: _emptyToNull(_hexController.text),
      pattern: _emptyToNull(_patternController.text) ?? 'solid',
      fabric: _emptyToNull(_fabricController.text),
      fit: _emptyToNull(_fitController.text),
      formality: _formality,
      styleTags: splitTags(_styleTagsController.text),
      occasionTags: splitTags(_occasionTagsController.text),
      climateTags: splitTags(_climateTagsController.text),
      indiaTags: splitTags(_occasionTagsController.text),
      localImageRef: _emptyToNull(_localRefController.text) ??
          _localImageService.wardrobeRefForItem(_emptyToNull(_itemIdController.text) ?? 'new_item'),
      featureVectorSummary: _featureSummary,
    );
    await widget.appState.addWardrobeItem(item);
    if (mounted && widget.appState.error == null) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.appState;
    return AppGradientScaffold(
      appBar: AppBar(title: const Text('Add wardrobe item')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          StatusBanner(error: state.error, message: state.statusMessage, isBusy: state.isBusy),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: _styleMode,
                    decoration: const InputDecoration(labelText: 'Style mode', border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'menswear', child: Text('Menswear')),
                      DropdownMenuItem(value: 'womenswear', child: Text('Womenswear')),
                      DropdownMenuItem(value: 'mixed', child: Text('Mixed / Unisex')),
                    ],
                    onChanged: (value) => setState(() => _styleMode = value ?? 'mixed'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _itemIdController,
                    decoration: const InputDecoration(labelText: 'Item ID (optional)', hintText: 'shirt_001', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Display name', hintText: 'Light blue office shirt', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _categoryController,
                    decoration: const InputDecoration(labelText: 'Category', hintText: 'shirt, kurti, saree, chinos, juttis...', border: OutlineInputBorder()),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Category is required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _subcategoryController,
                    decoration: const InputDecoration(labelText: 'Subcategory (optional)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _colorController,
                    decoration: const InputDecoration(labelText: 'Color', hintText: 'navy blue, mustard yellow, charcoal', border: OutlineInputBorder()),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Color is required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _hexController,
                    decoration: const InputDecoration(labelText: 'Hex color (optional)', hintText: '#A8C7E8', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _patternController,
                    decoration: const InputDecoration(labelText: 'Pattern', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _fabricController,
                    decoration: const InputDecoration(labelText: 'Fabric', hintText: 'cotton, linen, silk, denim', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _fitController,
                    decoration: const InputDecoration(labelText: 'Fit', hintText: 'slim, regular, relaxed, flowy', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  Text('Formality: $_formality/10'),
                  Slider(
                    value: _formality.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: '$_formality',
                    onChanged: (value) => setState(() => _formality = value.round()),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _styleTagsController,
                    decoration: const InputDecoration(labelText: 'Style tags', hintText: 'formal, ethnic, festive, minimal', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _occasionTagsController,
                    decoration: const InputDecoration(labelText: 'Occasion tags', hintText: 'office, college, haldi, wedding guest', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _climateTagsController,
                    decoration: const InputDecoration(labelText: 'Climate tags', hintText: 'hot_humid, monsoon, winter', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _localRefController,
                    decoration: const InputDecoration(
                      labelText: 'Local image reference',
                      hintText: 'local://wardrobe/shirt_001.jpg or file:///...',
                      helperText: 'Only a local pointer/string is sent. Actual image bytes stay on-device.',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _pickAndExtractImage,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Pick local photo & extract color'),
                  ),
                  if (_featureSummary.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      "Local extraction: ${_featureSummary['dominant_color_name']} ${_featureSummary['dominant_hex_color']} · ${_featureSummary['pattern_hint']} · confidence ${((_featureSummary['confidence'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)}",
                      style: TextStyle(color: Colors.green.shade300),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: state.isBusy ? null : _save,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Save structured item'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WardrobeGridCard extends StatelessWidget {
  const _WardrobeGridCard({required this.item, required this.onDelete});

  final WardrobeItem item;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: LocalWardrobeImage(
                    localImageRef: item.localImageRef,
                    hexColor: item.hexColor,
                    borderRadius: 16,
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: InkWell(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(99)),
                      child: const Icon(Icons.delete_outline, size: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(item.displayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            [item.category, if (item.occasionTags.isNotEmpty) item.occasionTags.first].join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppColors.mutedForeground, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _WardrobeItemCard extends StatelessWidget {
  const _WardrobeItemCard({required this.item, required this.onDelete});

  final WardrobeItem item;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: LocalWardrobeImage(localImageRef: item.localImageRef, hexColor: item.hexColor, width: 44, height: 44),
        title: Text(item.displayName, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text([
          item.category,
          item.styleMode,
          if (item.fabric != null) item.fabric!,
          if (item.occasionTags.isNotEmpty) item.occasionTags.join('/'),
          if (item.localImageRef != null) item.localImageRef!,
        ].join(' · ')),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

class _EmptyWardrobe extends StatelessWidget {
  const _EmptyWardrobe();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Text('No wardrobe items yet. Add a demo set or manually enter your first item.'),
      ),
    );
  }
}

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
