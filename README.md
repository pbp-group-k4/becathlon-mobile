# becathlon-mobile

> A Flutter-powered mobile storefront backed by a Django REST API, inspired by Decathlon’s polished browsing experience but lightweight. 
Features include responsive product grids, fast search, filters, and a simplified checkout flow, all optimized for speed and usability.

## Team Members

- Muhammad Adra Prakoso – Backend developer / 2406453530
- Berguegou Briana Yadjam – 2506561555
- Zahran Musyaffa Ramadhan Mulya – 2406365401
- Gunata Prajna Putra Sakri – 2406453461
- Muhammad Vegard Fathul Islam – 2406365332
- Kent Wilbert Wijaya

## Application Story & Benefits (Mobile App)

### What is Becathlon Mobile?

*Becathlon Mobile* is a Flutter-powered e-commerce application that brings the multisport shopping experience directly to your smartphone. 
Inspired by Decathlon’s clean user experience and comprehensive product catalog, the app recreates a modern sports retail journey while serving as a practical learning project for full-stack mobile development.

### The Story

In today’s mobile-first world, shoppers expect fast, intuitive, and personalized experiences, 
especially when choosing equipment for their sport. Whether someone is a casual runner, a gym enthusiast, or a professional climber, Becathlon Mobile aims to make discovering and purchasing sports gear effortless, engaging, and available anywhere.

The mobile app transforms the traditional browsing and buying experience into a portable digital journey, offering:

* **Full Product Catalog**: Browse sports equipment and categories anytime, anywhere
* **Personalized Recommendations**: Tailored product suggestions based on user preferences and history
* **Optimized Shopping Flow**: From browsing to checkout, every step is streamlined for small screens
* **Store Integration**: Locate physical stores when users want in-person shopping or product trials

### Key Benefits

**For Customers:**

* **Fast, Smooth Navigation**: Mobile-optimized UI with easy browsing and filtering
* **Rich Product Experience**: High-quality visuals, detailed descriptions, and informed purchasing
* **Smart Shopping Tools**: Add to cart, adjust quantities, compare, and make decisions easily
* **Mobile Order Tracking**: View order history and live order status directly in the app
* **Personalized Platform**: Saved preferences and recommended products tailored to the user

**For Administrators (Backend):**

* **Full System Control** via the Django admin dashboard:

  * Manage inventory, categories, and product data
  * Handle returns, sales, and customer accounts
  * Maintain store location data
* Web dashboard and mobile app stay in sync through shared APIs

**For Developers:**

* **Modern Cross-Platform Stack**: Built using Flutter and Dart, following clean development patterns
* **Modular and Scalable**: Organized architecture ready for future enhancements
* **API-Driven**: Demonstrates real mobile-to-backend communication with Django REST
* **Learning Friendly**: Ideal for practicing mobile UI/UX, state management, API integration, and architecture

### App Flow

**For Guest Users:** Users can open the app, browse categories, scroll through products, search with filters, view details, add items to cart, or explore nearby stores. Checkout and order placement require a login.

**For Registered Users:** After logging in, users can:

* Browse featured and recommended items
* Search and filter the catalog
* View detailed product pages
* Add items to cart and manage quantities
* Proceed through a quick checkout experience
* Place orders and get confirmation
* Track order status in real time
* Update profile and preferences

**For Admins:** Product, order, user, and store management continues via the Django admin panel, with all changes reflected in the mobile app through the API.


## Modules (Flutter)

| Module          | Location / Components                                                                                               | Purpose                                                                 |
| --------------- | ------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| Core / Home     | `lib/main.dart`, `lib/screens/home/`, `lib/widgets/common/`, `lib/navigation/`                                      | App entry point, navigation, homepage, about screen, shared UI elements |
| Authentication  | `lib/screens/auth/`, `lib/services/auth_service.dart`, `lib/models/user.dart`, `lib/widgets/auth/`                  | User login, registration, logout, token/session handling                |
| Catalog         | `lib/screens/catalog/`, `lib/models/product.dart`, `lib/services/product_service.dart`, `assets/data/products.json` | Product listing, categories, product detail pages                       |
| Search          | `lib/screens/search/`, `lib/services/search_service.dart`                                                           | Search UI and filtering logic                                           |
| Cart            | `lib/screens/cart/`, `lib/providers/cart_provider.dart`, `lib/models/cart_item.dart`                                | Manage shopping cart state, add/remove items                            |
| Checkout        | `lib/screens/checkout/`, `lib/services/payment_service.dart`, `lib/widgets/checkout/`                               | Mock checkout workflow and order confirmation                           |
| Orders          | `lib/screens/orders/`, `lib/models/order.dart`, `lib/services/order_service.dart`                                   | Order history, mock refund handling                                     |
| Store Locator   | `lib/screens/stores/`, `lib/models/store.dart`, `lib/services/store_service.dart`, `assets/data/stores.json`        | Store locator with mock map/location data                               |
| Recommendations | `lib/screens/recommendations/`, `lib/services/recommendation_service.dart`                                          | Product recommendations logic and UI                                    |
| Profiles        | `lib/screens/profile/`, `lib/models/profile.dart`, `lib/services/profile_service.dart`, `lib/widgets/profile/`      | User account management, settings, saved preferences                    |

## User Roles

| Role                  | Description                                                  | Permissions                                                                                                                                                                                                                                                                      | Relevant App Modules                                                                                                                                                                                                                          |
| --------------------- | ------------------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Guest / Visitor**   | Unregistered users exploring the app.                        | - Browse products and categories<br>- Search and apply filters<br>- Add items to a temporary cart<br>- View product details and read limited reviews                                                                                                                             | `Home & Navigation` (landing pages)<br>`Catalog` (product listings & details)<br>`Search` (search & filtering)<br>`Cart` (local-only cart state)<br>`Recommendations` (basic suggestions)                                                     |
| **Client / Customer** | Registered app users with an account.                        | - Everything a guest can do<br>- Login and manage account<br>- Save delivery addresses & preferences<br>- Add to persistent cart (stored via API)<br>- Order and checkout flow<br>- Track order status<br>- Submit reviews and ratings<br>- Receive personalized recommendations | `Authentication` (login, registration)<br>`Profiles` (user info & settings)<br>`Cart` (sync persistent cart)<br>`Checkout` (payment & order placement)<br>`Orders` (order history & tracking)<br>`Recommendations` (personalized suggestions) |
| **Administrator**     | Backend administrators managing the system via Django Admin. | - Manage users, roles, and authentication<br>- Add/update/remove products<br>- Configure store locations, inventory, payments, and shipping<br>- Review analytics and reports<br>- Moderate user content and refund claims                                                       | Managed through the **Django backend**, reflected in the mobile app via API:<br>- Users & roles<br>- Product catalog & categories<br>- Orders & refunds<br>- Store locations<br>- Platform configuration                                      |

