import 'package:agri_queue/models/farmer.dart';
import 'package:agri_queue/widgets/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Farmer farmerWith({String? photoUrl}) => Farmer(
  id: 'FID-TEST',
  name: 'Test Farmer',
  mobile: '+919876543210',
  mandiId: '',
  mandiName: '',
  mandiAddress: '',
  landSizeAcres: 0,
  village: '',
  district: '',
  state: '',
  kisanCreditCard: '',
  aadhaarMasked: '',
  bankAccountMasked: '',
  bankName: '',
  avatarInitials: 'TF',
  photoUrl: photoUrl,
);

void main() {
  testWidgets('shows initials when no profile photo exists', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileAvatar(
            farmer: farmerWith(),
            size: 48,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            borderWidth: 1.5,
            borderColor: Colors.green,
          ),
        ),
      ),
    );

    expect(find.text('TF'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('shows the network photo when a URL exists', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileAvatar(
            farmer: farmerWith(photoUrl: 'https://example.com/photo.jpg'),
            size: 48,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            borderWidth: 1.5,
            borderColor: Colors.green,
          ),
        ),
      ),
    );

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<NetworkImage>());
    expect((image.image as NetworkImage).url, 'https://example.com/photo.jpg');
  });
}
