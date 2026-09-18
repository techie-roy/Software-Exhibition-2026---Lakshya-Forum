class AppLanguage {
  final String code;
  final String englishName;
  final String nativeName;
  final String scriptSample;

  const AppLanguage({
    required this.code,
    required this.englishName,
    required this.nativeName,
    required this.scriptSample,
  });

  static const List<AppLanguage> supportedLanguages = [
    AppLanguage(
      code: 'en',
      englishName: 'English',
      nativeName: 'English',
      scriptSample: 'Welcome to AgriQueue',
    ),
    AppLanguage(
      code: 'hi',
      englishName: 'Hindi',
      nativeName: 'हिन्दी',
      scriptSample: 'एग्रीक्यू में आपका स्वागत है',
    ),
    AppLanguage(
      code: 'te',
      englishName: 'Telugu',
      nativeName: 'తెలుగు',
      scriptSample: 'అగ్రి క్యూకి స్వాగతం',
    ),
    AppLanguage(
      code: 'ta',
      englishName: 'Tamil',
      nativeName: 'தமிழ்',
      scriptSample: 'அக்ரி க்யூவிற்கு வரவேற்கிறோம்',
    ),
    AppLanguage(
      code: 'mr',
      englishName: 'Marathi',
      nativeName: 'मराठी',
      scriptSample: 'ॲग्रीक्यू मध्ये आपले स्वागत आहे',
    ),
    AppLanguage(
      code: 'bn',
      englishName: 'Bengali',
      nativeName: 'বাংলা',
      scriptSample: 'অ্যাগ্রিকিউতে স্বাগতম',
    ),
    AppLanguage(
      code: 'gu',
      englishName: 'Gujarati',
      nativeName: 'ગુજરાતી',
      scriptSample: 'એગ્રીક્યુમાં આપનું સ્વાગત છે',
    ),
    AppLanguage(
      code: 'pa',
      englishName: 'Punjabi',
      nativeName: 'ਪੰਜਾਬੀ',
      scriptSample: 'ਐਗਰੀਕਿਊ ਵਿੱਚ ਜੀ ਆਇਆਂ ਨੂੰ',
    ),
    AppLanguage(
      code: 'kn',
      englishName: 'Kannada',
      nativeName: 'ಕನ್ನಡ',
      scriptSample: 'ಅಗ್ರಿಕ್ಯೂಗೆ ಸುಸ್ವಾಗತ',
    ),
  ];
}
