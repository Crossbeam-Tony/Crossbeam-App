import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/data_service.dart';
import '../widgets/custom_card.dart';
import 'crew_detail_page.dart';

class CrewsScreen extends StatelessWidget {
  const CrewsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<DataService>(
      builder: (context, dataService, child) {
        try {
          final crews = dataService.crews;
          if (crews.isEmpty) {
            return const Scaffold(
              body: Center(child: Text('No crews available')),
            );
          }
          return Scaffold(
            appBar: AppBar(
              title: const Text('Crews'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    // TODO: Navigate to create crew screen
                  },
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(4.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                  childAspectRatio: 0.75,
                ),
                itemCount: crews.length,
                itemBuilder: (context, index) {
                  try {
                    final crew = crews[index];
                    return CrewCard(
                      title: crew.name,
                      imageUrl: crew.imageUrl,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CrewDetailPage(crew: crew),
                          ),
                        );
                      },
                    );
                  } catch (e) {
                    // Return a placeholder if there's an error with a specific crew
                    return const Card(
                      child: Center(
                        child: Icon(Icons.error),
                      ),
                    );
                  }
                },
              ),
            ),
          );
        } catch (e) {
          // Return error screen if there's a general error
          return Scaffold(
            appBar: AppBar(title: const Text('Crews')),
            body: const Center(
              child: Text('Error loading crews'),
            ),
          );
        }
      },
    );
  }
}
