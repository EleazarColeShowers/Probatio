import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/api_request.dart';
import '../bloc/request_bloc.dart';
import '../bloc/request_event.dart';
import '../bloc/request_state.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({super.key});

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();
  String _selectedMethod = 'GET';
  final Map<String, String> _headers = {};
  final _bodyController = TextEditingController();

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
      name: _nameController.text.trim(),
      url: _urlController.text.trim(),
      method: _selectedMethod,
      headers: _headers,
      body: _bodyController.text.trim().isEmpty
          ? null
          : _bodyController.text.trim(), createdAt: DateTime.timestamp(),
    );

    context.read<RequestBloc>().add(SendRequestEvent(request));
  }

  void _saveRequest() {
    if (!_formKey.currentState!.validate()) return;

    final request = ApiRequest(
      name: _nameController.text.trim(),
      url: _urlController.text.trim(),
      method: _selectedMethod,
      headers: _headers,
      body: _bodyController.text.trim().isEmpty
          ? null
          : _bodyController.text.trim(),
      createdAt: DateTime.now(),
    );

    context.read<RequestBloc>().add(SaveRequestEvent(request));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      border: OutlineInputBorder(),
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
                    ),
                    items: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH']
                        .map((method) => DropdownMenuItem(
                      value: method,
                      child: Text(method),
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
                      border: OutlineInputBorder(),
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
                  const SizedBox(height: 16),

                  // Body Input (for POST/PUT/PATCH)
                  if (_selectedMethod != 'GET' && _selectedMethod != 'DELETE')
                    TextFormField(
                      controller: _bodyController,
                      decoration: const InputDecoration(
                        labelText: 'Body (JSON)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                    ),
                  const SizedBox(height: 24),

                  // Send Button
                  ElevatedButton(
                    onPressed: state is RequestSending ? null : _sendRequest,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    child: state is RequestSending
                        ? const CircularProgressIndicator()
                        : const Text('Send Request'),
                  ),

                  // Response Display
                  if (state is RequestSent) ...[
                    const SizedBox(height: 24),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Status: ${state.response.statusCode}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: state.response.isSuccess
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Time: ${state.response.responseTime}ms'),
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
}
