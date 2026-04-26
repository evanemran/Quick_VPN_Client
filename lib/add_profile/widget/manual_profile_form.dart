import 'package:flutter/material.dart';

import '../../themes/app_colors.dart';

class ManualProfileForm extends StatefulWidget {
  const ManualProfileForm({super.key});

  @override
  State<ManualProfileForm> createState() => _ManualProfileFormState();
}

class _ManualProfileFormState extends State<ManualProfileForm> {
  bool obscureText = true;

  String? selectedValue = "IKEv2/IPSec MSCHAPv2";
  String? selectedCertificate = 'Don\'t verify server';
  String? selectedServerCertificate = 'SvcAgentKey';

  final List<String> items = [
    'IKEv2/IPSec MSCHAPv2',
    'IKEv2/IPSec PSK',
    'IKEv2/IPSec RSA',
    'IKEv2/IPSec EAP-TLS'
  ];
  final List<String> certificates = [
    'Don\'t verify server',
    'FMEKeyStore',
    'FindMyMobile',
    'SvcAgentKey'
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      decoration: colors.glassDecoration(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manual setup',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Use this when you want to enter credentials and certificates yourself.',
              style: TextStyle(
                color: colors.textMuted,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            _fieldLabel(context, "Name"),
            TextField(
              controller: TextEditingController(),
              style: TextStyle(color: colors.textPrimary, fontSize: 16),
              decoration: const InputDecoration(hintText: 'Enter profile name'),
            ),
            const SizedBox(height: 16),
            _fieldLabel(context, "Type"),
            DropdownButtonFormField<String>(
              value: selectedValue,
              dropdownColor: colors.surfaceStrong,
              isExpanded: true,
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => selectedValue = val),
            ),
            const SizedBox(height: 16),
            _fieldLabel(context, "Server address"),
            TextField(
              controller: TextEditingController(),
              style: TextStyle(color: colors.textPrimary, fontSize: 16),
              decoration: const InputDecoration(hintText: 'Enter address'),
            ),
            const SizedBox(height: 16),
            _fieldLabel(context, "IPSec Identifier"),
            TextField(
              controller: TextEditingController(),
              style: TextStyle(color: colors.textPrimary, fontSize: 16),
              decoration: const InputDecoration(hintText: 'Not used'),
            ),
            const SizedBox(height: 16),
            _fieldLabel(context, "IPSec CA Certificate"),
            DropdownButtonFormField<String>(
              value: selectedCertificate,
              dropdownColor: colors.surfaceStrong,
              isExpanded: true,
              items: certificates.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => selectedCertificate = val),
            ),
            const SizedBox(height: 16),
            _fieldLabel(context, "IPSec Server Certificate"),
            DropdownButtonFormField<String>(
              value: selectedServerCertificate,
              dropdownColor: colors.surfaceStrong,
              isExpanded: true,
              items: certificates.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) =>
                  setState(() => selectedServerCertificate = val),
            ),
            const SizedBox(height: 16),
            _fieldLabel(context, "Username"),
            TextField(
              controller: TextEditingController(),
              style: TextStyle(color: colors.textPrimary, fontSize: 16),
              decoration: const InputDecoration(hintText: 'Enter username'),
            ),
            const SizedBox(height: 16),
            _fieldLabel(context, "Password"),
            TextField(
              controller: TextEditingController(),
              obscureText: obscureText,
              style: TextStyle(color: colors.textPrimary, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Enter password',
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: colors.textMuted,
                  ),
                  onPressed: () {
                    setState(() {
                      obscureText = !obscureText;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(BuildContext context, String label) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          color: colors.textMuted,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
