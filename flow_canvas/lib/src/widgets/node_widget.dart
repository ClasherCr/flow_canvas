import 'package:flow_canvas/flow_canvas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef NodeBuilder =
    Widget Function(
      BuildContext context,
      FlowNode node,
      bool isSelected,
      bool isHovered,
    );
typedef NodeMenuBuilder =
    List<PopupMenuEntry<String>> Function(BuildContext context, FlowNode node);
typedef NodeDragCallback = void Function(FlowNode node, Offset delta);
typedef NodeModalCallback = void Function(FlowNode node);

class FlowNodeWidget extends ConsumerStatefulWidget {
  final FlowNode node;
  final NodeBuilder? nodeBuilder;
  final NodeMenuBuilder? nodeMenuBuilder;
  final NodeDragCallback? onNodeDrag;
  final VoidCallback? onNodeTap;
  final NodeModalCallback? onNodeModalOpen;
  final double gridSize;

  const FlowNodeWidget({
    super.key,
    required this.node,
    this.nodeBuilder,
    this.nodeMenuBuilder,
    this.onNodeDrag,
    this.onNodeTap,
    this.onNodeModalOpen,
    this.gridSize = 20.0,
  });

  @override
  ConsumerState<FlowNodeWidget> createState() => _FlowNodeWidgetState();
}

class _FlowNodeWidgetState extends ConsumerState<FlowNodeWidget> {
  bool _isHovered = false;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = ref.watch(
      flowProvider.select((state) => state.selectedNodeId == widget.node.id),
    );

    return Positioned(
      left: widget.node.x,
      top: widget.node.y,
      child: GestureDetector(
        onTap: () {
          // Single tap: select node
          ref.read(flowProvider.notifier).selectNode(widget.node.id);
          widget.onNodeTap?.call();
        },
        onDoubleTap: () {
          // Double tap: open modal (n8n behavior)
          if (widget.onNodeModalOpen != null) {
            widget.onNodeModalOpen!(widget.node);
          }
        },
        onPanStart: (_) {
          setState(() => _isDragging = true);
          ref.read(flowProvider.notifier).selectNode(widget.node.id);
        },
        onPanUpdate: (details) {
          widget.onNodeDrag?.call(widget.node, details.delta);
          ref
              .read(flowProvider.notifier)
              .moveNode(widget.node.id, details.delta);
        },
        onPanEnd: (details) {
          setState(() => _isDragging = false);
          // Snap to grid
          final snappedX =
              (widget.node.x / widget.gridSize).round() * widget.gridSize;
          final snappedY =
              (widget.node.y / widget.gridSize).round() * widget.gridSize;
          final updated = widget.node.copyWith(x: snappedX, y: snappedY);
          ref.read(flowProvider.notifier).updateNode(widget.node.id, updated);
        },
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child:
              widget.nodeBuilder?.call(
                context,
                widget.node,
                isSelected,
                _isHovered,
              ) ??
              _buildDefaultNode(context, isSelected, _isHovered),
        ),
      ),
    );
  }

  Widget _buildDefaultNode(
    BuildContext context,
    bool isSelected,
    bool isHovered,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: widget.node.width,
      height: widget.node.height,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).dividerColor,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isHovered ? 0.15 : 0.08),
            blurRadius: isHovered ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon and status row
                Row(
                  children: [
                    // Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: widget.node.color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getIconForTitle(widget.node.title),
                        color: widget.node.color,
                        size: 22,
                      ),
                    ),
                    const Spacer(),
                    // Status
                    if (widget.node.isCompleted)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.green,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Title
                Text(
                  widget.node.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Description
                Expanded(
                  child: Text(
                    widget.node.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Hover actions
          if (isHovered || isSelected)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.more_vert, size: 16),
                  onPressed: _showNodeMenu,
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  tooltip: 'More options',
                ),
              ),
            ),
          // Ports
          ..._buildPorts(),
        ],
      ),
    );
  }

  List<Widget> _buildPorts() {
    return PortPosition.values.map((position) {
      final offset = _getPortOffset(position);
      final showPort =
          _isHovered ||
          ref.watch(
            flowProvider.select(
              (state) => state.selectedNodeId == widget.node.id,
            ),
          );

      return Positioned(
        left: offset.dx - 8,
        top: offset.dy - 8,
        child: Opacity(
          opacity: showPort ? 1.0 : 0.3,
          child: DragTarget<String>(
            onAcceptWithDetails: (details) {
              final parts = details.data.split(':');
              if (parts.length == 3) {
                final fromNodeId = parts[0];
                final fromPortStr = parts[1];
                final fromPort = PortPosition.values.firstWhere(
                  (p) => p.name == fromPortStr,
                );

                if (fromNodeId != widget.node.id) {
                  final connection = FlowConnection.create(
                    fromNodeId,
                    widget.node.id,
                    fromPort,
                    position,
                  );
                  ref.read(flowProvider.notifier).addConnection(connection);
                }
              }
            },
            builder: (context, candidateData, rejectedData) {
              return Draggable<String>(
                data: '${widget.node.id}:${position.name}:$position',
                feedback: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: widget.node.color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: candidateData.isNotEmpty
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: candidateData.isNotEmpty
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).dividerColor,
                      width: 2,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }).toList();
  }

  Offset _getPortOffset(PortPosition position) {
    switch (position) {
      case PortPosition.top:
        return Offset(widget.node.width / 2, 0);
      case PortPosition.bottom:
        return Offset(widget.node.width / 2, widget.node.height);
      case PortPosition.left:
        return Offset(0, widget.node.height / 2);
      case PortPosition.right:
        return Offset(widget.node.width, widget.node.height / 2);
    }
  }

  IconData _getIconForTitle(String title) {
    // You can customize this mapping
    switch (title.toLowerCase()) {
      case 'start':
      case 'begin':
        return Icons.play_arrow;
      case 'end':
      case 'finish':
        return Icons.stop;
      case 'process':
      case 'transform':
        return Icons.transform;
      case 'decision':
        return Icons.call_split;
      default:
        return Icons.help_outline;
    }
  }

  void _showNodeMenu() {
    final menuItems =
        widget.nodeMenuBuilder?.call(context, widget.node) ??
        _buildDefaultMenu();

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        widget.node.x + widget.node.width,
        widget.node.y,
        widget.node.x,
        widget.node.y + widget.node.height,
      ),
      items: menuItems,
    ).then((value) {
      if (value != null) {
        _handleMenuAction(value);
      }
    });
  }

  List<PopupMenuEntry<String>> _buildDefaultMenu() {
    return [
      PopupMenuItem<String>(
        value: 'duplicate',
        child: const Row(
          children: [
            Icon(Icons.copy, size: 16),
            SizedBox(width: 8),
            Text('Duplicate'),
          ],
        ),
      ),
      const PopupMenuDivider(),
      PopupMenuItem<String>(
        value: 'delete',
        child: const Row(
          children: [
            Icon(Icons.delete, size: 16, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    ];
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'duplicate':
        ref.read(flowProvider.notifier).duplicateNode(widget.node.id);
        break;
      case 'delete':
        ref.read(flowProvider.notifier).deleteNode(widget.node.id);
        break;
    }
  }
}
