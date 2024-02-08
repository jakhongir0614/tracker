import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/theme_provider.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Center(
        child: CupertinoSwitch(
          onChanged: (value) =>
              Provider.of<ThemeProvider>(context,listen: false).toggleMode()
          ,
          value: Provider.of<ThemeProvider>(context).isDarkMode,
        ),
      ),
    );
  }
}
