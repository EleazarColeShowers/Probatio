import 'package:flutter/material.dart';
import 'package:probatio/shared/widgets/custombutton.dart';

class CollectionsPage extends StatefulWidget {
  const CollectionsPage({Key? key}) : super(key: key);

  @override
  State<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage> {
  String? selectedCollection;
  
  final List<Map<String, dynamic>> collections = [
    {
      'name': 'User Management API',
      'description': 'All user-related endpoints',
      'requests': [
        {'method': 'GET', 'url': 'https://api.example.com/users'},
        {'method': 'POST', 'url': 'https://api.example.com/users/create'},
        {'method': 'PUT', 'url': 'https://api.example.com/users/update'},
      ],
    },
    {
      'name': 'Product API',
      'description': 'Product catalog operations',
      'requests': [
        {'method': 'GET', 'url': 'https://api.example.com/products'},
        {'method': 'POST', 'url': 'https://api.example.com/products/create'},
        {'method': 'DELETE', 'url': 'https://api.example.com/products/5'},
      ],
    },
    {
      'name': 'Authentication',
      'description': 'Login and auth endpoints',
      'requests': [
        {'method': 'POST', 'url': 'https://api.example.com/auth/login'},
        {'method': 'POST', 'url': 'https://api.example.com/auth/logout'},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    selectedCollection = collections[0]['name'];
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

  Map<String, dynamic>? _getSelectedCollectionData() {
    return collections.firstWhere(
      (c) => c['name'] == selectedCollection,
      orElse: () => collections[0],
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedData = _getSelectedCollectionData();
    
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Collections',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Column(
                children: [
                  if (selectedCollection != null) ...[
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Delete Collection'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  SizedBox(
                    width: 180,
                    child: CustomButton(
                      text: 'New Collection',
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Collection tabs
          SizedBox(
            height: 50,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: collections.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final collection = collections[index];
                final isSelected = selectedCollection == collection['name'];
                
                return InkWell(
                  onTap: () {
                    setState(() {
                      selectedCollection = collection['name'];
                    });
                  },
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
                          collection['name'],
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
                            '${(collection['requests'] as List).length}',
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
          const SizedBox(height: 16),
          
          // Collection description
          if (selectedData != null) ...[
            Text(
              selectedData['description'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Requests list
          Expanded(
            child: selectedData != null
                ? ListView.separated(
                    itemCount: (selectedData['requests'] as List).length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final request = (selectedData['requests'] as List)[index];
                      return _buildRequestCard(
                        request['method'],
                        request['url'],
                      );
                    },
                  )
                : const Center(
                    child: Text('No collection selected'),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(String method, String url) {
    return InkWell(
      onTap: () {
        print('Tapped on: $method $url');
      },
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _getMethodColor(method).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  method,
                  style: TextStyle(
                    color: _getMethodColor(method),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  url,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}