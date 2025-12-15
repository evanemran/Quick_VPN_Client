import 'package:flutter/material.dart';

import '../../themes/app_colors.dart';

class ServerBottomSheet extends StatefulWidget {
  final List<String> servers;

  const ServerBottomSheet({super.key, required this.servers});

  @override
  State<ServerBottomSheet> createState() => _ServerBottomSheetState();
}

class _ServerBottomSheetState extends State<ServerBottomSheet> {
  late String selectedServer;
  bool expanded = false;

  @override
  void initState() {
    super.initState();
    selectedServer = widget.servers.first;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      height: expanded ? 300 : 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => setState(() => expanded = !expanded),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$selectedServer',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Icon(expanded ? Icons.expand_more : Icons.expand_less, color: Colors.white,),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (expanded)
            Expanded(
              child: ListView.builder(
                itemCount: widget.servers.length,
                itemBuilder: (context, index) {
                  final server = widget.servers[index];
                  return ListTile(
                    title: Text('$server', style: TextStyle(color: Colors.white),),
                    onTap: () {
                      setState(() {
                        selectedServer = server;
                        expanded = false;
                      });
                    },
                    selected: server == selectedServer,
                    selectedTileColor: Colors.grey.shade200,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
