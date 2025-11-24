# Becathlon Mobile - Flutter E-Commerce Prototype

A Flutter mobile application prototype for the Becathlon sports equipment e-commerce platform, featuring authentication, product catalog browsing, shopping cart management, and user profiles. This app connects to a Django backend via REST API.

## Features

### ✅ Implemented
- **Authentication**
  - User login with Django backend integration
  - User registration
  - Session management with cookies
  - Logout functionality

- **Product Catalog**
  - Browse all products in a grid layout
  - Search products by name or category
  - View detailed product information
  - Product images, prices, stock availability, and ratings

- **Shopping Cart**
  - Add products to cart
  - Update item quantities
  - Remove items from cart
  - View cart total and item count
  - Cart state management with Provider

- **User Profile**
  - View user information
  - Access to menu items (orders, wishlist, settings)
  - Logout functionality

- **Modern UI/UX**
  - Gradient backgrounds and glassmorphism effects
  - Bottom navigation for easy access
  - Pull-to-refresh on product lists
  - Smooth animations and transitions
  - Material 3 design system

### 🚧 Coming Soon
- Checkout and payment integration
- Order history and tracking
- Product recommendations
- Store locator with maps
- Wishlist functionality

## Tech Stack

- **Frontend**: Flutter 3.x
- **State Management**: Provider
- **Backend Integration**: Django REST API
- **Authentication**: pbp_django_auth package
- **HTTP Client**: http package
- **UI**: Material 3, Google Fonts

## Prerequisites

- Flutter SDK (3.0 or higher)
- Android Studio / VS Code with Flutter extensions
- Android Emulator or physical device
- Django backend running (see backend setup below)

## Installation

1. **Clone or navigate to the project directory**
   ```bash
   cd becathlon_mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Update Django backend URL**
   Edit the following files and replace `http://10.0.2.2:8000` with your Django backend URL:
   - `lib/services/product_service.dart` (line 9)
   - `lib/screens/auth/login.dart` (line 120)
   - `lib/screens/auth/register.dart` (line 151)
   - `lib/screens/profile/profile.dart` (line 118)

   **Note**: 
   - For Android emulator: Use `http://10.0.2.2:8000`
   - For iOS simulator: Use `http://localhost:8000` or `http://127.0.0.1:8000`
   - For physical device: Use your computer's IP address (e.g., `http://192.168.1.100:8000`)

4. **Run the app**
   ```bash
   flutter run
   ```

## Django Backend Setup

Your Django backend should have the following endpoints:

### Authentication Endpoints
- `POST /auth/login/` - User login
  - Request: `{ "username": "...", "password": "..." }`
  - Response: `{ "status": true, "message": "...", "username": "..." }`

- `POST /auth/register/` - User registration
  - Request: `{ "username": "...", "password": "...", "password2": "..." }`
  - Response: `{ "status": true/false, "message": "..." }`

- `POST /auth/logout/` - User logout
  - Response: `{ "status": true, "message": "..." }`

### Product Endpoints
- `GET /api/products/` - Get all products
  - Response: Array of product objects
- `GET /api/products/<id>/` - Get single product
- `GET /api/products/?category=<category>` - Filter by category
- `GET /api/products/?search=<query>` - Search products

### Product JSON Format
Products should follow this structure:
```json
{
  "pk": "1",
  "fields": {
    "name": "Product Name",
    "description": "Product description",
    "price": 99.99,
    "category": "Category",
    "image": "image_url",
    "stock": 10,
    "rating": 4.5
  }
}
```

Or simplified format:
```json
{
  "id": "1",
  "name": "Product Name",
  "description": "Product description",
  "price": 99.99,
  "category": "Category",
  "image": "image_url",
  "stock": 10,
  "rating": 4.5
}
```

### Django CORS Configuration

Add these to your Django `settings.py`:

```python
INSTALLED_APPS = [
    ...
    'corsheaders',
    ...
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    ...
]

CORS_ALLOW_ALL_ORIGINS = True
CORS_ALLOW_CREDENTIALS = True
CSRF_COOKIE_SECURE = True
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SAMESITE = 'None'
SESSION_COOKIE_SAMESITE = 'None'

ALLOWED_HOSTS = [..., '10.0.2.2']
```

## Project Structure

```
lib/
├── main.dart                 # App entry point with providers
├── models/                   # Data models
│   ├── user.dart
│   ├── product.dart
│   └── cart_item.dart
├── services/                 # API services
│   └── product_service.dart
├── providers/                # State management
│   └── cart_provider.dart
├── screens/                  # UI screens
│   ├── auth/
│   │   ├── login.dart
│   │   └── register.dart
│   ├── home/
│   │   └── home.dart
│   ├── catalog/
│   │   ├── catalog.dart
│   │   └── product_detail.dart
│   ├── cart/
│   │   └── cart.dart
│   └── profile/
│       └── profile.dart
└── widgets/                  # Reusable widgets
    └── common/
```

## Usage

1. **Login/Register**: Start by logging in with existing credentials or create a new account
2. **Browse Products**: Navigate to the Catalog tab to view all products
3. **Search**: Use the search bar to find specific products
4. **View Details**: Tap on any product to see detailed information
5. **Add to Cart**: Add items to your cart from the catalog or product detail page
6. **Manage Cart**: View and edit your cart in the Cart tab
7. **Profile**: Access your profile and logout from the Profile tab

## Troubleshooting

### Cannot connect to Django backend
- Ensure Django server is running
- Check that you're using the correct IP address
- For Android emulator, use `10.0.2.2` instead of `localhost`
- Verify CORS settings in Django

### Build errors
Run `flutter clean` then `flutter pub get`

### Deprecation warnings
The app uses some methods with deprecation warnings (like `withOpacity`), but these don't affect functionality. They will be updated in future releases.

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is created for educational purposes as part of the PBP (Platform-Based Programming) course.

## Acknowledgments

- PBP Teaching Team for the integration tutorial
- Flutter team for the excellent framework
- Django team for the robust backend framework
