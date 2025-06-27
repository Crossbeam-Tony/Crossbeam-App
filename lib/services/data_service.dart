import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile.dart';
import '../models/collaborate_request.dart';
import '../models/event.dart';
import '../models/project.dart';
import '../models/marketplace_listing.dart';
import '../models/post.dart';
import '../models/crew.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import '../models/marketplace_item.dart';
import 'dart:async';

class DataService extends ChangeNotifier {
  final _logger = Logger('DataService');
  final SupabaseClient _supabase = Supabase.instance.client;

  bool _isInitialized = false;
  bool _isNotifying = false; // Prevent recursive notifications
  Timer? _debounceTimer; // Debounce timer for notifications

  // Current user
  UserProfile? _currentUser;
  UserProfile? get currentUser => _currentUser;

  // collaboration requests keyed by project ID
  final Map<String, CollaborateRequest> _collabs = {};
  SharedPreferences? _prefs;

  // RSVP statuses keyed by event ID
  final Map<String, bool> _rsvps = {};
  SharedPreferences? _prefsRsvp;

  // Cached data from Supabase
  List<Post> _posts = [];
  List<Crew> _crews = [];
  List<Project> _projects = [];
  List<Event> _events = [];
  List<MarketplaceListing> _marketplaceListings = [];
  List<UserProfile> _users = [];
  List<MarketplaceItem> _marketplaceItems = [];

  List<Post> get posts => List.unmodifiable(_posts);
  List<Crew> get crews => List.unmodifiable(_crews);
  List<Project> get projects {
    _logger.info(
        'DataService - projects getter called, returning ${_projects.length} projects');
    return List.unmodifiable(_projects);
  }

  List<Event> get events => List.unmodifiable(_events);
  List<MarketplaceListing> get marketplaceListings =>
      List.unmodifiable(_marketplaceListings);
  List<UserProfile> get users => List.unmodifiable(_users);
  List<MarketplaceItem> get marketplaceItems =>
      List.unmodifiable(_marketplaceItems);

  final String _currentUserId = 'u1';

  List<Post> get crewsfeedPosts => List.unmodifiable(_posts);
  String get currentUserId => _currentUserId;

  final List<String> _friends = [];
  List<String> get friends => List.unmodifiable(_friends);

  DataService(UserProfile? user) {
    _currentUser = user;
    _initializeData();
  }

  @override
  void notifyListeners() {
    if (!_isNotifying) {
      _isNotifying = true;

      // Cancel any existing timer
      _debounceTimer?.cancel();

      // Debounce notifications to prevent excessive updates
      _debounceTimer = Timer(const Duration(milliseconds: 100), () {
        super.notifyListeners();
        _isNotifying = false;
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _initializeData() {
    try {
      _logger.info('DataService initialized successfully');
    } catch (e) {
      _logger.severe('Error initializing DataService: $e');
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize SharedPreferences
      _prefs = await SharedPreferences.getInstance();
      _prefsRsvp = await SharedPreferences.getInstance();

      // Load data in parallel from Supabase
      await Future.wait<void>([
        initCollabs(),
        initRsvps(),
        loadUsers(),
        loadProjects(),
        loadEvents(),
        loadPosts(),
        loadCrews(),
        loadMarketplaceListings(),
        loadMarketplaceItems(),
      ]);

      _isInitialized = true;
      notifyListeners();
      _logger.info('DataService async initialization completed');
    } catch (e) {
      _logger.severe('Error in async initialization: $e');
    }
  }

  // Load users from Supabase
  Future<void> loadUsers() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .order('created_at', ascending: false);

      _users = response.map((json) => UserProfile.fromJson(json)).toList();
      _logger.info('Loaded ${_users.length} users from Supabase');
    } catch (e) {
      _logger.warning('Error loading users: $e');
      _users = [];
    }
  }

  // Load projects from Supabase
  Future<void> loadProjects() async {
    try {
      final response = await _supabase
          .from('projects')
          .select()
          .order('created_at', ascending: false);

      _projects = response.map((json) => Project.fromJson(json)).toList();
      _logger.info('Loaded ${_projects.length} projects from Supabase');
    } catch (e) {
      _logger.warning('Error loading projects: $e');
      _projects = [];
    }
  }

  // Load events from Supabase
  Future<void> loadEvents() async {
    try {
      final response = await _supabase
          .from('events')
          .select()
          .order('date', ascending: false);

      _events = response.map((json) => Event.fromJson(json)).toList();
      _logger.info('Loaded ${_events.length} events from Supabase');
    } catch (e) {
      _logger.warning('Error loading events: $e');
      _events = [];
    }
  }

  // Load posts from Supabase
  Future<void> loadPosts() async {
    try {
      final response = await _supabase
          .from('posts')
          .select()
          .order('created_at', ascending: false);

      _posts = response.map((json) => Post.fromJson(json)).toList();
      _logger.info('Loaded ${_posts.length} posts from Supabase');
    } catch (e) {
      _logger.warning('Error loading posts: $e');
      _posts = [];
    }
  }

  // Load crews from Supabase
  Future<void> loadCrews() async {
    try {
      final response = await _supabase
          .from('crews')
          .select()
          .order('created_at', ascending: false);

      _crews = response.map((json) => Crew.fromJson(json)).toList();
      _logger.info('Loaded ${_crews.length} crews from Supabase');
    } catch (e) {
      _logger.warning('Error loading crews: $e');
      _crews = [];
    }
  }

  // Load marketplace listings from Supabase
  Future<void> loadMarketplaceListings() async {
    try {
      final response = await _supabase
          .from('marketplace_listings')
          .select()
          .order('created_at', ascending: false);

      _marketplaceListings =
          response.map((json) => MarketplaceListing.fromJson(json)).toList();
      _logger.info(
          'Loaded ${_marketplaceListings.length} marketplace listings from Supabase');
    } catch (e) {
      _logger.warning('Error loading marketplace listings: $e');
      _marketplaceListings = [];
    }
  }

  // Load marketplace items from Supabase
  Future<void> loadMarketplaceItems() async {
    try {
      final response = await _supabase
          .from('marketplace_items')
          .select()
          .order('created_at', ascending: false);

      _marketplaceItems =
          response.map((json) => MarketplaceItem.fromJson(json)).toList();
      _logger.info(
          'Loaded ${_marketplaceItems.length} marketplace items from Supabase');
    } catch (e) {
      _logger.warning('Error loading marketplace items: $e');
      _marketplaceItems = [];
    }
  }

  Future<void> initCollabs() async {
    for (var key in _prefs!.getKeys()) {
      if (!key.startsWith('collab_')) continue;
      final projectId = key.replaceFirst('collab_', '');
      final value = _prefs!.getString(key)!;
      final parts = value.split('|');
      _collabs[projectId] = CollaborateRequest(
        id: parts[0],
        projectId: projectId,
        senderId: parts[1],
        receiverId: parts[2],
        message: parts.length > 3 && parts[3].isNotEmpty ? parts[3] : null,
        sentAt: DateTime.parse(parts[4]),
        confirmedAt: parts.length > 5 && parts[5].isNotEmpty
            ? DateTime.parse(parts[5])
            : null,
        isConfirmed: parts.length > 6 && parts[6] == '1',
        isRejected: parts.length > 7 && parts[7] == '1',
      );
    }
  }

  CollaborateRequest getCollab(String projectId) {
    return _collabs[projectId] ??
        CollaborateRequest(
          id: UniqueKey().toString(),
          projectId: projectId,
          senderId: _currentUser?.id ?? '1',
          receiverId: '',
          sentAt: DateTime.now(),
        );
  }

  Future<void> initRsvps() async {
    for (final k in _prefsRsvp!.getKeys()) {
      if (k.startsWith('rsvp_')) {
        final eventId = k.substring(5);
        _rsvps[eventId] = _prefsRsvp!.getBool(k) ?? false;
      }
    }
  }

  bool isGoing(String eventId) => _rsvps[eventId] ?? false;

  Future<void> toggleCollab(String projectId, {String? message}) async {
    final curr = getCollab(projectId);
    final next = !curr.isConfirmed && !curr.isRejected;

    final request = CollaborateRequest(
      id: curr.id,
      projectId: projectId,
      senderId: _currentUser?.id ?? '1',
      receiverId: curr.receiverId,
      message: next ? message : null,
      sentAt: DateTime.now(),
      isConfirmed: false,
      isRejected: false,
    );

    _collabs[projectId] = request;

    await _prefs!.setString('collab_$projectId',
        '${request.id}|${request.senderId}|${request.receiverId}|${request.message ?? ''}|${request.sentAt.toIso8601String()}|${request.confirmedAt?.toIso8601String() ?? ''}|${request.isConfirmed ? '1' : '0'}|${request.isRejected ? '1' : '0'}');

    notifyListeners();
  }

  Future<void> toggleRsvp(String eventId) async {
    final current = isGoing(eventId);
    _rsvps[eventId] = !current;
    await _prefsRsvp!.setBool('rsvp_$eventId', !current);
    notifyListeners();
  }

  // Fixed crew categories
  final List<String> crewCategories = [
    'Cars',
    'Fishing',
    'Gaming',
    'Fitness',
    'DIY',
    'Pets',
    'Cooking',
    'Parenting',
    'Camping',
    'Hunting'
  ];

  // Valrico venues only
  final List<String> venues = [
    'Alafia River',
    'Valrico Town Center',
    'Valrico GameHub',
    'Valrico Community Park',
    'Lithia Springs Park'
  ];

  // User lookup methods - Updated to use Supabase
  Future<UserProfile?> getUserProfile(String id) async {
    try {
      final response =
          await _supabase.from('profiles').select().eq('id', id).single();
      return UserProfile.fromJson(response);
    } catch (e) {
      _logger.warning('User not found with id: $id');
      return null;
    }
  }

  Future<UserProfile?> findUserByUsername(String username) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('username', username)
          .single();
      return UserProfile.fromJson(response);
    } catch (e) {
      debugPrint('User not found by username: $username');
      return null;
    }
  }

  Future<UserProfile?> findUserByRealname(String realname) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('real_name', realname)
          .single();
      return UserProfile.fromJson(response);
    } catch (e) {
      debugPrint('User not found by realname: $realname');
      return null;
    }
  }

  // Updated to search in loaded users first, then query Supabase if not found
  UserProfile? getUserByIdentifier(String identifier) {
    try {
      // First try to find in loaded users
      final user = _users.firstWhere(
        (user) => user.id == identifier || user.fullName == identifier,
      );
      return user;
    } catch (e) {
      // If not found in loaded users, return null
      // The calling code should handle this by using the async methods
      debugPrint('User not found in loaded data: $identifier');
      return null;
    }
  }

  List<Project> getProjectsByUserId(String userId) {
    return _projects.where((project) => project.userId == userId).toList();
  }

  UserProfile? findUserByName(String name) {
    try {
      return _users.firstWhere(
        (user) => user.fullName == name,
        orElse: () => throw Exception('User not found'),
      );
    } catch (e) {
      return null;
    }
  }

  UserProfile? getUserById(String id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Event> getEventsByOrganizer(String organizerId) {
    return _events.where((event) => event.organizerId == organizerId).toList();
  }

  List<Project> getProjectsByCrew(String crew) {
    return _projects
        .where((project) => project.tags?.contains(crew) ?? false)
        .toList();
  }

  List<MarketplaceListing> getListingsByCrew(String crew) {
    return _marketplaceListings
        .where((listing) => listing.crew == crew)
        .toList();
  }

  List<MarketplaceListing> getListingsBySeller(String sellerId) {
    return _marketplaceListings
        .where((listing) => listing.sellerId == sellerId)
        .toList();
  }

  void setCurrentUser(UserProfile? user) {
    _currentUser = user;
    notifyListeners();
  }

  // Updated methods to work with Supabase
  void setPosts(List<Post> posts) {
    _posts.clear();
    _posts.addAll(posts);
    notifyListeners();
  }

  void setCrews(List<Crew> crews) {
    _crews = crews;
    notifyListeners();
  }

  void setProjects(List<Project> projects) {
    _projects = projects;
    notifyListeners();
  }

  void setEvents(List<Event> events) {
    _events.clear();
    _events.addAll(events);
    notifyListeners();
  }

  // Add methods with Supabase integration
  Future<void> addPost(Post post) async {
    try {
      final response =
          await _supabase.from('posts').insert(post.toJson()).select().single();

      final newPost = Post.fromJson(response);
      _posts.insert(0, newPost);
      notifyListeners();
      _logger.info('Post added successfully: ${newPost.id}');
    } catch (e) {
      _logger.severe('Error adding post: $e');
      rethrow;
    }
  }

  Future<void> addCrew(Crew crew) async {
    try {
      final response =
          await _supabase.from('crews').insert(crew.toJson()).select().single();

      final newCrew = Crew.fromJson(response);
      _crews.add(newCrew);
      notifyListeners();
      _logger.info('Crew added successfully: ${newCrew.id}');
    } catch (e) {
      _logger.severe('Error adding crew: $e');
      rethrow;
    }
  }

  Future<void> addProject(Project project) async {
    try {
      final response = await _supabase
          .from('projects')
          .insert(project.toJson())
          .select()
          .single();

      final newProject = Project.fromJson(response);
      _projects.add(newProject);
      notifyListeners();
      _logger.info('Project added successfully: ${newProject.id}');
    } catch (e) {
      _logger.severe('Error adding project: $e');
      rethrow;
    }
  }

  Future<void> addEvent(Event event) async {
    try {
      final response = await _supabase
          .from('events')
          .insert(event.toJson())
          .select()
          .single();

      final newEvent = Event.fromJson(response);
      _events.add(newEvent);
      notifyListeners();
      _logger.info('Event added successfully: ${newEvent.id}');
    } catch (e) {
      _logger.severe('Error adding event: $e');
      rethrow;
    }
  }

  Future<void> updatePost(Post post) async {
    try {
      final response = await _supabase
          .from('posts')
          .update(post.toJson())
          .eq('id', post.id)
          .select()
          .single();

      final updatedPost = Post.fromJson(response);
      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        _posts[index] = updatedPost;
        notifyListeners();
        _logger.info('Post updated successfully: ${post.id}');
      }
    } catch (e) {
      _logger.severe('Error updating post: $e');
      rethrow;
    }
  }

  Future<void> updateCrew(Crew crew) async {
    try {
      final response = await _supabase
          .from('crews')
          .update(crew.toJson())
          .eq('id', crew.id)
          .select()
          .single();

      final updatedCrew = Crew.fromJson(response);
      final index = _crews.indexWhere((c) => c.id == crew.id);
      if (index != -1) {
        _crews[index] = updatedCrew;
        notifyListeners();
        _logger.info('Crew updated successfully: ${crew.id}');
      }
    } catch (e) {
      _logger.severe('Error updating crew: $e');
      rethrow;
    }
  }

  Future<void> updateProject(Project project) async {
    try {
      final response = await _supabase
          .from('projects')
          .update(project.toJson())
          .eq('id', project.id)
          .select()
          .single();

      final updatedProject = Project.fromJson(response);
      final index = _projects.indexWhere((p) => p.id == project.id);
      if (index != -1) {
        _projects[index] = updatedProject;
        notifyListeners();
        _logger.info('Project updated successfully: ${project.id}');
      }
    } catch (e) {
      _logger.severe('Error updating project: $e');
      rethrow;
    }
  }

  Future<void> updateEvent(Event event) async {
    try {
      final response = await _supabase
          .from('events')
          .update(event.toJson())
          .eq('id', event.id)
          .select()
          .single();

      final updatedEvent = Event.fromJson(response);
      final index = _events.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        _events[index] = updatedEvent;
        notifyListeners();
        _logger.info('Event updated successfully: ${event.id}');
      }
    } catch (e) {
      _logger.severe('Error updating event: $e');
      rethrow;
    }
  }

  Future<void> deletePost(String id) async {
    try {
      await _supabase.from('posts').delete().eq('id', id);

      _posts.removeWhere((p) => p.id == id);
      notifyListeners();
      _logger.info('Post deleted successfully: $id');
    } catch (e) {
      _logger.severe('Error deleting post: $e');
      rethrow;
    }
  }

  Future<void> deleteCrew(String id) async {
    try {
      await _supabase.from('crews').delete().eq('id', id);

      _crews.removeWhere((c) => c.id == id);
      notifyListeners();
      _logger.info('Crew deleted successfully: $id');
    } catch (e) {
      _logger.severe('Error deleting crew: $e');
      rethrow;
    }
  }

  Future<void> deleteProject(String id) async {
    try {
      await _supabase.from('projects').delete().eq('id', id);

      _projects.removeWhere((p) => p.id == id);
      notifyListeners();
      _logger.info('Project deleted successfully: $id');
    } catch (e) {
      _logger.severe('Error deleting project: $e');
      rethrow;
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _supabase.from('events').delete().eq('id', id);

      _events.removeWhere((e) => e.id == id);
      notifyListeners();
      _logger.info('Event deleted successfully: $id');
    } catch (e) {
      _logger.severe('Error deleting event: $e');
      rethrow;
    }
  }

  Future<void> toggleLike(String postId) async {
    try {
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        final newLikes = post.likes + 1;

        // Update in Supabase
        await _supabase
            .from('posts')
            .update({'likes': newLikes}).eq('id', postId);

        // Update local state
        final now = DateTime.now();
        _posts[postIndex] = Post(
          id: post.id,
          authorId: post.authorId,
          author: post.author,
          authorAvatar: post.authorAvatar,
          crew: post.crew,
          title: post.title,
          description: post.description,
          imageUrl: post.imageUrl,
          type: post.type,
          date: post.date,
          likes: newLikes,
          comments: post.comments,
          createdAt: post.createdAt,
          updatedAt: now,
        );
        notifyListeners();
        _logger.info('Post like toggled successfully: $postId');
      }
    } catch (e) {
      _logger.severe('Error toggling post like: $e');
      rethrow;
    }
  }

  Future<void> addComment(String postId, Comment comment) async {
    try {
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        final updatedComments = List<Comment>.from(post.comments)..add(comment);

        // Update in Supabase
        await _supabase.from('posts').update({
          'comments': updatedComments.map((c) => c.toJson()).toList()
        }).eq('id', postId);

        // Update local state
        final now = DateTime.now();
        _posts[postIndex] = Post(
          id: post.id,
          authorId: post.authorId,
          author: post.author,
          authorAvatar: post.authorAvatar,
          crew: post.crew,
          title: post.title,
          description: post.description,
          imageUrl: post.imageUrl,
          type: post.type,
          date: post.date,
          likes: post.likes,
          comments: updatedComments,
          createdAt: post.createdAt,
          updatedAt: now,
        );
        notifyListeners();
        _logger.info('Comment added successfully to post: $postId');
      }
    } catch (e) {
      _logger.severe('Error adding comment: $e');
      rethrow;
    }
  }

  Future<void> refreshCrewsfeed() async {
    try {
      await loadPosts();
      _logger.info('Crewsfeed refreshed successfully');
    } catch (e) {
      _logger.severe('Error refreshing crewsfeed: $e');
      rethrow;
    }
  }

  Future<Project?> getProjectById(String id) async {
    try {
      final response =
          await _supabase.from('projects').select().eq('id', id).single();
      return Project.fromJson(response);
    } catch (e) {
      _logger.warning('Project not found with id: $id');
      return null;
    }
  }

  MarketplaceListing? getMarketplaceListingById(String id) {
    try {
      return _marketplaceListings.firstWhere((listing) => listing.id == id);
    } catch (e) {
      _logger.warning('Marketplace listing not found with id: $id');
      return null;
    }
  }

  // Refresh all data from Supabase
  Future<void> refreshAllData() async {
    try {
      await Future.wait<void>([
        loadUsers(),
        loadProjects(),
        loadEvents(),
        loadPosts(),
        loadCrews(),
        loadMarketplaceListings(),
        loadMarketplaceItems(),
      ]);
      notifyListeners();
      _logger.info('All data refreshed successfully');
    } catch (e) {
      _logger.severe('Error refreshing all data: $e');
      rethrow;
    }
  }
}
