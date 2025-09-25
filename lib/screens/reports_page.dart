import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/device_test.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../theme/app_components.dart';
import 'report_detail_screen.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class ReportsPage extends StatefulWidget {
  final String? deviceId;

  const ReportsPage({super.key, this.deviceId});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final ScrollController _scrollController = ScrollController();
  final AuthService _authService = AuthService();

  List<DeviceTest> _reports = [];
  List<Map<String, dynamic>> _devices = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  final int _pageSize = 20;

  // Filters
  String? _selectedDeviceId;
  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Set initial device filter if provided
    if (widget.deviceId != null) {
      _selectedDeviceId = widget.deviceId;
    }
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreReports();
    }
  }

  Future<void> _loadInitialData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.organization != null) {
      await Future.wait([
        _loadDevices(authProvider.organization!['id']),
        _loadReports(reset: true),
      ]);
    }
  }

  Future<void> _loadDevices(String companyId) async {
    final devices = await _authService.getDevicesForOrganization(companyId);
    setState(() {
      _devices = devices;
    });
  }

  Future<void> _loadReports({bool reset = false}) async {
    if (_isLoading || (!_hasMore && !reset)) return;

    setState(() {
      _isLoading = true;
      if (reset) {
        _currentPage = 0;
        _hasMore = true;
        _reports.clear();
      }
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.organization == null) return;

    try {
      // FIX: Use the standard page size for all loads to make all reports available
      // The logic to limit the initial load to 10 reports is removed.
      const currentLimit = 20; // Use _pageSize (20)
      final currentOffset = _currentPage * currentLimit;

      final reportsData = await _authService.getDeviceTests(
        companyId: authProvider.organization!['id'],
        deviceId: _selectedDeviceId,
        status: _selectedStatus,
        startDate: _startDate,
        endDate: _endDate,
        limit: currentLimit,
        offset: currentOffset,
      );

      final newReports = reportsData.map((data) => DeviceTest.fromJson(data)).toList();

      setState(() {
        _reports.addAll(newReports);
        _currentPage++;
        _hasMore = newReports.length == currentLimit;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreReports() async {
    await _loadReports();
  }

  void _applyFilters() {
    _loadReports(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea( // Use SafeArea to respect notches and system bars
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom Header: Back Button, Logo, Filter/Refresh Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SvgPicture.asset(
                    // Assumes 'lib/assets/logo.svg' path is correct
                    'lib/assets/logo.svg',
                    height: 32,
                    // colorFilter: ColorFilter.mode(AppColors.primaryText, BlendMode.srcIn),
                  ),
                  Row(
                    children: [
                      AppComponents.iconButton(
                        icon: Icons.filter_list,
                        onPressed: _showFilterModal,
                        iconColor: AppColors.primaryText,
                      ),
                      AppComponents.iconButton(
                        icon: Icons.refresh,
                        onPressed: () async {
                          await _loadReports(reset: true);
                        },
                        iconColor: AppColors.primaryText,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Main Report Title
              Text(
                'Device Test Reports',
                style: AppTextStyles.h1,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _loadReports(reset: true);
                  },
                  child: _buildReportsList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFilterModal() async {
    await showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => FilterModal(
        selectedDeviceId: _selectedDeviceId,
        selectedStatus: _selectedStatus,
        startDate: _startDate,
        endDate: _endDate,
        devices: _devices,
        onApply: (deviceId, status, start, end) {
          setState(() {
            _selectedDeviceId = deviceId;
            _selectedStatus = status;
            _startDate = start;
            _endDate = end;
          });
          _applyFilters();
          Navigator.of(context).pop();
        },
        onClear: () {
          setState(() {
            _selectedDeviceId = null;
            _selectedStatus = null;
            _startDate = null;
            _endDate = null;
          });
          _applyFilters();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _buildReportsList() {
    if (_reports.isEmpty && _isLoading) {
      return AppComponents.loadingIndicator();
    }

    if (_reports.isEmpty && !_isLoading) {
      final hasFiltersApplied = _selectedDeviceId != null ||
          _selectedStatus != null ||
          _startDate != null ||
          _endDate != null;

      return AppComponents.emptyState(
        icon: Icons.assessment_outlined,
        title: hasFiltersApplied ? 'No reports found' : 'No reports available',
        subtitle: hasFiltersApplied
            ? 'Try adjusting your filters to see more results'
            : 'Reports will appear here once device tests are completed',
      );
    }

    return ListView.builder(
      controller: _scrollController,
      // Use AppSizes.lg here, assuming it's correctly defined
      itemCount: _reports.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _reports.length) {
          return Padding(
            padding: const EdgeInsets.all(24.0), // Using 24.0 as placeholder for AppSizes.lg
            child: AppComponents.loadingIndicator(),
          );
        }

        final report = _reports[index];
        return _buildReportCard(report);
      },
    );
  }

  // --- REVISED Report Card Implementation ---
  Widget _buildReportCard(DeviceTest report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0), // Using 16.0 as placeholder for AppSizes.md
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            // Images icon from assets
            Container(
              width: 60,
              height: 60,
              // MODIFIED: Use the device image asset path
              child: Image.asset(
                'assets/device.png',
                width: 60,
                height: 60,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.devices, size: 40, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 24),
            // Report content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Report : ${report.folderName}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (report.testDate != null)
                    Text(
                      'Date : ${report.testDate!.day} ${_getMonthName(report.testDate!.month)} ${report.testDate!.year}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                // Assuming ReportDetailScreen accepts 'report'
                                builder: (context) => ReportDetailScreen(report: report),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF245C9E),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'View',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Implement download functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Download functionality will be implemented')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Download',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Function for Month Name ---
  String _getMonthName(int month) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    // Safety check just in case month is out of range 1-12
    if (month >= 1 && month <= 12) {
      return months[month];
    }
    return '';
  }
}

// The FilterModal implementation remains the same
class FilterModal extends StatefulWidget {
  final String? selectedDeviceId;
  final String? selectedStatus;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<Map<String, dynamic>> devices;
  final void Function(String?, String?, DateTime?, DateTime?) onApply;
  final VoidCallback onClear;

  const FilterModal({
    super.key,
    required this.selectedDeviceId,
    required this.selectedStatus,
    required this.startDate,
    required this.endDate,
    required this.devices,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<FilterModal> createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  String? _selectedDeviceId;
  String? _selectedStatus;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _selectedDeviceId = widget.selectedDeviceId;
    _selectedStatus = widget.selectedStatus;
    if (widget.startDate != null && widget.endDate != null) {
      _dateRange = DateTimeRange(start: widget.startDate!, end: widget.endDate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBackground,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text('Filters', style: AppTextStyles.h2),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _selectedDeviceId,
                decoration: InputDecoration(
                  labelText: 'Device',
                  border: OutlineInputBorder(
                    borderRadius: AppBorderRadius.input,
                    borderSide: BorderSide(color: AppColors.dividerColor),
                  ),
                  isDense: true,
                  labelStyle: AppTextStyles.bodyMedium,
                  filled: true,
                  fillColor: AppColors.cardBackground,
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('All Devices'),
                  ),
                  ...widget.devices.map((device) => DropdownMenuItem<String>(
                    value: device['id'],
                    child: Text(device['device_name'] ?? 'Unknown Device'),
                  )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedDeviceId = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(
                    borderRadius: AppBorderRadius.input,
                    borderSide: BorderSide(color: AppColors.dividerColor),
                  ),
                  isDense: true,
                  labelStyle: AppTextStyles.bodyMedium,
                  filled: true,
                  fillColor: AppColors.cardBackground,
                ),
                items: const [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text('All Status'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'pending',
                    child: Text('Pending'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'passed',
                    child: Text('Passed'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'failed',
                    child: Text('Failed'),
                  ),
                  DropdownMenuItem<String>(
                    value: 'incomplete',
                    child: Text('Incomplete'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Text('Date Range', style: AppTextStyles.bodyLarge),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final picked = await showDateRangePicker(
                    context: context,
                    initialDateRange: _dateRange,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      _dateRange = picked;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    border: Border.all(color: AppColors.dividerColor),
                    borderRadius: AppBorderRadius.input,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: AppColors.tertiaryText),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _dateRange == null
                              ? 'Select date range'
                              : '${_dateRange!.start.day}/${_dateRange!.start.month}/${_dateRange!.start.year} - ${_dateRange!.end.day}/${_dateRange!.end.month}/${_dateRange!.end.year}',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryText),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApply(
                          _selectedDeviceId,
                          _selectedStatus,
                          _dateRange?.start,
                          _dateRange?.end,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 24.0), // Placeholder for AppSizes.lg
                        shape: RoundedRectangleBorder(
                          borderRadius: AppBorderRadius.button,
                        ),
                      ),
                      child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      onPressed: widget.onClear,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryText,
                        padding: const EdgeInsets.symmetric(vertical: 24.0), // Placeholder for AppSizes.lg
                        shape: RoundedRectangleBorder(
                          borderRadius: AppBorderRadius.button,
                        ),
                      ),
                      child: const Text('Clear', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}