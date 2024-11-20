  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import 'package:sqflite_common_ffi/sqflite_ffi.dart';
  

  import 'package:application_demo/steinbruch.dart';
  import 'package:application_demo/vormahlung.dart';
  import 'package:application_demo/ofen.dart';
  import 'package:application_demo/m_eigenschaften.dart';
  import 'package:application_demo/nachmahlung.dart';
  import 'package:application_demo/moertel.dart';
  import 'package:application_demo/beton.dart';
  import 'package:application_demo/search.dart';

  void main() async{
    WidgetsFlutterBinding.ensureInitialized();
      // Initialize FFI database factory
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    await databaseFactory.setDatabasesPath(await getDatabasesPath());
    runApp(MyApp());
  }

  class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
      return ChangeNotifierProvider(
        create: (context) => MyAppState(),
        child: MaterialApp(
          title: 'Application Demo',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          ),
          home: MyHomePage(),
        ),
      );
    }
  }

  class MyAppState extends ChangeNotifier {

    void getNext() {
      notifyListeners();
    }
  }

  class MyHomePage extends StatefulWidget {
    @override
    State<MyHomePage> createState() => _MyHomePageState();
  }

  class _MyHomePageState extends State<MyHomePage> {
    var selectedIndex = 0;

    @override
    Widget build(BuildContext context) {
      var colorScheme = Theme.of(context).colorScheme;

      Widget page;
      switch (selectedIndex) {
        case 0:
          page = SteinbruchForm();
          break;
        case 1:
          page = VormahlungForm();
          break;
        case 2:
          page = OfenForm();
          break;
        case 3:
          page = MaterialEigenschaftenForm();
          break;
        case 4:
          page = NachmahlungForm();
          break;
        case 5:
          page = MoertelZusammensetzungForm();
          break;
        case 6:
          page = BetonZusammensetzungForm();
          break;
        case 7:
          page = SearchForm();
          break;
        default:
          throw UnimplementedError('no widget for $selectedIndex');
      }

      // The container for the current page, with its background color
      // and subtle switching animation.
      var mainArea = ColoredBox(
        color: colorScheme.surfaceContainerHighest,
        child: AnimatedSwitcher(
          duration: Duration(milliseconds: 200),
          child: page,
        ),
      );

      return Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 450) {
              // Use a more mobile-friendly layout with BottomNavigationBar
              // on narrow screens.
              return Column(
                children: [
                  Expanded(child: mainArea),
                  SafeArea(
                    child: BottomNavigationBar(
                      items: [
                        BottomNavigationBarItem(
                          icon: Icon(Icons.landscape),
                          label: 'Steinbruch',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.grain),
                          label: 'Vormahlung',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.local_fire_department),
                          label: 'Ofen',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.science),
                          label: 'MaterialEigenschaften',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.build),
                          label: 'Endmahlung',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.water_drop),
                          label: 'MörtelZusammensetzung',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.construction),
                          label: 'BetonZusammensetzung',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(Icons.search),
                          label: 'Search',
                        ),
                      ],
                      currentIndex: selectedIndex,
                      onTap: (value) {
                        setState(() {
                          selectedIndex = value;
                        });
                      },
                    ),
                  )
                ],
              );
            } else {
              return Row(
                children: [
                  SafeArea(
                    child: NavigationRail(
                      // extended: constraints.maxWidth >= 600,
                      extended: false,
                      destinations: [
                        NavigationRailDestination(
                          icon: Icon(Icons.landscape),
                          label: Text('Steinbruch'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.grain),
                          label: Text('vormahlung'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.local_fire_department),
                          label: Text('Ofen'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.science),
                          label: Text('M-Eigenschaften'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.build),
                          label: Text('Endmahlung'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.water_drop),
                          label: Text('Mörtel'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.construction),
                          label: Text('Beton'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.search),
                          label: Text('Search'),
                        ),
                      ],
                      labelType: NavigationRailLabelType.all,
                      selectedIndex: selectedIndex,
                      onDestinationSelected: (value) {
                        setState(() {
                          selectedIndex = value;
                        });
                      },
                    ),
                  ),
                  Expanded(child: mainArea),
                ],
              );
            }
          },
        ),
      );
    }
  }


  class PlaceholderWidget extends StatelessWidget {
    final String text;

    const PlaceholderWidget({Key? key, required this.text}) : super(key: key);

    @override
    Widget build(BuildContext context) {
      return Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        );
    }
  }
