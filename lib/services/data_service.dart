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
import '../data/dummy_crews.dart';
// import '../data/local_users.dart';
import '../models/marketplace_item.dart';
import '../data/dummy_marketplace.dart';
import '../data/dummy_posts.dart';
import '../data/seed_data.dart';
import '../data/seed_projects.dart';
import '../utils/placeholder_image.dart';

class DataService extends ChangeNotifier {
  final _logger = Logger('DataService');

  bool _isInitialized = false;

  // Current user
  UserProfile? _currentUser;
  UserProfile? get currentUser => _currentUser;

  // collaboration requests keyed by project ID
  final Map<String, CollaborateRequest> _collabs = {};
  SharedPreferences? _prefs;

  // RSVP statuses keyed by event ID
  final Map<String, bool> _rsvps = {};
  SharedPreferences? _prefsRsvp;

  final List<Post> _posts = [];
  List<Crew> _crews = [];
  List<Project> _projects = [];
  final List<Event> _events = [];
  final List<MarketplaceListing> _marketplaceListings = [];
  final List<UserProfile> _users = [];

  List<Post> get posts => List.unmodifiable(_posts);
  List<Crew> get crews => _crews;
  List<Project> get projects {
    print(
        'DEBUG: DataService - projects getter called, returning ${_projects.length} projects');
    return _projects;
  }

  List<Event> get events => List.unmodifiable(_events);
  List<MarketplaceListing> get marketplaceListings =>
      List.unmodifiable(_marketplaceListings);
  List<UserProfile> get users => _users;

  final String _currentUserId = 'u1';

  List<Post> get crewsfeedPosts => _posts;
  String get currentUserId => _currentUserId;

  final List<String> _friends = [];
  List<String> get friends => List.unmodifiable(_friends);

  final List<MarketplaceItem> _marketplaceItems = [];
  List<MarketplaceItem> get marketplaceItems =>
      List.unmodifiable(_marketplaceItems);

  DataService(UserProfile? user) {
    _currentUser = user;
    _initializeData();
  }

  void _initializeData() {
    try {
      // Populate users from localUsers
      // _users.addAll(localUsers);

      // Set current user
      // if (_currentUser == null) {
      //   _currentUser = _users.firstWhere(
      //     (user) => user.id == _currentUserId,
      //     orElse: () => _users.first,
      //   );
      // }

      // Load other data
      _loadMockData();

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

      // Load data in parallel
      await Future.wait<void>([
        initCollabs(),
        initRsvps(),
      ]);

      _isInitialized = true;
      notifyListeners();
      _logger.info('DataService async initialization completed');
    } catch (e) {
      _logger.severe('Error in async initialization: $e');
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

  // User lookup methods
  Future<UserProfile?> getUserProfile(String id) async {
    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', id)
          .single();
      return UserProfile.fromJson(response);
    } catch (e) {
      _logger.warning('User not found with id: $id');
      return null;
    }
  }

  Future<UserProfile?> findUserByUsername(String username) async {
    try {
      final response = await Supabase.instance.client
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
      final response = await Supabase.instance.client
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

  UserProfile? getUserByIdentifier(String identifier) {
    try {
      return _users.firstWhere(
        (user) => user.id == identifier || user.name == identifier,
      );
    } catch (e) {
      debugPrint('User not found: $identifier');
      return null;
    }
  }

  List<Project> getProjectsByUser(String userId) {
    return _projects.where((project) => project.ownerId == userId).toList();
  }

  UserProfile? findUserByName(String name) {
    try {
      return _users.firstWhere(
        (user) => user.name == name,
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
    return _projects.where((project) => project.owner == crew).toList();
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

  void addPost(Post post) {
    _posts.insert(0, post);
    notifyListeners();
  }

  void addCrew(Crew crew) {
    _crews.add(crew);
    notifyListeners();
  }

  void addProject(Project project) {
    _projects.add(project);
    notifyListeners();
  }

  void addEvent(Event event) {
    _events.add(event);
    notifyListeners();
  }

  void updatePost(Post post) {
    final index = _posts.indexWhere((p) => p.id == post.id);
    if (index != -1) {
      _posts[index] = post;
      notifyListeners();
    }
  }

  void updateCrew(Crew crew) {
    final index = _crews.indexWhere((c) => c.id == crew.id);
    if (index != -1) {
      _crews[index] = crew;
      notifyListeners();
    }
  }

  void updateProject(Project project) {
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      _projects[index] = project;
      notifyListeners();
    }
  }

  void updateEvent(Event event) {
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _events[index] = event;
      notifyListeners();
    }
  }

  void deletePost(String id) {
    _posts.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void deleteCrew(String id) {
    _crews.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  void deleteProject(String id) {
    _projects.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void deleteEvent(String id) {
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void _loadMockData() {
    try {
      // Load mock events
      // _events.addAll(seededEvents);

      // Load mock projects
      _projects.addAll(seedProjects);
      print('DEBUG: DataService - Loaded ${_projects.length} projects');

      // Load mock marketplace items
      _marketplaceListings.addAll(dummyListings);

      // Load crews
      _crews.addAll(dummyCrews);

      notifyListeners();
      _logger.info('Mock data loaded successfully');
    } catch (e) {
      _logger.severe('Error loading mock data: $e');
      print('DEBUG: DataService - Error loading mock data: $e');
    }
  }

  void toggleLike(String postId) {
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex != -1) {
      final post = _posts[postIndex];
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
        likes: post.likes + 1,
        comments: post.comments,
        createdAt: post.createdAt,
        updatedAt: now,
      );
      notifyListeners();
    }
  }

  void addComment(String postId, Comment comment) {
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex != -1) {
      final post = _posts[postIndex];
      final now = DateTime.now();
      final updatedComments = List<Comment>.from(post.comments)..add(comment);
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
    }
  }

  Future<void> refreshCrewsfeed() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Reload mock data
    _loadMockData();
  }

  Future<Project?> getProjectById(String id) async {
    try {
      final response = await Supabase.instance.client
          .from('projects')
          .select()
          .eq('id', id)
          .single();
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
}
