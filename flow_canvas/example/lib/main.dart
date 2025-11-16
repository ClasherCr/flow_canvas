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
      title: 'Flow Canvas - Feature Showcase',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const ExampleSelector(),
    );
  }
}

// Main selector to show different examples
class ExampleSelector extends StatelessWidget {
  const ExampleSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flow Canvas Examples'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildExampleCard(
            context,
            'Basic Workflow Editor',
            'Simple node-based workflow with drag & drop',
            Icons.account_tree,
            Colors.blue,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BasicWorkflowExample()),
            ),
          ),
          _buildExampleCard(
            context,
            'Custom Node Styles',
            'Different node types with custom rendering',
            Icons.palette,
            Colors.purple,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CustomNodeExample()),
            ),
          ),
          _buildExampleCard(
            context,
            'Data Flow Visualization',
            'Real-time data processing pipeline',
            Icons.data_usage,
            Colors.green,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DataFlowExample()),
            ),
          ),
          _buildExampleCard(
            context,
            'Mind Map',
            'Hierarchical mind mapping tool',
            Icons.psychology,
            Colors.orange,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MindMapExample()),
            ),
          ),
          _buildExampleCard(
            context,
            'Node Configuration',
            'n8n-style modal dialogs for nodes',
            Icons.settings,
            Colors.red,
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NodeConfigExample()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

// Example 1: Basic Workflow Editor
class BasicWorkflowExample extends ConsumerStatefulWidget {
  const BasicWorkflowExample({super.key});

  @override
  ConsumerState<BasicWorkflowExample> createState() =>
      _BasicWorkflowExampleState();
}

class _BasicWorkflowExampleState extends ConsumerState<BasicWorkflowExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Basic Workflow Editor')),
      body: FlowCanvas(
        gridColor: Colors.blueGrey,
        backgroundColor: Colors.white,
        showZoomControl: true,
        nodePaletteBuilder: (context, onClose) => _buildBasicPalette(onClose),
        nodeModalBuilder: (context, node, onUpdate, onClose) {
          return _buildBasicModal(context, node, onUpdate, onClose);
        },
      ),
    );
  }

  Widget _buildBasicPalette(VoidCallback onClose) {
    final nodes = [
      ('Start', 'Begin workflow', Icons.play_arrow, Colors.green),
      ('Process', 'Process data', Icons.transform, Colors.blue),
      ('Decision', 'Make decision', Icons.call_split, Colors.orange),
      ('End', 'End workflow', Icons.stop, Colors.red),
    ];

    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Nodes',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: onClose),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: nodes.length,
              itemBuilder: (context, index) {
                final (title, desc, icon, color) = nodes[index];
                return _buildDraggableNode(title, desc, icon, color);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicModal(
    BuildContext context,
    FlowNode node,
    ValueChanged<FlowNode> onUpdate,
    VoidCallback onClose,
  ) {
    return Dialog(
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: node.color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    node.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(icon: const Icon(Icons.close), onPressed: onClose),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Node Name',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: node.title),
              onChanged: (value) {
                onUpdate(node.copyWith(title: value));
              },
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              controller: TextEditingController(text: node.description),
              maxLines: 3,
              onChanged: (value) {
                onUpdate(node.copyWith(description: value));
              },
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: onClose, child: const Text('Cancel')),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: onClose, child: const Text('Save')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableNode(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Draggable<Map<String, dynamic>>(
      data: {
        'title': title,
        'description': description,
        'icon': icon,
        'color': color,
      },
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 200,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
  bool _showPalette = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flow Canvas Example')),
      body: FlowCanvas(
        gridColor: Colors.blueGrey,
        backgroundColor: Colors.white,
        // Enable zoom control on the left side
        showZoomControl: true,
        zoomControlAlignment: Alignment.centerLeft,
        zoomControlOffset: const Offset(16, 0),
        // Node palette builder
        nodePaletteBuilder: _showPalette
            ? (context, onClose) {
                return _buildNodePalette(onClose);
              }
            : null,
        // Custom node modal (n8n style)
        nodeModalBuilder: (context, node, onUpdate, onClose) {
          return _buildCustomNodeModal(context, node, onUpdate, onClose);
        },
      ),
    );
  }

  Widget _buildCustomNodeModal(
    BuildContext context,
    FlowNode node,
    ValueChanged<FlowNode> onUpdate,
    VoidCallback onClose,
  ) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            // n8n-style header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: node.color.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: node.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconForTitle(node.title),
                      color: node.color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          node.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
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
                    icon: const Icon(Icons.close, size: 24),
                    onPressed: onClose,
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            // Content area with tabs (n8n style)
            Expanded(
              child: Row(
                children: [
                  // Left sidebar with tabs
                  Container(
                    width: 200,
                    decoration: BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                    ),
                    child: ListView(
                      children: [
                        _buildTabItem(Icons.settings, 'Parameters', true),
                        _buildTabItem(Icons.code, 'JSON', false),
                        _buildTabItem(Icons.history, 'Executions', false),
                        _buildTabItem(Icons.info_outline, 'Info', false),
                      ],
                    ),
                  ),
                  // Main content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Node Parameters',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Example parameters
                          _buildParameterField('Name', node.title),
                          const SizedBox(height: 16),
                          _buildParameterField('Description', node.description),
                          const SizedBox(height: 16),
                          _buildParameterDropdown('Status', 'Active'),
                          const SizedBox(height: 24),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.blue.withOpacity(0.2),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.lightbulb_outline,
                                        size: 20,
                                        color: Colors.blue.shade700,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Tip',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Configure your node parameters here. You can use expressions, add credentials, and customize behavior.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.blue.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // Delete node
                      ref.read(flowProvider.notifier).deleteNode(node.id);
                      onClose();
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: onClose,
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          // Save and execute
                          onClose();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: node.color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: const Text('Save & Execute'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(IconData icon, String label, bool isActive) {
    return Container(
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : null,
        border: Border(
          left: BorderSide(
            color: isActive
                ? Theme.of(context).primaryColor
                : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(
          icon,
          size: 20,
          color: isActive ? Theme.of(context).primaryColor : null,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? Theme.of(context).primaryColor : null,
          ),
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildParameterField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: value),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildParameterDropdown(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          items: [
            'Active',
            'Inactive',
            'Pending',
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (_) {},
        ),
      ],
    );
  }

  IconData _getIconForTitle(String title) {
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
        return Icons.widgets;
    }
  }

  Widget _buildNodePalette(VoidCallback onClose) {
    return Container(
      width: 300,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey)),
            ),
            child: Row(
              children: [
                const Text(
                  'Nodes',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close), onPressed: onClose),
              ],
            ),
          ),
          // Node list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                _buildDraggableNode(
                  'Start',
                  'Begin the flow',
                  Icons.play_arrow,
                  Colors.green,
                ),
                _buildDraggableNode(
                  'Process',
                  'Process data',
                  Icons.transform,
                  Colors.blue,
                ),
                _buildDraggableNode(
                  'Decision',
                  'Make a decision',
                  Icons.call_split,
                  Colors.orange,
                ),
                _buildDraggableNode(
                  'End',
                  'End the flow',
                  Icons.stop,
                  Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableNode(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Draggable<Map<String, dynamic>>(
      data: {
        'title': title,
        'description': description,
        'icon': icon,
        'color': color,
      },
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 200,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
