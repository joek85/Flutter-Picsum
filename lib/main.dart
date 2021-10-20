import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AppState();
  }
}

class _AppState extends State {
  late Future <List<Data>> futureData;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futureData = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        ImagePage.routeName: (context) => const ImagePage()
      },
      onGenerateRoute: (settings){
        if (settings.name == ImagePage.routeName){
          final args = settings.arguments as ScreenArguments;
          return MaterialPageRoute(builder: (context) {return const ImagePage();});
        }
      },
      title: 'Flutter Picsum',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.pink,
          accentColor: Colors.yellow
        ).copyWith(secondary: Colors.amber,)
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Picsum'),
        ),
        body: Center(
          child: FutureBuilder <List<Data>>(
            future: futureData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                List<Data>? data = snapshot.data;
                return
                  GridView.count(crossAxisCount: 2,
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 5,
                      padding: const EdgeInsets.all(5),
                      shrinkWrap: true,
                      children:
                        data!.map<Widget>((data) {
                        return InkWell(child:
                        CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: data.url,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, ImagePage.routeName, arguments: ScreenArguments(data.url));
                        });
                      }).toList()
                  );
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              // By default show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }

}
class ScreenArguments {
  final String url;
  ScreenArguments(this.url);
}
class _Photo {
  _Photo({
    required this.assetName,
    required this.title,
    required this.subtitle,
  });
  final String assetName;
  final String title;
  final String subtitle;
}
class Data {
  late int id;
  late String author;
  late String width;
  late String height;
  late String url;

  Data({required this.author, required this.url});

  factory Data.fromJson(Map<String, dynamic> json){
    return Data(
      author: json['author'],
      url: json['download_url']
    );
  }
}
Future <List<Data>> fetchData() async {
  final response = await http.get(Uri.parse('https://picsum.photos/v2/list?limit=5'));
  if (response.statusCode == 200) {
    List dataList = json.decode(response.body);
    return dataList.map((e) => Data.fromJson(e)).toList();
  }else{
    throw Exception('error');
  }
}

class ImagePage extends StatelessWidget{

  const ImagePage({Key? key}) : super(key: key);
  static const routeName = '/imageDetails';

  @override
  Widget build(BuildContext context) {
    final args  = ModalRoute.of(context)!.settings.arguments as ScreenArguments;

    return Scaffold(
          appBar: AppBar(
            title: const Text('Image Details'),
          ),
          body: Center(child:
          CachedNetworkImage(
            fit: BoxFit.fill,
            imageUrl: args.url,
            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ))
      );
  }
}
class _GridTitleText extends StatelessWidget {
  const _GridTitleText(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.center,
      child: Text(text, style: const TextStyle(fontSize: 20),),
    );
  }
}
class _GridDemoPhotoItem extends StatelessWidget {
  const _GridDemoPhotoItem({Key? key, required this.photo}) : super(key: key);

  final _Photo photo;
  // final GridListDemoType tileStyle;
  @override
  Widget build(BuildContext context) {
    final Widget image = Material(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: photo.assetName,
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    );
    return GridTile(child: image, footer: Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5)),
      clipBehavior: Clip.antiAlias,
      child: GridTileBar(
        backgroundColor: Colors.black54,
        subtitle: _GridTitleText(photo.subtitle),
      ),
    ),
      header: Material(
        color: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5)
        ),
        clipBehavior: Clip.antiAlias,
        child: GridTileBar(
          backgroundColor: Colors.black54,
          title: _GridTitleText(photo.title),
        ),
      ),
    );
  }

}
class GridListDemo extends StatelessWidget {
  const GridListDemo({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}
