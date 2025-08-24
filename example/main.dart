import 'package:flutter/material.dart';
import 'package:awesome_celebration/awesome_celebration.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Awesome Celebration Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CelebrationDemo(),
    );
  }
}

class CelebrationDemo extends StatelessWidget {
  const CelebrationDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Celebration Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Choose a celebration type:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                CelebrationManager.show(
                  context,
                  type: CelebrationType.confetti,
                  onEnd: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Confetti celebration ended!')),
                    );
                  },
                );
              },
              child: const Text('🎊 Confetti'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                CelebrationManager.show(
                  context,
                  type: CelebrationType.emojiRain,
                  onEnd: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Emoji rain ended!')),
                    );
                  },
                );
              },
              child: const Text('🎉 Emoji Rain'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                CelebrationManager.show(
                  context,
                  type: CelebrationType.fireworks,
                  onEnd: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Fireworks celebration ended!')),
                    );
                  },
                );
              },
              child: const Text('🎆 Fireworks'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                CelebrationManager.show(
                  context,
                  type: CelebrationType.hearts,
                  onEnd: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Hearts celebration ended!')),
                    );
                  },
                );
              },
              child: const Text('💖 Hearts'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                CelebrationManager.show(
                  context,
                  type: CelebrationType.stars,
                  onEnd: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Stars celebration ended!')),
                    );
                  },
                );
              },
              child: const Text('⭐ Twinkling Stars'),
            ),
            const SizedBox(height: 30),
            const Divider(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                CelebrationManager.dismissAll();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All celebrations dismissed!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Dismiss All'),
            ),
            const SizedBox(height: 16),
            Text(
              'Active celebrations: ${CelebrationManager.hasActiveCelebrations}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
