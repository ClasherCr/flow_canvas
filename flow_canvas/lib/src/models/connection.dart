import 'node.dart';

/// Represents a connection between two nodes
class FlowConnection {
  final String id;
  final String fromNodeId;
  final String toNodeId;
  final PortPosition fromPort;
  final PortPosition toPort;

  const FlowConnection({
    required this.id,
    required this.fromNodeId,
    required this.toNodeId,
    required this.fromPort,
    required this.toPort,
  });

  factory FlowConnection.create(
    String fromNodeId,
    String toNodeId,
    PortPosition fromPort,
    PortPosition toPort,
  ) {
    return FlowConnection(
      id: '$fromNodeId-$toNodeId-${fromPort.name}-${toPort.name}',
      fromNodeId: fromNodeId,
      toNodeId: toNodeId,
      fromPort: fromPort,
      toPort: toPort,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fromNodeId': fromNodeId,
    'toNodeId': toNodeId,
    'fromPort': fromPort.name,
    'toPort': toPort.name,
  };

  factory FlowConnection.fromJson(Map<String, dynamic> json) => FlowConnection(
    id: json['id'],
    fromNodeId: json['fromNodeId'],
    toNodeId: json['toNodeId'],
    fromPort: PortPosition.values.firstWhere((e) => e.name == json['fromPort']),
    toPort: PortPosition.values.firstWhere((e) => e.name == json['toPort']),
  );
}
