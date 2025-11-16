import 'package:flutter/material.dart';

/// Represents a port position on a node
enum PortPosition { top, bottom, left, right }

/// Generic node model for the flow canvas
class FlowNode {
  final String id;
  final String title;
  final String description;
  final double x;
  final double y;
  final double width;
  final double height;
  final Color color;
  final Map<String, dynamic> data;
  final bool isCompleted;

  const FlowNode({
    required this.id,
    required this.title,
    required this.description,
    required this.x,
    required this.y,
    this.width = 200,
    this.height = 120,
    this.color = Colors.blue,
    this.data = const {},
    this.isCompleted = false,
  });

  FlowNode copyWith({
    String? id,
    String? title,
    String? description,
    double? x,
    double? y,
    double? width,
    double? height,
    Color? color,
    Map<String, dynamic>? data,
    bool? isCompleted,
  }) {
    return FlowNode(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      color: color ?? this.color,
      data: data ?? this.data,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'x': x,
    'y': y,
    'width': width,
    'height': height,
    'color': color.value,
    'data': data,
    'isCompleted': isCompleted,
  };

  factory FlowNode.fromJson(Map<String, dynamic> json) => FlowNode(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    x: json['x'],
    y: json['y'],
    width: json['width'] ?? 200,
    height: json['height'] ?? 120,
    color: Color(json['color']),
    data: json['data'] ?? {},
    isCompleted: json['isCompleted'] ?? false,
  );
}
