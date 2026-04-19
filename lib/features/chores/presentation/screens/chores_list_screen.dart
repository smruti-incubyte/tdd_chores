import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tdd_chores/core/enums/enums.dart';
import 'package:tdd_chores/core/services/auth_service.dart';
import 'package:tdd_chores/core/utils/date_time_formatter.dart';
import 'package:tdd_chores/features/chores/domain/entities/group_chore.dart';
import 'package:tdd_chores/features/chores/domain/entities/single_chore.dart';
import 'package:tdd_chores/features/chores/presentation/bloc/chores_bloc.dart';
import 'package:tdd_chores/features/chores/presentation/bloc/chores_events.dart';
import 'package:tdd_chores/features/chores/presentation/bloc/chores_states.dart';
import 'package:tdd_chores/features/chores/presentation/screens/add_chore_screen.dart';
import 'package:tdd_chores/features/chores/presentation/screens/add_chore_photo_screen.dart';
import 'package:tdd_chores/features/chores/presentation/screens/create_group_screen.dart';
import 'package:tdd_chores/features/chores/presentation/screens/group_chores_screen.dart';
import 'package:tdd_chores/features/chores/presentation/widgets/empty_chores.dart';

class ChoresListScreen extends StatefulWidget {
  const ChoresListScreen({super.key});

  @override
  State<ChoresListScreen> createState() => _ChoresListScreenState();
}

class _ChoresListScreenState extends State<ChoresListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<ChoresBloc>().add(GetGroupChoresEvent());
    context.read<ChoresBloc>().add(GetSingleChoresEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addChore() async {
    print('addChore-${_tabController.index}');
    await Navigator.push<SingleChoreEntity>(
      context,
      MaterialPageRoute(builder: (context) => const AddChoreScreen()),
    );
  }

  void _addChoreGroup() async {
    print('addChoreGroup-${_tabController.index}');
    final result = await Navigator.push<DateTime>(
      context,
      MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
    );

    if (result != null) {
      await Navigator.push<GroupChoreEntity>(
        context,
        MaterialPageRoute(
          builder: (context) => GroupChoresScreen(initialDateTime: result),
        ),
      );
    }
  }

  void _editChoreGroup(GroupChoreEntity group) async {
    print('editChoreGroup-${group.chores}');
    await Navigator.push<GroupChoreEntity>(
      context,
      MaterialPageRoute(
        builder: (context) => GroupChoresScreen(
          id: group.id,
          initialDateTime: group.dateTime,
          existingChores: group.chores,
        ),
      ),
    );
  }

  Future<void> _openSingleChorePhotoFlow(SingleChoreEntity chore) async {
    if (chore.photoUrl == null) {
      await Navigator.push<SingleChoreEntity>(
        context,
        MaterialPageRoute(
          builder: (context) => AddChorePhotoScreen(chore: chore),
        ),
      );
      return;
    }

    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => _ChorePhotoViewerScreen(chore: chore),
      ),
    );
  }

  Future<void> _handleSignOut() async {
    try {
      await _authService.signOut();
      // Navigation will be handled by the auth state listener in main.dart
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _refreshChores() async {
    context.read<ChoresBloc>().add(GetGroupChoresEvent());
    context.read<ChoresBloc>().add(GetSingleChoresEvent());
    // Add a small delay to ensure the events are processed
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Widget _buildSingleChoreThumbnail(SingleChoreEntity chore) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget placeholder() {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_outlined,
              size: 22,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              'No photo',
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (chore.photoUrl == null) {
      return placeholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 64,
        height: 64,
        child: Image.network(
          chore.photoUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => placeholder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: _handleSignOut,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Single'),
            Tab(text: 'Group'),
          ],
        ),
      ),
      body: BlocBuilder<ChoresBloc, ChoresState>(
        builder: (context, state) {
          if (state is ChoresLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ChoresError) {
            return Center(child: Text(state.message));
          }
          if (state is ChoresLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                // Single Chores Tab
                RefreshIndicator(
                  onRefresh: _refreshChores,
                  child: state.singleChores.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 200),
                            EmptyChoresWidget(
                              title: 'No single chores yet',
                              subtitle:
                                  'Tap the + button to add a single chore',
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: state.singleChores.length,
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (context, index) {
                            final chore = state.singleChores[index];
                            final hasPhoto = chore.photoUrl != null;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () => _openSingleChorePhotoFlow(chore),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      _buildSingleChoreThumbnail(chore),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              chore.name,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                decoration:
                                                    chore.status ==
                                                        ChoreStatus.done
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                                color:
                                                    chore.status ==
                                                        ChoreStatus.done
                                                    ? Colors.grey[600]
                                                    : null,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              DateTimeFormatter.formatDateTime(
                                                chore.dateTime,
                                              ),
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              hasPhoto
                                                  ? 'Tap to view photo'
                                                  : 'Tap to add photo',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              chore.status == ChoreStatus.done
                                              ? Colors.green[50]
                                              : Colors.orange[50],
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color:
                                                chore.status == ChoreStatus.done
                                                ? Colors.green[200]!
                                                : Colors.orange[200]!,
                                            width: 1,
                                          ),
                                        ),
                                        child: DropdownButton<ChoreStatus>(
                                          value: chore.status,
                                          underline: const SizedBox(),
                                          isDense: true,
                                          icon: Icon(
                                            Icons.arrow_drop_down,
                                            size: 20,
                                            color:
                                                chore.status == ChoreStatus.done
                                                ? Colors.green[700]
                                                : Colors.orange[700],
                                          ),
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color:
                                                chore.status == ChoreStatus.done
                                                ? Colors.green[700]
                                                : Colors.orange[700],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          items: const [
                                            DropdownMenuItem(
                                              value: ChoreStatus.todo,
                                              child: Text('Todo'),
                                            ),
                                            DropdownMenuItem(
                                              value: ChoreStatus.done,
                                              child: Text('Done'),
                                            ),
                                          ],
                                          onChanged: (ChoreStatus? newStatus) {
                                            if (newStatus != null) {
                                              final updatedChore =
                                                  SingleChoreEntity(
                                                    createdBy: chore.createdBy,
                                                    id: chore.id,
                                                    name: chore.name,
                                                    dateTime: chore.dateTime,
                                                    status: newStatus,
                                                    photoUrl: chore.photoUrl,
                                                  );
                                              context.read<ChoresBloc>().add(
                                                UpdateSingleChoresEvent(
                                                  chore: updatedChore,
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () {
                                          context.read<ChoresBloc>().add(
                                            DeleteSingleChoresEvent(
                                              chore: chore,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                // Group Chores Tab
                RefreshIndicator(
                  onRefresh: _refreshChores,
                  child: state.groupChores.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 200),
                            EmptyChoresWidget(
                              title: 'No group chores yet',
                              subtitle: 'Tap the + button to create a group',
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: state.groupChores.length,
                          padding: const EdgeInsets.all(16),
                          itemBuilder: (context, index) {
                            final group = state.groupChores[index];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () {
                                  print("editingggggggg...");
                                  _editChoreGroup(group);
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor:
                                                group.chores.any(
                                                  (chore) =>
                                                      chore.status !=
                                                      ChoreStatus.done,
                                                )
                                                ? Theme.of(context)
                                                      .colorScheme
                                                      .secondaryContainer
                                                : Colors.green[100],
                                            child: Icon(
                                              group.chores.any(
                                                    (chore) =>
                                                        chore.status !=
                                                        ChoreStatus.done,
                                                  )
                                                  ? Icons.group_work_outlined
                                                  : Icons.check_circle,
                                              color:
                                                  group.chores.any(
                                                    (chore) =>
                                                        chore.status !=
                                                        ChoreStatus.done,
                                                  )
                                                  ? Theme.of(
                                                      context,
                                                    ).colorScheme.secondary
                                                  : Colors.green[700],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      DateTimeFormatter.formatDateTime(
                                                        group.dateTime,
                                                      ),
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey[600],
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${group.chores.length} chore${group.chores.length != 1 ? 's' : ''}',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[500],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete_outline,
                                            ),
                                            onPressed: () {
                                              context.read<ChoresBloc>().add(
                                                DeleteGroupChoresEvent(
                                                  groupChore: group,
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      if (group.chores.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        const Divider(),
                                        const SizedBox(height: 8),
                                        ...group.chores.map((choreItem) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 8,
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  choreItem.status ==
                                                          ChoreStatus.done
                                                      ? Icons.check_circle
                                                      : Icons
                                                            .check_circle_outline,
                                                  size: 20,
                                                  color:
                                                      choreItem.status ==
                                                          ChoreStatus.done
                                                      ? Colors.green[700]
                                                      : Colors.grey[600],
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    choreItem.name,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      decoration:
                                                          choreItem.status ==
                                                              ChoreStatus.done
                                                          ? TextDecoration
                                                                .lineThrough
                                                          : null,
                                                      color:
                                                          choreItem.status ==
                                                              ChoreStatus.done
                                                          ? Colors.grey[600]
                                                          : Colors.grey[800],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        choreItem.status ==
                                                            ChoreStatus.done
                                                        ? Colors.green[50]
                                                        : Colors.orange[50],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                    border: Border.all(
                                                      color:
                                                          choreItem.status ==
                                                              ChoreStatus.done
                                                          ? Colors.green[200]!
                                                          : Colors.orange[200]!,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Text(
                                                    choreItem.status ==
                                                            ChoreStatus.done
                                                        ? 'Done'
                                                        : 'Todo',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          choreItem.status ==
                                                              ChoreStatus.done
                                                          ? Colors.green[700]
                                                          : Colors.orange[700],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _addChore();
          } else {
            _addChoreGroup();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _ChorePhotoViewerScreen extends StatelessWidget {
  final SingleChoreEntity chore;

  const _ChorePhotoViewerScreen({required this.chore});

  @override
  Widget build(BuildContext context) {
    final photoUrl = chore.photoUrl;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(chore.name),
      ),
      body: photoUrl == null
          ? const Center(
              child: Text(
                'No photo available',
                style: TextStyle(color: Colors.white),
              ),
            )
          : InteractiveViewer(
              minScale: 0.8,
              maxScale: 4,
              child: Center(
                child: Image.network(
                  photoUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }

                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (_, _, _) => const Center(
                    child: Text(
                      'Unable to load photo',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
