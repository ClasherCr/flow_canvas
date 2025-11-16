# Flow Canvas

A highly customizable, professional-grade flow canvas widget for Flutter, inspired by n8n and Figma. Perfect for building workflow editors, node-based editors, automation tools, and visual programming interfaces.

## Features

✨ **Infinite Canvas** - Smooth panning and zooming with intelligent boundary management
🎯 **Drag & Drop Nodes** - Intuitive node placement with grid snapping
🔗 **Visual Connections** - Connect nodes with beautiful bezier curves
⚡ **High Performance** - Optimized rendering with viewport culling
🎨 **Fully Customizable** - Every aspect can be customized to match your design
📱 **Zoom Control Bar** - Built-in vertical zoom slider with customizable positioning
💬 **Node Modals** - n8n-style modal dialogs for node configuration
🎭 **Theming Support** - Works seamlessly with Flutter's theme system
📦 **State Management** - Built-in Riverpod state management

## Screenshots

_(Add your screenshots here)_

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flow_canvas: ^0.1.0
  flutter_riverpod: ^2.4.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flow_canvas/flow_canvas.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FlowCanvas(
          canvasWidth: 10000,
          canvasHeight: 10000,
          gridSize: 20,
          gridColor: Colors.grey,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
```

### With Zoom Control

```dart
FlowCanvas(
  showZoomControl: true,
  zoomControlAlignment: Alignment.centerLeft,
  zoomControlOffset: const Offset(16, 0),
  minZoom: 0.1,
  maxZoom: 2.0,
)
```

### With Node Palette

```dart
FlowCanvas(
  nodePaletteBuilder: (context, onClose) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          // Your custom node palette UI
          Draggable<Map<String, dynamic>>(
            data: {
              'title': 'My Node',
              'description': 'Node description',
              'color': Colors.blue,
            },
            child: ListTile(
              title: const Text('My Node'),
            ),
          ),
        ],
      ),
    );
  },
)
```

### With Custom Node Modal (n8n-style)

```dart
FlowCanvas(
  nodeModalBuilder: (context, node, onUpdate, onClose) {
    return Dialog(
      child: Container(
        width: 800,
        height: 600,
        child: Column(
          children: [
            // Header
            Text(node.title, style: Theme.of(context).textTheme.headlineMedium),

            // Your custom configuration UI
            TextField(
              decoration: const InputDecoration(labelText: 'Node Name'),
              onChanged: (value) {
                final updatedNode = node.copyWith(title: value);
                onUpdate(updatedNode);
              },
            ),

            // Actions
            ElevatedButton(
              onPressed: onClose,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  },
)
```

### Custom Node Rendering

```dart
FlowCanvas(
  nodeBuilder: (context, node, isSelected, isHovered) {
    return Container(
      width: 200,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          if (isHovered)
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
            ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.settings, color: node.color),
          Text(node.title),
          Text(node.description),
        ],
      ),
    );
  },
)
```

### Custom Zoom Control

```dart
FlowCanvas(
  showZoomControl: true,
  zoomControlBuilder: (context, currentZoom, minZoom, maxZoom, onZoomChanged, onResetView) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => onZoomChanged(currentZoom * 1.2),
          ),
          Text('${(currentZoom * 100).toInt()}%'),
          Slider(
            value: currentZoom,
            min: minZoom,
            max: maxZoom,
            onChanged: onZoomChanged,
          ),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: () => onZoomChanged(currentZoom / 1.2),
          ),
          IconButton(
            icon: const Icon(Icons.fit_screen),
            onPressed: onResetView,
          ),
        ],
      ),
    );
  },
)
```

## Configuration Options

### Canvas Properties

| Property          | Type     | Default        | Description                     |
| ----------------- | -------- | -------------- | ------------------------------- |
| `canvasWidth`     | `double` | `10000.0`      | Width of the canvas in pixels   |
| `canvasHeight`    | `double` | `10000.0`      | Height of the canvas in pixels  |
| `minZoom`         | `double` | `0.1`          | Minimum zoom level              |
| `maxZoom`         | `double` | `2.0`          | Maximum zoom level              |
| `gridSize`        | `double` | `20.0`         | Size of grid cells for snapping |
| `gridColor`       | `Color`  | `Colors.grey`  | Color of the grid lines         |
| `backgroundColor` | `Color`  | `Colors.white` | Canvas background color         |

### Zoom Control Properties

| Property               | Type                  | Default                | Description                    |
| ---------------------- | --------------------- | ---------------------- | ------------------------------ |
| `showZoomControl`      | `bool`                | `true`                 | Show/hide zoom control bar     |
| `zoomControlAlignment` | `Alignment`           | `Alignment.centerLeft` | Position of zoom control       |
| `zoomControlOffset`    | `Offset?`             | `null`                 | Custom offset for zoom control |
| `zoomControlBuilder`   | `ZoomControlBuilder?` | `null`                 | Custom zoom control widget     |

### Callback Properties

| Property             | Type                  | Description                          |
| -------------------- | --------------------- | ------------------------------------ |
| `nodePaletteBuilder` | `NodePaletteBuilder?` | Builder for custom node palette      |
| `nodeModalBuilder`   | `NodeModalBuilder?`   | Builder for node configuration modal |
| `nodeBuilder`        | `NodeBuilder?`        | Custom node widget builder           |
| `nodeMenuBuilder`    | `NodeMenuBuilder?`    | Custom context menu for nodes        |
| `backgroundPainter`  | `BackgroundPainter?`  | Custom canvas background painter     |
| `onNodeTap`          | `VoidCallback?`       | Called when a node is tapped         |
| `onNodeDrag`         | `NodeDragCallback?`   | Called when a node is dragged        |

## Advanced Features

### Programmatic Control

Access the flow state and control nodes programmatically:

```dart
// Inside a ConsumerWidget or ConsumerStatefulWidget
final flowNotifier = ref.read(flowProvider.notifier);

// Add a node
flowNotifier.addNode(FlowNode(
  id: 'node-1',
  title: 'My Node',
  description: 'Description',
  x: 100,
  y: 100,
  color: Colors.blue,
));

// Update a node
flowNotifier.updateNode('node-1', updatedNode);

// Delete a node
flowNotifier.deleteNode('node-1');

// Add connection
flowNotifier.addConnection(connection);

// Select node
flowNotifier.selectNode('node-1');
```

### Custom Background

```dart
FlowCanvas(
  backgroundPainter: (canvas, size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  },
)
```

## Best Practices

1. **Always wrap with ProviderScope**: FlowCanvas uses Riverpod for state management
2. **Use unique node IDs**: Ensure each node has a unique identifier
3. **Optimize node rendering**: Use const constructors and keys where possible
4. **Handle modal updates**: Update node state through the `onUpdate` callback in modals
5. **Test on different screen sizes**: The canvas adapts to viewport size automatically

## Examples

Check out the `/example` folder for a complete implementation including:

- Custom node palette with drag & drop
- n8n-style node modals with tabs
- Custom zoom control
- Node connections and interactions
- Theme integration

**📖 Detailed Examples**: See [`EXAMPLES.md`](EXAMPLES.md) for 6 comprehensive examples showing different use cases.

**⚙️ Advanced Configuration**: See [`CANVAS_CONFIGURATION.md`](CANVAS_CONFIGURATION.md) for detailed canvas configuration options.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Inspired by [n8n](https://n8n.io) workflow automation tool
- Design patterns from [Figma](https://figma.com) canvas interactions
- Built with [Flutter](https://flutter.dev) and [Riverpod](https://riverpod.dev)

## Support

For bugs, questions, and discussions please use the [GitHub Issues](https://github.com/yourusername/flow_canvas/issues).
