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
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SearchBar(leading: Icon(Icons.search)),
            SizedBox(height: 16),
            BigCard(),
            SizedBox(height: 16),
            CategorySection(titleStyle: titleStyle),
            SizedBox(height: 16),
            RecommendedSection(titleStyle: titleStyle),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
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
        selectedIndex: selectedIndex,
      ),
    );
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
          image: 'assets/images/cleaning.jpg',
        ),
        SizedBox(height: 10),
        RecommendedItem(
          label: 'Repairing',
          author: 'Mike Smith',
          rating: 4.1,
          price: 10,
          image: 'assets/images/repairing.jpg',
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
  });
  final String label;
  final String author;
  final num rating;
  final int price;
  final String image;
  final int sale = 0;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: [
          Image(image: AssetImage(image)),
          SizedBox(width: 5),
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text(label), Text('Off $sale%')],
                ),
                Text('by $author'),
                Row(
                  children: [
                    CardIconText(icon: Icons.star, text: rating.toString()),
                    SizedBox(width: 5),
                    CardIconText(
                      icon: Icons.currency_bitcoin,
                      text: '$price/h',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
              icon: Icons.cleaning_services,
              route: '/cleaning',
            ),
            CategoryItem(
              label: 'Repairing',
              icon: Icons.repartition,
              route: '/',
            ),
            CategoryItem(
              label: 'Laundry',
              icon: Icons.cleaning_services,
              route: '/',
            ),
            CategoryItem(
              label: 'Painting',
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
    required this.route,
  });
  final String label;
  final IconData icon;
  final String route;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, route);
          },
          child: Icon(icon),
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
      child: Column(
        children: [
          Text('What Services do you need?'),
          ElevatedButton(onPressed: () {}, child: Text('Get Started')),
        ],
      ),
    );
  }
}
