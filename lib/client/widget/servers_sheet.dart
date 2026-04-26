import 'package:flutter/material.dart';

import '../../themes/app_colors.dart';

class ServerBottomSheet extends StatefulWidget {
  const ServerBottomSheet({super.key, required this.servers});

  final List<String> servers;

  @override
  State<ServerBottomSheet> createState() => _ServerBottomSheetState();
}

class _ServerBottomSheetState extends State<ServerBottomSheet> {
  late String selectedServer;

  @override
  void initState() {
    super.initState();
    selectedServer = widget.servers.first;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration: BoxDecoration(
        color: colors.locationSheet,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: colors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: colors.textMuted.withOpacity(0.25),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Choose server',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: ListView.separated(
              itemCount: widget.servers.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final server = widget.servers[index];
                final selected = server == selectedServer;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedServer = server;
                      });
                    },
                    borderRadius: BorderRadius.circular(22),
                    child: Ink(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        gradient: selected ? colors.heroGradient : null,
                        color: selected ? null : colors.panelFill,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: selected
                              ? Colors.white.withOpacity(0.24)
                              : colors.stroke,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: selected
                                ? Colors.white.withOpacity(0.14)
                                : colors.softIconFill,
                            child: Text(
                              server.characters.first.toUpperCase(),
                              style: TextStyle(
                                color: selected ? Colors.white : colors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              server,
                              style: TextStyle(
                                color: selected ? Colors.white : colors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(
                            selected
                                ? Icons.check_circle_rounded
                                : Icons.chevron_right_rounded,
                            color: selected ? Colors.white : colors.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
