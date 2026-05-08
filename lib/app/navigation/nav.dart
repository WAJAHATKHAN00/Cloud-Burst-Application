import 'package:flutter/material.dart';

class NavItem {
  final IconData icon;
  final String label;
  const NavItem({required this.icon, required this.label});
}

const navItems = <NavItem>[
  NavItem(icon: Icons.home_rounded, label: 'Home'),
  NavItem(icon: Icons.public_rounded, label: 'Map'),
  NavItem(icon: Icons.warning_amber_rounded, label: 'Alerts'),
  NavItem(icon: Icons.menu_book_rounded, label: 'Report'),
  NavItem(icon: Icons.person_rounded, label: 'Profile'),
];
