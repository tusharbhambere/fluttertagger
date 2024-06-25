import 'package:flutter/material.dart';
import 'package:example/models/post.dart';
import 'package:example/views/view_models/home_view_model.dart';
import 'package:example/views/view_models/search_view_model.dart';
import 'package:example/views/widgets/comment_text_field.dart';
import 'package:example/views/widgets/post_widget.dart';
import 'package:fluttertagger/fluttertagger.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterTagger Demo',
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: Colors.redAccent.withOpacity(.3),
        ),
        primarySwatch: Colors.red,
      ),
      home: const HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  late AnimationController _animationController;

  double overlayHeight = 380;

  late final homeViewModel = HomeViewModel();
  late final _controller = FlutterTaggerController(
    //Initial text value with tag is formatted internally
    //following the construction of FlutterTaggerController.
    //After this controller is constructed, if you
    //wish to update its text value with raw tag string,
    //call (_controller.formatTags) after that.
    text:
        "Hey @11a27531b866ce0016f9e582#brad#. It's time to #11a27531b866ce0016f9e582#Flutter#!",
  );
  late final _focusNode = FocusNode();

  void _focusListener() {
    if (!_focusNode.hasFocus) {
      _controller.dismissOverlay();
    }
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_focusListener);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _focusNode.removeListener(_focusListener);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var insets = MediaQuery.of(context).viewInsets;
    return GestureDetector(
      onTap: () {
        _controller.dismissOverlay();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.redAccent,
          title: const Text("The Squad"),
        ),
        bottomNavigationBar: FlutterTagger(
          controller: _controller,
          animationController: _animationController,
          onSearch: (query, triggerChar) {
            if (triggerChar == "@") {
              searchViewModel.searchUser(query);
            }
            if (triggerChar == "#") {
              searchViewModel.searchHashtag(query);
            }
          },
          triggerCharacterAndStyles: const {
            "@": TextStyle(color: Colors.pinkAccent),
            "#": TextStyle(color: Colors.blueAccent),
          },
          tagTextFormatter: (id, tag, triggerCharacter) {
            return "$triggerCharacter$id#$tag#";
          },
          overlayMaxHeight: overlayHeight,
          tagItemBuilder: (tag, selectedTag, isLast) {
            return ListTile(
              title: Text(tag.name),
              onTap: () {
                _controller.addTag(id: tag.id, name: tag.name);
                _focusNode.requestFocus();
              },
            );
          },
          builder: (context, containerKey) {
            return CommentTextField(
              focusNode: _focusNode,
              containerKey: containerKey,
              insets: insets,
              controller: _controller,
              onSend: () {
                FocusScope.of(context).unfocus();
                homeViewModel.addPost(_controller.formattedText);
                _controller.clear();
              },
            );
          },
        ),
        body: ValueListenableBuilder<List<Post>>(
          valueListenable: homeViewModel.posts,
          builder: (_, posts, __) {
            return ListView.builder(
              itemCount: posts.length,
              itemBuilder: (_, index) {
                return PostWidget(post: posts[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
