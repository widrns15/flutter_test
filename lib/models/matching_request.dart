import 'package:pet_sitter_app/models/post.dart' as user_model;
import 'post.dart';

class MatchingRequest {
  final int id;
  final Post? post;
  final user_model.User requester;
  final String message;
  final String status;
  final DateTime? respondedAt;

  MatchingRequest({
    required this.id,
    required this.post,
    required this.requester,
    required this.message,
    required this.status,
    this.respondedAt,
  });

  factory MatchingRequest.fromJson(Map<String, dynamic> json) {
    return MatchingRequest(
      id: json['id'],
      post: json['post'] != null ? Post.fromJson(json['post']) : null,
      requester: user_model.User.fromJson(json['requester']),
      message: json['message'] ?? '',
      status: json['status'],
      respondedAt:
          json['respondedAt'] != null
              ? DateTime.tryParse(json['respondedAt'])
              : null,
    );
  }
}
