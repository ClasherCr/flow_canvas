# Flow Canvas Configuration Guide

## Infinite Canvas Mode (Default)

The Flow Canvas now supports **infinite canvas mode** by default, which prevents visible canvas edges when zooming out.

### Key Features

#### 1. **Infinite Canvas Mode** ✨
```dart
FlowCanvas(
  infiniteCanvas: true,  // Default: true
  // ... other properties
)
```

When enabled:
- Canvas appears endless when zooming out (no visible boundaries)
- Users can pan infinitely in all directions
- Background grid renders only visible portions for optimal performance
- Creates a professional, boundless workspace experience

When disabled:
- Canvas has fixed boundaries at `canvasWidth` x `canvasHeight`
- Users see canvas edges when zooming out significantly

#### 2. **Panning Bounds Control**
```dart
FlowCanvas(
  infiniteCanvas: false,
  clampPanningToBounds: true,  // Only applies when infiniteCanvas is false
  // ... other properties
)
```

Controls whether panning is restricted to canvas boundaries (only when `infiniteCanvas: false`).

#### 3. **Canvas Size**
```dart
FlowCanvas(
  canvasWidth: 10000.0,   // Default: 10000 (increased from 5000)
  canvasHeight: 10000.0,  // Default: 10000 (increased from 5000)
  // ... other properties
)
```

Even with infinite mode, a large canvas size ensures plenty of space for nodes.

#### 4. **Zoom Levels**
```dart
FlowCanvas(
  minZoom: 0.1,  // Default: 0.1 (can zoom out 10x)
  maxZoom: 2.0,  // Default: 2.0 (increased from 1.0, can zoom in 2x)
  // ... other properties
)
```

Extended zoom range for better workflow visibility and detail work.

#### 5. **Grid Customization**
```dart
FlowCanvas(
  gridSize: 20.0,              // Default: 20.0
  gridColor: Colors.grey,      // Default: Colors.grey
  backgroundColor: Colors.white, // Default: Colors.white
  // ... other properties
)
```

Grid now renders as **dots** (not lines) for:
- Better performance
- Cleaner visual appearance
- Only renders visible portion of grid

### Complete Example

```dart
import 'package:flow_canvas/flow_canvas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyWorkflowCanvas extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlowCanvas(
      // Infinite canvas (no visible edges)
      infiniteCanvas: true,
      
      // Large canvas size for plenty of space
      canvasWidth: 10000.0,
      canvasHeight: 10000.0,
      
      // Extended zoom range
      minZoom: 0.1,  // Zoom out 10x
      maxZoom: 2.0,  // Zoom in 2x
      
      // Grid appearance
      gridSize: 20.0,
      gridColor: Colors.grey.withOpacity(0.3),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      
      // Optional: Custom node palette
      nodePaletteBuilder: (context, onClose) {
        return Container(
          width: 300,
          child: Card(
            child: NodePalette(onClose: onClose),
          ),
        );
      },
      
      // Optional: Custom node rendering
      nodeBuilder: (context, node) {
        return CustomNodeWidget(node: node);
      },
    );
  }
}
```

### Migration from Previous Version

If you were using the old version with visible canvas edges:

**Before:**
```dart
FlowCanvas(
  canvasWidth: 5000.0,
  canvasHeight: 5000.0,
  minZoom: 0.1,
  maxZoom: 1.0,
)
```

**After (Infinite Mode - Recommended):**
```dart
FlowCanvas(
  infiniteCanvas: true,      // NEW: Enable infinite canvas
  canvasWidth: 10000.0,      // Increased size
  canvasHeight: 10000.0,     // Increased size
  minZoom: 0.1,
  maxZoom: 2.0,              // Increased zoom range
)
```

**After (Bounded Mode - Legacy):**
```dart
FlowCanvas(
  infiniteCanvas: false,          // Disable infinite mode
  clampPanningToBounds: true,    // Restrict panning to boundaries
  canvasWidth: 5000.0,
  canvasHeight: 5000.0,
  minZoom: 0.5,                  // Higher min zoom to prevent seeing edges
  maxZoom: 1.0,
)
```

### Performance Optimizations

The canvas now includes several performance optimizations:

1. **Visible Rect Calculation**: Only visible portions of the grid are rendered
2. **Dot Grid**: Dots instead of lines reduce rendering overhead
3. **Smart Repainting**: Grid only repaints when visible area, size, or color changes
4. **Efficient Node Dropping**: Improved coordinate transformation for drag-and-drop

### Best Practices

1. **Always use infinite canvas mode** for professional applications
2. Set `canvasWidth/Height` to at least `10000.0` for ample space
3. Use `minZoom: 0.1` and `maxZoom: 2.0` for good zoom range
4. Customize `gridColor` to match your theme
5. Use dots for grid (default behavior) for cleaner appearance

### Troubleshooting

**Q: I still see canvas edges when zooming out**
- Ensure `infiniteCanvas: true` (default)
- Check that you're not overriding `boundaryMargin` in InteractiveViewer

**Q: Canvas feels too small**
- Increase `canvasWidth` and `canvasHeight` to larger values (e.g., 20000.0)
- Note: With infinite mode, users won't see the edges anyway

**Q: Performance issues with many nodes**
- Grid optimization only renders visible portions automatically
- Consider implementing node virtualization for 1000+ nodes
- Use `visibleRect` property for custom optimizations

**Q: How do I disable infinite mode?**
```dart
FlowCanvas(
  infiniteCanvas: false,
  clampPanningToBounds: true,
)
```

## Advanced Customization

### Custom Background Painter
```dart
FlowCanvas(
  backgroundPainter: (canvas, size) {
    // Draw custom background
    final paint = Paint()..color = Colors.blue.withOpacity(0.1);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  },
)
```

### Custom Node Builder
```dart
FlowCanvas(
  nodeBuilder: (context, node) {
    return Container(
      width: node.width,
      height: node.height,
      decoration: BoxDecoration(
        color: node.color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(blurRadius: 4)],
      ),
      child: Text(node.title),
    );
  },
)
```

### Node Menu Builder
```dart
FlowCanvas(
  nodeMenuBuilder: (context, node, onClose) {
    return PopupMenuButton(
      itemBuilder: (context) => [
        PopupMenuItem(child: Text('Edit')),
        PopupMenuItem(child: Text('Delete')),
        PopupMenuItem(child: Text('Duplicate')),
      ],
    );
  },
)
```

---

**Package Version**: 1.0.0+  
**Last Updated**: 2025-11-16  
**License**: MIT
