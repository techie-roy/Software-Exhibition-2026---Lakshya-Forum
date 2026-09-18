import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../app/constants.dart';
import '../app/localizations.dart';
import '../services/aadhaar_ocr_service.dart';
import '../utils/aadhaar_validator.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';

class AadhaarScannerScreen extends StatefulWidget {
  const AadhaarScannerScreen({super.key});

  @override
  State<AadhaarScannerScreen> createState() => _AadhaarScannerScreenState();
}

class _AadhaarScannerScreenState extends State<AadhaarScannerScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  bool _permissionDenied = false;
  bool _isTorchOn = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cameraController = _cameraController;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
      _cameraController = null;
      _isCameraInitialized = false;
      _isTorchOn = false;
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    setState(() {
      _errorMessage = null;
      _permissionDenied = false;
    });

    final s = S.of(context);
    try {
      final status = await Permission.camera.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        if (mounted) {
          setState(() {
            _permissionDenied = true;
          });
        }
        return;
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _errorMessage = s.noCameraFound;
          });
        }
        return;
      }

      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      try {
        await controller.initialize();
      } catch (e) {
        controller.dispose();
        rethrow;
      }

      if (mounted) {
        setState(() {
          _cameraController = controller;
          _isCameraInitialized = true;
          _isTorchOn = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = s.cameraUnavailableDesc;
        });
      }
    }
  }

  Future<void> _captureAndScan() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized || _isProcessing) {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final xfile = await controller.takePicture();
      final scanResult = await AadhaarOcrService.processImageFileFull(xfile.path);

      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });

      if (scanResult == null || scanResult.aadhaarNumber.isEmpty) {
        _showNoNumberFoundDialog();
      } else {
        _showDetailsConfirmation(scanResult);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });
      _showNoNumberFoundDialog(
        S.of(context).couldntReadAadhaar,
      );
    }
  }

  Future<void> _toggleTorch(CameraController controller) async {
    final nextState = !_isTorchOn;
    try {
      await controller.setFlashMode(nextState ? FlashMode.torch : FlashMode.off);
      if (!mounted) return;
      setState(() {
        _isTorchOn = nextState;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isTorchOn = false;
      });
    }
  }

  Widget _buildTorchButton(CameraController controller) {
    final isOn = _isTorchOn;
    final s = S.of(context);

    return Tooltip(
      message: isOn ? s.turnFlashlightOff : s.turnFlashlightOn,
      child: GestureDetector(
        onTap: () => _toggleTorch(controller),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isOn ? Colors.amber.shade600 : Colors.black.withValues(alpha: 0.55),
            border: Border.all(
              color: isOn ? Colors.amber.shade300 : Colors.white,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(
            isOn ? Icons.flashlight_on : Icons.flashlight_off,
            color: isOn ? Colors.white : Colors.white70,
            size: 28,
          ),
        ),
      ),
    );
  }

  void _showNoNumberFoundDialog([String? customMessage]) {
    final s = S.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLarge)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppDimensions.paddingLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.statusAlertBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.statusAlert.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(
                    Icons.document_scanner_outlined,
                    color: AppColors.statusAlert,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  s.couldntDetectAadhaar,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  customMessage ?? s.couldntReadAadhaar,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  text: s.tryAgain,
                  icon: Icons.refresh,
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 10),
                SecondaryButton(
                  text: s.enterManually,
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDetailsConfirmation(AadhaarScanResult scanResult) {
    final s = S.of(context);
    bool isRevealed = false;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLarge)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final displayAadhaar = isRevealed
                ? AadhaarValidator.formatGrouped(scanResult.aadhaarNumber)
                : AadhaarValidator.formatMasked(scanResult.aadhaarNumber);

            return SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.surfacePaleGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.primaryGreen,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      s.aadhaarDetectedTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.verifyExtracted,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoftMint,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.badge_outlined, color: AppColors.primaryGreen, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              displayAadhaar,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              isRevealed ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.primaryLight,
                            ),
                            onPressed: () {
                              setModalState(() {
                                isRevealed = !isRevealed;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    if (scanResult.isNameDetected && scanResult.name != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSoftMint,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                          border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person_outline, color: AppColors.primaryGreen, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                scanResult.name!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (scanResult.isDobDetected && scanResult.dob != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceSoftMint,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                          border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.cake_outlined, color: AppColors.primaryGreen, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                scanResult.dob!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.info_outline, size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            s.verificationDisclaimer,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surfacePaleGreen,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.edit_outlined, size: 14, color: AppColors.primaryGreen),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              s.editDetailsHint,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      text: s.useTheseDetails,
                      icon: Icons.check,
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(this.context, scanResult);
                      },
                    ),
                    const SizedBox(height: 10),
                    SecondaryButton(
                      text: s.scanAgain,
                      icon: Icons.refresh,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPermissionDeniedView() {
    final s = S.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.statusWarningBg,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.statusWarning.withValues(alpha: 0.3)),
              ),
              child: const Icon(
                Icons.videocam_off_outlined,
                color: AppColors.statusWarning,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              s.cameraPermissionRequired,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              s.cameraPermissionDesc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              text: s.grantPermission,
              icon: Icons.lock_open_outlined,
              onPressed: () async {
                await openAppSettings();
              },
            ),
            const SizedBox(height: 12),
            SecondaryButton(
              text: s.enterManually,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraErrorView() {
    final s = S.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.statusAlertBg,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.statusAlert.withValues(alpha: 0.3)),
              ),
              child: const Icon(
                Icons.no_photography_outlined,
                color: AppColors.statusAlert,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              s.cameraUnavailable,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? s.cameraPreviewError,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              text: s.enterManually,
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),
            SecondaryButton(
              text: s.retryCamera,
              icon: Icons.refresh,
              onPressed: _initCamera,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          s.scanAadhaarCard,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: _permissionDenied
            ? _buildPermissionDeniedView()
            : _errorMessage != null
                ? _buildCameraErrorView()
                : !_isCameraInitialized
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                        ),
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          Center(
                            child: CameraPreview(_cameraController!),
                          ),

                          CustomPaint(
                            painter: _ScannerOverlayPainter(),
                          ),

                          Positioned(
                            top: 24,
                            left: 20,
                            right: 20,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                              ),
                              child: Text(
                                s.alignCard,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            bottom: 24,
                            left: 20,
                            right: 20,
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.shield_outlined, size: 14, color: AppColors.badgeGreenText),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            s.aadhaarProcessedSecurely,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  if (_isProcessing)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.75),
                                        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            s.readingAadhaar,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: _buildTorchButton(_cameraController!),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: _captureAndScan,
                                          child: Container(
                                            width: 72,
                                            height: 72,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white, width: 4),
                                              color: AppColors.primaryGreen,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withValues(alpha: 0.4),
                                                  blurRadius: 8,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.camera_alt,
                                              color: Colors.white,
                                              size: 32,
                                            ),
                                          ),
                                        ),
                                        const Expanded(child: SizedBox()),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.55)
      ..style = PaintingStyle.fill;

    final frameWidth = size.width * 0.88;
    final frameHeight = frameWidth / 1.58;
    final frameRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.45),
      width: frameWidth,
      height: frameHeight,
    );
    final roundedFrame = RRect.fromRectAndRadius(frameRect, const Radius.circular(16));

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(roundedFrame)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, backgroundPaint);

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(roundedFrame, borderPaint);

    final cornerPaint = Paint()
      ..color = AppColors.primaryLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const cornerLength = 24.0;

    canvas.drawLine(Offset(frameRect.left, frameRect.top + cornerLength),
        Offset(frameRect.left, frameRect.top + 8), cornerPaint);
    canvas.drawLine(Offset(frameRect.left + 8, frameRect.top),
        Offset(frameRect.left + cornerLength, frameRect.top), cornerPaint);

    canvas.drawLine(Offset(frameRect.right, frameRect.top + cornerLength),
        Offset(frameRect.right, frameRect.top + 8), cornerPaint);
    canvas.drawLine(Offset(frameRect.right - 8, frameRect.top),
        Offset(frameRect.right - cornerLength, frameRect.top), cornerPaint);

    canvas.drawLine(Offset(frameRect.left, frameRect.bottom - cornerLength),
        Offset(frameRect.left, frameRect.bottom - 8), cornerPaint);
    canvas.drawLine(Offset(frameRect.left + 8, frameRect.bottom),
        Offset(frameRect.left + cornerLength, frameRect.bottom), cornerPaint);

    canvas.drawLine(Offset(frameRect.right, frameRect.bottom - cornerLength),
        Offset(frameRect.right, frameRect.bottom - 8), cornerPaint);
    canvas.drawLine(Offset(frameRect.right - 8, frameRect.bottom),
        Offset(frameRect.right - cornerLength, frameRect.bottom), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
