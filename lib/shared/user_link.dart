import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../models/user_profile.dart';
import '../services/data_service.dart';
import 'avatar.dart';

class UserLink extends StatefulWidget {
  final String userId;
  final double? size;
  final bool showName;
  final bool showUsername;
  final TextStyle? nameStyle;
  final TextStyle? usernameStyle;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;
  final bool useListTile;

  const UserLink({
    super.key,
    required this.userId,
    this.size,
    this.showName = true,
    this.showUsername = true,
    this.nameStyle,
    this.usernameStyle,
    this.trailing,
    this.padding,
    this.useListTile = false,
  });

  @override
  State<UserLink> createState() => _UserLinkState();
}

class _UserLinkState extends State<UserLink> {
  late Future<UserProfile?> _userFuture;

  @override
  void initState() {
    super.initState();
    final dataService = Provider.of<DataService>(context, listen: false);
    _userFuture = dataService.getUserProfile(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
              height: 40, width: 40, child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }
        final user = snapshot.data!;

        final avatar = Avatar(
          imageUrl: user.avatarUrl,
          size: 40,
          username: user.username,
          userId: user.id,
        );

        if (!widget.useListTile) {
          return GestureDetector(
            onTap: () => context.push('/user/${user.id}'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                avatar,
                if (widget.showName || widget.showUsername) ...[
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.showName)
                        GestureDetector(
                          onTap: () => context.push('/user/${user.id}'),
                          child: Text(
                            user.realname,
                            style: widget.nameStyle ??
                                Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                          ),
                        ),
                      if (widget.showUsername)
                        GestureDetector(
                          onTap: () => context.push('/user/${user.id}'),
                          child: Text(
                            '@${user.username}',
                            style: widget.usernameStyle ??
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                          ),
                        ),
                    ],
                  ),
                ],
                if (widget.trailing != null) ...[
                  const SizedBox(width: 8),
                  widget.trailing!,
                ],
              ],
            ),
          );
        }

        return ListTile(
          contentPadding: widget.padding,
          leading: avatar,
          title: widget.showName
              ? GestureDetector(
                  onTap: () => context.push('/user/${user.id}'),
                  child: Text(
                    user.realname,
                    style: widget.nameStyle?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
              : null,
          subtitle: widget.showUsername
              ? GestureDetector(
                  onTap: () => context.push('/user/${user.id}'),
                  child: Text(
                    '@${user.username}',
                    style: widget.usernameStyle?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
              : null,
          trailing: widget.trailing,
          onTap: () => context.push('/user/${user.id}'),
        );
      },
    );
  }
}
