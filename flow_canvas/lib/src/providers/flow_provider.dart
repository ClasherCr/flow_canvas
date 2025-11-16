import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/node.dart';
import '../models/connection.dart';

class FlowState {
  final List<FlowNode> nodes;
  final List<FlowConnection> connections;
  final String? selectedNodeId;
  final String? selectedConnectionId;

  const FlowState({
    this.nodes = const [],
    this.connections = const [],
    this.selectedNodeId,
    this.selectedConnectionId,
  });

  FlowState copyWith({
    List<FlowNode>? nodes,
    List<FlowConnection>? connections,
    String? selectedNodeId,
    String? selectedConnectionId,
  }) {
    return FlowState(
      nodes: nodes ?? this.nodes,
      connections: connections ?? this.connections,
      selectedNodeId: selectedNodeId,
      selectedConnectionId: selectedConnectionId,
    );
  }
}

class FlowNotifier extends StateNotifier<FlowState> {
  FlowNotifier() : super(const FlowState());

  final _uuid = const Uuid();

  void addNode(FlowNode node) {
    state = state.copyWith(nodes: [...state.nodes, node]);
  }

  void updateNode(String nodeId, FlowNode updatedNode) {
    state = state.copyWith(
      nodes: state.nodes
          .map((node) => node.id == nodeId ? updatedNode : node)
          .toList(),
    );
  }

  void deleteNode(String nodeId) {
    state = state.copyWith(
      nodes: state.nodes.where((node) => node.id != nodeId).toList(),
      connections: state.connections
          .where((conn) => conn.fromNodeId != nodeId && conn.toNodeId != nodeId)
          .toList(),
      selectedNodeId: state.selectedNodeId == nodeId
          ? null
          : state.selectedNodeId,
    );
  }

  void moveNode(String nodeId, Offset delta) {
    final node = state.nodes.firstWhere((n) => n.id == nodeId);
    final updatedNode = node.copyWith(
      x: node.x + delta.dx,
      y: node.y + delta.dy,
    );
    updateNode(nodeId, updatedNode);
  }

  void selectNode(String? nodeId) {
    state = state.copyWith(selectedNodeId: nodeId);
  }

  void addConnection(FlowConnection connection) {
    state = state.copyWith(connections: [...state.connections, connection]);
  }

  void deleteConnection(String connectionId) {
    state = state.copyWith(
      connections: state.connections
          .where((conn) => conn.id != connectionId)
          .toList(),
      selectedConnectionId: state.selectedConnectionId == connectionId
          ? null
          : state.selectedConnectionId,
    );
  }

  void selectConnection(String? connectionId) {
    state = state.copyWith(selectedConnectionId: connectionId);
  }

  void duplicateNode(String nodeId) {
    final node = state.nodes.firstWhere((n) => n.id == nodeId);
    final duplicatedNode = node.copyWith(
      id: _uuid.v4(),
      x: node.x + 20,
      y: node.y + 20,
    );
    addNode(duplicatedNode);
  }
}

final flowProvider = StateNotifierProvider<FlowNotifier, FlowState>((ref) {
  return FlowNotifier();
});
