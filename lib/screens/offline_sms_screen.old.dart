import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:permission_handler/permission_handler.dart';

class OfflineSmsScreen extends StatefulWidget {
  const OfflineSmsScreen({super.key});

  @override
  State<OfflineSmsScreen> createState() => _OfflineSmsScreenState();
}

class _OfflineSmsScreenState extends State<OfflineSmsScreen> {
  static const MethodChannel _smsChannel = MethodChannel(
    'com.example.pasenger/sms',
  );
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _dropoffController = TextEditingController();

  String? _mobileNumber;
  bool _hasPermission = false;
  bool _permissionRequestInProgress = false;

  @override
  void initState() {
    super.initState();
    _initAll();
  }

  Future<void> _initAll() async {
    await _initMobileNumber();
    // SMS permissions requested lazily when needed.
  }

  Future<void> _initMobileNumber() async {
    if (!await MobileNumber.hasPhonePermission) {
      await MobileNumber.requestPhonePermission;
    }
    final String? mobileNumber = await MobileNumber.mobileNumber;
    if (!mounted) return;
    setState(() {
      _mobileNumber = mobileNumber;
      _phoneController.text = _mobileNumber ?? '';
    });
  }

  Future<bool> _requestPermissions() async {
    if (_permissionRequestInProgress) {
      return _hasPermission;
    }
    _permissionRequestInProgress = true;
    try {
      final Map<Permission, PermissionStatus> statuses = await [
        Permission.sms,
        Permission.phone,
      ].request();
      final bool granted = statuses.values.every((status) => status.isGranted);
      if (!mounted) return false;
      setState(() {
        _hasPermission = granted;
      });
      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permissions not granted. Cannot send SMS.'),
          ),
        );
      }
      return granted;
    } finally {
      _permissionRequestInProgress = false;
    }
  }

  Future<void> _sendBooking() async {
    if (!_hasPermission) {
      final bool granted = await _requestPermissions();
      if (!granted) return;
    }

    final String name = _nameController.text.trim();
    final String phone = _phoneController.text.trim();
    final String pickup = _pickupController.text.trim();
    final String dropoff = _dropoffController.text.trim();

    if (name.isEmpty || phone.isEmpty || pickup.isEmpty || dropoff.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields.')),
        );
      }
      return;
    }

    final String message =
        'Taxi Booking:\nName: $name\nPhone: $phone\nPickup: $pickup\nDropoff: $dropoff';

    // Replace with actual taxi service number
    const String taxiNumber = '0914919398'; // Demo number

    try {
      await _sendSms(taxiNumber, message);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('SMS sent successfully.')));
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to send SMS (${e.code}): ${e.message ?? e.details ?? 'Unknown error'}',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to send SMS: $e')));
      }
    }
  }

  Future<void> _sendSms(String phoneNumber, String message) {
    return _smsChannel.invokeMethod<void>('sendSms', {
      'phone': phoneNumber,
      'message': message,
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _pickupController.dispose();
    _dropoffController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meter Taxi Booking')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _pickupController,
              decoration: const InputDecoration(labelText: 'Pickup Location'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dropoffController,
              decoration: const InputDecoration(labelText: 'Dropoff Location'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _sendBooking,
              child: const Text('Book Taxi'),
            ),
          ],
        ),
      ),
    );
  }
}
