import '../models/listing.dart';

final List<Listing> seededListings = [
  Listing(
    title: 'CNC Milling Service',
    subtitle: 'Precision CNC service.',
    description:
        'Professional CNC milling services for metal and plastic parts.',
    price: 50.0,
    category: ListingCategory.project,
  ),
  Listing(
    title: '3D Printer Filament Pack',
    subtitle: 'Spare filament for FDM.',
    description: 'High-quality PLA filament for 3D printing.',
    price: 25.0,
    category: ListingCategory.project,
  ),
  Listing(
    title: 'Engine Rebuild Kit',
    subtitle: 'Complete kit for small block.',
    description: 'Complete engine rebuild kit including all necessary parts.',
    price: 299.0,
    category: ListingCategory.project,
  ),
];
