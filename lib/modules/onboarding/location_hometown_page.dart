import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../providers/onboarding_provider.dart';
import '../../config/theme_presets.dart';

class LocationHometownPage extends StatefulWidget {
  const LocationHometownPage({Key? key}) : super(key: key);

  @override
  State<LocationHometownPage> createState() => _LocationHometownPageState();
}

class _LocationHometownPageState extends State<LocationHometownPage> {
  final TextEditingController _currentLocationController =
      TextEditingController();
  final TextEditingController _hometownController = TextEditingController();
  bool _isLoadingLocation = false;
  bool _isLoadingAutocomplete = false;
  String location = '';
  String hometown = '';
  List<String> _locationSuggestions = [];
  List<String> _hometownSuggestions = [];
  bool _showLocationSuggestions = false;
  bool _showHometownSuggestions = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<OnboardingProvider>();
    _currentLocationController.text = provider.currentLocation;
    _hometownController.text = provider.hometown;
    location = provider.currentLocation;
    hometown = provider.hometown;
  }

  @override
  void dispose() {
    _currentLocationController.dispose();
    _hometownController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse geocode
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        final location =
            '${placemark.locality ?? ''}, ${placemark.administrativeArea ?? ''}'
                .trim();

        if (location.isNotEmpty) {
          _currentLocationController.text = location;
          this.location = location;
          context.read<OnboardingProvider>().setLocation(hometown, location);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _getLocationSuggestions(String query, bool isHometown) async {
    if (query.length < 2) {
      setState(() {
        if (isHometown) {
          _hometownSuggestions = [];
          _showHometownSuggestions = false;
        } else {
          _locationSuggestions = [];
          _showLocationSuggestions = false;
        }
      });
      return;
    }

    setState(() {
      _isLoadingAutocomplete = true;
    });

    try {
      List<Location> locations = await locationFromAddress(query);
      List<String> suggestions = [];

      for (Location loc in locations.take(5)) {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          loc.latitude,
          loc.longitude,
        );

        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          final suggestion =
              '${placemark.locality ?? ''}, ${placemark.administrativeArea ?? ''}'
                  .trim();
          if (suggestion.isNotEmpty && !suggestions.contains(suggestion)) {
            suggestions.add(suggestion);
          }
        }
      }

      setState(() {
        if (isHometown) {
          _hometownSuggestions = suggestions;
          _showHometownSuggestions = suggestions.isNotEmpty;
        } else {
          _locationSuggestions = suggestions;
          _showLocationSuggestions = suggestions.isNotEmpty;
        }
        _isLoadingAutocomplete = false;
      });
    } catch (e) {
      setState(() {
        if (isHometown) {
          _hometownSuggestions = [];
          _showHometownSuggestions = false;
        } else {
          _locationSuggestions = [];
          _showLocationSuggestions = false;
        }
        _isLoadingAutocomplete = false;
      });
    }
  }

  void _selectLocationSuggestion(String suggestion) {
    _currentLocationController.text = suggestion;
    location = suggestion;
    context.read<OnboardingProvider>().setLocation(hometown, location);
    setState(() {
      _showLocationSuggestions = false;
    });
  }

  void _selectHometownSuggestion(String suggestion) {
    _hometownController.text = suggestion;
    hometown = suggestion;
    context.read<OnboardingProvider>().setLocation(hometown, location);
    setState(() {
      _showHometownSuggestions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, child) {
        final currentTheme =
            getThemePresetBySlug(provider.themeSlug, provider.isDarkMode);

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Header
              Text(
                'Where are you?',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: currentTheme?.textColor,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                'Help us connect you with people nearby',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: currentTheme?.textColor.withOpacity(0.7) ??
                          Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                    ),
              ),
              const SizedBox(height: 20),

              // Current Location Section
              Text(
                'Current Location *',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: currentTheme?.textColor,
                    ),
              ),
              const SizedBox(height: 8),

              // Use Current Location button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                  icon: _isLoadingLocation
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: currentTheme?.primaryColor,
                          ),
                        )
                      : Icon(Icons.my_location,
                          size: 20, color: currentTheme?.primaryColor),
                  label: Text(
                      _isLoadingLocation
                          ? 'Getting location...'
                          : 'Use Current Location',
                      style: TextStyle(
                        fontSize: 14,
                        color: currentTheme?.primaryColor,
                      )),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    side: BorderSide(
                        color: currentTheme?.primaryColor ?? Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Manual location input with autocomplete
              Stack(
                children: [
                  TextField(
                    controller: _currentLocationController,
                    style: TextStyle(color: currentTheme?.textColor),
                    decoration: InputDecoration(
                      labelText: 'Or enter manually',
                      hintText: 'e.g., San Francisco, CA',
                      prefixIcon: Icon(Icons.location_on,
                          size: 20, color: currentTheme?.primaryColor),
                      suffixIcon: _isLoadingAutocomplete
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: currentTheme?.primaryColor,
                                ),
                              ),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      labelStyle: TextStyle(
                          color: currentTheme?.textColor.withOpacity(0.7)),
                      hintStyle: TextStyle(
                          color: currentTheme?.textColor.withOpacity(0.5)),
                    ),
                    onChanged: (value) {
                      location = value;
                      context
                          .read<OnboardingProvider>()
                          .setLocation(hometown, location);
                      _getLocationSuggestions(value, false);
                    },
                    onTap: () {
                      if (_currentLocationController.text.isNotEmpty) {
                        _getLocationSuggestions(
                            _currentLocationController.text, false);
                      }
                    },
                  ),
                  if (_showLocationSuggestions)
                    Positioned(
                      top: 50,
                      left: 0,
                      right: 0,
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _locationSuggestions.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              dense: true,
                              title: Text(
                                _locationSuggestions[index],
                                style: TextStyle(
                                  color: currentTheme?.textColor,
                                  fontSize: 14,
                                ),
                              ),
                              onTap: () => _selectLocationSuggestion(
                                  _locationSuggestions[index]),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // Hometown Section
              Text(
                'Hometown (Optional)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: currentTheme?.textColor,
                    ),
              ),
              const SizedBox(height: 8),

              // Hometown input with autocomplete
              Stack(
                children: [
                  TextField(
                    controller: _hometownController,
                    style: TextStyle(color: currentTheme?.textColor),
                    decoration: InputDecoration(
                      labelText: 'Where did you grow up?',
                      hintText: 'e.g., Portland, OR',
                      prefixIcon: Icon(Icons.home,
                          size: 20, color: currentTheme?.primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      labelStyle: TextStyle(
                          color: currentTheme?.textColor.withOpacity(0.7)),
                      hintStyle: TextStyle(
                          color: currentTheme?.textColor.withOpacity(0.5)),
                    ),
                    onChanged: (value) {
                      hometown = value;
                      context
                          .read<OnboardingProvider>()
                          .setLocation(hometown, location);
                      _getLocationSuggestions(value, true);
                    },
                    onTap: () {
                      if (_hometownController.text.isNotEmpty) {
                        _getLocationSuggestions(_hometownController.text, true);
                      }
                    },
                  ),
                  if (_showHometownSuggestions)
                    Positioned(
                      top: 50,
                      left: 0,
                      right: 0,
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _hometownSuggestions.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              dense: true,
                              title: Text(
                                _hometownSuggestions[index],
                                style: TextStyle(
                                  color: currentTheme?.textColor,
                                  fontSize: 14,
                                ),
                              ),
                              onTap: () => _selectHometownSuggestion(
                                  _hometownSuggestions[index]),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}
