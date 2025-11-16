# Flow Canvas Examples

This document showcases what you can do with the `flow_canvas` package. Run the example app to see these in action!

## 🎯 Example 1: Basic Workflow Builder

**What it demonstrates:**

- Drag & drop node palette
- Custom node types (Trigger, Action, Condition)
- Node connections with arrows
- Double-click to configure nodes
- Real-time zoom control

**Use cases:**

- Automation workflow builders (like n8n, Zapier)
- Business process modeling (BPMN)
- CI/CD pipeline designers
- Task orchestration tools

**Key features shown:**

```dart
FlowCanvas(
  nodePaletteBuilder: (context) => NodePalette(...),
  nodeModalBuilder: (context, node) => ConfigDialog(...),
  showZoomControl: true,
)
```

---

## 🎨 Example 2: Custom Node Styles

**What it demonstrates:**

- Customizable node appearance
- Different color schemes
- Custom zoom control positioning (right side)
- Infinite canvas with custom grid colors

**Use cases:**

- Branded workflow builders
- Themed diagram editors
- Custom visualization tools
- Corporate design systems

**Key features shown:**

```dart
FlowCanvas(
  gridColor: Colors.grey.shade300,
  backgroundColor: Colors.grey.shade50,
  zoomControlAlignment: Alignment.centerRight,
)
```

---

## 📊 Example 3: Data Flow Visualization

**What it demonstrates:**

- Data pipeline representation
- Process flow diagrams
- Green-themed design for data processing
- Visual connection flows

**Use cases:**

- ETL pipeline builders
- Data transformation workflows
- Machine learning pipelines
- Analytics flow designers

**Key features shown:**

```dart
FlowCanvas(
  gridColor: Colors.green.shade200,
  backgroundColor: Colors.green.shade50,
)
```

---

## 🧠 Example 4: Mind Map

**What it demonstrates:**

- Hierarchical node structures
- Orange-themed design for brainstorming
- Zoom control on bottom-left
- Free-form organization

**Use cases:**

- Mind mapping applications
- Concept mapping tools
- Brainstorming software
- Knowledge organization systems

**Key features shown:**

```dart
FlowCanvas(
  gridColor: Colors.orange.shade200,
  backgroundColor: Colors.orange.shade50,
  zoomControlAlignment: Alignment.bottomLeft,
)
```

---

## ⚙️ Example 5: Node Configuration

**What it demonstrates:**

- Advanced node configuration
- Modal dialogs on double-click
- Red-themed design for configuration
- Full customization capabilities

**Use cases:**

- Complex workflow builders
- Configurable automation tools
- Advanced diagram editors
- Parameter-heavy applications

**Key features shown:**

```dart
FlowCanvas(
  gridColor: Colors.red.shade200,
  backgroundColor: Colors.red.shade50,
  nodeModalBuilder: (context, node) => AdvancedConfig(...),
)
```

---

## 🚀 Quick Start

1. Add dependency:

```yaml
dependencies:
  flow_canvas: ^1.0.0
```

2. Wrap your app with `ProviderScope`:

```dart
void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

3. Use `FlowCanvas`:

```dart
FlowCanvas(
  showZoomControl: true,
  gridColor: Colors.blue.shade200,
  backgroundColor: Colors.blue.shade50,
)
```

---

## 🎨 Customization Options

| Feature           | Description                     | Example                                       |
| ----------------- | ------------------------------- | --------------------------------------------- |
| **Grid Color**    | Customize grid appearance       | `gridColor: Colors.grey.shade300`             |
| **Background**    | Set canvas background           | `backgroundColor: Colors.grey.shade50`        |
| **Zoom Control**  | Show/hide zoom UI               | `showZoomControl: true`                       |
| **Zoom Position** | Place zoom control anywhere     | `zoomControlAlignment: Alignment.centerRight` |
| **Zoom Offset**   | Fine-tune positioning           | `zoomControlOffset: const Offset(-16, 80)`    |
| **Node Palette**  | Custom drag-drop palette        | `nodePaletteBuilder: (context) => ...`        |
| **Node Modal**    | Configure nodes on double-click | `nodeModalBuilder: (context, node) => ...`    |
| **Min/Max Zoom**  | Control zoom limits             | `minZoom: 0.5, maxZoom: 3.0`                  |

---

## 💡 Common Use Cases

### 1. **Workflow Automation**

Build visual automation tools like n8n, Zapier, or Integromat.

### 2. **Diagram Editors**

Create flowchart, UML, or BPMN diagram editors.

### 3. **Mind Mapping**

Build brainstorming and knowledge organization tools.

### 4. **Data Pipelines**

Visualize ETL processes, data transformations, or analytics flows.

### 5. **Game Editors**

Create node-based game logic editors or behavior trees.

### 6. **Visual Programming**

Build visual programming environments or node-based coding tools.

---

## 📦 Features Included

✅ **Infinite Canvas** - Pan and zoom without boundaries  
✅ **Grid Background** - Customizable grid for alignment  
✅ **Zoom Control** - Built-in UI with customizable positioning  
✅ **Node System** - Drag, drop, connect, and configure nodes  
✅ **Modals** - Double-click nodes to open configuration dialogs  
✅ **State Management** - Built-in Riverpod integration  
✅ **Responsive** - Works on all platforms (Web, Mobile, Desktop)  
✅ **Customizable** - Every aspect can be themed and styled

---

## 🎯 Next Steps

1. **Run the examples** - See all features in action
2. **Read the README** - Detailed API documentation
3. **Customize** - Adapt examples to your needs
4. **Build** - Create your own workflow/diagram tool!

---

## 📝 License

MIT License - See LICENSE file for details
