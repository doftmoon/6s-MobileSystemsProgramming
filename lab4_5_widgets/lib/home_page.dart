import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var h2Style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onSurface,
    );

    var navIndex = 0;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SearchBar(leading: Icon(Icons.search)),
            SizedBox(height: 10),
            Card(),
            SizedBox(height: 10),
            Text('Category', style: h2Style),
            Row(
              children: [
                Column(
                  children: [
                    Icon(Icons.cleaning_services),
                    SizedBox(height: 5),
                    Text('Cleaning'),
                  ],
                ),
              ],
            ),
            NavigationBar(
              destinations: [
                NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
                NavigationDestination(
                  icon: Icon(Icons.shopping_bag),
                  label: 'Booking',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  label: 'Schedule',
                ),
                NavigationDestination(
                  icon: Icon(Icons.bookmark_border_rounded),
                  label: 'Saved',
                ),
                NavigationDestination(
                  icon: Icon(Icons.messenger_outline_rounded),
                  label: 'Message',
                ),
              ],
              selectedIndex: navIndex,
            ),
          ],
        ),
      ),
    );
  }
}
