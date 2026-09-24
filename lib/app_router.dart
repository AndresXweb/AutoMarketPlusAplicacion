import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/register_screen.dart';
import 'features/catalog/presentation/catalog_screen.dart';
import 'features/contact/presentation/contact_screen.dart';
import 'features/favorites/presentation/favorites_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/my_vehicles/presentation/my_vehicles_screen.dart';
import 'features/offers/presentation/offers_screen.dart';
import 'features/profile/presentation/profile_screen.dart';
import 'features/vehicle/presentation/vehicle_detail_screen.dart';
import 'shell_scaffold.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return ShellScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/catalog', builder: (_, __) => const CatalogScreen()),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/vehicle/:id',
      builder: (_, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return VehicleDetailScreen(id: id);
      },
    ),
    GoRoute(path: '/my-vehicles', builder: (_, __) => const MyVehiclesScreen()),
    GoRoute(path: '/favorites', builder: (_, __) => const FavoritesScreen()),
    GoRoute(path: '/offers', builder: (_, __) => const OffersScreen()),
    GoRoute(path: '/contact', builder: (_, __) => const ContactScreen()),
  ],
);
