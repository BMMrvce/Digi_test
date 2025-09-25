import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Ensure these imports point to your actual files
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart'; // Source for AppColors, AppTextStyles, AppSizes, AppComponents
import '../theme/app_components.dart';
import 'reports_page.dart'; // Source for ReportsPage

// --- ImageCarousel Widget ---
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
              child: Image.asset(item, fit: BoxFit.cover, width: MediaQuery.of(context).size.width,
                errorBuilder: (context, error, stackTrace) => Container(height: 150, color: AppColors.primaryAccent, child: const Center(child: Text("Banner"))),
              ),
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

// --- Homepage Widget ---
class Homepage extends StatefulWidget {
  const Homepage({super.key});
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  // Assuming AuthService is correctly instantiated/provided
  final AuthService _authService = AuthService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    // Assuming AuthProvider is available via Provider.of
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
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.business),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const ImageCarousel(),
              const SizedBox(height: 20),
              _buildStatisticsCards(context, authProvider),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Instruments (Devices)',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
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
              const SizedBox(height: 16),
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

  // --- Helper Methods (Stats & Device List) ---

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? iconColor,
  }) {
    // AppComponents.iconButton is assumed to be defined in '../theme/app_components.dart'
    return AppComponents.iconButton(
      icon: icon,
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? AppColors.cardBackground,
      iconColor: iconColor ?? AppColors.primaryText,
      size: AppSizes.iconMedium,
    );
  }

  Widget _buildStatisticsCards(BuildContext context, AuthProvider authProvider) {
    if (authProvider.organization == null) {
      return Row(
        children: [
          Expanded(child: _buildStatCard('0', 'Total\nDevices')),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('0', 'AMC\nActive')),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('0', 'Service\nRequest')),
        ],
      );
    }

    // AuthService.getDevicesForOrganization is assumed to exist
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _authService.getDevicesForOrganization(authProvider.organization!['id']),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Row(
            children: [
              Expanded(child: _buildStatCard('...', 'Total\nDevices')),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('...', 'AMC\nActive')),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('...', 'Service\nRequest')),
            ],
          );
        }

        final devices = snapshot.data ?? [];
        final totalDevices = devices.length;

        final now = DateTime.now();
        final amcActiveDevices = devices.where((device) {
          if (device['amc_end_date'] == null) return false;
          try {
            final amcEndDate = DateTime.parse(device['amc_end_date']);
            return amcEndDate.isAfter(now);
          } catch (e) {
            return false;
          }
        }).length;

        const serviceRequests = 0;

        return Row(
          children: [
            Expanded(child: _buildStatCard(totalDevices.toString(), 'Total\nDevices')),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(amcActiveDevices.toString(), 'AMC\nActive')),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard(serviceRequests.toString(), 'Service\nRequest')),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String number, String label) {
    // AppComponents.card is assumed to be defined in '../theme/app_components.dart'
    return AppComponents.card(
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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

  // --- Device Card Implementation ---
  Widget _buildDeviceCard(BuildContext context, Map<String, dynamic> device) {
    const String deviceName = "DigiPICK™ i11";
    final String deviceIdShort = (device['id'] != null && device['id'].length >= 6)
        ? device['id'].substring(device['id'].length - 6)
        : (device['id'] ?? 'cb3b69');

    final bool isActive = device['archived'] != true;
    final now = DateTime.now();
    final amcEndDate = device['amc_end_date'] != null
        ? DateTime.tryParse(device['amc_end_date'])
        : null;
    final bool isAmcActive = amcEndDate != null && amcEndDate.isAfter(now);

    final String deviceStatusText = isActive ? 'Available' : 'Unavailable';
    final Color deviceStatusColor = isActive ? const Color(0xFF4CAF50) : const Color(0xFFF44336);
    final String amcStatusText = isAmcActive ? 'Active' : 'Inactive';
    final Color amcStatusColor = isAmcActive ? const Color(0xFF4CAF50) : const Color(0xFFF44336);

    return GestureDetector(
      onTap: () => _navigateToReports(context, device),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Column(
          children: [
            // 1. TOP CARD SECTION
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: deviceName,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 160,
                          height: 1,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryAccent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Device ID
                        Row(
                          children: [
                            const Text('Device ID : ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
                            Text(deviceIdShort, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: Colors.black)),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Device Status
                        Row(
                          children: [
                            const Text('Device Status : ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: deviceStatusColor, borderRadius: BorderRadius.circular(4)),
                              child: Text(deviceStatusText, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // AMC Status
                        Row(
                          children: [
                            const Text('AMC Status : ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(color: amcStatusColor, borderRadius: BorderRadius.circular(4)),
                              child: Text(amcStatusText, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Right side - Device image
                  Container(
                    width: 120,
                    height: 160,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset('assets/device.png', fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) {
                        return Container(decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)), child: Icon(Icons.devices, size: 60, color: Colors.grey[400]));
                      }),
                    ),
                  ),
                ],
              ),
            ),

            // 2. BOTTOM BUTTONS STRIP
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    // Both buttons navigate to ReportsPage
                    onTap: () => _navigateToReports(context, device),
                    child: Container(
                      margin: const EdgeInsets.only(left: 16),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1976D2), // Blue color
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Service',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    // Both buttons navigate to ReportsPage
                    onTap: () => _navigateToReports(context, device),
                    child: Container(
                      margin: const EdgeInsets.only(right: 16),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Stats',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- Navigation Method ---
  void _navigateToReports(BuildContext context, Map<String, dynamic> device) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportsPage(deviceId: device['id']),
      ),
    );
  }
}