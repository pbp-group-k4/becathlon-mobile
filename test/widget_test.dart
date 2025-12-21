import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

// Imports from your project
import 'package:becathlon_mobile/screens/login.dart';
import 'package:becathlon_mobile/screens/home.dart';
import 'package:becathlon_mobile/screens/cart_screen.dart';
import 'package:becathlon_mobile/screens/order_list_screen.dart';
import 'package:becathlon_mobile/screens/stores/store.dart';
import 'package:becathlon_mobile/screens/profile_screen.dart';

/// ---------------------------------------------------------------------------
/// HTTP OVERRIDES (To fix Map 400 Errors)
/// ---------------------------------------------------------------------------
class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _TestHttpClient();
  }
}

class _TestHttpClient implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return _TestHttpClientRequest();
  }
  
  // Implement other required members with dummy behavior
  @override var autoUncompress = true;
  @override var connectionTimeout;
  @override var idleTimeout = const Duration(seconds: 15);
  @override var maxConnectionsPerHost;
  @override var userAgent;

  @override
  dynamic noSuchMethod(Invocation invocation) {
     // fallback for other methods not used by simple image fetching
    return super.noSuchMethod(invocation);
  }
}

class _TestHttpClientRequest implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async {
    return _TestHttpClientResponse();
  }
  
  // Dummy implementations
  @override var headers = _TestHttpHeaders();
  @override void add(List<int> data) {}
  @override void write(Object? obj) {}
  @override dynamic noSuchMethod(Invocation invocation) => null;
}

class _TestHttpClientResponse implements HttpClientResponse {
  @override int get statusCode => 200; // Success!
  @override int get contentLength => 0;
  @override HttpClientHeaders get headers => _TestHttpHeaders();
  
  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    // Return empty stream to simulate empty image/response
    return const Stream<List<int>>.empty().listen(onData, 
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
  
  @override dynamic noSuchMethod(Invocation invocation) => null;
}

class _TestHttpHeaders implements HttpClientHeaders {
  @override void add(String name, Object value, {bool preserveHeaderCase = false}) {}
  @override dynamic noSuchMethod(Invocation invocation) => null;
}

/// ---------------------------------------------------------------------------
/// MOCK BACKEND SERVICE
/// ---------------------------------------------------------------------------
class MockCookieRequest extends CookieRequest {
  @override
  Future<dynamic> postJson(String url, dynamic data) async {
    // Mock Login Response
    if (url.contains('login')) {
      return {
        'status': true,
        'message': 'Login successful',
        'username': 'Test User',
      };
    }
    return {'status': false, 'message': 'Mock Error'};
  }

  @override
  Future<dynamic> get(String url) async {
    // Mock Product List
    if (url.contains('products')) {
      return [
        {
          "pk": 1,
          "fields": {
            "name": "Test Running Shoes",
            "description": "High quality shoes",
            "price": "149.99",
            "category": "Footwear",
            "brand": "Nike",
            "image": "",
            "stock": 10,
            "rating": "4.5"
          }
        },
        {
          "pk": 2,
          "fields": {
            "name": "Test Yoga Mat",
            "description": "Non-slip mat",
            "price": "29.99",
            "category": "Accessories",
            "brand": "Lululemon",
            "image": "",
            "stock": 5,
            "rating": "5.0"
          }
        }
      ];
    }
    // Mock Categories
    if (url.contains('categories')) {
      return [
        {"name": "Footwear"},
        {"name": "Accessories"}
      ];
    }
    
    // FIX: Mock Profile Response
    if (url.contains('profiles/api')) {
      return {
        'username': 'testuser',
        'first_name': 'Test',
        'last_name': 'User',
        'email': 'test@example.com',
        'phone': '123456789',
        'preferred_sports': 'Running',
        'newsletter_opt_in': true,
      };
    }
    
    return {'status': false};
  }

  @override
  Future<dynamic> logout(String url) async {
    return {'status': true, 'message': 'Logged out successfully'};
  }
}

/// ---------------------------------------------------------------------------
/// MAIN TEST SUITE
/// ---------------------------------------------------------------------------
void main() {
  // Install HttpOverrides before tests run
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  group('Becathlon Mobile App Full Integration Tests', () {
    late MockCookieRequest mockRequest;

    setUp(() {
      mockRequest = MockCookieRequest();
      mockRequest.loggedIn = false;
    });

    // TEST 1: LOGIN FLOW
    testWidgets('User can log in successfully', (WidgetTester tester) async {
      await tester.pumpWidget(
        Provider<CookieRequest>.value(
          value: mockRequest,
          child: const MaterialApp(home: LoginPage()),
        ),
      );

      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);

      await tester.enterText(find.ancestor(
        of: find.text('Username'),
        matching: find.byType(TextFormField),
      ), 'testuser');

      await tester.enterText(find.ancestor(
        of: find.text('Password'),
        matching: find.byType(TextFormField),
      ), 'password123');

      await tester.tap(find.text('Sign In'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('BECATHLON'), findsOneWidget);
      expect(find.textContaining('Welcome, Test User'), findsOneWidget);
    });

    // TEST 2: PRODUCT LOADING & DISPLAY
    testWidgets('Home page loads and displays products', (WidgetTester tester) async {
      await tester.pumpWidget(
        Provider<CookieRequest>.value(
          value: mockRequest,
          child: const MaterialApp(home: HomePage()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test Running Shoes'), findsOneWidget);
      expect(find.text('\$149.99'), findsOneWidget);
    });

    // TEST 3: SEARCH FUNCTIONALITY
    testWidgets('Search bar interactions work', (WidgetTester tester) async {
      await tester.pumpWidget(
        Provider<CookieRequest>.value(
          value: mockRequest,
          child: const MaterialApp(home: HomePage()),
        ),
      );
      await tester.pumpAndSettle();

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'Yoga');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pump();

      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    // TEST 4: NAVIGATION
    testWidgets('Navigation icons open correct screens', (WidgetTester tester) async {
      await tester.pumpWidget(
        Provider<CookieRequest>.value(
          value: mockRequest,
          child: const MaterialApp(home: HomePage()),
        ),
      );
      await tester.pumpAndSettle();

      // Store Locator
      await tester.tap(find.byIcon(Icons.store));
      await tester.pumpAndSettle();
      expect(find.byType(StoreLocatorScreen), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Profile
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      // This will now pass because MockCookieRequest returns profile data
      expect(find.byType(ProfilePage), findsOneWidget);
    });

    // TEST 5: LOGOUT
    testWidgets('Logout dialog appears and functions', (WidgetTester tester) async {
      await tester.pumpWidget(
        Provider<CookieRequest>.value(
          value: mockRequest,
          child: const MaterialApp(home: HomePage()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();

      // FIX: Expect "Logout" to appear twice (Dialog Title and Button)
      expect(find.text('Logout'), findsNWidgets(2));
      expect(find.text('Are you sure you want to logout?'), findsOneWidget);

      // Tap the Logout BUTTON (usually the last one in the tree)
      await tester.tap(find.widgetWithText(TextButton, 'Logout'));
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
    });
  });
}