import 'package:flutter/material.dart';

void main() =>
    runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        home: new DefaultTabController(
          length: 3,
          child: new Scaffold(
            appBar: new AppBar(
              bottom: new TabBar(
                tabs: [
                  new Tab(text: "Channels"),
                  new Tab(text: "Friends"),
                  new Tab(text: "Whispers")
                ],
              ),
              backgroundColor: Colors.deepPurple,
              title: const Text('Twitch TV'),
              leading: new IconButton(
                  icon:
                  new Icon(Icons.search),
                  onPressed: _search),
              actions: <Widget>[
                new IconButton(
                    icon: new Icon(Icons.alarm),
                    onPressed: _search),
                new IconButton(
                    icon: new ImageIcon(new AssetImage('images/profile.png')),
                    onPressed: _search)
              ],
            ),
            body: new TwitchMain(),
          ),
        )
    );
  }

  void _search() {

  }
}

class TwitchMain extends StatefulWidget {

  @override
  _TwitchMainState createState() => new _TwitchMainState();
}

class _TwitchMainState extends State<TwitchMain> with TickerProviderStateMixin {
  int _currentIndex = 0;
  BottomNavigationBarType _type = BottomNavigationBarType.shifting;
  List<NavigationIconView> _navigationViews;

  @override
  void initState() {
    super.initState();
    _navigationViews = <NavigationIconView>[
      new NavigationIconView(
          icon: const Icon(Icons.voice_chat),
          title: "Live",
          color: Colors.deepPurple,
          vsync: this
      ),
      new NavigationIconView(
          icon: const Icon(Icons.whatshot),
          title: "Pulse",
          color: Colors.deepPurple,
          vsync: this
      ),
      new NavigationIconView(
          icon: const Icon(Icons.video_library),
          title: "Browse",
          color: Colors.deepPurple,
          vsync: this
      )
    ];

    for (NavigationIconView view in _navigationViews) {
      view.controller.addListener(_rebuild);
    }
    _navigationViews[_currentIndex].controller.value = 1.0;
  }

  void _rebuild() {
    setState(() {
      // Rebuild in order to animate views.
    });
  }

  @override
  void dispose() {
    for (NavigationIconView view in _navigationViews) {
      view.controller.dispose();
    }
    super.dispose();
  }

  Widget _buildTransitionsStack() {
    final List<FadeTransition> transitions = <FadeTransition>[];

    for (NavigationIconView view in _navigationViews) {
      transitions.add(view.transition(_type, context));
    }

    transitions.sort((FadeTransition a, FadeTransition b) {
      final Animation<double> aAnimation = a.opacity;
      final Animation<double> bAnimation = b.opacity;
      final double aValue = aAnimation.value;
      final double bValue = bAnimation.value;
      return aValue.compareTo(bValue);
    });

    return new Stack(children: transitions);
  }

  @override
  Widget build(BuildContext context) {
    final List<ListItem> items = new List<ListItem>.generate(
      1000,
          (i) =>
      i % 6 == 0
          ? new HeadingItem("Heading $i")
          : new ChannelItem("previewImg $i", i, "channelLogo $i", "channelName $i", "streamTitle $i", "gameTitle $i"),
    );

    final BottomNavigationBar botNavBar = new BottomNavigationBar(
      items: _navigationViews
          .map((NavigationIconView navigationView) => navigationView.item)
          .toList(),
      currentIndex: _currentIndex,
      type: _type,
      onTap: (int index) {
        setState(() {
          _navigationViews[_currentIndex].controller.reverse();
          _currentIndex = index;
          _navigationViews[_currentIndex].controller.forward();
        });
      },
    );

    return new Scaffold(
      body: new ListView.builder(
        itemCount: items.length,

        itemBuilder: (context, index) {
          final item = items[index];

          if (item is HeadingItem) {
            return new ListTile(
              title: new Text(
                item.heading,
                style: Theme.of(context).textTheme.headline,
              ),
            );
          } else if (item is ChannelItem) {
            return new ListTile(
              title: new Text(item.channelName),
              subtitle: new Text(item.viewerCount.toString()),
            );
          }
        },
      ),
//      body: new Center(
//          child: _buildTransitionsStack()
//      ),
      bottomNavigationBar: botNavBar,
    );
  }
}


// Model Class for BottomNavigationBar
class NavigationIconView {
  NavigationIconView({
    Widget icon,
    String title,
    Color color,
    TickerProvider vsync,
  })
      : _icon = icon,
        _color = color,
        _title = title,
        item = new BottomNavigationBarItem(
          icon: icon,
          title: new Text(title),
          backgroundColor: color,
        ),
        controller = new AnimationController(
          duration: kThemeAnimationDuration,
          vsync: vsync,
        ) {
    _animation = new CurvedAnimation(
      parent: controller,
      curve: const Interval(0.5, 1.0, curve: Curves.fastOutSlowIn),
    );
  }

  final Widget _icon;
  final Color _color;
  final String _title;
  final BottomNavigationBarItem item;
  final AnimationController controller;
  CurvedAnimation _animation;

  FadeTransition transition(BottomNavigationBarType type,
      BuildContext context) {
    Color iconColor;
    if (type == BottomNavigationBarType.shifting) {
      iconColor = _color;
    } else {
      final ThemeData themeData = Theme.of(context);
      iconColor = themeData.brightness == Brightness.light
          ? themeData.primaryColor
          : themeData.accentColor;
    }

    return new FadeTransition(
      opacity: _animation,
      child: new SlideTransition(
        position: new Tween<Offset>(
          begin: const Offset(0.0, 0.02), // Slightly down.
          end: Offset.zero,
        ).animate(_animation),
        child: new IconTheme(
          data: new IconThemeData(
            color: iconColor,
            size: 120.0,
          ),
          child: new Semantics(
            label: 'Placeholder for $_title tab',
            child: _icon,
          ),
        ),
      ),
    );
  }
}


// The base class for the different types of items the List can contain
abstract class ListItem {}

// A ListItem that contains data to display a heading
class HeadingItem implements ListItem {
  final String heading;

  HeadingItem(this.heading);
}

// A ListItem that contains data to display channel details
class ChannelItem implements ListItem {
  final String previewImg;
  final int viewerCount;
  final String channelLogo;
  final String channelName;
  final String streamTitle;
  final String gameTitle;

  ChannelItem(this.previewImg, this.viewerCount, this.channelLogo,
      this.channelName, this.streamTitle, this.gameTitle);
}