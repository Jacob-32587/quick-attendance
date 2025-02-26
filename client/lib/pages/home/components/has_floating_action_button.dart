import 'package:flutter/widgets.dart';

/// Class which forces implementation of a method that builds a Floating Action Button
/// Used because the Scaffold widget is what holds the definition of FAB.
/// Only 1 FAB can exist at any one time, and only some of the home pages need one.
/// Because the pages are nested within the scaffold, they can't have their own scaffold widget.
abstract class HasFloatingActionButton {
  Widget buildFAB();
}
