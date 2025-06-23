import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../components/sliding_card.dart';
import '../../models/event.dart';
import '../../shared/avatar.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  int? _openCardIndex;
  int? _highlightedIndex;
  final ScrollController _scrollController = ScrollController();
  final Map<MarkerId, int> _markerIdToIndex = {};
  GoogleMapController? _mapController;
  String? _mapStyle;

  // Dark mode map style
  static const String _darkMapStyle = '''[
    {
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#212121"
        }
      ]
    },
    {
      "elementType": "labels.icon",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    },
    {
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#757575"
        }
      ]
    },
    {
      "elementType": "labels.text.stroke",
      "stylers": [
        {
          "color": "#212121"
        }
      ]
    },
    {
      "featureType": "administrative",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#757575"
        }
      ]
    },
    {
      "featureType": "administrative.country",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#9e9e9e"
        }
      ]
    },
    {
      "featureType": "administrative.land_parcel",
      "stylers": [
        {
          "visibility": "off"
        }
      ]
    },
    {
      "featureType": "administrative.locality",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#bdbdbd"
        }
      ]
    },
    {
      "featureType": "poi",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#757575"
        }
      ]
    },
    {
      "featureType": "poi.park",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#181818"
        }
      ]
    },
    {
      "featureType": "poi.park",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#616161"
        }
      ]
    },
    {
      "featureType": "poi.park",
      "elementType": "labels.text.stroke",
      "stylers": [
        {
          "color": "#1b1b1b"
        }
      ]
    },
    {
      "featureType": "road",
      "elementType": "geometry.fill",
      "stylers": [
        {
          "color": "#2c2c2c"
        }
      ]
    },
    {
      "featureType": "road",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#8a8a8a"
        }
      ]
    },
    {
      "featureType": "road.arterial",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#373737"
        }
      ]
    },
    {
      "featureType": "road.highway",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#3c3c3c"
        }
      ]
    },
    {
      "featureType": "road.highway.controlled_access",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#4e4e4e"
        }
      ]
    },
    {
      "featureType": "road.local",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#616161"
        }
      ]
    },
    {
      "featureType": "transit",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#757575"
        }
      ]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [
        {
          "color": "#000000"
        }
      ]
    },
    {
      "featureType": "water",
      "elementType": "labels.text.fill",
      "stylers": [
        {
          "color": "#3d3d3d"
        }
      ]
    }
  ]''';

  void _updateMapStyle(BuildContext context) {
    // Check if the current theme is dark mode using the context
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    String? newMapStyle;
    if (isDarkMode) {
      newMapStyle = _darkMapStyle;
    } else {
      newMapStyle = null; // Use default light style
    }

    // Only update if the style has changed
    if (_mapStyle != newMapStyle) {
      _mapStyle = newMapStyle;

      // Apply the new style if the controller is available
      if (_mapController != null) {
        _mapController?.setMapStyle(_mapStyle);
      }
    }
  }

  Set<Marker> _buildMarkers() {
    return {
      // for (int i = 0; i < seededEvents.length; i++)
      //   Marker(
      //     markerId: MarkerId(seededEvents[i].id),
      //     position: LatLng(seededEvents[i].latitude, seededEvents[i].longitude),
      //     infoWindow: InfoWindow(title: seededEvents[i].title),
      //     icon:
      //         BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      //     onTap: () {
      //       context.push('/events/${seededEvents[i].id}');
      //     },
      //   )
    };
  }

  void _scrollToIndex(int index) {
    _scrollController.animateTo(
      index * 120.0, // Approximate card height
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _onCardOpen(int index) {
    setState(() {
      _openCardIndex = index;
    });
  }

  void _onCardClose() {
    setState(() {
      _openCardIndex = null;
    });
  }

  void _onMarkerTapped(int index) {
    _scrollController.animateTo(
      index * 300.0, // Assuming each card is 300px high
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
    setState(() {
      _highlightedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Update map style when theme changes
    _updateMapStyle(context);

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(27.9378, -82.2418), // Valrico, FL
              zoom: 10.5,
            ),
            markers: _buildMarkers(),
            onMapCreated: (controller) {
              _mapController = controller;
              // Apply map style after controller is created
              if (_mapStyle != null) {
                controller.setMapStyle(_mapStyle);
              }
            },
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text('Events', style: Theme.of(context).textTheme.headlineSmall),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8.0),
            controller: _scrollController,
            itemCount: 0, // seededEvents.length,
            itemBuilder: (context, index) {
              return const SizedBox.shrink();
              // final event = seededEvents[index];
              // return SlidingCard(
              //   name: event.title,
              //   asset: event.imageUrl,
              //   offset: 100 * index.toDouble(),
              //   isOpen: _openCardIndex == index,
              //   onTap: () {
              //     setState(() {
              //       _openCardIndex = _openCardIndex == index ? null : index;
              //     });
              //   },
              //   child: _buildCardDetails(event),
              // );
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildCardDetails(Event event) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16),
              const SizedBox(width: 8),
              Text(
                '${event.date.day}/${event.date.month}/${event.date.year}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16),
              const SizedBox(width: 8),
              Text(
                event.location,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.person, size: 16),
              const SizedBox(width: 8),
              Text(
                'Organized by ${event.organizer}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Avatar(
                imageUrl: event.organizerAvatar,
                size: 30,
                userId: event.organizerId,
              ),
              const SizedBox(width: 10),
              const Text('Attendees:'),
              // Display attendee avatars
            ],
          ),
        ],
      ),
    );
  }
}
