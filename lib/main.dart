import 'package:flutter/material.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HomePage());
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // ← Tab 개수와 동일해야 함
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(icon: Icon(Icons.menu), onPressed: () {}),
                  Text('Alchemist Hunter'),
                ],
              ),
              TextButton(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [Text("Diamonds"), Icon(Icons.diamond)],
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: const TabBar(
            indicatorColor: Colors.transparent,
            labelPadding: EdgeInsets.zero,
            tabs: [
              Tab(
                child: Column(
                  children: [Icon(Icons.person), Text('Characters')],
                ),
              ),
              Tab(child: Column(children: [Icon(Icons.spa), Text('Weapons')])),
              Tab(child: Column(children: [Icon(Icons.shield), Text('Armor')])),
              Tab(child: Column(children: [Icon(Icons.pets), Text('Pets')])),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(2),
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey,
                      ),
                      child: Center(child: Text('Character ${index + 1}')),
                    ),
                  );
                },
              ),
            ),
            Center(child: Text('Page 2')),
            Center(child: Text('Page 3')),
            Center(child: Text('Page 4')),
          ],
        ),
      ),
    );
  }
}
