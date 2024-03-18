import 'package:flutter/material.dart';

class CustomBottomBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final VoidCallback onAddPressed;

  const CustomBottomBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.onAddPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(5, (index) {
          IconData iconData;
          switch (index) {
            case 0:
              iconData = Icons.dashboard;
              break;
            case 1:
              iconData = Icons.pie_chart;
              break;
            case 2:
              iconData = Icons.add;
              break;
            case 3:
              iconData = Icons.list;
              break;
            case 4:
              iconData = Icons.settings;
              break;
            default:
              iconData = Icons.dashboard;
          }
          return IconButton(
            icon: Icon(iconData),
            onPressed: index == 2 ? onAddPressed : () => onItemSelected(index),
            color: index == 2
                ? Colors.grey
                : (selectedIndex == index ? Colors.blue : Colors.grey),
          );
        }),
      ),
    );
  }
}
