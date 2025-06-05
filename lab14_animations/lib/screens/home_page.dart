import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lab4_5_widgets/widgets/CardIconText.dart';

import '../utils/custom_curve.dart';

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

class TopSection extends StatefulWidget {
  const TopSection({super.key});

  @override
  State<TopSection> createState() => _TopSectionState();
}

class _TopSectionState extends State<TopSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;
  late Animation<double> _rotationAnimation;
  bool _isBellAnimating = false;

  @override
  void initState() {
    super.initState();
    // 1. Инициализация AnimationController
    _rotationController = AnimationController(
      duration: const Duration(
        milliseconds: 500,
      ), // Длительность одного полного вращения/цикла
      vsync: this, // this предоставляет TickerProvider
    );

    // 2. Инициализация Animation с Tween
    // Анимация от 0 до 2*PI (полный оборот)
    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _rotationController,
        curve: Curves.easeInOut, // Плавная кривая
      ),
    );

    // Можно добавить слушателя для отслеживания статуса анимации
    _rotationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Если хотим, чтобы она вращалась только один раз и останавливалась
        // _rotationController.reset(); // Сбросить, если нужно для повторного запуска
        // setState(() {
        //   _isBellAnimating = false;
        // });
        // Если хотим повторять или делать что-то еще
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  void _toggleBellAnimation() {
    if (_rotationController.isAnimating) {
      _rotationController.stop(); // Можно остановить, если уже анимируется
      // _rotationController.reset(); // Или сбросить
      setState(() {
        _isBellAnimating = false;
      });
    } else {
      // Запускаем вперед. Для повторного вращения при каждом нажатии,
      // если она уже завершилась, нужно сбросить:
      if (_rotationController.status == AnimationStatus.completed) {
        _rotationController.reset();
      }
      _rotationController.forward(); // Запускаем анимацию
      setState(() {
        _isBellAnimating = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
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
            // Используем AnimatedBuilder для перестроения только иконки при анимации
            AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (BuildContext context, Widget? child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: child,
                );
              },
              child: IconButton(
                // Этот IconButton не будет перестраиваться каждый кадр
                icon: Icon(
                  Icons.notifications,
                  color:
                      _isBellAnimating
                          ? Theme.of(context).colorScheme.primary
                          : null,
                ),
                onPressed: _toggleBellAnimation,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.account_circle),
          ],
        ),
      ],
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

class RecommendedItem extends StatefulWidget {
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
  State<RecommendedItem> createState() => _RecommendedItemState();
}

class _RecommendedItemState extends State<RecommendedItem> {
  bool _isCardTapped = false;
  bool _isImageAnimationInProgress = false;

  void _onImageAnimationEnd() {
    setState(() {
      _isImageAnimationInProgress = false; // Сбрасываем флаг
    });
    print('Анимация изображения для "${widget.label}" завершена!');
    // Здесь можно выполнить любое другое действие, например:
    if (_isCardTapped) {
      // Если карточка все еще "нажата" после анимации увеличения
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Изображение "${widget.label}" увеличено!'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Если карточка "отпущена" после анимации уменьшения
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Изображение "${widget.label}" вернулось к норме.'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const animationDuration = Duration(milliseconds: 700);
    double imageSize = _isCardTapped ? 110.0 : 100.0;
    BoxBorder? imageBorder =
        _isCardTapped
            ? Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 2.0,
            )
            : null;
    EdgeInsets contentPadding =
        _isCardTapped
            ? const EdgeInsets.only(
              left: 12.0,
              top: 8.0,
              bottom: 8.0,
              right: 8.0,
            )
            : const EdgeInsets.only(
              left: 0.0,
              top: 8.0,
              bottom: 8.0,
              right: 8.0,
            );
    double saleOpacity = _isCardTapped ? 1.0 : 0.4;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        // NOTE: onTap
        onTap: () {
          if (_isImageAnimationInProgress) return;

          setState(() {
            _isCardTapped = !_isCardTapped;
            _isImageAnimationInProgress = true;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: animationDuration,
                // NOTE: curve and onEnd
                curve: const CubicEaseInCurve(),
                onEnd: _onImageAnimationEnd,
                width: imageSize,
                height: imageSize,
                decoration: BoxDecoration(
                  border: imageBorder,
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: AssetImage(widget.image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AnimatedPadding(
                  duration: animationDuration,
                  curve: Curves.easeOut,
                  padding: contentPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.label),
                      Text(
                        'by ${widget.author}',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          CardIconText(
                            icon: Icons.star,
                            text: widget.rating.toString(),
                            color: Colors.yellow.shade100,
                          ),
                          const SizedBox(width: 5),
                          CardIconText(
                            icon: Icons.currency_bitcoin,
                            text: '${widget.price}/h',
                            color: Colors.indigo.shade50,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.sale > 0)
                AnimatedOpacity(
                  duration: animationDuration,
                  curve: Curves.easeOut,
                  opacity: saleOpacity,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4.0, left: 4.0),
                    child: Text(
                      'Off ${widget.sale}%',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              else
                const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}

class CategorySection extends StatefulWidget {
  const CategorySection({super.key, required this.titleStyle});

  final TextStyle titleStyle;

  @override
  State<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<CategorySection> {
  bool _canStartAnimation = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _canStartAnimation = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_canStartAnimation)
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (BuildContext context, double value, Widget? child) {
                  final currentFontSize =
                      (widget.titleStyle.fontSize ?? 16.0) *
                      (0.5 + value * 0.5);
                  final currentOpacity = value;
                  return Opacity(
                    opacity: currentOpacity,
                    child: Text(
                      'Category',
                      style: widget.titleStyle.copyWith(
                        fontSize: currentFontSize,
                      ),
                    ),
                  );
                },
              )
            else
              Opacity(
                opacity: 0.0,
                child: Text(
                  'Category',
                  style: widget.titleStyle.copyWith(
                    fontSize: (widget.titleStyle.fontSize ?? 16.0) * 0.5,
                  ),
                ),
              ),
            TextButton(onPressed: () {}, child: const Text('See all')),
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

class BigCard extends StatefulWidget {
  const BigCard({super.key});

  @override
  State<BigCard> createState() => _BigCardState();
}

class _BigCardState extends State<BigCard> with SingleTickerProviderStateMixin {
  late AnimationController _pulsateController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulsateController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Анимация масштаба от 1.0 (нормальный размер) до 1.05 (немного больше) и обратно
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.05,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.05,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50.0,
      ),
    ]).animate(_pulsateController);

    // Чтобы анимация повторялась
    // _pulsateController.repeat(reverse: true); // Закомментируем, будем запускать по нажатию

    // Для отладки
    // _scaleAnimation.addListener(() {
    //   setState(() {}); // Не нужно, если используем AnimatedBuilder
    // });
  }

  @override
  void dispose() {
    _pulsateController.dispose();
    super.dispose();
  }

  void _togglePulsateAnimation() {
    if (_pulsateController.isAnimating) {
      _pulsateController.stop();
      // Можно сбросить до начального состояния, если остановить в середине
      // _pulsateController.reset(); // Это вернет масштаб к 1.0
    } else {
      // Если хотим, чтобы при каждом нажатии она "пульсировала" один раз (туда-обратно)
      // и потом останавливалась. Для повторного запуска нужно будет reset(), если completed.
      if (_pulsateController.status == AnimationStatus.completed ||
          _pulsateController.status == AnimationStatus.dismissed) {
        _pulsateController.forward(from: 0.0); // Запускаем с начала
      } else {
        _pulsateController.forward();
      }
      // Если хотим, чтобы она начала бесконечно пульсировать по нажатию:
      // _pulsateController.repeat(reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePulsateAnimation,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Card(
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: <Widget>[
              Image.asset('assets/images/cleaning_card.png'),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text('Get Started'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
