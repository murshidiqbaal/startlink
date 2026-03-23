import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:startlink/features/admin/presentation/bloc/admin_bloc.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AdminBloc(repository: AdminRepositoryImpl())..add(FetchAllUsers()),
      child: Scaffold(
        appBar: AppBar(title: const Text('User Management')),
        body: BlocConsumer<AdminBloc, AdminState>(
          listener: (context, state) {
            if (state is AdminOperationSuccess) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
            if (state is AdminError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          buildWhen: (previous, current) =>
              current is AdminUsersLoaded || current is AdminLoading,
          builder: (context, state) {
            if (state is AdminLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is AdminUsersLoaded) {
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.users.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final user = state.users[index];
                  return ListTile(
                    tileColor: AppColors.surfaceGlass,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    leading: CircleAvatar(
                      backgroundImage: user.profilePhoto != null
                          ? NetworkImage(user.profilePhoto!)
                          : null,
                      child: user.profilePhoto == null
                          ? Text(user.fullName?[0] ?? '?')
                          : null,
                    ),
                    title: Text(
                      user.fullName ?? 'Unknown User',
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      user.id,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'ban',
                          child: Text(
                            'Ban User',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'ban') {
                          context.read<AdminBloc>().add(BanUser(user.id));
                        }
                      },
                    ),
                  );
                },
              );
            }
            return const Center(child: Text('No users found'));
          },
        ),
      ),
    );
  }
}
