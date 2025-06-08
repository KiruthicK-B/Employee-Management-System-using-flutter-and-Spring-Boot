import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Employee Management System',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
      home: EmployeeListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Employee {
  String? employeeName;
  String? employeeEmail;
  int? employeeAge;
  String? employeeDept;
  double? employeeSalary;
  int? id;

  Employee({
    this.employeeName,
    this.employeeEmail,
    this.employeeAge,
    this.employeeDept,
    this.employeeSalary,
    this.id,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      employeeName: json['employee_Name'],
      employeeEmail: json['employee_Email'],
      employeeAge: json['employee_Age'],
      employeeDept: json['employee_Dept'],
      employeeSalary: (json['employee_Salary'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_Name': employeeName,
      'employee_Email': employeeEmail,
      'employee_Age': employeeAge,
      'employee_Dept': employeeDept,
      'employee_Salary': employeeSalary,
    };
  }
}

class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;

  ApiResponse({required this.success, required this.message, this.data});
}

class ApiService {
  static const String baseUrl = 'http://192.168.109.157:8082';
  static const Duration timeout = Duration(seconds: 30);

  static Future<ApiResponse> _handleResponse(http.Response response, String operation) async {
    try {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse(
          success: true,
          message: '$operation completed successfully',
          data: response.body.isNotEmpty ? json.decode(response.body) : null,
        );
      } else {
        String errorMessage;
        try {
          final errorData = json.decode(response.body);
          errorMessage = errorData['message'] ?? errorData['error'] ?? 'Server error occurred';
        } catch (e) {
          errorMessage = 'Server returned status code: ${response.statusCode}';
        }
        return ApiResponse(success: false, message: errorMessage);
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'Failed to process server response');
    }
  }

  static Future<ApiResponse> fetchEmployees() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/fetch'))
          .timeout(timeout);
      
      final apiResponse = await _handleResponse(response, 'Fetch employees');
      if (apiResponse.success && apiResponse.data != null) {
        List<Employee> employees = (apiResponse.data as List)
            .map((json) => Employee.fromJson(json))
            .toList();
        return ApiResponse(
          success: true,
          message: 'Employees loaded successfully',
          data: employees,
        );
      }
      return apiResponse;
    } on SocketException {
      return ApiResponse(success: false, message: 'No internet connection. Please check your network.');
    } on HttpException {
      return ApiResponse(success: false, message: 'Server connection failed. Please try again.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Unexpected error: ${e.toString()}');
    }
  }

  static Future<ApiResponse> findEmployeeById(int id) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/find/$id'))
          .timeout(timeout);
      
      final apiResponse = await _handleResponse(response, 'Find employee');
      if (apiResponse.success && apiResponse.data != null) {
        Employee employee = Employee.fromJson(apiResponse.data);
        return ApiResponse(
          success: true,
          message: 'Employee found successfully',
          data: employee,
        );
      }
      return apiResponse;
    } on SocketException {
      return ApiResponse(success: false, message: 'No internet connection. Please check your network.');
    } on HttpException {
      return ApiResponse(success: false, message: 'Server connection failed. Please try again.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Failed to find employee: ${e.toString()}');
    }
  }

  static Future<ApiResponse> insertEmployee(Employee employee) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/insert'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(employee.toJson()),
          )
          .timeout(timeout);
      
      return await _handleResponse(response, 'Add employee');
    } on SocketException {
      return ApiResponse(success: false, message: 'No internet connection. Please check your network.');
    } on HttpException {
      return ApiResponse(success: false, message: 'Server connection failed. Please try again.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Failed to add employee: ${e.toString()}');
    }
  }

  static Future<ApiResponse> updateEmployee(int id, Employee employee) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/update/$id'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode(employee.toJson()),
          )
          .timeout(timeout);
      
      return await _handleResponse(response, 'Update employee');
    } on SocketException {
      return ApiResponse(success: false, message: 'No internet connection. Please check your network.');
    } on HttpException {
      return ApiResponse(success: false, message: 'Server connection failed. Please try again.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Failed to update employee: ${e.toString()}');
    }
  }

  static Future<ApiResponse> deleteEmployee(int id) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/delete/$id'),
            headers: {
              'Accept': 'application/json',
            },
          )
          .timeout(timeout);
      
      return await _handleResponse(response, 'Delete employee');
    } on SocketException {
      return ApiResponse(success: false, message: 'No internet connection. Please check your network.');
    } on HttpException {
      return ApiResponse(success: false, message: 'Server connection failed. Please try again.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Failed to delete employee: ${e.toString()}');
    }
  }
}

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  _EmployeeListScreenState createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  List<Employee> employees = [];
  List<Employee> filteredEmployees = [];
  bool isLoading = true;
  String errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadEmployees();
    _searchController.addListener(_filterEmployees);
  }

  void _filterEmployees() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredEmployees = employees;
      } else {
        filteredEmployees = employees.where((employee) {
          return (employee.employeeName?.toLowerCase().contains(query) ?? false) ||
                 (employee.employeeEmail?.toLowerCase().contains(query) ?? false) ||
                 (employee.employeeDept?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
    });
  }

  Future<void> loadEmployees() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final response = await ApiService.fetchEmployees();
    
    setState(() {
      isLoading = false;
      if (response.success) {
        employees = response.data ?? [];
        filteredEmployees = employees;
      } else {
        errorMessage = response.message;
      }
    });
  }

  Future<void> deleteEmployee(Employee employee) async {
    if (employee.id == null) {
      _showErrorSnackBar('Invalid employee ID');
      return;
    }

    final confirmed = await _showDeleteConfirmation(employee);
    if (!confirmed) return;

    _showLoadingDialog('Deleting employee...');

    final response = await ApiService.deleteEmployee(employee.id!);
    
    Navigator.of(context).pop(); // Close loading dialog

    if (response.success) {
      _showSuccessSnackBar(response.message);
      await loadEmployees();
    } else {
      _showErrorSnackBar(response.message);
    }
  }

  Future<bool> _showDeleteConfirmation(Employee employee) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 28),
              SizedBox(width: 12),
              Text('Confirm Delete', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Are you sure you want to delete this employee?'),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Name: ${employee.employeeName ?? 'Unknown'}', 
                         style: TextStyle(fontWeight: FontWeight.w500)),
                    Text('Email: ${employee.employeeEmail ?? 'No email'}'),
                    Text('Department: ${employee.employeeDept ?? 'No department'}'),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Text('This action cannot be undone.', 
                   style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.grey.shade600)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Delete'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ) ?? false;
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(message),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Employee Management', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: loadEmployees,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search employees...',
                prefixIcon: Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          
          // Employee Count
          if (!isLoading && errorMessage.isEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.people, size: 20, color: Colors.grey.shade600),
                  SizedBox(width: 8),
                  Text(
                    '${filteredEmployees.length} employee(s) found',
                    style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          
          // Main Content
          Expanded(
            child: isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading employees...', style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  )
                : errorMessage.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                            SizedBox(height: 16),
                            Text('Oops! Something went wrong', 
                                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                errorMessage, 
                                style: TextStyle(color: Colors.grey.shade600),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: loadEmployees,
                              icon: Icon(Icons.refresh),
                              label: Text('Retry'),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      )
                    : filteredEmployees.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
                                SizedBox(height: 16),
                                Text(
                                  _searchController.text.isNotEmpty 
                                      ? 'No employees match your search' 
                                      : 'No employees found',
                                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  _searchController.text.isNotEmpty 
                                      ? 'Try different search terms' 
                                      : 'Add your first employee to get started',
                                  style: TextStyle(color: Colors.grey.shade500),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(16),
                            itemCount: filteredEmployees.length,
                            itemBuilder: (context, index) {
                              final employee = filteredEmployees[index];
                              return Card(
                                margin: EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  contentPadding: EdgeInsets.all(16),
                                  leading: CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Theme.of(context).colorScheme.primary,
                                    child: Text(
                                      employee.employeeName?.substring(0, 1).toUpperCase() ?? 'E',
                                      style: TextStyle(
                                        color: Colors.white, 
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  title: Container(
                                    child: Text(
                                      employee.employeeName ?? 'Unknown',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.email, size: 16, color: Colors.grey.shade600),
                                          SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              employee.employeeEmail ?? 'No email',
                                              style: TextStyle(color: Colors.grey.shade700),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.work, size: 16, color: Colors.grey.shade600),
                                          SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              employee.employeeDept ?? 'No department',
                                              style: TextStyle(color: Colors.grey.shade700),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Icon(Icons.cake, size: 16, color: Colors.grey.shade600),
                                          SizedBox(width: 4),
                                          Text(
                                            '${employee.employeeAge ?? 'N/A'}',
                                            style: TextStyle(color: Colors.grey.shade700),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.attach_money, size: 16, color: Colors.green),
                                          SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              '₹${employee.employeeSalary?.toStringAsFixed(0) ?? 'N/A'}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.green.shade700,
                                                fontSize: 15,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (String value) {
                                      if (value == 'edit') {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => EmployeeFormScreen(
                                              employee: employee,
                                              onSave: loadEmployees,
                                            ),
                                          ),
                                        );
                                      } else if (value == 'delete') {
                                        deleteEmployee(employee);
                                      }
                                    },
                                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                      PopupMenuItem<String>(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                                            SizedBox(width: 8),
                                            Text('Edit'),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem<String>(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete, color: Colors.red.shade400),
                                            SizedBox(width: 8),
                                            Text('Delete'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  isThreeLine: true,
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EmployeeFormScreen(onSave: loadEmployees),
            ),
          );
        },
        icon: Icon(Icons.add),
        label: Text('Add Employee'),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class EmployeeFormScreen extends StatefulWidget {
  final Employee? employee;
  final VoidCallback onSave;

  const EmployeeFormScreen({super.key, this.employee, required this.onSave});

  @override
  _EmployeeFormScreenState createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _deptController = TextEditingController();
  final _salaryController = TextEditingController();
  bool isLoading = false;

  // Department options
  final List<String> departments = [
    'Engineering',
    'Marketing',
    'Sales',
    'Human Resources',
    'Finance',
    'Operations',
    'Customer Support',
    'Product Management',
    'Design',
    'Quality Assurance',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.employee != null) {
      _nameController.text = widget.employee!.employeeName ?? '';
      _emailController.text = widget.employee!.employeeEmail ?? '';
      _ageController.text = widget.employee!.employeeAge?.toString() ?? '';
      _deptController.text = widget.employee!.employeeDept ?? '';
      _salaryController.text = widget.employee!.employeeSalary?.toString() ?? '';
    }
  }

  Future<void> saveEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final employee = Employee(
      employeeName: _nameController.text.trim(),
      employeeEmail: _emailController.text.trim(),
      employeeAge: int.tryParse(_ageController.text),
      employeeDept: _deptController.text.trim(),
      employeeSalary: double.tryParse(_salaryController.text),
    );

    ApiResponse response;
    if (widget.employee == null) {
      response = await ApiService.insertEmployee(employee);
    } else {
      response = await ApiService.updateEmployee(widget.employee!.id!, employee);
    }

    setState(() => isLoading = false);

    if (response.success) {
      _showSuccessSnackBar(response.message);
      widget.onSave();
      Navigator.pop(context);
    } else {
      _showErrorSnackBar(response.message);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          widget.employee == null ? 'Add Employee' : 'Edit Employee',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Employee Information',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 20),
                    
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Employee Name *',
                        prefixIcon: Icon(Icons.person),
                        helperText: 'Enter the full name of the employee',
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter employee name';
                        }
                        if (value.trim().length < 2) {
                          return 'Name must be at least 2 characters long';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email Address *',
                        prefixIcon: Icon(Icons.email),
                        helperText: 'Enter a valid email address',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter email address';
                        }
                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _ageController,
                            decoration: InputDecoration(
                              labelText: 'Age *',
                              prefixIcon: Icon(Icons.cake),
                              helperText: '18-65 years',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter age';
                              }
                              final age = int.tryParse(value);
                              if (age == null || age < 18 || age > 65) {
                                return 'Age must be between 18-65';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: departments.contains(_deptController.text) ? _deptController.text : null,
                            decoration: InputDecoration(
                              labelText: 'Department *',
                              prefixIcon: Icon(Icons.work),
                              helperText: 'Select department',
                            ),
                            items: departments.map((String dept) {
                              return DropdownMenuItem<String>(
                                value: dept,
                                child: Text(dept),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _deptController.text = newValue ?? '';
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select department';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _salaryController,
                      decoration: InputDecoration(
                        labelText: 'Salary *',
                        prefixIcon: Icon(Icons.attach_money),
                        helperText: 'Enter monthly salary in rupees',
                        prefixText: '₹ ',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter salary';
                        }
                        final salary = double.tryParse(value);
                        if (salary == null || salary <= 0) {
                          return 'Please enter a valid salary amount';
                        }
                        if (salary < 10000) {
                          return 'Salary must be at least ₹10,000';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),
                    
                    Text(
                      '* Required fields',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading ? null : () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text('Cancel'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : saveEmployee,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Saving...'),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(widget.employee == null ? Icons.add : Icons.update),
                              SizedBox(width: 8),
                              Text(
                                widget.employee == null ? 'Add Employee' : 'Update Employee',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _deptController.dispose();
    _salaryController.dispose();
    super.dispose();
  }
}