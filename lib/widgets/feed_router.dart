import 'package:flutter/material.dart';
import '../models/feed_item.dart';
import 'feed_card_builders.dart';

// Feed router that dynamically renders correct card type
Widget buildFeedItem(FeedItem item) {
  switch (item.type) {
    case 'project':
      return buildProjectCard((item as ProjectFeedItem).project);
    case 'event':
      return buildEventCard((item as EventFeedItem).event);
    case 'listing':
      return buildListingCard((item as ListingFeedItem).listing);
    default:
      return const SizedBox(); // fallback
  }
}
