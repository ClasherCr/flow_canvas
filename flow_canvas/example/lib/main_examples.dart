import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flow_canvas/flow_canvas.dart';

// This file contains additional examples - you can copy these to main.dart if needed

// Example 2: Custom Node Styles
class CustomNodeExample extends ConsumerStatefulWidget {
  const CustomNodeExample({super.key});

  @override
  ConsumerState<CustomNodeExample> createState() => _CustomNodeExampleState();
}

class _CustomNodeExampleState extends ConsumerState<CustomNodeExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Node Styles')),
      body: FlowCanvas(
        gridColor: Colors.grey.shade300,
        backgroundColor: Colors.grey.shade50,
        showZoomControl: true,
        zoomControlAlignment: Alignment.centerRight,
      ),
    );
  }
}

// Example 3: Data Flow
class DataFlowExample extends ConsumerStatefulWidget {
  const DataFlowExample({super.key});

  @override
  ConsumerState<DataFlowExample> createState() => _DataFlowExampleState();
}

class _DataFlowExampleState extends ConsumerState<DataFlowExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Flow Visualization')),
      body: FlowCanvas(
        gridColor: Colors.green.shade200,
        backgroundColor: Colors.green.shade50,
        showZoomControl: true,
      ),
    );
  }
}

// Example 4: Mind Map
class MindMapExample extends ConsumerStatefulWidget {
  const MindMapExample({super.key});

  @override
  ConsumerState<MindMapExample> createState() => _MindMapExampleState();
}

class _MindMapExampleState extends ConsumerState<MindMapExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mind Map')),
      body: FlowCanvas(
        gridColor: Colors.orange.shade200,
        backgroundColor: Colors.orange.shade50,
        showZoomControl: true,
        zoomControlAlignment: Alignment.bottomLeft,
      ),
    );
  }
}

// Example 5: Node Configuration
class NodeConfigExample extends ConsumerStatefulWidget {
  const NodeConfigExample({super.key});

  @override
  ConsumerState<NodeConfigExample> createState() => _NodeConfigExampleState();
}

class _NodeConfigExampleState extends ConsumerState<NodeConfigExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Node Configuration')),
      body: FlowCanvas(
        gridColor: Colors.red.shade200,
        backgroundColor: Colors.red.shade50,
        showZoomControl: true,
      ),
    );
  }
}
