import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../theme/app_components.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Homepage extends StatefulWidget {
  Homepage({super.key});
  @override
  State<Homepage> createState() => _HomepageState();
}

class ImageCarousel extends StatefulWidget {
  const ImageCarousel({super.key});
  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _current = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    final List<String> imgList = [
      'assets/banner.png',
      'assets/banner.png',
      'assets/banner.png',
    ];
    return Column(
      children: [
        CarouselSlider(
          carouselController: _carouselController,
          options: CarouselOptions(
            autoPlay: true,
            enlargeCenterPage: false,
            aspectRatio: 2.0,
            autoPlayInterval: const Duration(seconds: 4),
            viewportFraction: 1.0,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
          items: imgList.map((item) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 5.0),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10.0)),
              child: Image.asset(item, fit: BoxFit.cover, width: MediaQuery.of(context).size.width),
            ),
          )).toList(),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: imgList.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _carouselController.animateToPage(entry.key),
              child: Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black)
                      .withOpacity(_current == entry.key ? 0.9 : 0.4),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}


class _HomepageState extends State<Homepage> {
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;
  int _current = 0;
  final CarouselSliderController _carouselSliderController = CarouselSliderController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Center(
                child: SizedBox(
                  height: 48,
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // --- Use the split carousel widget ---
              ImageCarousel(),
              const SizedBox(height: 20),
              _buildSummarySection(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My devices',
                    style: AppTextStyles.h1,
                  ),
                  Row(
                    children: [
                      _buildIconButton(
                        icon: _isSearching ? Icons.close : Icons.search,
                        onPressed: () {
                          setState(() {
                            _isSearching = !_isSearching;
                            if (!_isSearching) {
                              _searchController.clear();
                              _searchQuery = '';
                            }
                          });
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildIconButton(
                        icon: Icons.refresh,
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_isSearching) ...[
                AppComponents.card(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search devices...',
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: AppColors.tertiaryText),
                    ),
                    style: AppTextStyles.bodyMedium,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
              Expanded(
                child: _buildDevicesList(context, authProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    return AppComponents.iconButton(
      icon: icon,
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? AppColors.cardBackground,
      iconColor: iconColor ?? AppColors.primaryText,
      size: AppSizes.iconMedium,
    );
  }

  Widget _buildSummarySection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: AppComponents.card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Vertically center content
              crossAxisAlignment: CrossAxisAlignment.center, // Horizontally center content
              children: [
                Text(
                  '6',
                  style: AppTextStyles.h1.copyWith(color: AppColors.primaryText),
                  textAlign: TextAlign.center, // Ensure text itself is centered
                ),
                Text(
                  'Under Warranty',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center, // Ensure text itself is centered
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AppComponents.card(
            child: SizedBox(
              height: 65, // Adjust the height as needed to match the other cards
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Vertically center content
                crossAxisAlignment: CrossAxisAlignment.center, // Horizontally center content
                children: [
                  Text(
                    '2',
                    style: AppTextStyles.h1.copyWith(color: AppColors.primaryText),
                    textAlign: TextAlign.center, // Ensure text itself is centered
                  ),
                  Text(
                    'AMC Active',
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center, // Ensure text itself is centered
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AppComponents.card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Vertically center content
              crossAxisAlignment: CrossAxisAlignment.center, // Horizontally center content
              children: [
                Text(
                  '0',
                  style: AppTextStyles.h1.copyWith(color: AppColors.primaryText),
                  textAlign: TextAlign.center, // Ensure text itself is centered
                ),
                Text(
                  'Service Request',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center, // Ensure text itself is centered
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDevicesList(BuildContext context, AuthProvider authProvider) {
    if (authProvider.organization == null) {
      return AppComponents.emptyState(
        icon: Icons.business_outlined,
        title: 'No organization found',
      );
    }

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: authProvider.organization != null
          ? _authService.getDevicesForOrganization(
        authProvider.organization!['id'],
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      )
          : Future.value([]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return AppComponents.loadingIndicator();
        }

        if (snapshot.hasError) {
          return AppComponents.emptyState(
            icon: Icons.error_outline,
            title: 'Error loading devices',
          );
        }

        final devices = snapshot.data ?? [];

        if (devices.isEmpty) {
          return AppComponents.emptyState(
            icon: Icons.devices_outlined,
            title: 'No devices found',
            subtitle: 'No devices registered for this organization',
          );
        }

        return ListView.builder(
          itemCount: devices.length,
          itemBuilder: (context, index) {
            final device = devices[index];
            return _buildDeviceCard(context, device);
          },
        );
      },
    );
  }

  Widget _buildDeviceCard(BuildContext context, Map<String, dynamic> device) {
    // Use a null-aware operator for safety
    final deviceStatus = device['device_status'] ?? 'Not available';
    final amcStatus = device['amc_status'] ?? 'Not active';

    // Function to get the color based on status text
    Color _getStatusColor(String status) {
      if (status.toLowerCase().contains('active') || status.toLowerCase().contains('available')) {
        return Colors.green[600]!;
      }
      return Colors.grey[400]!;
    }

    // Function to get the background color based on status
    Color _getStatusBackgroundColor(String status) {
      if (status.toLowerCase().contains('active') || status.toLowerCase().contains('available')) {
        return Colors.green[100]!;
      }
      return Colors.grey[200]!;
    }

    // Function to get the text color for the buttons
    Color _getButtonTextColor(bool isSelected) {
      return isSelected ? Colors.white : AppColors.primaryText;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text with an underline
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                        ),
                      ),
                      child: Text(
                        '${device['device_name'] ?? 'Unknown Device'}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Device ID row
                    Row(
                      children: [
                        Text('Device ID:', style: AppTextStyles.bodySmall),
                        const SizedBox(width: 4),
                        Text(
                          device['device_id'] ?? 'N/A',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Device Status row with dynamic color
                    Row(
                      children: [
                        Text('Device Status:', style: AppTextStyles.bodySmall),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(deviceStatus),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            deviceStatus,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // AMC Status row with dynamic color
                    Row(
                      children: [
                        Text('AMC Status:', style: AppTextStyles.bodySmall),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(amcStatus),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            amcStatus,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Image.asset(
                'assets/device.png',
                width: 80,
                height: 120,
                fit: BoxFit.contain,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Service',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Stats',
                      style: TextStyle(color: AppColors.primaryText),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  void _showDeviceDetails(BuildContext context, Map<String, dynamic> device) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Device Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: device['archived'] != true
                              ? const Color(0xFFE8F5E8)
                              : const Color(0xFFFFE8E8),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          device['archived'] != true ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: device['archived'] != true
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFF44336),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        device['device_name'] ?? 'Unknown Device',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (device['make'] != null || device['model'] != null)
                        Text(
                          '${device['make'] ?? ''} ${device['model'] ?? ''}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF424242),
                          ),
                        ),
                      const SizedBox(height: 24),
                      _buildDetailRow('Serial Number', device['serial_number']),
                      _buildDetailRow('MAC Address', device['mac_address']),
                      _buildDetailRow('Make', device['make']),
                      _buildDetailRow('Model', device['model']),
                      _buildDetailRow('Category', device['category']),
                      _buildDetailRow('Location', device['location']),
                      _buildDetailRow('Purchase Date', device['purchase_date'] != null
                          ? _formatDate(DateTime.parse(device['purchase_date'])) : null),
                      _buildDetailRow('Warranty Expiry', device['warranty_expiry_date'] != null
                          ? _formatDate(DateTime.parse(device['warranty_expiry_date'])) : null),
                      _buildDetailRow('AMC End Date', device['amc_end_date'] != null
                          ? _formatDate(DateTime.parse(device['amc_end_date'])) : null),
                      _buildDetailRow('Supplier', device['supplier']),
                      _buildDetailRow('Cost', device['cost']?.toString()),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
