// ignore_for_file: public_member_api_docs, use_build_context_synchronously
import 'dart:async';
import 'dart:typed_data';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

void main() => runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: SafariPage()));

class SafariPage extends StatefulWidget {
  const SafariPage({super.key});

  @override
  State<SafariPage> createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<SafariPage> {
  late final WebViewController _controller;
  final _textController = TextEditingController();
  String _url = "https://www.google.com/";
  bool isNull = false;

  void _loadUrl(String url) {
    if (url == "") {
      setState(() {
        isNull = false;
      });
    } else {
      setState(() {
        isNull = true;
      });
      _controller.loadRequest(Uri.parse(url));
    }
  }

  void _handleSubmitted(String url) {
    setState(() {
      _url = url;
    });
    _loadUrl(url);
  }

  Future<void> _web(String url) async {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
            Page resource error:
            code: ${error.errorCode}
            description: ${error.description}
            errorType: ${error.errorType}
            isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            debugPrint('url change to ${change.url}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse(url));
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    _controller = controller;
  }

  @override
  void initState() {
    super.initState();
    _web(_url);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      appBar: isNull == false
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              toolbarHeight: 30,
              centerTitle: true,
              flexibleSpace: Container(
                padding: const EdgeInsets.only(top: 40, left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    NavigationControls(webViewController: _controller),
                  ],
                ),
              )),
      bottomNavigationBar: isNull == false
          ? Container()
          : FadeInUp(
              child: Hero(
                  tag: "tag",
                  child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40)),
                      child: Container(
                          color: Colors.white,
                          height: 90,
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.all(23),
                          child: TextField(
                              keyboardAppearance:
                                  MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark
                                      ? Brightness.dark
                                      : Brightness.light,
                              style: const TextStyle(color: Colors.black),
                              controller: _textController,
                              onSubmitted: (val) async {
                                if (val.isEmpty) {
                                  setState(() {
                                    isNull = true;
                                  });
                                }
                                _handleSubmitted(val);
                              },
                              decoration: InputDecoration(
                                prefixIcon: const Icon(
                                  Iconsax.search_normal,
                                  size: 18,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color.fromARGB(255, 213, 213, 213),
                                      width: 0.7),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Color.fromARGB(255, 213, 213, 213),
                                      width: 0.7),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                fillColor:
                                    const Color.fromARGB(255, 213, 213, 213),
                                filled: true,
                                contentPadding:
                                    const EdgeInsets.only(left: 15, top: 5),
                                alignLabelWithHint: true,
                                suffixIcon: GestureDetector(
                                    onTap: () async {
                                      final String? url =
                                          await _controller.currentUrl();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text('Favorited $url')),
                                      );
                                    },
                                    child: const Icon(
                                      Iconsax.heart_add,
                                      color: Colors.grey,
                                    )),
                                hintText: 'Search on Address',
                                hintStyle: const TextStyle(
                                    color: Color.fromARGB(255, 118, 118, 118),
                                    fontFamily: "arial"),
                              )))))),
      body: isNull == false
          ? Stack(
              children: [
                SizedBox(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Image.asset(
                      "assets/background.jpg",
                      fit: BoxFit.cover,
                    )),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FadeInDown(
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                                height: 100,
                                width: 100,
                                padding: const EdgeInsets.all(10),
                                color: Colors.white,
                                child: Image.asset(
                                  "assets/safari.png",
                                  height: 100,
                                )))),
                    Container(
                      height: 20,
                    ),
                    FadeInDown(
                        child: const Text(
                      "Safari",
                      style:
                          TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    )),
                    Container(
                      height: 20,
                    ),
                    FadeIn(
                      child: Hero(
                          tag: "tag",
                          child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(40),
                                  topRight: Radius.circular(40)),
                              child: Container(
                                  color: Colors.transparent,
                                  height: 90,
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.all(23),
                                  child: TextField(
                                      keyboardAppearance: MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.dark
                                          ? Brightness.dark
                                          : Brightness.light,
                                      style:
                                          const TextStyle(color: Colors.black),
                                      controller: _textController,
                                      onSubmitted: (val) async {
                                        if (val.isEmpty) {
                                          setState(() {
                                            isNull = true;
                                          });
                                        }
                                        _handleSubmitted(val);
                                      },
                                      decoration: InputDecoration(
                                        prefixIcon: const Icon(
                                          Iconsax.search_normal,
                                          size: 18,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Color.fromARGB(
                                                  255, 213, 213, 213),
                                              width: 0.7),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              color: Color.fromARGB(
                                                  255, 213, 213, 213),
                                              width: 0.7),
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        fillColor: const Color.fromARGB(
                                            255, 213, 213, 213),
                                        filled: true,
                                        contentPadding: const EdgeInsets.only(
                                            left: 15, top: 5),
                                        alignLabelWithHint: true,
                                        hintText: 'Search on Address',
                                        hintStyle: const TextStyle(
                                            color: Color.fromARGB(
                                                255, 118, 118, 118),
                                            fontFamily: "arial"),
                                      ))))),
                    )
                  ],
                )
              ],
            )
          : WebViewWidget(controller: _controller),
    );
  }
}

enum MenuOptions {
  showUserAgent,
  listCookies,
  clearCookies,
  addToCache,
  listCache,
  clearCache,
  doPostRequest,
  loadFlutterAsset,
  setCookie,
}

class SampleMenu extends StatelessWidget {
  SampleMenu({
    super.key,
    required this.webViewController,
  });

  final WebViewController webViewController;
  late final WebViewCookieManager cookieManager = WebViewCookieManager();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PopupMenuButton<MenuOptions>(
          icon: const Icon(
            Iconsax.more,
            color: Colors.blue,
          ),
          key: const ValueKey<String>('ShowPopupMenu'),
          onSelected: (MenuOptions value) {
            switch (value) {
              case MenuOptions.showUserAgent:
                _onShowUserAgent();
                break;
              case MenuOptions.listCookies:
                _onListCookies(context);
                break;
              case MenuOptions.clearCookies:
                _onClearCookies(context);
                break;
              case MenuOptions.addToCache:
                _onAddToCache(context);
                break;
              case MenuOptions.listCache:
                _onListCache();
                break;
              case MenuOptions.clearCache:
                _onClearCache(context);
                break;
              case MenuOptions.doPostRequest:
                _onDoPostRequest();
                break;
              case MenuOptions.loadFlutterAsset:
                _onLoadFlutterAssetExample();
                break;
              case MenuOptions.setCookie:
                _onSetCookie();
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuItem<MenuOptions>>[
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.showUserAgent,
              child: Text('Show user agent'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.listCookies,
              child: Text('List cookies'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.clearCookies,
              child: Text('Clear cookies'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.addToCache,
              child: Text('Add to cache'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.listCache,
              child: Text('List cache'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.clearCache,
              child: Text('Clear cache'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.doPostRequest,
              child: Text('Post Request'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.loadFlutterAsset,
              child: Text('Load Flutter Asset'),
            ),
            const PopupMenuItem<MenuOptions>(
              value: MenuOptions.setCookie,
              child: Text('Set cookie'),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(
            Iconsax.refresh,
            color: Colors.black,
          ),
          onPressed: () => webViewController.reload(),
        ),
      ],
    );
  }

  Future<void> _onShowUserAgent() {
    return webViewController.runJavaScript(
      'Toaster.postMessage("User Agent: " + navigator.userAgent);',
    );
  }

  Future<void> _onListCookies(BuildContext context) async {
    final String cookies = await webViewController
        .runJavaScriptReturningResult('document.cookie') as String;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
          bottomLeft: Radius.circular(0),
          bottomRight: Radius.circular(0),
        ),
      ),
      backgroundColor: Colors.red,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('Cookies:'),
          _getCookieList(cookies),
        ],
      ),
    ));
  }

  Future<void> _onAddToCache(BuildContext context) async {
    await webViewController.runJavaScript(
      'caches.open("test_caches_entry"); localStorage["test_localStorage"] = "dummy_entry";',
    );
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Added a test entry to cache.'),
    ));
  }

  Future<void> _onListCache() {
    return webViewController.runJavaScript('caches.keys()'
        '.then((cacheKeys) => JSON.stringify({"cacheKeys" : cacheKeys, "localStorage" : localStorage}))'
        '.then((caches) => Toaster.postMessage(caches))');
  }

  Future<void> _onClearCache(BuildContext context) async {
    await webViewController.clearCache();
    await webViewController.clearLocalStorage();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Cache cleared.'),
    ));
  }

  Future<void> _onClearCookies(BuildContext context) async {
    final bool hadCookies = await cookieManager.clearCookies();
    String message = 'There were cookies. Now, they are gone!';
    if (!hadCookies) {
      message = 'There are no cookies.';
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  Future<void> _onSetCookie() async {
    await cookieManager.setCookie(
      const WebViewCookie(
        name: 'foo',
        value: 'bar',
        domain: 'httpbin.org',
        path: '/anything',
      ),
    );
    await webViewController.loadRequest(Uri.parse(
      'https://httpbin.org/anything',
    ));
  }

  Future<void> _onDoPostRequest() {
    return webViewController.loadRequest(
      Uri.parse('https://httpbin.org/post'),
      method: LoadRequestMethod.post,
      headers: <String, String>{'foo': 'bar', 'Content-Type': 'text/plain'},
      body: Uint8List.fromList('Test Body'.codeUnits),
    );
  }

  Future<void> _onLoadFlutterAssetExample() {
    return webViewController.loadFlutterAsset('assets/www/index.html');
  }

  Widget _getCookieList(String cookies) {
    if (cookies == '""') {
      return Container();
    }
    final List<String> cookieList = cookies.split(';');
    final Iterable<Text> cookieWidgets =
        cookieList.map((String cookie) => Text(cookie));
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: cookieWidgets.toList(),
    );
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls({super.key, required this.webViewController});

  final WebViewController webViewController;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.blue,
          ),
          onPressed: () async {
            if (await webViewController.canGoBack()) {
              await webViewController.goBack();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No back history item')),
              );
            }
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.arrow_forward_ios,
            color: Colors.blue,
          ),
          onPressed: () async {
            if (await webViewController.canGoForward()) {
              await webViewController.goForward();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No forward history item')),
              );
            }
          },
        ),
        Container(
          width: MediaQuery.of(context).size.width / 2.3,
        ),
        SampleMenu(webViewController: webViewController),
      ],
    );
  }
}
