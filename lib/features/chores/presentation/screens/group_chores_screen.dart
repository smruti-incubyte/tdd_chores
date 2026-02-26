import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:tdd_chores/core/enums/enums.dart';
import 'package:tdd_chores/features/chores/domain/entities/group_chore.dart';
import 'package:tdd_chores/features/chores/presentation/bloc/chores_bloc.dart';
import 'package:tdd_chores/features/chores/presentation/bloc/chores_events.dart';
import 'package:tdd_chores/features/chores/presentation/bloc/chores_states.dart';
import 'package:uuid/uuid.dart';

class GroupChoresScreen extends StatefulWidget {
  final String? id;
  final DateTime initialDateTime;
  final List<GroupChoreItem>? existingChores;

  const GroupChoresScreen({
    super.key,
    this.id,
    required this.initialDateTime,
    this.existingChores,
  });

  @override
  State<GroupChoresScreen> createState() => _GroupChoresScreenState();
}

class _GroupChoresScreenState extends State<GroupChoresScreen> {
  late List<GroupChoreItem> _chores;

  @override
  void initState() {
    super.initState();
    _chores = widget.existingChores != null
        ? List.from(widget.existingChores!)
        : [];
  }

  void _addChoreToGroup() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const AddChoreToGroupDialog(),
    );

    if (result != null && result.trim().isNotEmpty && mounted) {
      _chores.add(
        GroupChoreItem(
          name: result.trim(),
          status: ChoreStatus.todo,
          id: Uuid().v4(),
        ),
      );
      if (widget.id != null) {
        context.read<ChoresBloc>().add(
          UpdateGroupChoresEvent(
            groupChore: GroupChoreEntity(
              id: widget.id ?? '1',
              dateTime: widget.initialDateTime,
              chores: _chores,
            ),
          ),
        );
      } else {
        context.read<ChoresBloc>().add(
          AddGroupChoresEvent(
            groupChore: GroupChoreEntity(
              id: widget.id ?? '1',
              dateTime: widget.initialDateTime,
              chores: _chores,
            ),
          ),
        );
      }
      Navigator.of(context).pop();
    }
  }

  void _saveAndReturn() {
    Navigator.of(context).pop();
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('d MMM \'at\' h:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 32),
          onPressed: _saveAndReturn,
        ),
        title: const Text('Group Chores'),
      ),
      body: BlocBuilder<ChoresBloc, ChoresState>(
        builder: (context, state) {
          if (state is ChoresLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ChoresError) {
            return Center(child: Text(state.message));
          }
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDateTime(widget.initialDateTime),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _chores.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.playlist_add,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No chores in this group',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the + button to add chores',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _chores.length,
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) {
                              newIndex -= 1;
                            }
                            final item = _chores.removeAt(oldIndex);
                            _chores.insert(newIndex, item);
                          });
                        },
                        itemBuilder: (context, index) {
                          final choreItem = _chores[index];
                          return Card(
                            key: ValueKey(choreItem.name + index.toString()),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.drag_handle,
                                    color: Colors.grey[400],
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  CircleAvatar(
                                    backgroundColor:
                                        choreItem.status == ChoreStatus.done
                                        ? Colors.green[100]
                                        : Theme.of(
                                            context,
                                          ).colorScheme.tertiaryContainer,
                                    child: Icon(
                                      choreItem.status == ChoreStatus.done
                                          ? Icons.check_circle
                                          : Icons.check_circle_outline,
                                      color:
                                          choreItem.status == ChoreStatus.done
                                          ? Colors.green[700]
                                          : Theme.of(
                                              context,
                                            ).colorScheme.onTertiaryContainer,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      choreItem.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        decoration:
                                            choreItem.status == ChoreStatus.done
                                            ? TextDecoration.lineThrough
                                            : null,
                                        color:
                                            choreItem.status == ChoreStatus.done
                                            ? Colors.grey[600]
                                            : null,
                                      ),
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
                                          choreItem.status == ChoreStatus.done
                                          ? Colors.green[50]
                                          : Colors.orange[50],
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color:
                                            choreItem.status == ChoreStatus.done
                                            ? Colors.green[200]!
                                            : Colors.orange[200]!,
                                        width: 1,
                                      ),
                                    ),
                                    child: DropdownButton<ChoreStatus>(
                                      value: choreItem.status,
                                      underline: const SizedBox(),
                                      isDense: true,
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        size: 20,
                                        color:
                                            choreItem.status == ChoreStatus.done
                                            ? Colors.green[700]
                                            : Colors.orange[700],
                                      ),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color:
                                            choreItem.status == ChoreStatus.done
                                            ? Colors.green[700]
                                            : Colors.orange[700],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
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
                                        if (newStatus != null &&
                                            widget.id != null) {
                                          _chores[index] = _chores[index]
                                              .copyWith(status: newStatus);
                                          context.read<ChoresBloc>().add(
                                            UpdateGroupChoresEvent(
                                              groupChore: GroupChoreEntity(
                                                id: widget.id!,
                                                dateTime:
                                                    widget.initialDateTime,
                                                chores: _chores,
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () {
                                      setState(() {
                                        _chores.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addChoreToGroup,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddChoreToGroupDialog extends StatefulWidget {
  const AddChoreToGroupDialog({super.key});

  @override
  State<AddChoreToGroupDialog> createState() => _AddChoreToGroupDialogState();
}

class _AddChoreToGroupDialogState extends State<AddChoreToGroupDialog> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Chore'),
      content: TextField(
        controller: _nameController,
        decoration: const InputDecoration(
          labelText: 'Chore Name',
          border: OutlineInputBorder(),
        ),
        autofocus: true,
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            Navigator.of(context).pop(value.trim());
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_nameController.text.trim().isNotEmpty) {
              Navigator.of(context).pop(_nameController.text.trim());
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
