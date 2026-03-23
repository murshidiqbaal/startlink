import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:startlink/core/theme/app_theme.dart';
import 'package:startlink/features/admin/data/repositories/admin_repository_impl.dart';
import 'package:startlink/features/admin/presentation/bloc/admin_bloc.dart';

class AdminIdeasPage extends StatelessWidget {
  const AdminIdeasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          AdminBloc(repository: AdminRepositoryImpl())..add(FetchAllIdeas()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Idea Management')),
        body: BlocConsumer<AdminBloc, AdminState>(
          listener: (context, state) {
            if (state is AdminOperationSuccess) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          buildWhen: (previous, current) =>
              current is AdminIdeasLoaded || current is AdminLoading,
          builder: (context, state) {
            if (state is AdminLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is AdminIdeasLoaded) {
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.ideas.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final idea = state.ideas[index];
                  return ListTile(
                    tileColor: AppColors.surfaceGlass,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    leading: const Icon(
                      Icons.lightbulb,
                      color: AppColors.brandCyan,
                    ),
                    title: Text(
                      idea.title,
                      style: const TextStyle(color: AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      idea.status,
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.rose),
                      onPressed: () {
                        context.read<AdminBloc>().add(DeleteIdea(idea.id));
                      },
                    ),
                  );
                },
              );
            }
            return const Center(child: Text('No ideas found'));
          },
        ),
      ),
    );
  }
}
