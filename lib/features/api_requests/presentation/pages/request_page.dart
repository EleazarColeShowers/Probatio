import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/api_request.dart';
import '../bloc/request_bloc.dart';
import '../bloc/request_event.dart';
import '../bloc/request_state.dart';

class RequestPage extends StatefulWidget {
  final ApiRequest? initialRequest;

  const RequestPage({
    Key? key,
    this.initialRequest,
  }) : super(key: key);

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _urlController;
  late TextEditingController _bodyController;
  late String _selectedMethod;
  Map<String, String> _headers = {};

  bool get _isEditing => widget.initialRequest != null;

  @override
  void initState() {
    super.initState();

    if (_isEditing) {
      _nameController = TextEditingController(text: widget.initialRequest!.name);
      _urlController = TextEditingController(text: widget.initialRequest!.url);
      _bodyController = TextEditingController(text: widget.initialRequest!.body ?? '');
      _selectedMethod = widget.initialRequest!.method;
      _headers = Map<String, String>.from(widget.initialRequest!.headers ?? {});
    } else {
      _nameController = TextEditingController();
      _urlController = TextEditingController();
      _bodyController = TextEditingController();
      _selectedMethod = 'GET';
      _headers = {};
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _sendRequest() {
    if (!_formKey.currentState!.validate()) return;

    final request = ApiRequest(
      id: widget.initialRequest?.id,
      name: _nameController.text.trim(),
      url: _urlController.text.trim(),
      method: _selectedMethod,
      headers: _headers,
      body: _bodyController.text.trim().isEmpty
          ? null
          : _bodyController.text.trim(),
      createdAt: widget.initialRequest?.createdAt ?? DateTime.now(),
    );

    context.read<RequestBloc>().add(SendRequestEvent(request));
  }

  void _saveRequest() {
    if (!_formKey.currentState!.validate()) return;

    final request = ApiRequest(
      id: widget.initialRequest?.id,
      name: _nameController.text.trim(),
      url: _urlController.text.trim(),
      method: _selectedMethod,
      headers: _headers,
      body: _bodyController.text.trim().isEmpty
          ? null
          : _bodyController.text.trim(),
      createdAt: widget.initialRequest?.createdAt ?? DateTime.now(),
    );

    context.read<RequestBloc>().add(SaveRequestEvent(request));
  }

  void _addHeader() {
    final keyController = TextEditingController();
    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Header'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keyController,
              decoration: const InputDecoration(
                labelText: 'Key',
                hintText: 'Content-Type',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(
                labelText: 'Value',
                hintText: 'application/json',
              ),
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
              if (keyController.text.trim().isNotEmpty) {
                setState(() {
                  _headers[keyController.text.trim()] =
                      valueController.text.trim();
                });
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Request' : 'New Request'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveRequest,
            tooltip: 'Save Request',
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

          if (state is RequestSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            // Optionally navigate back after saving
            // Navigator.pop(context);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Request Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Request Name',
                      hintText: 'Get Users',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.label),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Method Selector
                  DropdownButtonFormField<String>(
                    value: _selectedMethod,
                    decoration: const InputDecoration(
                      labelText: 'Method',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.http),
                    ),
                    items: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH']
                        .map((method) => DropdownMenuItem(
                      value: method,
                      child: Text(
                        method,
                        style: TextStyle(
                          color: _getMethodColor(method),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedMethod = value!);
                    },
                  ),
                  const SizedBox(height: 16),

                  // URL Input
                  TextFormField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      labelText: 'URL',
                      hintText: 'https://api.example.com/users',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a URL';
                      }
                      if (!value.startsWith('http')) {
                        return 'URL must start with http:// or https://';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Headers Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Headers',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _addHeader,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Header'),
                      ),
                    ],
                  ),
                  if (_headers.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ..._headers.entries.map((entry) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(entry.key),
                        subtitle: Text(entry.value),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _headers.remove(entry.key);
                            });
                          },
                        ),
                      ),
                    )),
                  ] else ...[
                    const SizedBox(height: 8),
                    Text(
                      'No headers added',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Body Input (for POST/PUT/PATCH)
                  if (_selectedMethod != 'GET' && _selectedMethod != 'DELETE') ...[
                    const Text(
                      'Request Body',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _bodyController,
                      decoration: const InputDecoration(
                        hintText: '{"key": "value"}',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 8,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Send Button
                  ElevatedButton.icon(
                    onPressed: state is RequestSending ? null : _sendRequest,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    icon: state is RequestSending
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.send),
                    label: Text(
                      state is RequestSending ? 'Sending...' : 'Send Request',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),

                  // Response Display
                  if (state is RequestSent) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text(
                      'Response',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  state.response.isSuccess
                                      ? Icons.check_circle
                                      : Icons.error,
                                  color: state.response.isSuccess
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Status: ${state.response.statusCode}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: state.response.isSuccess
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Time: ${state.response.responseTime}ms',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const Divider(height: 24),
                            const Text(
                              'Response Body:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: SelectableText(
                                state.response.body,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
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
}