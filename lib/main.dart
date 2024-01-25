import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social_firebase_auth/firebase_options.dart';
import 'package:flutter_social_firebase_auth/widgets/google_sign_in_button/google_sign_in_button.dart';
import 'package:google_sign_in/google_sign_in.dart';

const List<String> scopes = <String>['email', 'OpenID', 'perfil'];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social Login',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Social Login'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GoogleSignIn googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _currentUser;

  @override
  void initState() {
    super.initState();
    googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {
      if (kIsWeb && account != null) {
        await googleSignIn.canAccessScopes(scopes);
      }
      print("onCurrentUserChanged: ${account}");
      setState(() {
        _currentUser = account;
      });
    });

    googleSignIn.signInSilently();
  }

  Future<UserCredential?> _signInWithGoogle() async {
    GoogleSignInAccount? googleSignInAccount;
    try {
      if (kIsWeb) {
        googleSignInAccount = await googleSignIn.signInSilently();
      } else {
        googleSignInAccount = await googleSignIn.signIn();
      }
      GoogleSignInAuthentication authentication =
          await googleSignInAccount!.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: authentication.accessToken,
        idToken: authentication.idToken,
      );

      setState(() {
        _currentUser = googleSignInAccount;
      });

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (error) {
      debugPrint('ERROR: $error');
    }
    return null;
  }

  Future<void> _handleSignOut() => googleSignIn.disconnect();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _currentUser != null
                ? Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 1,
                          child: ListTile(
                            leading: GoogleUserCircleAvatar(
                              identity: _currentUser!,
                            ),
                            title: Text(_currentUser?.displayName ?? ''),
                            subtitle: Text(_currentUser!.email),
                          ),
                        ),
                        IconButton(
                          onPressed: _handleSignOut,
                          icon: const Icon(Icons.logout),
                        )
                      ],
                    ),
                  )
                : buildSignInButton(
                    onPressed: _signInWithGoogle,
                  ),
          ],
        ),
      ),
    );
  }
}
