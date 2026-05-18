import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StartupSocietyMember {
  final String name;
  final String role;
  final String? percentage;

  const StartupSocietyMember({
    required this.name,
    required this.role,
    this.percentage,
  });

  factory StartupSocietyMember.fromMap(Map<String, dynamic> map) {
    return StartupSocietyMember(
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      percentage: map['percentage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role,
      'percentage': percentage,
    };
  }
}

class StartupQuestion {
  final String question;
  final String? answer;
  final DateTime? createdAt;

  const StartupQuestion({
    required this.question,
    this.answer,
    this.createdAt,
  });

  factory StartupQuestion.fromMap(Map<String, dynamic> map) {
    DateTime? parsedDate;

    final createdAt = map['createdAt'];

    if (createdAt is Timestamp) {
      parsedDate = createdAt.toDate();
    } else if (createdAt is DateTime) {
      parsedDate = createdAt;
    }

    return StartupQuestion(
      question: map['question']?.toString() ?? '',
      answer: map['answer']?.toString(),
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'answer': answer,
      'createdAt': createdAt,
    };
  }
}

class StartupDocumentItem {
  final String title;
  final String description;
  final IconData icon;
  final String? url;

  const StartupDocumentItem({
    required this.title,
    required this.description,
    required this.icon,
    this.url,
  });

  factory StartupDocumentItem.fromMap(Map<String, dynamic> map) {
    return StartupDocumentItem(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      icon: Icons.description_rounded,
      url: map['url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'url': url,
    };
  }
}
