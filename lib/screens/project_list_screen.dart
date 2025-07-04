import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/project.dart'; // Adjust if needed
import 'dart:async';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen> {
  late Box<Project> projectBox;

  final Map<int, bool> isTracking = {};
  final Map<int, DateTime?> startTimes = {};
  final Map<int, Timer?> timers = {};

  @override
  void initState() {
    super.initState();
    projectBox = Hive.box<Project>('projectsBox');

    for (int i = 0; i < projectBox.length; i++) {
      isTracking[i] = false;
      startTimes[i] = null;
      timers[i] = null;
    }
  }

  void toggleTracking(int index) {
    final project = projectBox.getAt(index);
    if (project == null) return;

    setState(() {
      if (isTracking[index] == true) {
        // Stop tracking
        isTracking[index] = false;
        timers[index]?.cancel();
        timers[index] = null;

        if (startTimes[index] != null) {
          final duration = DateTime.now().difference(startTimes[index]!);
          project.elapsed += duration;
          project.save();
          startTimes[index] = null;
        }
      } else {
        // Start tracking
        isTracking[index] = true;
        startTimes[index] = DateTime.now();

        timers[index] = Timer.periodic(const Duration(seconds: 1), (_) {
          setState(() {});
        });
      }
    });
  }

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes % 60)}:${twoDigits(d.inSeconds % 60)}";
  }

  void _showAddProjectDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Project'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Project name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              //showDialog(context: context, builder: (_) => AlertDialog(content: Text("✅ Done")));
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                final newProject = Project(
                  name: name,
                  elapsed: Duration.zero,
                  startTime: null,
                );
                print("🛠 Project object created: ${newProject.name}");

                projectBox.add(newProject);
                print("✅ Project added to Hive box. Total projects: ${projectBox.length}");

                setState(() {
                  print("🔄 UI refresh via setState");
                });
              } else {
                print("⚠️ Empty name. Skipping add.");
              }
              Navigator.of(context).pop();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int index) {
    final project = projectBox.getAt(index);
    if (project == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: Text('Are you sure you want to delete "${project.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                timers[index]?.cancel();
                isTracking.remove(index);
                startTimes.remove(index);
                timers.remove(index);
                projectBox.deleteAt(index);
              });
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  void _renameProject(int index) {
    final project = projectBox.getAt(index);
    if (project == null) return;

    final controller = TextEditingController(text: project.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Project'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter new name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != project.name) {
                project.name = newName;
                project.save();
                setState(() {});
              }
              Navigator.of(context).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var timer in timers.values) {
      timer?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: projectBox.listenable(),
        builder: (context, Box<Project> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text('No projects added.'));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final project = box.getAt(index)!;
              final tracking = isTracking[index] ?? false;

              Duration total = project.elapsed;
              if (tracking && startTimes[index] != null) {
                total += DateTime.now().difference(startTimes[index]!);
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(project.name),
                  subtitle: Text('Tracked: ${formatDuration(total)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () => toggleTracking(index),
                        child: Text(tracking ? 'Stop' : 'Start'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tracking ? Colors.red : Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.grey),
                        onPressed: () => _confirmDelete(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blueAccent),
                        onPressed: () => _renameProject(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddProjectDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
