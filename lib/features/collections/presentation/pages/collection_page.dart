import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../api_requests/domain/entities/api_request.dart';
import '../../../api_requests/presentation/bloc/request_bloc.dart';
import '../../../api_requests/presentation/bloc/request_event.dart';
import '../../../api_requests/presentation/bloc/request_state.dart';
import '../../../api_requests/presentation/pages/request_page.dart';
import '../../domain/entities/collection.dart';
import '../bloc/collection_bloc.dart';
import '../bloc/collection_event.dart';
import '../bloc/collection_state.dart';

class CollectionsPage extends StatefulWidget {
  const CollectionsPage({Key? key}) : super(key: key);

  @override
  State<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage> {
  String? selectedCollectionId;
  List<ApiRequest> allRequests = [];

  @override
  void initState() {
    super.initState();
    // Load collections and saved requests
    context.read<CollectionBloc>().add(GetCollectionsEvent());
    context.read<RequestBloc>().add(GetSavedRequestsEvent());
  }

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return Colors.green;
      case 'POST':
        return Colors.blue;
      case 'PUT':
        return Colors.orange;
      case 'PATCH':
        return Colors.purple;
      case 'DELETE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showCreateCollectionDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create Collection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'User Management API',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'All user-related endpoints',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                final collection = Collection(
                  name: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                  createdAt: DateTime.now(),
                );
                context.read<CollectionBloc>().add(
                  CreateCollectionEvent(collection),
                );
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Collection collection) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Collection'),
        content: Text('Delete "${collection.name}"? Requests inside will not be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CollectionBloc>().add(
                DeleteCollectionEvent(collection.id!),
              );
              if (selectedCollectionId == collection.id) {
                setState(() => selectedCollectionId = null);
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddRequestDialog(Collection collection) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocBuilder<RequestBloc, RequestState>(
        builder: (context, state) {
          if (state is! RequestsLoaded) {
            return const AlertDialog(
              content: Center(child: CircularProgressIndicator()),
            );
          }

          // Filter out requests already in this collection
          final availableRequests = state.requests
              .where((req) => !collection.requestIds.contains(req.id))
              .toList();

          return AlertDialog(
            title: const Text('Add Request to Collection'),
            content: SizedBox(
              width: double.maxFinite,
              child: availableRequests.isEmpty
                  ? const Padding(
                padding: EdgeInsets.all(16),
                child: Text('No available requests to add'),
              )
                  : ListView.builder(
                shrinkWrap: true,
                itemCount: availableRequests.length,
                itemBuilder: (context, index) {
                  final request = availableRequests[index];
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getMethodColor(request.method).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        request.method,
                        style: TextStyle(
                          color: _getMethodColor(request.method),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    title: Text(request.name),
                    subtitle: Text(
                      request.url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      context.read<CollectionBloc>().add(
                        AddRequestToCollectionEvent(
                          collectionId: collection.id!,
                          requestId: request.id!,
                        ),
                      );
                      Navigator.pop(dialogContext);
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  List<ApiRequest> _getRequestsForCollection(Collection collection) {
    return allRequests
        .where((req) => collection.requestIds.contains(req.id))
        .toList();
  }

  void _openRequest(ApiRequest request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<RequestBloc>()),
            BlocProvider.value(value: context.read<CollectionBloc>()),
          ],
          child: RequestPage(initialRequest: request),
        ),
      ),
    );
  }

  void _removeRequestFromCollection(Collection collection, String requestId) {
    context.read<CollectionBloc>().add(
      RemoveRequestFromCollectionEvent(
        collectionId: collection.id!,
        requestId: requestId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Collections'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<CollectionBloc>().add(GetCollectionsEvent());
              context.read<RequestBloc>().add(GetSavedRequestsEvent());
            },
          ),
        ],
      ),
      body: BlocConsumer<RequestBloc, RequestState>(
        listener: (context, state) {
          if (state is RequestsLoaded) {
            setState(() {
              allRequests = state.requests;
            });
          }
        },
        builder: (context, requestState) {
          return BlocConsumer<CollectionBloc, CollectionState>(
            listener: (context, state) {
              if (state is CollectionError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }

              if (state is CollectionCreated || state is CollectionDeleted) {
                final message = state is CollectionCreated
                    ? state.message
                    : (state as CollectionDeleted).message;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message)),
                );
              }
            },
            builder: (context, state) {
              if (state is CollectionLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is CollectionsLoaded) {
                if (state.collections.isEmpty) {
                  return _buildEmptyState();
                }

                // Auto-select first collection if none selected
                if (selectedCollectionId == null && state.collections.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    setState(() {
                      selectedCollectionId = state.collections.first.id;
                    });
                  });
                }

                Collection selectedCollection;
                if (selectedCollectionId != null) {
                  try {
                    selectedCollection = state.collections.firstWhere(
                          (c) => c.id == selectedCollectionId,
                    );
                  } catch (e) {
                    // If not found, default to first collection
                    selectedCollection = state.collections.first;
                  }
                } else {
                  selectedCollection = state.collections.first;
                }

                return _buildCollectionsView(state.collections, selectedCollection);
              }

              return _buildEmptyState();
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateCollectionDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Collection'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No collections yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create collections to organize your requests',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showCreateCollectionDialog,
            icon: const Icon(Icons.add),
            label: const Text('Create Collection'),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionsView(List<Collection> collections, Collection selectedCollection) {
    final requests = _getRequestsForCollection(selectedCollection);

    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Collection tabs
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: collections.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final collection = collections[index];
                final isSelected = selectedCollectionId == collection.id;

                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedCollectionId = collection.id;
                    });
                  },
                  onLongPress: () => _showDeleteConfirmation(collection),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.folder,
                          size: 18,
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          collection.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.2)
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${collection.requestIds.length}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Collection header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedCollection.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (selectedCollection.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        selectedCollection.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _showAddRequestDialog(selectedCollection),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Request'),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _showDeleteConfirmation(selectedCollection),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Delete Collection',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Requests list
          Expanded(
            child: requests.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No requests in this collection',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showAddRequestDialog(selectedCollection),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Request'),
                  ),
                ],
              ),
            )
                : ListView.separated(
              itemCount: requests.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final request = requests[index];
                return _buildRequestCard(selectedCollection, request);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(Collection collection, ApiRequest request) {
    return Dismissible(
      key: Key('${collection.id}_${request.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.remove_circle_outline, color: Colors.white, size: 32),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Remove from Collection'),
            content: Text('Remove "${request.name}" from this collection?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Remove'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        _removeRequestFromCollection(collection, request.id!);
      },
      child: InkWell(
        onTap: () => _openRequest(request),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getMethodColor(request.method).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    request.method,
                    style: TextStyle(
                      color: _getMethodColor(request.method),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        request.url,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}