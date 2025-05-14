import 'package:flutter/material.dart';
import 'package:lab4_5_widgets/widgets/CardIconText.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var titleStyle = theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.onSurface,
      fontSize: 20,
    );

    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TopSection(),
                SizedBox(height: 12),
                SearchBar(leading: Icon(Icons.search)),
                SizedBox(height: 24),
                BigCard(),
                SizedBox(height: 24),
                CategorySection(titleStyle: titleStyle),
                SizedBox(height: 24),
                RecommendedSection(titleStyle: titleStyle),
              ],
            ),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          destinations: [
            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(
              icon: Icon(Icons.shopping_bag),
              label: 'Bookings',
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
          selectedIndex: selectedIndex,
        ),
      ),
    );
  }
}

class TopSection extends StatelessWidget {
  const TopSection({super.key});

  @override
  Widget build(BuildContext context) {
    return (Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.clean_hands),
            SizedBox(width: 6),
            Text('HomeChores'),
          ],
        ),
        Row(
          children: [
            Icon(Icons.notifications),
            SizedBox(width: 8),
            Icon(Icons.account_circle),
          ],
        ),
      ],
    ));
  }
}

// Custom widgets
class RecommendedSection extends StatelessWidget {
  const RecommendedSection({super.key, required this.titleStyle});

  final TextStyle titleStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recommended', style: titleStyle),
            TextButton(onPressed: () {}, child: Text('See all')),
          ],
        ),
        SizedBox(height: 10),
        RecommendedItem(
          label: 'Cleaning',
          author: 'Rose Conwell',
          rating: 4.1,
          price: 10,
          image: 'assets/images/cleaning.png',
          sale: 15,
        ),
        SizedBox(height: 10),
        RecommendedItem(
          label: 'Repairing',
          author: 'Mike Smith',
          rating: 4.1,
          price: 10,
          image: 'assets/images/repairing.png',
          sale: 17,
        ),
      ],
    );
  }
}

class RecommendedItem extends StatelessWidget {
  const RecommendedItem({
    super.key,
    required this.label,
    required this.author,
    required this.rating,
    required this.price,
    required this.image,
    this.sale = 0,
  });
  final String label;
  final String author;
  final num rating;
  final int price;
  final String image;
  final int sale;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image(image: AssetImage(image), height: 100, width: 100),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label),
                  Text(
                    'by $author',
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.4),
                    ),
                  ),
                  Row(
                    children: [
                      CardIconText(
                        icon: Icons.star,
                        text: rating.toString(),
                        color: Colors.yellow.shade100,
                      ),
                      SizedBox(width: 5),
                      CardIconText(
                        icon: Icons.currency_bitcoin,
                        text: '$price/h',
                        color: Colors.indigo.shade50,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Text('Off $sale%'),
          ],
        ),
      ),
    );
  }
}

class CategorySection extends StatelessWidget {
  const CategorySection({super.key, required this.titleStyle});

  final TextStyle titleStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Category', style: titleStyle),
            TextButton(onPressed: () {}, child: Text('See all')),
          ],
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CategoryItem(
              label: 'Cleaning',
              color: Colors.lightGreen,
              icon: Icons.cleaning_services,
              route: '/cleaning',
            ),
            CategoryItem(
              label: 'Repairing',
              color: Colors.lightGreen,
              icon: Icons.home_repair_service,
              route: '/',
            ),
            CategoryItem(
              label: 'Laundry',
              color: Colors.lightGreen,
              icon: Icons.cleaning_services,
              route: '/',
            ),
            CategoryItem(
              label: 'Painting',
              color: Colors.lightGreen,
              icon: Icons.format_paint,
              route: '/',
            ),
          ],
        ),
      ],
    );
  }
}

class CategoryItem extends StatelessWidget {
  const CategoryItem({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.route,
  });
  final String label;
  final IconData icon;
  final Color color;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, route);
          },
          child: Icon(icon, color: color),
        ),
        SizedBox(height: 5),
        Text(label),
      ],
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    return Card(
      child: Stack(
        fit: StackFit.loose,
        alignment: Alignment.bottomLeft,
        children: <Widget>[
          Image.asset('assets/images/cleaning_card.png'),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(onPressed: () {}, child: Text('Get Started')),
          ),
        ],
      ),
    );
  }
}
