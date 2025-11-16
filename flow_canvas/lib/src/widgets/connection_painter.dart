import 'package:flutter/material.dart';
import '../models/node.dart';
import '../models/connection.dart';

class FlowConnectionPainter extends CustomPainter {
  final List<FlowConnection> connections;
  final List<FlowNode> nodes;
  final String? selectedConnectionId;
  final Color connectionColor;
  final Color selectedConnectionColor;
  final double connectionWidth;

  FlowConnectionPainter({
    required this.connections,
    required this.nodes,
    this.selectedConnectionId,
    this.connectionColor = Colors.blue,
    this.selectedConnectionColor = Colors.orange,
    this.connectionWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final connection in connections) {
      _drawConnection(canvas, connection);
    }
  }

  void _drawConnection(Canvas canvas, FlowConnection connection) {
    final fromNode = nodes.firstWhere(
      (node) => node.id == connection.fromNodeId,
    );
    final toNode = nodes.firstWhere((node) => node.id == connection.toNodeId);

    final fromPoint = _getPortPosition(fromNode, connection.fromPort);
    final toPoint = _getPortPosition(toNode, connection.toPort);

    final isSelected = connection.id == selectedConnectionId;
    final color = isSelected ? selectedConnectionColor : connectionColor;

    final paint = Paint()
      ..color = color
      ..strokeWidth = connectionWidth
      ..style = PaintingStyle.stroke;

    // Draw Bézier curve
    final path = Path();
    path.moveTo(fromPoint.dx, fromPoint.dy);

    // Control points for smooth curve
    final dx = (toPoint.dx - fromPoint.dx).abs();
    final cp1 = Offset(fromPoint.dx + dx * 0.5, fromPoint.dy);
    final cp2 = Offset(toPoint.dx - dx * 0.5, toPoint.dy);

    path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, toPoint.dx, toPoint.dy);

    canvas.drawPath(path, paint);

    // Draw arrow at the end
    _drawArrow(canvas, toPoint, _getDirection(fromPoint, toPoint), color);
  }

  void _drawArrow(Canvas canvas, Offset tip, Offset direction, Color color) {
    const arrowSize = 8.0;
    final normalized = direction / direction.distance;
    final perpendicular =
        Offset(-normalized.dy, normalized.dx) * arrowSize * 0.5;

    final arrowPath = Path()
      ..moveTo(tip.dx, tip.dy)
      ..lineTo(
        tip.dx - normalized.dx * arrowSize - perpendicular.dx,
        tip.dy - normalized.dy * arrowSize - perpendicular.dy,
      )
      ..lineTo(
        tip.dx - normalized.dx * arrowSize + perpendicular.dx,
        tip.dy - normalized.dy * arrowSize + perpendicular.dy,
      )
      ..close();

    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(arrowPath, arrowPaint);
  }

  Offset _getPortPosition(FlowNode node, PortPosition port) {
    switch (port) {
      case PortPosition.top:
        return Offset(node.x + node.width / 2, node.y);
      case PortPosition.bottom:
        return Offset(node.x + node.width / 2, node.y + node.height);
      case PortPosition.left:
        return Offset(node.x, node.y + node.height / 2);
      case PortPosition.right:
        return Offset(node.x + node.width, node.y + node.height / 2);
    }
  }

  Offset _getDirection(Offset from, Offset to) {
    return to - from;
  }

  @override
  bool shouldRepaint(FlowConnectionPainter oldDelegate) {
    return oldDelegate.connections != connections ||
        oldDelegate.nodes != nodes ||
        oldDelegate.selectedConnectionId != selectedConnectionId;
  }
}
