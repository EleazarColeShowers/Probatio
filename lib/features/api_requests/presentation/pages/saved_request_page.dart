import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/api_request.dart';
import '../bloc/request_bloc.dart';
import '../bloc/request_event.dart';
import '../bloc/request_state.dart';
import 'request_page.dart'; // Your main request page

class SavedPage extends StatefulWidget {
  const SavedPage({Key? key}) : super(key: key);

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  @override
  void initState() {
    super.initState();
    // Load saved requests when page opens
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

  String _formatTimestamp(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _showDeleteConfirmation(BuildContext context, ApiRequest request) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Request'),
        content: Text('Are you sure you want to delete "${request.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<RequestBloc>().add(
                DeleteRequestEvent(request.id!),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _loadRequestInEditor(BuildContext context, ApiRequest request) {
    // Navigate to request page with pre-filled data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<RequestBloc>(),
          child: RequestPage(initialRequest: request),
        ),
      ),
    );
  }

  void _showRequestOptions(BuildContext context, ApiRequest request) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Edit Request'),
              onTap: () {
                Navigator.pop(sheetContext);
                _loadRequestInEditor(context, request);
              },
            ),
            ListTile(
              leading: const Icon(Icons.send, color: Colors.green),
              title: const Text('Send Now'),
              onTap: () {
                Navigator.pop(sheetContext);
                context.read<RequestBloc>().add(SendRequestEvent(request));
                _showSendingSnackbar(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy, color: Colors.orange),
              title: const Text('Duplicate'),
              onTap: () {
                Navigator.pop(sheetContext);
                final duplicate = ApiRequest(
                  name: '${request.name} (Copy)',
                  url: request.url,
                  method: request.method,
                  headers: request.headers != null
                      ? Map<String, String>.from(request.headers!)
                      : {},
                  body: request.body,
                  createdAt: DateTime.now(),
                );
                context.read<RequestBloc>().add(SaveRequestEvent(duplicate));
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(sheetContext);
                _showDeleteConfirmation(context, request);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showSendingSnackbar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sending request...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<RequestBloc>().add(GetSavedRequestsEvent());
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: BlocConsumer<RequestBloc, RequestState>(
        listener: (context, state) {
          if (state is RequestError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }

          if (state is RequestDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }

          if (state is RequestSaved) {
            // Reload the list after saving
            context.read<RequestBloc>().add(GetSavedRequestsEvent());
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          }

          if (state is RequestSent) {
            // Show response in a dialog or navigate to response viewer
            _showResponseDialog(context, state.response);
          }
        },
        builder: (context, state) {
          // Loading state
          if (state is RequestLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Empty state
          if (state is RequestsLoaded && state.requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No saved requests yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create and save your first API request',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<RequestBloc>(),
                            child: const RequestPage(),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create Request'),
                  ),
                ],
              ),
            );
          }

          // Loaded state with data
          if (state is RequestsLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<RequestBloc>().add(GetSavedRequestsEvent());
                // Wait a bit for the state to update
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                color: Colors.white,
                child: ListView.separated(
                  itemCount: state.requests.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final request = state.requests[index];
                    return _buildRequestCard(context, request);
                  },
                ),
              ),
            );
          }

          // Default/error fallback
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('Something went wrong'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<RequestBloc>().add(GetSavedRequestsEvent());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<RequestBloc>(),
                child: const RequestPage(),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, ApiRequest request) {
    return Dismissible(
      key: Key(request.id ?? request.url),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 32,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Delete Request'),
            content: Text('Delete "${request.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        context.read<RequestBloc>().add(DeleteRequestEvent(request.id!));
      },
      child: InkWell(
        onTap: () => _loadRequestInEditor(context, request),
        onLongPress: () => _showRequestOptions(context, request),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Method Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
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
                          fontSize: 13,
                        ),
                      ),
                    ),
                    // More Options Button
                    IconButton(
                      icon: const Icon(Icons.more_vert, size: 20),
                      onPressed: () => _showRequestOptions(context, request),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Request Name
                Text(
                  request.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                // URL
                Text(
                  request.url,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Footer with timestamp and badges
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      _formatTimestamp(request.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if ((request.headers?.isNotEmpty ?? false)) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.article, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${request.headers!.length} headers',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    if (request.body != null && request.body!.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.description, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'Has body',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showResponseDialog(BuildContext context, response) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(
              response.isSuccess ? Icons.check_circle : Icons.error,
              color: response.isSuccess ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text('Status: ${response.statusCode}'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Time: ${response.durationMs}ms'),
              const Divider(height: 24),
              const Text(
                'Response Body:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.grey[100],
                child: Text(
                  response.body.length > 500
                      ? '${response.body.substring(0, 500)}...'
                      : response.body,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// ============================================
// FEATURES ADDED:
// ============================================
// ✓ Loads real data from BLoC on page open
// ✓ Pull-to-refresh to reload requests
// ✓ Tap to edit request (opens in editor)
// ✓ Long press for options menu
// ✓ Swipe-to-delete with confirmation
// ✓ Send request directly from saved list
// ✓ Duplicate requests
// ✓ Empty state with "Create Request" button
// ✓ Loading indicator
// ✓ Error handling with retry
// ✓ Real timestamp formatting
// ✓ Response dialog when sending
// ✓ Floating action button to create new request
// ✓ Shows request metadata (headers, body)
// ============================================