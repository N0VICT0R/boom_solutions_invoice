import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:boom_solutions_invoice/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class CheckInScreen extends StatefulWidget {
  final VoidCallback? onSuccess; // Callback for data refresh
  const CheckInScreen({super.key, this.onSuccess});

  @override
  _CheckInScreenState createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _isLoadingLocation = true;
  bool _isLoadingCustomerLocation = true;
  Position? _currentPosition;
  Map<String, dynamic>? _customerLocation;
  double? _distanceToCustomer;
  String? _errorMessage;
  final TextEditingController _notesController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  bool _isButtonEnabled = false;

  final String baseUrl = "https://onix.boom-solutions.co/";
  final String apiToken = GetStorage().read('token') ?? '';
  final LinearGradient gradient = const LinearGradient(
    colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  final LinearGradient disabledGradient = const LinearGradient(
    colors: [Color(0xFF546E7A), Color(0xFF78909C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _notesController.addListener(_updateButtonState);
    _getCurrentLocation();
    _fetchCustomerLocation();
  }

  void _updateButtonState() {
    final bool hasText = _notesController.text.trim().isNotEmpty;
    if (hasText != _isButtonEnabled) {
      setState(() {
        _isButtonEnabled = hasText;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _errorMessage = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw S.of(context).locationServicesDisabled;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw S.of(context).locationPermissionDenied;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw S.of(context).locationPermissionsPermanentlyDenied;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });
      _calculateDistance();
    } catch (e) {
      setState(() {
        _errorMessage = '$e';
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _fetchCustomerLocation() async {
    setState(() {
      _isLoadingCustomerLocation = true;
      _errorMessage = null;
    });

    try {
      final int partnerId = Get.arguments['partnerId'];
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/partners/map?api_token=$apiToken'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        final List<dynamic> partners = data['partners'] ?? [];
        final partner = partners.firstWhere(
          (p) => p['id'] == partnerId,
          orElse: () => null,
        );

        if (partner == null) {
          throw S.of(context).customerNotFound;
        }

        double latitude = double.tryParse(partner['latitude']?.toString() ?? '0.0') ?? 0.0;
        double longitude = double.tryParse(partner['longitude']?.toString() ?? '0.0') ?? 0.0;
        String name = partner['name']?.toString() ?? S.of(context).unknownCustomer;

        setState(() {
          _customerLocation = {
            'latitude': latitude,
            'longitude': longitude,
            'name': name,
          };
          _isLoadingCustomerLocation = false;
        });
        _calculateDistance();
      } else {
        throw '${S.of(context).failedToFetchCustomerLocation}: ${response.statusCode}';
      }
    } catch (e) {
      setState(() {
        _errorMessage = '$e';
        _customerLocation = {'name': S.of(context).unknownCustomer, 'latitude': 0.0, 'longitude': 0.0};
        _isLoadingCustomerLocation = false;
      });
    }
  }

  void _calculateDistance() {
    if (_currentPosition != null && _customerLocation != null) {
      if (_customerLocation!['latitude'] == 0.0 && _customerLocation!['longitude'] == 0.0) {
        return;
      }

      double distanceInMeters = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        _customerLocation!['latitude'],
        _customerLocation!['longitude'],
      );
      setState(() {
        _distanceToCustomer = distanceInMeters / 1000;
      });
    }
  }

  Future<void> _submitCheckIn() async {
    if (!_isButtonEnabled) return;

    if (_currentPosition == null) {
      setState(() {
        _errorMessage = S.of(context).locationNotAvailable;
      });
      return;
    }

    if (_distanceToCustomer != null && _distanceToCustomer! > 10) {
      bool? proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: Text(S.of(context).distanceWarning, style: const TextStyle(color: Colors.orange)),
          content: Text(
            S.of(context).distanceWarningMessage,
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(S.of(context).cancel, style: const TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(S.of(context).proceed, style: const TextStyle(color: Color(0xFF42A5F5))),
            ),
          ],
        ),
      );

      if (proceed != true) return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final int partnerId = Get.arguments['partnerId'];
      final payload = {
        "api_token": apiToken,
        "partner_id": partnerId,
        "latitude": _currentPosition!.latitude,
        "longitude": _currentPosition!.longitude,
        "notes": _notesController.text,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/partners/check-in'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        if (!mounted) return;
        _showResponseDialog(data);
      } else {
        throw '${S.of(context).error}: ${response.statusCode}';
      }
    } catch (e) {
      setState(() {
        _errorMessage = '$e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showResponseDialog(Map<String, dynamic> response) {
    final bool isSuccess = response['success'] ?? false;
    final visit = response['visit'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(
              isSuccess ? S.of(context).success : S.of(context).failed,
              style: GoogleFonts.poppins(
                color: isSuccess ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (visit != null) ...[
              const SizedBox(height: 8),
              Text(
                S.of(context).visitDetails,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              _buildDetailRow(S.of(context).partner, visit['partner_name']),
              _buildDetailRow(S.of(context).date, visit['date']),
              _buildDetailRow(S.of(context).user, visit['user_name']),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              if (isSuccess) {
                widget.onSuccess?.call(); // Trigger data refresh
                Navigator.pop(context); // Navigate back to previous screen
              }
            },
            child: Text(
              S.of(context).ok,
              style: GoogleFonts.poppins(color: const Color(0xFF42A5F5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.white70),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: const Color(0xFF42A5F5)))
            : _buildCheckInForm(),
      ),
    );
  }

  Widget _buildCheckInForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 600),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    S.of(context).visitNote,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: FadeInUp(
              duration: const Duration(milliseconds: 700),
              child: Center(
                child: (_isLoadingLocation || _isLoadingCustomerLocation)
                    ? const CircularProgressIndicator(color: Color(0xFF42A5F5))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: gradient,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1976D2).withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.delivery_dining, color: Colors.white, size: 32),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 75),
                              CustomPaint(
                                size: const Size(80, 2),
                                painter: GradientDashedLinePainter(gradient: gradient),
                              ),
                              const SizedBox(height: 15),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  _distanceToCustomer != null
                                      ? S.of(context).distanceValue(_distanceToCustomer!.toStringAsFixed(2))
                                      : S.of(context).notAvailable,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          ScaleTransition(
                            scale: _pulseAnimation,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: gradient,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF42A5F5).withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.person, color: Colors.white, size: 32),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          FadeInUp(
            duration: const Duration(milliseconds: 800),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: _isButtonEnabled
                      ? Colors.green.withOpacity(0.4)
                      : Colors.orange.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_isButtonEnabled)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        S.of(context).notesRequired ?? "Notes required",
                        style: GoogleFonts.poppins(
                          color: Colors.orange.withOpacity(0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  TextField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      hintText: S.of(context).addNotes,
                      hintStyle: GoogleFonts.poppins(color: Colors.white38),
                      border: InputBorder.none,
                      prefixIcon: !_isButtonEnabled
                          ? Icon(Icons.edit, color: Colors.orange.withOpacity(0.8), size: 18)
                          : Icon(Icons.check_circle, color: Colors.green.withOpacity(0.8), size: 18),
                    ),
                    style: GoogleFonts.poppins(color: Colors.white),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            FadeInUp(
              duration: const Duration(milliseconds: 900),
              child: Text(
                _errorMessage!,
                style: GoogleFonts.poppins(color: Colors.red[400], fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: 24),
          FadeInUp(
            duration: const Duration(milliseconds: 1000),
            child: _ActionButton(
              label: S.of(context).checkIn,
              onTap: _isButtonEnabled ? _submitCheckIn : null,
              gradient: _isButtonEnabled ? gradient : disabledGradient,
              isEnabled: _isButtonEnabled,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _notesController.removeListener(_updateButtonState);
    _notesController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}

class GradientDashedLinePainter extends CustomPainter {
  final LinearGradient gradient;

  GradientDashedLinePainter({required this.gradient});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashWidth = 5;
    const dashSpace = 3;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _ActionButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final LinearGradient gradient;
  final bool isEnabled;

  const _ActionButton({
    required this.label,
    required this.onTap,
    required this.gradient,
    this.isEnabled = true,
  });

  @override
  __ActionButtonState createState() => __ActionButtonState();
}

class __ActionButtonState extends State<_ActionButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => widget.isEnabled ? _controller.forward() : null,
      onTapUp: (_) {
        if (widget.isEnabled) {
          _controller.reverse();
          widget.onTap?.call();
        }
      },
      onTapCancel: () => widget.isEnabled ? _controller.reverse() : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: widget.isEnabled
                    ? const Color(0xFF1976D2).withOpacity(0.3)
                    : Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!widget.isEnabled)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                Text(
                  widget.label,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: widget.isEnabled ? Colors.white : Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}