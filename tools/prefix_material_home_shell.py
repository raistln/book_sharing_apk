from pathlib import Path
import re

path = Path(r'd:\IAs\book_sharing_app_apk\lib\ui\screens\home\home_shell.dart')
text = path.read_text(encoding='utf-8')

words = [
    'Widget', 'BuildContext', 'Theme', 'ThemeData', 'ThemeMode', 'TextTheme', 'Navigator',
    'SafeArea', 'Padding', 'Column', 'Row', 'Expanded', 'Flexible', 'Center', 'Container',
    'SizedBox', 'AspectRatio', 'DecoratedBox', 'BoxDecoration', 'BorderRadius', 'BorderSide',
    'BoxShadow', 'Colors', 'ClipRRect', 'ClipPath', 'Text', 'TextAlign', 'TextButton',
    'FilledButton', 'OutlinedButton', 'ElevatedButton', 'Wrap', 'Alignment', 'Align',
    'IconButton', 'Icon', 'Icons', 'Divider', 'ListView', 'ListTile', 'CheckboxListTile',
    'SwitchListTile', 'Slider', 'AlertDialog', 'Card', 'ScaffoldMessenger', 'SnackBar',
    'CircularProgressIndicator', 'LinearProgressIndicator', 'Checkbox', 'Switch', 'Radio',
    'TextField', 'TextFormField', 'TextEditingController', 'InputDecoration',
    'OutlineInputBorder', 'FilledButton', 'OutlinedButton', 'Material', 'AnimatedSwitcher',
    'DraggableScrollableSheet', 'ValueListenableBuilder', 'RichText', 'TextSpan',
    'GestureDetector', 'InkWell', 'Tooltip', 'Chip', 'ChoiceChip', 'FilterChip', 'FloatingActionButton',
    'TabBar', 'Tab', 'TabBarView', 'TabController', 'EdgeInsets', 'Positioned', 'SliverList',
    'SliverToBoxAdapter', 'SliverFillRemaining', 'SliverPadding', 'ScrollController', 'Scrollbar',
    'SingleChildScrollView', 'ListBody', 'DropdownButton', 'DropdownMenuItem', 'PopupMenuButton',
    'PopupMenuItem', 'Spacer', 'Hero', 'Image', 'FadeInImage', 'CircleAvatar', 'Stack', 'FittedBox',
    'InkResponse', 'CupertinoActivityIndicator', 'CupertinoButton', 'CupertinoDialogAction',
    'CupertinoAlertDialog', 'CupertinoSlidingSegmentedControl', 'CupertinoSwitch', 'Positioned',
    'AnimatedContainer', 'AnimatedOpacity', 'AnimatedPositioned', 'AnimatedAlign', 'AnimatedPadding',
    'AnimatedCrossFade', 'AnimatedDefaultTextStyle', 'SliverAppBar', 'SliverOverlapInjector',
    'SliverOverlapAbsorber', 'SliverPersistentHeader', 'SliverSafeArea', 'SliverGrid', 'SliverPadding',
    'Theme', 'ThemeData', 'ThemeMode', 'ColorScheme', 'Color', 'TextOverflow', 'TextStyle',
    'ButtonStyle', 'ButtonStyleButton', 'OutlinedBorder', 'UnderlineInputBorder', 'FocusScope',
    'FocusScopeNode', 'RadioListTile', 'CheckboxListTile', 'SliderTheme', 'SliderThemeData',
    'ToggleButtons', 'ButtonBar', 'ButtonBarTheme', 'ListWheelScrollView', 'ReorderableListView',
    'NotificationListener', 'DraggableScrollableSheet', 'RepaintBoundary', 'Opacity', 'Baseline',
    'WrapAlignment', 'MainAxisAlignment', 'CrossAxisAlignment', 'MainAxisSize', 'TextBaseline',
    'ToolbarOptions', 'DefaultTextStyle', 'GridView', 'GridTile', 'GridTileBar', 'GridView',
    'LinearGradient', 'SweepGradient', 'RadialGradient', 'Gradient', 'ShaderMask', 'DecoratedBoxTransition',
    'PositionedTransition', 'ScaleTransition', 'SizeTransition', 'SlideTransition', 'RotationTransition',
    'FadeTransition', 'Hero', 'NotificationListener', 'PreferredSize', 'PreferredSizeWidget',
    'TabPageSelector', 'TabBarIndicatorSize', 'TextSelectionThemeData', 'TextSelectionTheme',
    'CupertinoTheme', 'CupertinoThemeData', 'CupertinoPageScaffold', 'CupertinoButton',
    'CupertinoTextField', 'CupertinoNavigationBar', 'CupertinoActionSheet',
    'CupertinoActionSheetAction', 'CupertinoPopoverMenu', 'CupertinoListTile', 'CupertinoPicker',
    'CupertinoSlider', 'CupertinoSegmentedControl', 'CupertinoTabBar', 'CupertinoTabView',
    'CupertinoPageRoute', 'CupertinoDialogAction', 'CupertinoDialog', 'CupertinoTimerPicker',
    'StatelessWidget', 'StatefulWidget', 'State', 'NavigationBar', 'NavigationDestination',
    'NavigationRail', 'NavigationRailDestination', 'NavigationDrawer', 'showModalBottomSheet',
    'WidgetsBinding', 'AppBar', 'WrapCrossAlignment', 'MainAxisAlignment', 'CrossAxisAlignment',
    'MainAxisSize'
]

# Deduplicate while preserving order
seen = set()
filtered_words = []
for word in words:
    if word not in seen:
        filtered_words.append(word)
        seen.add(word)

for word in filtered_words:
    pattern = rf'(?<!material\.)\b{word}\b'
    text = re.sub(pattern, f'material.{word}', text)

path.write_text(text, encoding='utf-8')
