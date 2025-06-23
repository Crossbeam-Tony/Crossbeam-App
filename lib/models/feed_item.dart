import 'project.dart';
import 'event.dart';
import 'marketplace_listing.dart';

// Abstract base class for all feed types
abstract class FeedItem {
  final String type;
  FeedItem(this.type);
}

// Type-specific adapters for each content type
class ProjectFeedItem extends FeedItem {
  final Project project;
  ProjectFeedItem(this.project) : super('project');
}

class EventFeedItem extends FeedItem {
  final Event event;
  EventFeedItem(this.event) : super('event');
}

class ListingFeedItem extends FeedItem {
  final MarketplaceListing listing;
  ListingFeedItem(this.listing) : super('listing');
}
