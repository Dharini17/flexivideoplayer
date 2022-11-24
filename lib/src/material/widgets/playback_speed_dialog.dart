import 'package:flutter/material.dart';

class PlaybackSpeedDialog extends StatelessWidget {
  const PlaybackSpeedDialog({
    Key? key,
    required List<double> speeds,
    required double selected,
  })  : _speeds = speeds,
        _selected = selected,
        super(key: key);

  final List<double> _speeds;
  final double _selected;

  @override
  Widget build(BuildContext context) {
    final Color selectedColor = Colors.black87;//Theme.of(context).primaryColor;

    return ListView.builder(
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      itemBuilder: (context, index) {
        final speed = _speeds[index];
        return ListTile(
          dense: true,
          title: Row(
            children: [

                Icon(
                  Icons.check,
                  size: 20.0,
                  color: speed == _selected ? selectedColor : Colors.transparent,
                ),

              const SizedBox(width: 16.0),
              Text(speed.toString(),),
            ],
          ),
          selected: speed == _selected,
          onTap: () {
            Navigator.of(context).pop(speed);
          },
        );
      },
      itemCount: _speeds.length,
    );
  }
}
