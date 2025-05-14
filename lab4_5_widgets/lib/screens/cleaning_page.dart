import 'dart:developer';

import 'package:flutter/material.dart';

import '../widgets/CardIconText.dart';

class CleaningPage extends StatelessWidget {
  const CleaningPage({super.key});

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var titleStyle = theme.textTheme.displaySmall!.copyWith(
      color: theme.colorScheme.onSurface,
      fontSize: 20,
    );
    final List<String> images = [
      'assets/images/cleaning.png',
      'assets/images/cleaning.png',
      'assets/images/cleaning.png',
    ];

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            CarouselSection(
              images: images,
              height: 300.0,
              onBackPressed: () {
                Navigator.pop(context);
              },
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    AboutSection(titleStyle: titleStyle),
                    SizedBox(height: 24),
                    ServiceProviders(titleStyle: titleStyle),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CarouselSection extends StatefulWidget {
  final List<String> images;
  final double height;
  final VoidCallback onBackPressed;

  const CarouselSection({
    super.key,
    required this.images,
    this.height = 200.0,
    required this.onBackPressed,
  });

  @override
  State<CarouselSection> createState() => _CarouselSectionState();
}

class _CarouselSectionState extends State<CarouselSection> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Carousel
        SizedBox(
          height: widget.height,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(widget.images[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),

        // Back Button
        Positioned(
          top: 32.0,
          left: 16.0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: widget.onBackPressed,
            ),
          ),
        ),

        // Page Indicator
        Positioned(
          bottom: 16.0,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.images.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                width: 8.0,
                height: 8.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      _currentPage == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AboutSection extends StatelessWidget {
  const AboutSection({super.key, required this.titleStyle});

  final TextStyle titleStyle;
  @override
  Widget build(BuildContext context) {
    return (Column(
      children: [
        Row(children: [Text('About', style: titleStyle)]),
        SizedBox(height: 10),
        Text(
          'dafbjkanlfopauiohufbkajlfjiaohubifakjnlkfhioaugivfkbjalnkfhioaugifvkabjflauivhfk',
        ),
      ],
    ));
  }
}

class ServiceProviders extends StatelessWidget {
  const ServiceProviders({super.key, required this.titleStyle});

  final TextStyle titleStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('Service Providers', style: titleStyle)],
        ),
        SizedBox(height: 10),
        ServiceProviderItem(
          author: 'Rose Conwell',
          rating: 4.1,
          price: 10,
          image: 'assets/images/cleaning.png',
          sale: 15,
        ),
        SizedBox(height: 10),
        ServiceProviderItem(
          author: 'Aron Jones',
          rating: 4.1,
          price: 10,
          image: 'assets/images/repairing.png',
          sale: 17,
        ),
        SizedBox(height: 10),
        ServiceProviderItem(
          author: 'Mary Nicole',
          rating: 4.1,
          price: 10,
          image: 'assets/images/repairing.png',
          sale: 17,
        ),
      ],
    );
  }
}

class ServiceProviderItem extends StatelessWidget {
  const ServiceProviderItem({
    super.key,
    required this.author,
    required this.rating,
    required this.price,
    required this.image,
    this.sale = 0,
  });
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
                  Text(author),
                  SizedBox(height: 32),
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
