import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models/node.dart';
import 'models/connection.dart';
import 'widgets/node_widget.dart';
import 'widgets/connection_painter.dart';
import 'providers/flow_provider.dart';

typedef NodePaletteBuilder =
    Widget Function(BuildContext context, VoidCallback onClose);
typedef BackgroundPainter = void Function(Canvas canvas, Size size);
typedef NodeModalBuilder =
    Widget Function(
      BuildContext context,
      FlowNode node,
      ValueChanged<FlowNode> onUpdate,
      VoidCallback onClose,
    );
typedef ZoomControlBuilder =
    Widget Function(
      BuildContext context,
      double currentZoom,
      double minZoom,
      double maxZoom,
      ValueChanged<double> onZoomChanged,
      VoidCallback onResetView,
    );

class FlowCanvas extends ConsumerStatefulWidget {
  final double canvasWidth;
  final double canvasHeight;
  final double minZoom;
  final double maxZoom;
  final double gridSize;
  final Color gridColor;
  final Color backgroundColor;
  final NodePaletteBuilder? nodePaletteBuilder;
  final BackgroundPainter? backgroundPainter;
  final NodeBuilder? nodeBuilder;
  final NodeMenuBuilder? nodeMenuBuilder;
  final VoidCallback? onNodeTap;
  final NodeDragCallback? onNodeDrag;
  final NodeModalBuilder? nodeModalBuilder;

  /// Enable infinite canvas mode (no boundaries visible when zooming out)
  final bool infiniteCanvas;

  /// Clamp panning to canvas bounds (only applies if infiniteCanvas is false)
  final bool clampPanningToBounds;

  /// Show zoom control bar
  final bool showZoomControl;

  /// Position of zoom control (left, right, or custom offset)
  final Alignment zoomControlAlignment;

  /// Custom zoom control builder
  final ZoomControlBuilder? zoomControlBuilder;

  /// Offset for zoom control position
  final Offset? zoomControlOffset;

  const FlowCanvas({
    super.key,
    this.canvasWidth = 10000.0,
    this.canvasHeight = 10000.0,
    this.minZoom = 0.1,
    this.maxZoom = 2.0,
    this.gridSize = 20.0,
    this.gridColor = Colors.grey,
    this.backgroundColor = Colors.white,
    this.nodePaletteBuilder,
    this.backgroundPainter,
    this.nodeBuilder,
    this.nodeMenuBuilder,
    this.onNodeTap,
    this.onNodeDrag,
    this.nodeModalBuilder,
    this.infiniteCanvas = true,
    this.clampPanningToBounds = false,
    this.showZoomControl = true,
    this.zoomControlAlignment = Alignment.centerLeft,
    this.zoomControlBuilder,
    this.zoomControlOffset,
  });

  @override
  ConsumerState<FlowCanvas> createState() => _FlowCanvasState();
}

class _FlowCanvasState extends ConsumerState<FlowCanvas> {
  late TransformationController _transformationController;
  final GlobalKey _canvasKey = GlobalKey();
  final GlobalKey _interactiveViewerKey = GlobalKey();
  bool _isPaletteOpen = true; // Track palette state
  bool _isClamping = false;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = context.findRenderObject() as RenderBox?;
      if (box != null) {
        final viewport = box.size;
        final dx = (viewport.width - widget.canvasWidth) / 2;
        final dy = (viewport.height - widget.canvasHeight) / 2;
        _transformationController.value = Matrix4.identity()..translate(dx, dy);
      }
    });

    _transformationController.addListener(_onTransformChanged);
  }

  void _onTransformChanged() {
    if (_isClamping) return;

    final matrix = _transformationController.value;
    final scale = matrix.getMaxScaleOnAxis();
    final translation = matrix.getTranslation();

    _isClamping = true;

    try {
      final box = context.findRenderObject();
      if (box is! RenderBox) return;

      final viewport = box.size;

      // Calculate the minimum zoom that ensures canvas always fills viewport
      final minScaleX = viewport.width / widget.canvasWidth;
      final minScaleY = viewport.height / widget.canvasHeight;
      final dynamicMinZoom = math.max(minScaleX, minScaleY);

      // Use the larger of user-defined minZoom or calculated minimum to prevent seeing outside canvas
      final effectiveMinZoom = math.max(widget.minZoom, dynamicMinZoom);

      // Clamp scale to ensure canvas always fills viewport
      final newScale = scale.clamp(effectiveMinZoom, widget.maxZoom);

      // Calculate scaled dimensions
      final scaledW = widget.canvasWidth * newScale;
      final scaledH = widget.canvasHeight * newScale;

      // Calculate bounds - canvas edges must never be visible inside viewport
      double minTx = viewport.width - scaledW;
      double maxTx = 0.0;

      // If canvas is smaller than viewport horizontally, center it
      if (scaledW <= viewport.width) {
        minTx = maxTx = (viewport.width - scaledW) / 2.0;
      }

      double minTy = viewport.height - scaledH;
      double maxTy = 0.0;

      // If canvas is smaller than viewport vertically, center it
      if (scaledH <= viewport.height) {
        minTy = maxTy = (viewport.height - scaledH) / 2.0;
      }

      // Clamp translation to bounds
      final newTx = translation.x.clamp(minTx, maxTx);
      final newTy = translation.y.clamp(minTy, maxTy);

      // Apply clamped transformation if anything changed
      if ((newScale - scale).abs() > 0.0001 ||
          newTx != translation.x ||
          newTy != translation.y) {
        _transformationController.value = Matrix4.identity()
          ..translate(newTx, newTy)
          ..scale(newScale);
      }

      // Trigger rebuild to update zoom control UI
      if (mounted) {
        setState(() {});
      }
    } finally {
      _isClamping = false;
    }
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformChanged);
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flowState = ref.watch(flowProvider);

    return Stack(
      children: [
        InteractiveViewer(
          key: _interactiveViewerKey,
          transformationController: _transformationController,
          // Always use infinite boundary to prevent seeing outside canvas
          boundaryMargin: const EdgeInsets.all(double.infinity),
          constrained: false,
          minScale: widget.minZoom,
          maxScale: widget.maxZoom,
          panEnabled: true,
          scaleEnabled: true,
          child: DragTarget<Map<String, dynamic>>(
            onAcceptWithDetails: (details) {
              final RenderBox? viewerBox =
                  _interactiveViewerKey.currentContext?.findRenderObject()
                      as RenderBox?;
              if (viewerBox == null) {
                // Fallback to canvas key
                final RenderBox box =
                    _canvasKey.currentContext!.findRenderObject() as RenderBox;
                final Offset localPosition = box.globalToLocal(details.offset);
                final Matrix4 inverse = Matrix4.inverted(
                  _transformationController.value,
                );
                final Offset canvasPosition = MatrixUtils.transformPoint(
                  inverse,
                  localPosition,
                );

                final nodeData = details.data;
                final newNode = FlowNode(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: nodeData['title'],
                  description: nodeData['description'],
                  x: canvasPosition.dx - 100,
                  y: canvasPosition.dy - 60,
                  color: nodeData['color'],
                  data: nodeData,
                );

                ref.read(flowProvider.notifier).addNode(newNode);
                return;
              }

              // Convert global position to InteractiveViewer's local coordinates
              final viewerLocal = viewerBox.globalToLocal(details.offset);

              // Get transformation matrix
              final matrix = _transformationController.value;
              final scale = matrix.getMaxScaleOnAxis();
              final translation = matrix.getTranslation();

              // Apply inverse transformation to get canvas coordinates
              final canvasX = (viewerLocal.dx - translation.x) / scale;
              final canvasY = (viewerLocal.dy - translation.y) / scale;

              final nodeData = details.data;
              final newNode = FlowNode(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: nodeData['title'],
                description: nodeData['description'],
                x: canvasX - 100,
                y: canvasY - 60,
                color: nodeData['color'],
                data: nodeData,
              );

              ref.read(flowProvider.notifier).addNode(newNode);
            },
            builder: (context, candidateData, rejectedData) {
              return GestureDetector(
                onTap: () {
                  ref.read(flowProvider.notifier).selectNode(null);
                  ref.read(flowProvider.notifier).selectConnection(null);
                },
                child: Container(
                  width: widget.canvasWidth,
                  height: widget.canvasHeight,
                  color: widget.backgroundColor,
                  child: Stack(
                    children: [
                      CustomPaint(
                        painter: _GridPainter(
                          gridSize: widget.gridSize,
                          gridColor: widget.gridColor,
                          backgroundPainter: widget.backgroundPainter,
                          visibleRect: _getVisibleRect(),
                        ),
                        size: Size(widget.canvasWidth, widget.canvasHeight),
                      ),
                      CustomPaint(
                        painter: FlowConnectionPainter(
                          connections: flowState.connections,
                          nodes: flowState.nodes,
                          selectedConnectionId: flowState.selectedConnectionId,
                        ),
                        size: Size(widget.canvasWidth, widget.canvasHeight),
                      ),
                      ...flowState.nodes.map(
                        (node) => FlowNodeWidget(
                          key: ValueKey(node.id),
                          node: node,
                          nodeBuilder: widget.nodeBuilder,
                          nodeMenuBuilder: widget.nodeMenuBuilder,
                          onNodeTap: widget.onNodeTap,
                          onNodeDrag: widget.onNodeDrag,
                          onNodeModalOpen: widget.nodeModalBuilder != null
                              ? (node) => _showNodeModal(node)
                              : null,
                          gridSize: widget.gridSize,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Floating palette
        if (_isPaletteOpen && widget.nodePaletteBuilder != null)
          Positioned(
            right: 16,
            top: 16,
            child: widget.nodePaletteBuilder!(
              context,
              () => setState(() => _isPaletteOpen = false),
            ),
          ),
        // FAB to toggle palette
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: () => setState(() => _isPaletteOpen = !_isPaletteOpen),
            child: Icon(_isPaletteOpen ? Icons.close : Icons.palette),
          ),
        ),
        // Zoom control bar
        if (widget.showZoomControl) _buildZoomControl(),
      ],
    );
  }

  Widget _buildZoomControl() {
    final currentZoom = _getCurrentZoom();

    if (widget.zoomControlBuilder != null) {
      return Align(
        alignment: widget.zoomControlAlignment,
        child: Padding(
          padding: EdgeInsets.only(
            left: widget.zoomControlOffset?.dx ?? 16,
            top: widget.zoomControlOffset?.dy ?? 0,
          ),
          child: widget.zoomControlBuilder!(
            context,
            currentZoom,
            widget.minZoom,
            widget.maxZoom,
            _setZoom,
            _resetView,
          ),
        ),
      );
    }

    return Align(
      alignment: widget.zoomControlAlignment,
      child: Padding(
        padding: EdgeInsets.only(
          left: widget.zoomControlOffset?.dx ?? 16,
          top: widget.zoomControlOffset?.dy ?? 0,
        ),
        child: _buildDefaultZoomControl(currentZoom),
      ),
    );
  }

  Widget _buildDefaultZoomControl(double currentZoom) {
    return Container(
      width: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Zoom in button
          IconButton(
            icon: const Icon(Icons.add, size: 20),
            onPressed: _zoomIn,
            tooltip: 'Zoom In',
            padding: const EdgeInsets.all(8),
          ),
          // Zoom percentage
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              '${(currentZoom * 100).toInt()}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
          // Zoom slider
          SizedBox(
            height: 120,
            child: RotatedBox(
              quarterTurns: 3,
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 2,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 12,
                  ),
                ),
                child: Slider(
                  value: currentZoom,
                  min: widget.minZoom,
                  max: widget.maxZoom,
                  onChanged: _setZoom,
                ),
              ),
            ),
          ),
          // Zoom out button
          IconButton(
            icon: const Icon(Icons.remove, size: 20),
            onPressed: _zoomOut,
            tooltip: 'Zoom Out',
            padding: const EdgeInsets.all(8),
          ),
          const Divider(height: 1),
          // Reset view button
          IconButton(
            icon: const Icon(Icons.fit_screen, size: 20),
            onPressed: _resetView,
            tooltip: 'Reset View',
            padding: const EdgeInsets.all(8),
          ),
        ],
      ),
    );
  }

  double _getCurrentZoom() {
    return _transformationController.value.getMaxScaleOnAxis();
  }

  void _setZoom(double zoom) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final viewport = box.size;
    final currentMatrix = _transformationController.value;
    final currentScale = currentMatrix.getMaxScaleOnAxis();
    final currentTranslation = currentMatrix.getTranslation();

    // Calculate viewport center in canvas coordinates
    final viewportCenterCanvas = Offset(
      (viewport.width / 2 - currentTranslation.x) / currentScale,
      (viewport.height / 2 - currentTranslation.y) / currentScale,
    );

    // Calculate new translation to keep viewport center fixed
    final newTranslation = Offset(
      viewport.width / 2 - viewportCenterCanvas.dx * zoom,
      viewport.height / 2 - viewportCenterCanvas.dy * zoom,
    );

    _transformationController.value = Matrix4.identity()
      ..translate(newTranslation.dx, newTranslation.dy)
      ..scale(zoom);
  }

  void _zoomIn() {
    final currentZoom = _getCurrentZoom();
    final newZoom = (currentZoom * 1.2).clamp(widget.minZoom, widget.maxZoom);
    _setZoom(newZoom);
  }

  void _zoomOut() {
    final currentZoom = _getCurrentZoom();
    final newZoom = (currentZoom / 1.2).clamp(widget.minZoom, widget.maxZoom);
    _setZoom(newZoom);
  }

  void _resetView() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    final viewport = box.size;
    final dx = (viewport.width - widget.canvasWidth) / 2;
    final dy = (viewport.height - widget.canvasHeight) / 2;

    _transformationController.value = Matrix4.identity()
      ..translate(dx, dy)
      ..scale(1.0);
  }

  void _showNodeModal(FlowNode node) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        if (widget.nodeModalBuilder != null) {
          return widget.nodeModalBuilder!(context, node, (updatedNode) {
            ref.read(flowProvider.notifier).updateNode(node.id, updatedNode);
          }, () => Navigator.of(context).pop());
        }

        // Default n8n-style modal
        return _buildDefaultNodeModal(node);
      },
    );
  }

  Widget _buildDefaultNodeModal(FlowNode node) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: node.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.settings, color: node.color, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          node.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          node.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            // Content area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Node Configuration',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.edit_note,
                                size: 64,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.color?.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Configure your node here',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Use nodeModalBuilder to customize this view',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color
                                      ?.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Footer with actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      // Save changes
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: node.color,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get the visible rectangle in canvas coordinates for optimized rendering
  Rect _getVisibleRect() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      return Rect.fromLTWH(0, 0, widget.canvasWidth, widget.canvasHeight);
    }

    final viewport = renderBox.size;
    final matrix = _transformationController.value;
    final scale = matrix.getMaxScaleOnAxis();
    final translation = matrix.getTranslation();

    final left = (0 - translation.x) / scale;
    final top = (0 - translation.y) / scale;
    final right = (viewport.width - translation.x) / scale;
    final bottom = (viewport.height - translation.y) / scale;

    return Rect.fromLTRB(left, top, right, bottom);
  }
}

class _GridPainter extends CustomPainter {
  final double gridSize;
  final Color gridColor;
  final BackgroundPainter? backgroundPainter;
  final Rect? visibleRect;

  _GridPainter({
    required this.gridSize,
    required this.gridColor,
    this.backgroundPainter,
    this.visibleRect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    backgroundPainter?.call(canvas, size);

    final paint = Paint()
      ..color = gridColor.withOpacity(0.3)
      ..strokeWidth = 1;

    // Optimize grid rendering by only drawing visible portion
    if (visibleRect != null) {
      final rect = visibleRect!;
      final padding = gridSize * 2;

      // Calculate visible grid range
      final startX = ((rect.left - padding) / gridSize).floor() * gridSize;
      final endX = ((rect.right + padding) / gridSize).ceil() * gridSize;
      final startY = ((rect.top - padding) / gridSize).floor() * gridSize;
      final endY = ((rect.bottom + padding) / gridSize).ceil() * gridSize;

      // Draw dots instead of lines for better performance and appearance
      for (double x = startX; x <= endX; x += gridSize) {
        for (double y = startY; y <= endY; y += gridSize) {
          if (x >= 0 && x <= size.width && y >= 0 && y <= size.height) {
            canvas.drawCircle(Offset(x, y), 1.5, paint);
          }
        }
      }
    } else {
      // Fallback: draw full grid with dots
      for (double x = 0; x < size.width; x += gridSize) {
        for (double y = 0; y < size.height; y += gridSize) {
          canvas.drawCircle(Offset(x, y), 1.5, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) {
    return oldDelegate.visibleRect != visibleRect ||
        oldDelegate.gridSize != gridSize ||
        oldDelegate.gridColor != gridColor;
  }
}
