import 'package:flutter/material.dart';
import 'package:probatio/shared/widgets/custombutton.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({Key? key}) : super(key: key);

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  String selectedMethod = 'GET';
  final TextEditingController urlController = TextEditingController(
    text: 'https://api.example.com/users',
  );
  final TextEditingController bodyController = TextEditingController(
    text: '{\n  "key": "value"\n}',
  );
  
  List<Map<String, TextEditingController>> headers = [
    {
      'key': TextEditingController(),
      'value': TextEditingController(),
    }
  ];

  List<Map<String, TextEditingController>> queryParams = [
    {
      'key': TextEditingController(),
      'value': TextEditingController(),
    }
  ];

  // Auth options
  String selectedAuthType = 'None'; // None, Bearer Token, Basic Auth, API Key
  final TextEditingController bearerTokenController = TextEditingController();
  final TextEditingController basicAuthUsernameController = TextEditingController();
  final TextEditingController basicAuthPasswordController = TextEditingController();
  final TextEditingController apiKeyController = TextEditingController();
  final TextEditingController apiKeyHeaderController = TextEditingController(text: 'X-API-Key');

  @override
  void dispose() {
    urlController.dispose();
    bodyController.dispose();
    bearerTokenController.dispose();
    basicAuthUsernameController.dispose();
    basicAuthPasswordController.dispose();
    apiKeyController.dispose();
    apiKeyHeaderController.dispose();
    
    for (var header in headers) {
      header['key']?.dispose();
      header['value']?.dispose();
    }
    for (var param in queryParams) {
      param['key']?.dispose();
      param['value']?.dispose();
    }
    super.dispose();
  }

  void _sendRequest() {
    // Build complete request
    Map<String, String> finalHeaders = {};
    
    // Add custom headers
    for (var header in headers) {
      final key = header['key']?.text ?? '';
      final value = header['value']?.text ?? '';
      if (key.isNotEmpty && value.isNotEmpty) {
        finalHeaders[key] = value;
      }
    }
    
    // Add auth headers
    if (selectedAuthType == 'Bearer Token' && bearerTokenController.text.isNotEmpty) {
      finalHeaders['Authorization'] = 'Bearer ${bearerTokenController.text}';
    } else if (selectedAuthType == 'API Key' && apiKeyController.text.isNotEmpty) {
      finalHeaders[apiKeyHeaderController.text] = apiKeyController.text;
    }
    
    // Build query string
    String finalUrl = urlController.text;
    List<String> queryStrings = [];
    for (var param in queryParams) {
      final key = param['key']?.text ?? '';
      final value = param['value']?.text ?? '';
      if (key.isNotEmpty && value.isNotEmpty) {
        queryStrings.add('$key=$value');
      }
    }
    if (queryStrings.isNotEmpty) {
      finalUrl += '?${queryStrings.join('&')}';
    }
    
    // Handle send request
    print('=== REQUEST DETAILS ===');
    print('Method: $selectedMethod');
    print('URL: $finalUrl');
    print('Auth Type: $selectedAuthType');
    print('Headers: $finalHeaders');
    if (['POST', 'PUT', 'PATCH'].contains(selectedMethod)) {
      print('Body: ${bodyController.text}');
    }
    print('=====================');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // HTTP Method Buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMethodButton('GET'),
              _buildMethodButton('POST'),
              _buildMethodButton('PUT'),
              _buildMethodButton('PATCH'),
              _buildMethodButton('DELETE'),
            ],
          ),
          const SizedBox(height: 24),
          
          // URL Section
          const Text(
            'URL',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: urlController,
            decoration: InputDecoration(
              hintText: 'https://api.example.com/users',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Query Parameters Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Query Parameters',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                onPressed: () {
                  setState(() {
                    queryParams.add({
                      'key': TextEditingController(),
                      'value': TextEditingController(),
                    });
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...queryParams.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, TextEditingController> param = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: param['key'],
                      decoration: InputDecoration(
                        hintText: 'Key (e.g., page)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: param['value'],
                      decoration: InputDecoration(
                        hintText: 'Value (e.g., 1)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  if (queryParams.length > 1)
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        setState(() {
                          param['key']?.dispose();
                          param['value']?.dispose();
                          queryParams.removeAt(index);
                        });
                      },
                    ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 24),

          // Authentication Section
          const Text(
            'Authentication',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedAuthType,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: const [
              DropdownMenuItem(value: 'None', child: Text('None')),
              DropdownMenuItem(value: 'Bearer Token', child: Text('Bearer Token')),
              DropdownMenuItem(value: 'Basic Auth', child: Text('Basic Auth')),
              DropdownMenuItem(value: 'API Key', child: Text('API Key')),
            ],
            onChanged: (value) {
              setState(() {
                selectedAuthType = value!;
              });
            },
          ),
          const SizedBox(height: 12),
          
          // Auth-specific fields
          if (selectedAuthType == 'Bearer Token') ...[
            TextField(
              controller: bearerTokenController,
              decoration: InputDecoration(
                hintText: 'Enter bearer token',
                labelText: 'Token',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
          
          if (selectedAuthType == 'Basic Auth') ...[
            TextField(
              controller: basicAuthUsernameController,
              decoration: InputDecoration(
                hintText: 'Username',
                labelText: 'Username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: basicAuthPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Password',
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
          
          if (selectedAuthType == 'API Key') ...[
            TextField(
              controller: apiKeyHeaderController,
              decoration: InputDecoration(
                hintText: 'Header name (e.g., X-API-Key)',
                labelText: 'Header Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: apiKeyController,
              decoration: InputDecoration(
                hintText: 'API Key value',
                labelText: 'API Key',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          
          // Headers Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Headers',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 20),
                onPressed: () {
                  setState(() {
                    headers.add({
                      'key': TextEditingController(),
                      'value': TextEditingController(),
                    });
                  });
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...headers.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, TextEditingController> header = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: header['key'],
                      decoration: InputDecoration(
                        hintText: 'Key (e.g., Content-Type)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: header['value'],
                      decoration: InputDecoration(
                        hintText: 'Value (e.g., application/json)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  if (headers.length > 1)
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        setState(() {
                          header['key']?.dispose();
                          header['value']?.dispose();
                          headers.removeAt(index);
                        });
                      },
                    ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 24),
          
          // Body JSON Section (only show for POST, PUT, PATCH)
          if (['POST', 'PUT', 'PATCH'].contains(selectedMethod)) ...[
            const Text(
              'Body (JSON)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: bodyController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: '{\n  "key": "value"\n}',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            const SizedBox(height: 24),
          ],
          
          // Send Request Button using CustomButton
          CustomButton(
            text: 'Send Request',
            onPressed: _sendRequest,
          ),
        ],
      ),
    );
  }

  Widget _buildMethodButton(String method) {
    final bool isSelected = selectedMethod == method;
    Color buttonColor;
    
    switch (method) {
      case 'GET':
        buttonColor = Colors.green;
        break;
      case 'POST':
        buttonColor = Colors.blue;
        break;
      case 'PUT':
        buttonColor = Colors.orange;
        break;
      case 'PATCH':
        buttonColor = Colors.purple;
        break;
      case 'DELETE':
        buttonColor = Colors.red;
        break;
      default:
        buttonColor = Colors.grey;
    }

    return OutlinedButton(
      onPressed: () {
        setState(() {
          selectedMethod = method;
        });
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? buttonColor.withOpacity(0.1) : Colors.white,
        side: BorderSide(
          color: isSelected ? buttonColor : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        method,
        style: TextStyle(
          color: buttonColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}