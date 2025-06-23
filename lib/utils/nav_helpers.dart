import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void goToComments(BuildContext context, String postId) {
  context.push('/comments/$postId');
}
