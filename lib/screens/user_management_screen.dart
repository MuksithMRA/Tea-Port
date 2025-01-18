import 'package:flutter/material.dart';
import '../widgets/admin/user_management_app_bar.dart';
import '../widgets/admin/user_form.dart';
import '../widgets/admin/user_list.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const UserManagementAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF8E1), Color(0xFFFFE0B2)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                // Desktop layout
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: UserForm(onUserAdded: () => setState(() {})),
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: UserList()),
                  ],
                );
              } else {
                // Mobile layout
                return Column(
                  children: [
                    UserForm(onUserAdded: () => setState(() {})),
                    const SizedBox(height: 16),
                    Expanded(child: UserList()),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
