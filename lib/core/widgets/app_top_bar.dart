import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_archive/core/theme/app_colors.dart';
import 'package:movie_archive/core/widgets/menu_row.dart';
import 'package:movie_archive/data/services/services.dart';

// Barra superior azul. En pantallas principales muestra el icono menu con el
// menú (Catálogo, Archivo, Cerrar sesión); en pantallas internas, la flecha de regresar.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    this.title = 'Movie Archive',
    this.showBack = false,
  });

  final String title;
  final bool showBack;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 64,
      backgroundColor: AppColors.navy,
      foregroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: showBack
          ? IconButton(
              tooltip: 'Regresar',
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/catalog');
                }
              },
            )
          : const _MainMenu(),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _MainMenu extends StatelessWidget {
  const _MainMenu();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Menú',
      icon: const Icon(Icons.menu, color: Colors.white),
      offset: const Offset(0, 48),
      onSelected: (value) {
        switch (value) {
          case 'catalog':
            context.go('/catalog');
          case 'archive':
            context.go('/archive');
          case 'logout':
            authService.signOut();
        }
      },
      itemBuilder: (context) => const <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'catalog',
          child: MenuRow(icon: Icons.movie_outlined, label: 'Catálogo'),
        ),
        PopupMenuItem<String>(
          value: 'archive',
          child: MenuRow(icon: Icons.folder_outlined, label: 'Archivo'),
        ),
        PopupMenuDivider(),
        PopupMenuItem<String>(
          value: 'logout',
          child: MenuRow(icon: Icons.logout, label: 'Cerrar sesión'),
        ),
      ],
    );
  }
}
