import 'dart:math' as math;

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

class AboutSection extends StatefulWidget {
  // <--- Изменили на StatefulWidget
  const AboutSection({super.key, required this.titleStyle});

  final TextStyle titleStyle;

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _revealController;

  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _titleLetterSpacing;

  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  // Объявляем _textWordSpacing, но не инициализируем здесь
  late Animation<double> _textWordSpacing;
  bool _animationsInitialized = false; // Флаг, чтобы инициализировать один раз

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Интервалы (остаются те же)
    const double interval1End = 0.4;
    const double interval2Start = 0.1;
    const double interval2End = 0.6;
    const double interval3Start = 0.4;
    const double interval3End = 0.8;
    const double interval4Start = 0.5;
    const double interval4End = 1.0;

    // --- Заголовок ---
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(0.0, interval1End, curve: Curves.easeIn),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0.3, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(
          interval2Start,
          interval2End,
          curve: Curves.easeOutCubic,
        ),
      ),
    );
    // Для titleLetterSpacing, если widget.titleStyle.letterSpacing доступен сразу (т.к. из widget)
    // то его можно инициализировать здесь. Если он тоже зависит от Theme, то перенести.
    // Предположим, widget.titleStyle не зависит от контекста в initState
    _titleLetterSpacing = Tween<double>(
      begin: 8.0,
      end: widget.titleStyle.letterSpacing ?? 0.0,
    ).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(
          interval2Start,
          interval2End,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    // --- Текст описания ---
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(
          interval3Start,
          interval3End,
          curve: Curves.easeIn,
        ),
      ),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _revealController,
        curve: const Interval(
          interval4Start,
          interval4End,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    // _textWordSpacing будет инициализирован в didChangeDependencies

    // Запуск анимации (оставляем здесь или переносим в didChangeDependencies после инициализации)
    // Лучше перенести после полной инициализации анимаций
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Инициализируем анимации, зависящие от context, только один раз
    if (!_animationsInitialized) {
      // Интервалы (если нужны здесь)
      const double interval4Start = 0.5;
      const double interval4End = 1.0;

      // Теперь Theme.of(context) доступен
      _textWordSpacing = Tween<double>(
        begin: 10.0,
        end: Theme.of(context).textTheme.bodyMedium?.wordSpacing ?? 0.0,
      ).animate(
        CurvedAnimation(
          parent: _revealController,
          curve: const Interval(
            interval4Start,
            interval4End,
            curve: Curves.easeOutCubic,
          ),
        ),
      );

      // Если _titleLetterSpacing тоже зависел бы от Theme, его инициализация была бы здесь

      _animationsInitialized = true;

      // Запускаем анимацию после того, как все анимации инициализированы
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _revealController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _revealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Важно: Убедиться, что _animationsInitialized true перед использованием _textWordSpacing
    // или добавить проверку на null, если _textWordSpacing может быть не инициализирован
    // (хотя с флагом _animationsInitialized, он должен быть инициализирован к моменту build)

    if (!_animationsInitialized) {
      // Можно показать заглушку, пока анимации не готовы
      return const SizedBox.shrink(); // Или CircularProgressIndicator
    }

    return AnimatedBuilder(
      animation: _revealController,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FractionalTranslation(
              translation: _titleSlide.value,
              child: Opacity(
                opacity: _titleOpacity.value,
                child: Text(
                  'About',
                  style: widget.titleStyle.copyWith(
                    letterSpacing: _titleLetterSpacing.value,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            FractionalTranslation(
              translation: _textSlide.value,
              child: Opacity(
                opacity: _textOpacity.value,
                child: Text(
                  'This is a detailed description of the cleaning service. We offer various packages to suit your needs, ensuring your space is sparkling clean and hygienic. Our professionals are well-trained and use eco-friendly products.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    // Используем _textWordSpacing.value
                    wordSpacing: _textWordSpacing.value,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class ServiceProviders extends StatefulWidget {
  const ServiceProviders({super.key, required this.titleStyle});

  final TextStyle titleStyle;

  @override
  State<ServiceProviders> createState() => _ServiceProvidersState();
}

class _ServiceProvidersState extends State<ServiceProviders>
    with SingleTickerProviderStateMixin {
  late AnimationController _staggeredController;

  late Animation<double> _item1Opacity;
  late Animation<double> _item1Scale;

  late Animation<double> _item2Opacity;
  late Animation<Offset> _item2Slide;

  late Animation<double> _item3Opacity;
  late Animation<double> _item3Rotation;
  late Animation<Color?> _item3CardColor;

  late Animation<double> _item4Opacity;
  late Animation<double> _item4Elevation;
  late Animation<Color?> _item4ShadowColor;

  final List<Map<String, dynamic>> _serviceProviderData = [
    {
      'author': 'Rose Conwell',
      'rating': 4.1,
      'price': 10,
      'image': 'assets/images/cleaning.png',
      'sale': 15,
    },
    {
      'author': 'Aron Jones',
      'rating': 4.1,
      'price': 10,
      'image': 'assets/images/repairing.png',
      'sale': 17,
    },
    {
      'author': 'Mary Nicole',
      'rating': 4.1,
      'price': 10,
      'image': 'assets/images/repairing.png',
      'sale': 17,
    },
    {
      'author': 'John Doe',
      'rating': 4.5,
      'price': 12,
      'image': 'assets/images/cleaning.png',
      'sale': 10,
    },
  ];

  @override
  void initState() {
    super.initState();

    _staggeredController = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    );

    const double intervalUnit = 1.0 / 4.0;
    const double animationOverlapFactor = 0.6;

    _item1Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggeredController,
        curve: Interval(
          0.0 * intervalUnit,
          (0.0 + animationOverlapFactor) * intervalUnit,
          curve: Curves.easeOut,
        ),
      ),
    );
    _item1Scale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggeredController,
        curve: Interval(
          0.0 * intervalUnit,
          (0.0 + animationOverlapFactor) * intervalUnit,
          curve: Curves.elasticOut,
        ),
      ),
    );

    _item2Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggeredController,
        curve: Interval(
          0.8 * intervalUnit,
          (0.8 + animationOverlapFactor) * intervalUnit,
          curve: Curves.easeOut,
        ),
      ),
    );
    _item2Slide = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _staggeredController,
        curve: Interval(
          0.8 * intervalUnit,
          (0.8 + animationOverlapFactor) * intervalUnit,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    _item3Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggeredController,
        curve: Interval(
          1.6 * intervalUnit,
          (1.6 + animationOverlapFactor) * intervalUnit,
          curve: Curves.easeOut,
        ),
      ),
    );
    _item3Rotation = Tween<double>(begin: math.pi / 16, end: 0.0).animate(
      CurvedAnimation(
        parent: _staggeredController,
        curve: Interval(
          1.6 * intervalUnit,
          (1.6 + animationOverlapFactor) * intervalUnit,
          curve: Curves.easeOutBack,
        ),
      ),
    );
    _item3CardColor = ColorTween(
      begin: Colors.grey.shade50,
      end: Colors.white,
    ).animate(
      CurvedAnimation(
        parent: _staggeredController,
        curve: Interval(
          1.6 * intervalUnit,
          (1.6 + animationOverlapFactor) * intervalUnit,
          curve: Curves.easeInOut,
        ),
      ),
    );

    _item4Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _staggeredController,
        curve: Interval(
          2.4 * intervalUnit,
          (2.4 + animationOverlapFactor) * intervalUnit,
          curve: Curves.easeOut,
        ),
      ),
    );
    _item4Elevation = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(
        parent: _staggeredController,
        curve: Interval(
          2.4 * intervalUnit,
          (2.4 + animationOverlapFactor) * intervalUnit,
          curve: Curves.easeOut,
        ),
      ),
    );
    _item4ShadowColor = ColorTween(
      begin: Colors.transparent,
      end: Colors.blueGrey.withOpacity(0.5),
    ).animate(
      CurvedAnimation(
        parent: _staggeredController,
        curve: Interval(
          2.4 * intervalUnit,
          (2.4 + animationOverlapFactor) * intervalUnit,
          curve: Curves.easeOut,
        ),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _staggeredController.forward();
      }
    });
  }

  @override
  void dispose() {
    _staggeredController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedServiceProviderItem({
    required Animation<double> opacity,
    Animation<double>? scale,
    Animation<Offset>? slide,
    Animation<double>? rotation,
    Animation<Color?>? cardColor,
    Animation<double>? elevation,
    Animation<Color?>? shadowColor,
    required Map<String, dynamic> data,
  }) {
    return AnimatedBuilder(
      animation: _staggeredController,
      builder: (context, child) {
        Widget current = Opacity(
          opacity: opacity.value,
          child: ServiceProviderItem(
            author: data['author'],
            rating: data['rating'],
            price: data['price'],
            image: data['image'],
            sale: data['sale'],
            cardBackgroundColor: cardColor?.value,
            cardElevation: elevation?.value,
            cardShadowColor: shadowColor?.value,
          ),
        );

        if (scale != null) {
          current = Transform.scale(scale: scale.value, child: current);
        }
        if (slide != null) {
          current = FractionalTranslation(
            translation: slide.value,
            child: current,
          );
        }
        if (rotation != null) {
          current = Transform.rotate(
            angle: rotation.value,
            alignment: Alignment.center,
            child: current,
          );
        }
        return current;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('Service Providers', style: widget.titleStyle)],
        ),
        SizedBox(height: 10),
        _buildAnimatedServiceProviderItem(
          opacity: _item1Opacity,
          scale: _item1Scale,
          data: _serviceProviderData[0],
        ),
        SizedBox(height: 10),
        _buildAnimatedServiceProviderItem(
          opacity: _item2Opacity,
          slide: _item2Slide,
          data: _serviceProviderData[1],
        ),
        SizedBox(height: 10),
        _buildAnimatedServiceProviderItem(
          opacity: _item3Opacity,
          rotation: _item3Rotation,
          cardColor: _item3CardColor,
          data: _serviceProviderData[2],
        ),
        SizedBox(height: 10),
        _buildAnimatedServiceProviderItem(
          opacity: _item4Opacity,
          elevation: _item4Elevation,
          shadowColor: _item4ShadowColor,
          data: _serviceProviderData[3],
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
    this.cardBackgroundColor,
    this.cardElevation,
    this.cardShadowColor,
  });
  final String author;
  final num rating;
  final int price;
  final String image;
  final int sale;
  final Color? cardBackgroundColor;
  final double? cardElevation;
  final Color? cardShadowColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: cardBackgroundColor ?? Theme.of(context).cardColor,
      elevation: cardElevation ?? Theme.of(context).cardTheme.elevation ?? 1.0,
      shadowColor: cardShadowColor ?? Theme.of(context).cardTheme.shadowColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image(
                image: AssetImage(image),
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(author, style: Theme.of(context).textTheme.titleMedium),
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
            if (sale > 0)
              Text(
                'Off $sale%',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
