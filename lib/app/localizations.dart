import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';

class S {
  static const Map<String, Map<String, String>> _translations = {
    'en': {
      // Language screen
      'app_title': 'AgriQueue',
      'app_subtitle': 'Smart Mandi Queue & Procurement System',
      'choose_language': 'Choose your Language',
      'save_language': 'Save Language',
      'continue_': 'Continue',
      // Auth
      'welcome_back': 'Welcome Back',
      'login_subtitle': 'Manage your mandi slots and track your queue',
      'mobile_number': 'Mobile Number',
      'password': 'Password',
      'enter_password': 'Enter your password',
      'forgot_password': 'Forgot Password',
      'login': 'Login',
      'continue_with_otp': 'Continue with OTP',
      'no_account': "Don't have an account? ",
      'register': 'Register',
      'reset_password': 'Reset Password',
      'reset_password_desc': 'For security, a temporary OTP reset link can be sent to your registered mobile number, or you can continue with login directly using "Continue with OTP".',
      'close': 'Close',
      'use_otp_instead': 'Use OTP Instead',
      'otp_hint': 'Please enter your mobile number to receive OTP',
      'invalid_login': 'Invalid login details',
      'email_address': 'Email Address',
      'login_with_email': 'Login with Email',
      'email_login_hint': 'example@gmail.com',
      'or_divider': 'OR',
      'continue_with_google': 'Continue with Google',
      'google_sign_in_unavailable': 'Google Sign-In is not configured for this build yet. Enable the Google provider and add an OAuth web client in Firebase Console, then re-download google-services.json.',
      'google_sign_in_failed': 'Google sign-in failed. Please try again.',
      'firebase_unconfigured': 'Firebase is not configured yet. Finish Firebase setup or continue with OTP login.',
      'reset_via_email_title': 'Reset Password via Email',
      'reset_via_email_desc': 'Enter your registered email address and we will send a password-reset link.',
      'send_reset_link': 'Send Reset Link',
      'reset_email_sent': 'Password reset email sent. Please check your inbox.',
      'email_required_msg': 'Please enter your email address',
      'password_min6_msg': 'Password must be at least 6 characters',
      'confirm_password': 'Confirm Password',
      'retype_password_hint': 'Re-type your password',
      'passwords_do_not_match': 'Passwords do not match',
      'password_required': 'Please confirm your password',
      // Registration
      'create_account': 'Create Account',
      'register_subtitle':
          'Register to book slots for selling your produce at the mandi',
      'aadhaar_number': 'Aadhaar Number',
      'on_device_ocr': 'On-Device OCR',
      'aadhaar_privacy_note': 'Your Aadhaar image is processed securely and is not stored by the app.',
      'aadhaar_detected':
          'Aadhaar details detected. Review and edit the fields below.',
      'full_name': 'Full Name',
      'date_of_birth': 'Date of Birth',
      'email_optional': 'Email (Optional)',
      'next': 'Next',
      'already_registered': 'Already have an account? ',
      'please_enter_mobile': 'Please enter your mobile number first',
      // OTP
      'verify_mobile': 'Verify your mobile number',
      'otp_sent_to': r'Enter the 6-digit OTP sent to $masked',
      'verify_continue': 'Verify & Continue',
      'resend_otp': 'Resend OTP',
      'resend_in': r'Resend OTP in $_countdown seconds',
      'change_mobile': 'Change Mobile Number',
      'enter_all_digits': 'Please enter all 6 digits of the OTP',
      'invalid_otp': 'Invalid OTP',
      'account_created': 'Account created successfully! Welcome to AgriQueue.',
      'registration_failed': 'Registration failed',
      'mobile_not_registered': 'Mobile number not registered',
      'not_registered_desc': 'The number +91 \$_phone is not associated with any farmer account.\nPlease register first to continue.',
      'redirecting_to_registration':
          r'Redirecting to registration in $_countdown seconds...',
      'register_now': 'Register Now',
      'try_another': 'Try Another Number',
      // Demo mode
      'demo_mode_title': 'Demo mode',
      'demo_mode_body': 'Authentication is simulated. Mobile number + password and OTP sign-in accept any password and any 6-digit OTP for demonstration only — this is not real verification.',
      'demo_mode_title_real': 'Password sign-in is demo',
      'demo_mode_body_real': 'Mobile number + password login accepts any password for demonstration only — no password backend is wired yet. OTP verification is real Firebase SMS: Google sends the code (SMS charges/quota may apply).',
      // Auth flow errors
      'otp_send_failed': 'Could not send the OTP. Please try again.',
      'mobile_already_registered':
          'This mobile number is already registered. Please log in instead.',
      // Simulated data disclosures
      'simulated_data_label': 'SIMULATED DATA',
      'simulated_queue_notice': 'Queue position and wait time are simulated demo values, not a live mandi feed.',
      'simulated_payment_notice': 'Sample transactions. Payment statuses and UTR numbers are simulated, not real bank settlements.',
      'simulated_notifications_notice':
          'Sample notifications. Nothing is delivered to your device.',
      'simulated_telemetry_notice': 'Gate crowd numbers are simulated and refreshed locally, not a live feed.',
      // Home
      'good_morning': 'Good morning',
      'good_afternoon': 'Good afternoon',
      'good_evening': 'Good evening',
      'mandi_notifications': 'Mandi Notifications',
      'queue_moving': 'Queue Moving Promptly',
      'queue_moving_desc':
          'Gate 2 is processing 25 farmers per hour. Keep your pass ready.',
      'msp_update': 'MSP Rate Update',
      'msp_update_desc':
          'Government procurement rates for Wheat stable at ₹2,125/Qtl.',
      'need_to_sell': 'Need to sell your produce?',
      'book_slot_now': 'Book Your Slot Now',
      'book_slot': 'Book Slot',
      'selected_mandi': 'Selected Mandi',
      'open': 'Open',
      'current_gate_status': 'Current Gate Status',
      'gates_active': 'Gates 1, 2 & 4 Active',
      'next_available_slot': 'Next Available Slot',
      'your_token': 'Your Token',
      'view_details': 'View Details',
      'market_price_today': 'Market Price (Today)',
      'view_all_prices': 'View All Prices',
      'mandi_insights': 'Mandi Insights',
      'ai_insight': 'AI Insight',
      'live_gate_crowd': 'Live Gate Crowd',
      'realtime_queue': 'Simulated gate load across procurement gates',
      'refresh': 'Refresh',
      'gate_telemetry_updated': 'Simulated gate telemetry refreshed.',
      // Queue tracking
      'live_mandi_queue': 'Mandi Queue (Demo)',
      'your_live_token': 'Your Token',
      'assigned_gate': 'Assigned Gate',
      'farmers_ahead': 'Farmers Ahead',
      'estimated_wait': 'Estimated Wait',
      'procurement_timeline': 'Procurement Stage Timeline',
      'before_gate': 'Before Entering Gate',
      'original_aadhaar': 'Original Aadhaar card or Voter ID',
      'bank_passbook': 'Bank passbook or cancelled cheque',
      'land_record': 'Land Record / Khasra Khatauni copy',
      'grain_sample': 'Clean grain sample ready for moisture meter test',
      'queue_updated': 'Queue telemetry updated',
      // Slot booking
      'book_procurement_slot': 'Book Procurement Slot',
      'today': 'Today',
      'tomorrow': 'Tomorrow',
      'day_after': 'Day After',
      'pick_date': 'Pick Date',
      'no_slots': 'No slots available for this selection',
      'try_different': 'Try selecting a different date or crop',
      'book_slot_btn': 'Book Slot',
      'slot_full': 'Slot Full',
      'booked': 'booked',
      // Procurement
      'my_bookings_payments': 'My Bookings & Payments',
      'payment_history': 'Payment History',
      'mandi_bookings': 'Mandi Bookings',
      'total_earnings': 'Total Earnings',
      'paid': 'Paid',
      'processing_': 'Processing',
      'pending': 'Pending',
      'procurement_transactions': 'Procurement Transactions',
      'view_slip': 'View Slip',
      'e_procurement_slip': 'E-Procurement Slip',
      'transaction_id': 'Transaction ID',
      'crop_procured': 'Crop Procured',
      'quantity': 'Quantity',
      'rate_quintal': 'Rate / Quintal',
      'total_amount': 'Total Net Amount',
      'bank_account': 'Bank Account',
      'utr_reference': 'UTR / Reference',
      'download_pdf': 'Preview E-Slip (Demo)',
      'slip_downloaded': 'Demo e-slip preview — no PDF file is downloaded.',
      'utr_pending_clearance': 'Awaiting bank clearance (demo)',
      'utr_awaiting_slip': 'Awaiting procurement slip (demo)',
      // Market prices
      'mandi_crop_prices': 'Mandi Crop Prices',
      'search_crops': 'Search crops (e.g. Wheat, धान)...',
      'no_crops_match': 'No crops match your query',
      'rates_per_quintal': 'Rates per Quintal',
      // Profile
      'farmer_profile': 'Farmer Profile',
      'personal_info': 'Personal Information',
      'my_mandi': 'My Mandi',
      'my_documents': 'My Documents',
      'kcc_aadhaar_bank': 'KCC, Aadhaar, Bank Linked',
      'language_hindi': 'Language / भाषा',
      'notifications_alerts': 'Notifications & Alerts',
      'sms_mandi_reminders': 'SMS and Mandi reminders active',
      'notifications_enabled':
          'Notifications are enabled for all booked slots.',
      'help_support': 'Help & Support',
      'toll_free': 'Toll free helpline & FAQs',
      'logout': 'Logout',
      'logout_title': 'Logout from AgriQueue?',
      'logout_desc': 'You will need to login again using your mobile number to access your slots and tokens.',
      'cancel': 'Cancel',
      'selected_mandi_label': 'Selected mandi',
      // Aadhaar scanner
      'scan_aadhaar': 'Scan Aadhaar Card',
      'align_card': 'Align your Aadhaar card inside the frame',
      'aadhaar_processed_securely': 'Your Aadhaar image is processed securely and is not stored by the app.',
      'reading_aadhaar': 'Reading Aadhaar card...',
      'turn_flashlight_off': 'Turn flashlight off',
      'turn_flashlight_on': 'Turn flashlight on',
      'camera_permission_required': 'Camera Permission Required',
      'camera_permission_desc': 'Camera access is needed to scan your Aadhaar card on-device. Images are never uploaded or saved.',
      'grant_permission': 'Grant Permission',
      'camera_unavailable': 'Camera Unavailable',
      'retry_camera': 'Retry Camera',
      'try_again': 'Try Again',
      'enter_manually': 'Enter Manually',
      'aadhaar_detected_title': 'Aadhaar details detected',
      'verify_extracted': 'Please verify the extracted details below',
      'use_details': 'Use these details',
      'scan_again': 'Scan Again',
      'edit_details_hint':
          'You can edit these details on the registration form.',
      'couldnt_detect': "Couldn't Detect Aadhaar Number",
      'couldnt_read_aadhaar': "Couldn't read the Aadhaar number. Please place the document inside the frame and try again.",
      // Booking confirmation
      'booking_confirmed': 'Booking Confirmed',
      'slot_booked': 'Slot Successfully Booked!',
      'token_pass_issued': 'Your entry token and pass have been issued.',
      'your_token_number': 'Your Token Number',
      'track_live_queue': 'Track Live Queue',
      'go_to_dashboard': 'Go to Dashboard',
      'arrive_early': 'Please arrive at least 15 minutes before your time slot. Carry original Aadhaar and Bank Passbook.',
      'mandi': 'Mandi',
      'crop': 'Crop',
      'date': 'Date',
      'time_slot': 'Time Slot',
      'farmer_name': 'Farmer Name',
      'faq': 'Frequently Asked Questions',
      // Nav bar
      'nav_home': 'Home',
      'nav_my_bookings': 'My Bookings',
      'nav_live_queue': 'Live Queue',
      'nav_price': 'Price',
      'nav_profile': 'Profile',
      // Misc
      'now': 'Now',
      'today_label': 'Today',
      'scan': 'Scan',
      'min': 'Min',
      'max': 'Max',
      'farmers': 'Farmers',
      'capacity': 'Capacity',
      'min_price': 'Min Price',
      'max_price': 'Max Price',
      'govt_msp': 'Govt MSP',
      'price_banner': 'Sample Rates • Demo Data',
      'price_banner_live': 'Live Mandi Rates',
      'price_source_govt': 'Source: data.gov.in (Government of India)',
      'simulated_price_notice': 'Sample crop rates for demonstration only — this is not a live mandi feed. Live government rates appear here when a data.gov.in API key is configured.',
      'live_prices_unavailable': 'Live government rates are unavailable right now — showing sample (demo) rates.',
      'sample_rates_caption':
          'Sample rates (demo data) — not a live mandi feed',
      // Targeted additions
      'available': 'Available',
      'filling_fast': 'Filling Fast',
      'confirmed': 'Confirmed',
      'in_queue': 'In Queue',
      'completed': 'Completed',
      'cancelled': 'Cancelled',
      'active': 'Active',
      'ten_min_ago': '10 min ago',
      'one_hour_ago': '1 hour ago',
      'predictive_mock': 'PREDICTIVE MOCK',
      'next_slot_mock': 'Today, 02:00 PM',
      'farmer_id': 'Farmer ID',
      'land_size': 'Land Size',
      'acres': 'Acres',
      'village': 'Village',
      'district': 'District',
      'state': 'State',
      'kcc_document': 'Kisan Credit Card (KCC)',
      'aadhaar_document': 'Aadhaar Card',
      'helpline_hours': '1800-180-1551 (6 AM – 10 PM)',
      'faq_1': 'How to cancel or reschedule a booked slot?',
      'faq_2': 'What happens if my vehicle reaches late?',
      'faq_3': 'When will procurement payment reflect in my bank?',
      'create_password_hint': 'Create a password',
      'hint_full_name': 'e.g. Ramesh Patel',
      // Validators
      'v_mobile_required': 'Please enter your mobile number',
      'v_mobile_invalid': 'Please enter a valid 10-digit mobile number',
      'v_password_required': 'Please enter your password',
      'v_password_short': 'Password must be at least 4 characters',
      'v_name_required': 'Please enter your full name',
      'v_name_invalid': 'Please enter a valid name',
      'v_email_invalid': 'Please enter a valid email address',
      'v_dob_required': 'Please enter your date of birth',
      'v_dob_format': 'Use DD/MM/YYYY format',
      'v_dob_invalid': 'Please enter a valid date of birth',
      'v_aadhaar_required': 'Please enter your 12-digit Aadhaar number',
      'v_aadhaar_length': 'Aadhaar number must be exactly 12 digits',
      'v_aadhaar_start': 'Aadhaar number cannot start with 0 or 1',
      'v_aadhaar_checksum': 'Invalid Aadhaar number (checksum failed)',
      // Units & tooltips
      'quintals': 'Quintals',
      'qtl': 'Qtl',
      'show_full_number': 'Show full number',
      'hide_number': 'Hide number',
      // Aadhaar scanner errors
      'no_camera_found': 'No camera found on this device.',
      'camera_unavailable_desc': 'Camera unavailable. Please verify device permissions or enter your Aadhaar number manually.',
      'camera_preview_error': 'Unable to start camera preview.',
      'verification_disclaimer': 'Format validation only. This does not verify identity or authenticity with UIDAI.',
      // Crop names (stable IDs resolved through localization)
      'crop_wheat': 'Wheat',
      'crop_paddy': 'Paddy',
      'crop_mustard': 'Mustard',
      'crop_maize': 'Maize',
      'crop_sugarcane': 'Sugarcane',
      'crop_potato': 'Potato',
      'crop_all': 'All',
      // Market categories
      'category_cereals': 'Cereals',
      'category_oilseeds': 'Oilseeds',
      'category_vegetables': 'Vegetables',
      'category_cash_crops': 'Cash Crops',
      // Gate status
      'gate_status_active': 'Active',
      'gate_status_high_crowd': 'High Crowd',
      'gate_status_smooth': 'Smooth',
      // Queue timeline steps
      'step_booked': 'Booked',
      'step_booked_desc': 'Slot reserved successfully',
      'step_arrived': 'Arrived',
      'step_arrived_desc': 'Vehicle checked at mandi entry',
      'step_in_queue': 'In Queue',
      'step_in_queue_desc': 'Waiting in holding yard',
      'step_at_gate': 'At Gate',
      'step_at_gate_desc': 'Proceeding to weighbridge scale',
      'step_procurement': 'Procurement',
      'step_procurement_desc': 'Quality inspection & unloading',
      'step_completed': 'Completed',
      'step_completed_desc': 'E-J form generated & payment dispatched',
      // Live queue
      'live_badge': 'DEMO',
      'last_updated': 'Last updated',
      'refreshing_in': 'Refreshing in',
      'seconds_suffix': 's',
      'auto_refresh_30s': 'Auto-refresh (demo) every 30 seconds',
      'fetching_live_data': 'Fetching simulated queue data...',
      'queue_refresh_error': 'Could not refresh queue. Showing last data.',
      'tap_to_retry': 'Tap to retry',
      // Booking confirmation
      'booking_id': 'Booking ID: ',
      // AI insight (mock)
      'ai_insight_text': 'Wheat prices may remain stable today with slight upward bias due to high mandi arrival quality. Ideal arrival window: Gate 2 before 11:00 AM.',
      // Cancel booking
      'cancel_booking': 'Cancel Booking',
      'cancel_booking_confirm': 'Are you sure you want to cancel this booking?',
      'keep_booking': 'Keep Booking',
      'confirm_cancel': 'Cancel Booking',
      'booking_cancelled_success': 'Booking cancelled successfully.',
      'booking_cancelled': 'Booking Cancelled',
      // Voice booking
      'book_by_voice': 'Book by Voice',
      'voice_booking_subtitle': 'Speak to book your mandi slot',
      'listening': 'Listening...',
      'speak_now': 'Speak now',
      'which_time_slot': 'Which time slot do you need?',
      'say_crop_name': 'Say the crop name, e.g. Wheat, Paddy',
      'say_time': 'Say the time, e.g. 9 AM, 11 baje',
      'voice_unavailable': 'Voice booking unavailable. You can book manually.',
      'voice_error': 'Could not recognize. Please try again.',
      'no_speech_detected': 'No speech detected. Please try again.',
      'microphone_permission_denied':
          'Microphone permission is required for voice booking.',
      'checking_availability': 'Checking availability...',
      'slot_available': 'Slot available',
      'slot_unavailable': 'Requested slot unavailable',
      'best_available_booked': 'Best available slot booked automatically',
      'voice_booking_success': 'Token booked successfully',
      'voice_booking_error': 'Could not complete booking. Please try again.',
      'no_available_slots':
          'No available slots found. Please try manual booking.',
      'crop_selected': 'Crop selected',
      'invalid_crop': 'Could not recognize the crop. Please try again.',
      'invalid_time': 'Could not understand the time. Please try again.',
      'try_manual_booking': 'Try Manual Booking',
      'token_details': 'Token Details',
      'requested_slot': 'Requested Slot',
      'booked_slot': 'Booked Slot',
      'processing_voice': 'Processing...',
      // Cancel booking getter
      'cancel_booking_action': 'Cancel Booking',
      // Voice booking flow
      'press_mic_to_speak': 'Press the mic and speak',
      'voice_example_hint': 'Try: "Wheat at 9 AM" or "गेहूं, सुबह 9 बजे"',
      'start_voice': 'Start',
      'initializing_voice': 'Starting voice assistant…',
      'open_settings': 'Open Settings',
      'requested_slot_unavailable_auto': 'Your requested slot is not available. We have booked the nearest available slot for you.',
      'listen_again': 'Listen Again',
      'grant_mic_permission': 'Grant Microphone Permission',
      // Voice booking spoken announcements ({...} placeholders are replaced)
      'voice_crop_prompt': 'Please tell me the crop you want to book. For example, wheat, paddy, or mustard.',
      'voice_time_prompt':
          'You selected {crop}. Please tell me which time slot you need.',
      'voice_checking_announcement':
          'You selected {time}. Checking slot availability.',
      'voice_slot_available_announcement':
          'The slot at {time} is available. Your token is being booked.',
      'voice_fallback_announcement': 'The slot at {requested} is not available. Booking the nearest available slot for you at {booked}.',
      'voice_success_announcement': 'Your token has been booked successfully. Your slot is at {time}. Your token number is {token}.',
      'voice_permission_denied_speech': 'Microphone permission not granted. Please grant microphone permission and try again.',
      'voice_not_understood': 'I did not understand that. Please say it again.',
      'voice_repeat_crop':
          'Could not recognize the crop. Please say the crop name again.',
      'voice_repeat_time':
          'Could not understand the time. Please say the time again.',
      'voice_no_slots_announcement': 'Sorry, no slots are available for this crop. Please try a different time or book manually.',
      'voice_tts_error': 'Voice assistant could not be started. Please check your device settings and try again.',
      'reason_label': 'Reason',
      'fallback_reason':
          'Requested slot unavailable - booked nearest available slot.',
    },
    'hi': {
      // Language screen
      'app_title': 'एग्रीक्यू',
      'app_subtitle': 'स्मार्ट मंडी कतार और प्रोक्योरमेंट सिस्टम',
      'choose_language': 'अपनी भाषा चुनें',
      'save_language': 'भाषा सहेजें',
      'continue_': 'जारी रखें',
      // Auth
      'welcome_back': 'वापसी पर स्वागत है',
      'login_subtitle': 'अपने मंडी स्लॉट प्रबंधित करें और कतार ट्रैक करें',
      'mobile_number': 'मोबाइल नंबर',
      'password': 'पासवर्ड',
      'enter_password': 'अपना पासवर्ड दर्ज करें',
      'forgot_password': 'पासवर्ड भूल गए?',
      'login': 'लॉगिन',
      'continue_with_otp': 'OTP से जारी रखें',
      'no_account': 'खाता नहीं है? ',
      'register': 'रजिस्टर करें',
      'reset_password': 'पासवर्ड रीसेट करें',
      'reset_password_desc': 'सुरक्षा के लिए, आपके पंजीकृत मोबाइल नंबर पर एक अस्थायी OTP रीसेट लिंक भेजा जा सकता है, या आप "OTP से जारी रखें" का उपयोग करके सीधे लॉग इन कर सकते हैं।',
      'close': 'बंद करें',
      'use_otp_instead': 'OTP का उपयोग करें',
      'otp_hint': 'कृपया OTP प्राप्त करने के लिए अपना मोबाइल नंबर दर्ज करें',
      'invalid_login': 'अमान्य लॉगिन विवरण',
      'email_address': 'ईमेल पता',
      'login_with_email': 'ईमेल से लॉगिन करें',
      'email_login_hint': 'example@gmail.com',
      'or_divider': 'या',
      'continue_with_google': 'Google से जारी रखें',
      'google_sign_in_unavailable': 'इस बिल्ड के लिए Google साइन-इन अभी कॉन्फ़िगर नहीं है। Firebase Console में Google प्रोवाइडर सक्षम करें और एक OAuth वेब क्लाइंट जोड़ें, फिर google-services.json दोबारा डाउनलोड करें।',
      'google_sign_in_failed':
          'Google साइन-इन विफल रहा। कृपया पुनः प्रयास करें।',
      'firebase_unconfigured': 'फायरबेस अभी कॉन्फ़िगर नहीं है। फायरबेस सेटअप पूरा करें या OTP लॉगिन से जारी रखें।',
      'reset_via_email_title': 'ईमेल द्वारा पासवर्ड रीसेट करें',
      'reset_via_email_desc':
          'अपना पंजीकृत ईमेल पता दर्ज करें, हम पासवर्ड-रीसेट लिंक भेजेंगे।',
      'send_reset_link': 'रीसेट लिंक भेजें',
      'reset_email_sent':
          'पासवर्ड रीसेट ईमेल भेज दिया गया है। कृपया अपना इनबॉक्स जांचें।',
      'email_required_msg': 'कृपया अपना ईमेल पता दर्ज करें',
      'password_min6_msg': 'पासवर्ड कम से कम 6 अक्षरों का होना चाहिए',
      'confirm_password': 'पासवर्ड की पुष्टि करें',
      'retype_password_hint': 'पासवर्ड फिर से टाइप करें',
      'passwords_do_not_match': 'पासवर्ड मेल नहीं खाते',
      'password_required': 'कृपया अपना पासवर्ड दोबारा दर्ज करें',
      // Registration
      'create_account': 'खाता बनाएं',
      'register_subtitle':
          'मंडी में अपनी उपज बेचने के लिए स्लॉट बुक करने हेतु पंजीकरण करें',
      'aadhaar_number': 'आधार नंबर',
      'on_device_ocr': 'ऑन-डिवाइस OCR',
      'aadhaar_privacy_note': 'आपकी आधार छवि सुरक्षित रूप से प्रोसेस होती है और ऐप द्वारा संग्रहीत नहीं की जाती है।',
      'aadhaar_detected':
          'आधार विवरण का पता चला। नीचे के फ़ील्ड की समीक्षा और संपादन करें।',
      'full_name': 'पूरा नाम',
      'date_of_birth': 'जन्म तिथि',
      'email_optional': 'ईमेल (वैकल्पिक)',
      'next': 'अगला',
      'already_registered': 'पहले से पंजीकृत? ',
      'please_enter_mobile': 'कृपया अपना मोबाइल नंबर दर्ज करें',
      // OTP
      'verify_mobile': 'अपने मोबाइल नंबर की पुष्टि करें',
      'otp_sent_to': r'को $masked पर भेजा गया 6-अंक OTP दर्ज करें',
      'verify_continue': 'सत्यापित करें और जारी रखें',
      'resend_otp': 'OTP पुनः भेजें',
      'resend_in': r'OTP पुनः भेजें $_countdown सेकंड में',
      'change_mobile': 'मोबाइल नंबर बदलें',
      'enter_all_digits': 'कृपया OTP के सभी 6 अंक दर्ज करें',
      'invalid_otp': 'अमान्य OTP',
      'account_created':
          'खाता सफलतापूर्वक बनाया गया! एग्रीक्यू में आपका स्वागत है।',
      'registration_failed': 'पंजीकरण विफल',
      'mobile_not_registered': 'मोबाइल नंबर पंजीकृत नहीं है',
      'not_registered_desc': 'नंबर +91 \$_phone किसी भी किसान खाते से संबद्ध नहीं है।\nकृपया जारी रखने के लिए पहले पंजीकरण करें।',
      'redirecting_to_registration':
          r'$_countdown सेकंड में पंजीकरण की ओर पुनर्निर्देशित हो रहे हैं...',
      'register_now': 'अभी पंजीकरण करें',
      'try_another': 'दूसरा नंबर आज़माएं',
      // Demo mode
      'demo_mode_title': 'डेमो मोड',
      'demo_mode_body': 'प्रमाणीकरण नकली है। मोबाइल नंबर + पासवर्ड और OTP साइन-इन में प्रदर्शन के लिए कोई भी पासवर्ड और कोई भी 6-अंकीय OTP स्वीकार किया जाता है — यह वास्तविक सत्यापन नहीं है।',
      'demo_mode_title_real': 'पासवर्ड साइन-इन डेमो है',
      'demo_mode_body_real': 'मोबाइल नंबर + पासवर्ड लॉगिन केवल प्रदर्शन के लिए कोई भी पासवर्ड स्वीकार करता है — अभी कोई पासवर्ड बैकएंड नहीं जुड़ा है। OTP सत्यापन वास्तविक Firebase SMS है: Google कोड भेजता है (SMS शुल्क/कोटा लागू हो सकता है)।',
      // Auth flow errors
      'otp_send_failed': 'OTP नहीं भेजा जा सका। कृपया पुनः प्रयास करें।',
      'mobile_already_registered':
          'यह मोबाइल नंबर पहले से पंजीकृत है। कृपया लॉगिन करें।',
      // Simulated data disclosures
      'simulated_data_label': 'नकली डेटा',
      'simulated_queue_notice': 'कतार की स्थिति और प्रतीक्षा समय नकली डेमो मान हैं, कोई लाइव मंडी फ़ीड नहीं।',
      'simulated_payment_notice': 'नमूना लेनदेन। भुगतान स्थिति और UTR नंबर नकली हैं, वास्तविक बैंक निपटान नहीं।',
      'simulated_notifications_notice':
          'नमूना सूचनाएं। आपके डिवाइस पर कुछ भी नहीं भेजा जाता।',
      'simulated_telemetry_notice': 'गेट भीड़ संख्याएं नकली हैं और स्थानीय रूप से रिफ्रेश होती हैं, कोई लाइव फ़ीड नहीं।',
      // Home
      'good_morning': 'शुभ प्रभात',
      'good_afternoon': 'नमस्ते',
      'good_evening': 'शुभ संध्या',
      'mandi_notifications': 'मंडी सूचनाएं',
      'queue_moving': 'कतार तेजी से आगे बढ़ रही है',
      'queue_moving_desc': 'गेट 2 प्रति घंटे 25 किसानों को प्रोसेस कर रहा है। अपना पास तैयार रखें।',
      'msp_update': 'MSP दर अपडेट',
      'msp_update_desc':
          'गेहूं की सरकारी खरीद दरें ₹2,125/क्विंटल पर स्थिर हैं।',
      'need_to_sell': 'अपनी उपज बेचनी है?',
      'book_slot_now': 'अभी अपना स्लॉट बुक करें',
      'book_slot': 'स्लॉट बुक करें',
      'selected_mandi': 'चयनित मंडी',
      'open': 'खुला',
      'current_gate_status': 'वर्तमान गेट स्थिति',
      'gates_active': 'गेट 1, 2 और 4 सक्रिय',
      'next_available_slot': 'अगला उपलब्ध स्लॉट',
      'your_token': 'आपका टोकन',
      'view_details': 'विवरण देखें',
      'market_price_today': 'बाज़ार मूल्य (आज)',
      'view_all_prices': 'सभी मूल्य देखें',
      'mandi_insights': 'मंडी अंतर्दृष्टि',
      'ai_insight': 'AI अंतर्दृष्टि',
      'live_gate_crowd': 'लाइव गेट भीड़',
      'realtime_queue': 'प्रोक्योरमेंट गेट में नकली कतार लोड',
      'refresh': 'रिफ्रेश',
      'gate_telemetry_updated': 'नकली गेट टेलीमेट्री रिफ्रेश की गई।',
      // Queue tracking
      'live_mandi_queue': 'मंडी कतार (डेमो)',
      'your_live_token': 'आपका टोकन',
      'assigned_gate': 'नियुक्त गेट',
      'farmers_ahead': 'किसान आगे',
      'estimated_wait': 'अनुमानित प्रतीक्षा',
      'procurement_timeline': 'प्रोक्योरमेंट चरण समयरेखा',
      'before_gate': 'गेट में प्रवेश से पहले',
      'original_aadhaar': 'मूल आधार कार्ड या वोटर आईडी',
      'bank_passbook': 'बैंक पासबुक या रद्द चेक',
      'land_record': 'भूमि रिकॉर्ड / खसरा खतौनी प्रतिलिपि',
      'grain_sample': 'नमी मीटर परीक्षण के लिए तैयार स्वच्छ अनाज नमूना',
      'queue_updated': 'कतार टेलीमेट्री अपडेट',
      // Slot booking
      'book_procurement_slot': 'प्रोक्योरमेंट स्लॉट बुक करें',
      'today': 'आज',
      'tomorrow': 'कल',
      'day_after': 'परसों',
      'pick_date': 'तिथि चुनें',
      'no_slots': 'इस चयन के लिए कोई स्लॉट उपलब्ध नहीं',
      'try_different': 'कोई अलग तिथि या फसल चुनने का प्रयास करें',
      'book_slot_btn': 'स्लॉट बुक करें',
      'slot_full': 'स्लॉट भरा',
      'booked': 'बुक किया',
      // Procurement
      'my_bookings_payments': 'मेरी बुकिंग और भुगतान',
      'payment_history': 'भुगतान इतिहास',
      'mandi_bookings': 'मंडी बुकिंग',
      'total_earnings': 'कुल कमाई',
      'paid': 'भुगतान किया',
      'processing_': 'प्रक्रिया में',
      'pending': 'लंबित',
      'procurement_transactions': 'प्रोक्योरमेंट लेनदेन',
      'view_slip': 'स्लिप देखें',
      'e_procurement_slip': 'ई-प्रोक्योरमेंट स्लिप',
      'transaction_id': 'लेनदेन आईडी',
      'crop_procured': 'कटाई की फसल',
      'quantity': 'मात्रा',
      'rate_quintal': 'दर / क्विंटल',
      'total_amount': 'कुल राशि',
      'bank_account': 'बैंक खाता',
      'utr_reference': 'UTR / संदर्भ',
      'download_pdf': 'ई-स्लिप पूर्वावलोकन (डेमो)',
      'slip_downloaded':
          'डेमो ई-स्लिप पूर्वावलोकन — कोई PDF फ़ाइल डाउनलोड नहीं होती।',
      'utr_pending_clearance': 'बैंक क्लीयरेंस प्रतीक्षित (डेमो)',
      'utr_awaiting_slip': 'प्रोक्योरमेंट स्लिप प्रतीक्षित (डेमो)',
      // Market prices
      'mandi_crop_prices': 'मंडी फसल मूल्य',
      'search_crops': 'फसलें खोजें (जैसे गेहूं, धान)...',
      'no_crops_match': 'आपकी खोज से कोई फसल मेल नहीं खाती',
      'rates_per_quintal': 'प्रति क्विंटल दरें',
      // Profile
      'farmer_profile': 'किसान प्रोफ़ाइल',
      'personal_info': 'व्यक्तिगत जानकारी',
      'my_mandi': 'मेरी मंडी',
      'my_documents': 'मेरे दस्तावेज',
      'kcc_aadhaar_bank': 'KCC, आधार, बैंक लिंक',
      'language_hindi': 'भाषा',
      'notifications_alerts': 'सूचनाएं और अलर्ट',
      'sms_mandi_reminders': 'SMS और मंडी अनुस्मारक सक्रिय',
      'notifications_enabled': 'सभी बुक किए गए स्लॉट के लिए सूचनाएं सक्षम हैं।',
      'help_support': 'सहायता और समर्थन',
      'toll_free': 'टोल-फ्री हेल्पलाइन और FAQs',
      'logout': 'लॉगआउट',
      'logout_title': 'एग्रीक्यू से लॉगआउट करें?',
      'logout_desc': 'अपने स्लॉट और टोकन तक पहुंचने के लिए आपको फिर से अपने मोबाइल नंबर से लॉगिन करना होगा।',
      'cancel': 'रद्द करें',
      'selected_mandi_label': 'चयनित मंडी',
      // Aadhaar scanner
      'scan_aadhaar': 'आधार कार्ड स्कैन करें',
      'align_card': 'अपने आधार कार्ड को फ्रेम के अंदर संरेखित करें',
      'aadhaar_processed_securely': 'आपकी आधार छवि सुरक्षित रूप से प्रोसेस होती है और ऐप द्वारा संग्रहीत नहीं की जाती है।',
      'reading_aadhaar': 'आधार कार्ड पढ़ा जा रहा है...',
      'turn_flashlight_off': 'फ्लैशलाइट बंद करें',
      'turn_flashlight_on': 'फ्लैशलाइट चालू करें',
      'camera_permission_required': 'कैमरा अनुमति आवश्यक',
      'camera_permission_desc': 'आपके आधार कार्ड को ऑन-डिवाइस स्कैन करने के लिए कैमरा एक्सेस आवश्यक है। छवियां कभी अपलोड या सहेजी नहीं जातीं।',
      'grant_permission': 'अनुमति दें',
      'camera_unavailable': 'कैमरा अनुपलब्ध',
      'retry_camera': 'कैमरा पुनः प्रयास करें',
      'try_again': 'पुनः प्रयास करें',
      'enter_manually': 'मैन्युअली दर्ज करें',
      'aadhaar_detected_title': 'आधार विवरण का पता चला',
      'verify_extracted': 'कृपया निकाले गए विवरण की पुष्टि करें',
      'use_details': 'इन विवरणों का उपयोग करें',
      'scan_again': 'पुनः स्कैन करें',
      'edit_details_hint':
          'आप पंजीकरण फॉर्म पर इन विवरणों को संपादित कर सकते हैं।',
      'couldnt_detect': 'आधार नंबर का पता नहीं चल सका',
      'couldnt_read_aadhaar': 'आधार नंबर नहीं पढ़ा जा सका। कृपया दस्तावेज़ को फ्रेम के अंदर रखें और पुनः प्रयास करें।',
      // Booking confirmation
      'booking_confirmed': 'बुकिंग पुष्टि',
      'slot_booked': 'स्लॉट सफलतापूर्वक बुक!',
      'token_pass_issued': 'आपका प्रवेश टोकन और पास जारी किया गया है।',
      'your_token_number': 'आपका टोकन नंबर',
      'track_live_queue': 'लाइव कतार ट्रैक करें',
      'go_to_dashboard': 'डैशबोर्ड पर जाएं',
      'arrive_early': 'कृपया अपने स्लॉट से कम से कम 15 मिनट पहले पहुंचें। मूल आधार और बैंक पासबुक साथ लाएं।',
      'mandi': 'मंडी',
      'crop': 'फसल',
      'date': 'तिथि',
      'time_slot': 'समय स्लॉट',
      'farmer_name': 'किसान का नाम',
      'faq': 'अक्सर पूछे जाने वाले प्रश्न',
      // Nav bar
      'nav_home': 'होम',
      'nav_my_bookings': 'मेरी बुकिंग',
      'nav_live_queue': 'लाइव कतार',
      'nav_price': 'मूल्य',
      'nav_profile': 'प्रोफ़ाइल',
      // Misc
      'now': 'अभी',
      'today_label': 'आज',
      'scan': 'स्कैन',
      'min': 'न्यूनतम',
      'max': 'अधिकतम',
      'farmers': 'किसान',
      'capacity': 'क्षमता',
      'min_price': 'न्यूनतम मूल्य',
      'max_price': 'अधिकतम मूल्य',
      'govt_msp': 'सरकारी एमएसपी',
      'price_banner': 'नमूना दरें • डेमो डेटा',
      'price_banner_live': 'लाइव मंडी दरें',
      'price_source_govt': 'स्रोत: data.gov.in (भारत सरकार)',
      'simulated_price_notice': 'ये फसल दरें केवल प्रदर्शन के नमूने हैं — यह लाइव मंडी फ़ीड नहीं है। data.gov.in API कुंजी कॉन्फ़िगर होने पर यहाँ सरकारी लाइव दरें दिखेंगी।',
      'live_prices_unavailable': 'सरकारी लाइव दरें अभी उपलब्ध नहीं हैं — नमूना (डेमो) दरें दिख रही हैं।',
      'sample_rates_caption': 'नमूना दरें (डेमो डेटा) — लाइव मंडी फ़ीड नहीं',
      // Targeted additions
      'available': 'उपलब्ध',
      'filling_fast': 'तेज़ी से भर रहा है',
      'confirmed': 'पुष्टि हुई',
      'in_queue': 'कतार में',
      'completed': 'पूर्ण',
      'cancelled': 'रद्द',
      'active': 'सक्रिय',
      'ten_min_ago': '10 मिनट पहले',
      'one_hour_ago': '1 घंटा पहले',
      'predictive_mock': 'पूर्वानुमानित मॉक',
      'next_slot_mock': 'आज, दोपहर 02:00 बजे',
      'farmer_id': 'किसान आईडी',
      'land_size': 'भूमि का आकार',
      'acres': 'एकड़',
      'village': 'गांव',
      'district': 'जिला',
      'state': 'राज्य',
      'kcc_document': 'किसान क्रेडिट कार्ड (केसीसी)',
      'aadhaar_document': 'आधार कार्ड',
      'helpline_hours': '1800-180-1551 (सुबह 6 बजे – रात 10 बजे)',
      'faq_1': 'बुक किया गया स्लॉट कैसे रद्द या पुनर्निर्धारित करें?',
      'faq_2': 'अगर मेरा वाहन देर से पहुंचे तो क्या होगा?',
      'faq_3': 'खरीद भुगतान मेरे बैंक में कब दिखेगा?',
      'create_password_hint': 'पासवर्ड बनाएं',
      'hint_full_name': 'जैसे रमेश पटेल',
      // Validators
      'v_mobile_required': 'कृपया अपना मोबाइल नंबर दर्ज करें',
      'v_mobile_invalid': 'कृपया एक मान्य 10-अंकीय मोबाइल नंबर दर्ज करें',
      'v_password_required': 'कृपया अपना पासवर्ड दर्ज करें',
      'v_password_short': 'पासवर्ड कम से कम 4 अक्षरों का होना चाहिए',
      'v_name_required': 'कृपया अपना पूरा नाम दर्ज करें',
      'v_name_invalid': 'कृपया एक मान्य नाम दर्ज करें',
      'v_email_invalid': 'कृपया एक मान्य ईमेल पता दर्ज करें',
      'v_dob_required': 'कृपया अपनी जन्म तिथि दर्ज करें',
      'v_dob_format': 'DD/MM/YYYY प्रारूप में दर्ज करें',
      'v_dob_invalid': 'कृपया एक मान्य जन्म तिथि दर्ज करें',
      'v_aadhaar_required': 'कृपया अपना 12-अंकीय आधार नंबर दर्ज करें',
      'v_aadhaar_length': 'आधार नंबर ठीक 12 अंकों का होना चाहिए',
      'v_aadhaar_start': 'आधार नंबर 0 या 1 से शुरू नहीं हो सकता',
      'v_aadhaar_checksum': 'अमान्य आधार नंबर (चेकसम विफल)',
      // Units & tooltips
      'quintals': 'क्विंटल',
      'qtl': 'क्विं',
      'show_full_number': 'पूरा नंबर दिखाएं',
      'hide_number': 'नंबर छुपाएं',
      // Aadhaar scanner errors
      'no_camera_found': 'इस डिवाइस पर कोई कैमरा नहीं मिला।',
      'camera_unavailable_desc': 'कैमरा अनुपलब्ध है। कृपया डिवाइस अनुमतियाँ जांचें या अपना आधार नंबर मैन्युअली दर्ज करें।',
      'camera_preview_error': 'कैमरा प्रीव्यू शुरू नहीं हो सका।',
      'verification_disclaimer': 'केवल प्रारूप सत्यापन। यह UIDAI के साथ पहचान या प्रामाणिकता की पुष्टि नहीं करता है।',
      // Crop names (stable IDs resolved through localization)
      'crop_wheat': 'गेहूँ',
      'crop_paddy': 'धान',
      'crop_mustard': 'सरसों',
      'crop_maize': 'मक्का',
      'crop_sugarcane': 'गन्ना',
      'crop_potato': 'आलू',
      'crop_all': 'सभी',
      // Market categories
      'category_cereals': 'अनाज',
      'category_oilseeds': 'तिलहन',
      'category_vegetables': 'सब्ज़ियाँ',
      'category_cash_crops': 'नकदी फसलें',
      // Gate status
      'gate_status_active': 'सक्रिय',
      'gate_status_high_crowd': 'उच्च भीड़',
      'gate_status_smooth': 'सुचारू',
      // Queue timeline steps
      'step_booked': 'बुक किया',
      'step_booked_desc': 'स्लॉट सफलतापूर्वक आरक्षित',
      'step_arrived': 'पहुंच गए',
      'step_arrived_desc': 'मंडी प्रवेश पर वाहन की जाँच हुई',
      'step_in_queue': 'कतार में',
      'step_in_queue_desc': 'होल्डिंग यार्ड में प्रतीक्षा',
      'step_at_gate': 'गेट पर',
      'step_at_gate_desc': 'वेइटिंग स्केल की ओर बढ़ रहे हैं',
      'step_procurement': 'प्रोक्योरमेंट',
      'step_procurement_desc': 'गुणवत्ता निरीक्षण एवं अनलोडिंग',
      'step_completed': 'पूर्ण',
      'step_completed_desc': 'ई-जे फॉर्म जनरेट हुआ और भुगतान भेजा गया',
      // Live queue
      'live_badge': 'डेमो',
      'last_updated': 'अंतिम अपडेट',
      'refreshing_in': 'रिफ्रेश हो रहा है',
      'seconds_suffix': 'से',
      'auto_refresh_30s': 'हर 30 सेकंड में ऑटो-रिफ्रेश (डेमो)',
      'fetching_live_data': 'नकली कतार डेटा लाया जा रहा है...',
      'queue_refresh_error':
          'कतार रिफ्रेश नहीं हो सकी। पिछला डेटा दिखाया जा रहा है।',
      'tap_to_retry': 'पुनः प्रयास करने के लिए टैप करें',
      // Booking confirmation
      'booking_id': 'बुकिंग आईडी: ',
      // AI insight (mock)
      'ai_insight_text': 'मंडी में उच्च गुणवत्ता वाली आवक के कारण गेहूं की कीमतें आज स्थिर और हल्की तेजी के साथ रह सकती हैं। आदर्श आवक समय: गेट 2, सुबह 11:00 बजे से पहले।',
      // Cancel booking
      'cancel_booking': 'बुकिंग रद्द करें',
      'cancel_booking_confirm':
          'क्या आप वाकई इस बुकिंग को रद्द करना चाहते हैं?',
      'keep_booking': 'बुकिंग रखें',
      'confirm_cancel': 'बुकिंग रद्द करें',
      'booking_cancelled_success': 'बुकिंग सफलतापूर्वक रद्द हो गई।',
      'booking_cancelled': 'बुकिंग रद्द',
      // Voice booking
      'book_by_voice': 'आवाज़ से बुक करें',
      'voice_booking_subtitle': 'अपना मंडी स्लॉट बोलकर बुक करें',
      'listening': 'सुन रहे हैं...',
      'speak_now': 'अब बोलें',
      'which_time_slot': 'किस समय का स्लॉट चाहिए?',
      'say_crop_name': 'फसल का नाम बोलें, जैसे गेहूं, धान',
      'say_time': 'समय बोलें, जैसे 9 बजे, 11 बजे',
      'voice_unavailable':
          'आवाज़ बुकिंग उपलब्ध नहीं है। आप मैनुअल बुक कर सकते हैं।',
      'voice_error': 'पहचान नहीं सके। कृपया पुनः प्रयास करें।',
      'no_speech_detected': 'कोई आवाज़ नहीं सुनी। कृपया पुनः प्रयास करें।',
      'microphone_permission_denied':
          'आवाज़ बुकिंग के लिए माइक्रोफ़ोन अनुमति आवश्यक है।',
      'checking_availability': 'उपलब्धता जाँच रहे हैं...',
      'slot_available': 'स्लॉट उपलब्ध है',
      'slot_unavailable': 'अनुरोधित स्लॉट उपलब्ध नहीं है',
      'best_available_booked':
          'सर्वोत्तम उपलब्ध स्लॉट स्वचालित रूप से बुक किया गया',
      'voice_booking_success': 'टोकन सफलतापूर्वक बुक हो गया',
      'voice_booking_error': 'बुकिंग पूरी नहीं हो सकी। कृपया पुनः प्रयास करें।',
      'no_available_slots':
          'कोई उपलब्ध स्लॉट नहीं मिला। कृपया मैनुअल बुकिंग करें।',
      'crop_selected': 'फसल चुनी गई',
      'invalid_crop': 'फसल पहचान नहीं सके। कृपया पुनः प्रयास करें।',
      'invalid_time': 'समय समझ नहीं आया। कृपया पुनः प्रयास करें।',
      'try_manual_booking': 'मैनुअल बुकिंग करें',
      'token_details': 'टोकन विवरण',
      'requested_slot': 'अनुरोधित स्लॉट',
      'booked_slot': 'बुक किया गया स्लॉट',
      'processing_voice': 'प्रक्रिया हो रही है...',
      'cancel_booking_action': 'बुकिंग रद्द करें',
      // Voice booking flow
      'press_mic_to_speak': 'माइक दबाकर बोलें',
      'voice_example_hint': 'कहें: "गेहूं, सुबह 9 बजे" या "wheat 9 am"',
      'start_voice': 'शुरू करें',
      'initializing_voice': 'वॉइस असिस्टेंट शुरू हो रहा है…',
      'open_settings': 'सेटिंग्स खोलें',
      'requested_slot_unavailable_auto': 'आपका अनुरोधित स्लॉट उपलब्ध नहीं है। हमने आपके लिए नजदीकी उपलब्ध स्लॉट बुक किया है।',
      'listen_again': 'फिर से सुनें',
      'grant_mic_permission': 'माइक्रोफोन अनुमति दें',
      // Voice booking spoken announcements ({...} placeholders are replaced)
      'voice_crop_prompt': 'कृपया फसल का नाम बताइए। जैसे गेहूं, धान या सरसों।',
      'voice_time_prompt':
          'आपने {crop} चुना है। कृपया बताइए कि किस समय का स्लॉट चाहिए।',
      'voice_checking_announcement':
          'आपने {time} का समय चुना है। स्लॉट उपलब्धता जांची जा रही है।',
      'voice_slot_available_announcement':
          '{time} का स्लॉट उपलब्ध है। आपका टोकन बुक किया जा रहा है।',
      'voice_fallback_announcement': '{requested} का स्लॉट उपलब्ध नहीं है। आपके लिए {booked} का सबसे नज़दीकी उपलब्ध स्लॉट बुक किया जा रहा है।',
      'voice_success_announcement': 'आपका टोकन सफलतापूर्वक बुक हो गया है। आपका समय {time} है। आपका टोकन नंबर {token} है।',
      'voice_permission_denied_speech': 'माइक की अनुमति नहीं मिली। कृपया माइक की अनुमति दें और दोबारा कोशिश करें।',
      'voice_not_understood': 'मुझे समझ नहीं आया। कृपया दोबारा बोलिए।',
      'voice_repeat_crop':
          'फसल पहचान में नहीं आई। कृपया फसल का नाम दोबारा बोलिए।',
      'voice_repeat_time': 'समय समझ में नहीं आया। कृपया समय दोबारा बोलिए।',
      'voice_no_slots_announcement': 'क्षमा करें, इस फसल के लिए कोई स्लॉट उपलब्ध नहीं है। कृपया दूसरा समय चुनें या मैन्युअल बुकिंग करें।',
      'voice_tts_error': 'वॉइस सहायक शुरू नहीं हो पाया। कृपया अपनी डिवाइस सेटिंग जांच कर दोबारा कोशिश करें।',
      'reason_label': 'कारण',
      'fallback_reason':
          'अनुरोधित स्लॉट उपलब्ध नहीं था - नजदीकी उपलब्ध स्लॉट बुक किया गया।',
    },
    'te': {
      'app_title': 'అగ్రి క్యూ',
      'app_subtitle': 'స్మార్ట్ మండి క్యూ & ప్రొక్యూర్‌మెంట్ సిస్టమ్',
      'choose_language': 'మీ భాషను ఎంచుకోండి',
      'save_language': 'భాషను సేవ్ చేయండి',
      'continue_': 'కొనసాగించండి',
      'welcome_back': 'తిరిగి స్వాగతం',
      'login_subtitle':
          'మీ మండి స్లాట్లను నిర్వహించండి మరియు క్యూను ట్రాక్ చేయండి',
      'mobile_number': 'మొబైల్ నంబర్',
      'password': 'పాస్‌వర్డ్',
      'login': 'లాగిన్',
      'continue_with_otp': 'OTP తో కొనసాగించండి',
      'no_account': 'ఖాతా లేదా? ',
      'register': 'నమోదు చేయండి',
      'create_account': 'ఖాతా సృష్టించండి',
      'register_subtitle': 'మండిలో మీ ఉత్పత్తిని అమ్మడానికి స్లాట్లు బుక్ చేయడానికి నమోదు చేయండి',
      'next': 'తదుపరి',
      'verify_mobile': 'మీ మొబైల్ నంబర్‌ను ధృవీకరించండి',
      'verify_continue': 'ధృవీకరించి కొనసాగించండి',
      'resend_otp': 'OTP మళ్లీ పంపండి',
      'change_mobile': 'మొబైల్ నంబర్ మార్చండి',
      'register_now': 'ఇప్పుడు నమోదు చేయండి',
      'try_another': 'మరొక నంబర్ ప్రయత్నించండి',
      'book_slot': 'స్లాట్ బుక్ చేయండి',
      'view_details': 'వివరాలు చూడండి',
      'logout': 'లాగౌట్',
      'cancel': 'రద్దు',
      'close': 'మూసివేయండి',
      'scan_aadhaar': 'ఆధార్ కార్డ్ స్కాన్ చేయండి',
      'enter_manually': 'మాన్యువల్ గా నమోదు చేయండి',
      'try_again': 'మళ్లీ ప్రయత్నించండి',
      'scan_again': 'మళ్లీ స్కాన్ చేయండి',
      'use_details': 'ఈ వివరాలను ఉపయోగించండి',
      'mandi': 'మండి',
      'crop': 'పంట',
      'date': 'తేదీ',
      'time_slot': 'సమయ స్లాట్',
      'farmer_name': 'రైతు పేరు',
      'faq': 'తరచుగా అడిగే ప్రశ్నలు',
      'nav_home': 'హోమ్',
      'nav_my_bookings': 'నా బుక్ింగ్స్',
      'nav_live_queue': 'లైవ్ క్యూ',
      'nav_price': 'ధర',
      'nav_profile': 'ప్రొఫైల్',
    },
    'ta': {
      'app_title': 'அக்ரி க்யூ',
      'app_subtitle': 'ஸ்மார்ட் மண்டி வரிசை & கொள்முதல் அமைப்பு',
      'choose_language': 'உங்கள் மொழியைத் தேர்ந்தெடுக்கவும்',
      'save_language': 'மொழியைச் சேமிக்கவும்',
      'continue_': 'தொடரவும்',
      'welcome_back': 'மீண்டும் வரவேற்கிறோம்',
      'login_subtitle':
          'உங்கள் மண்டி இடங்களை நிர்வகிக்கவும் வரிசையைக் கண்காணிக்கவும்',
      'mobile_number': 'மொபைல் எண்',
      'password': 'கடவுச்சொல்',
      'login': 'உள்நுழை',
      'continue_with_otp': 'OTP மூலம் தொடரவும்',
      'no_account': 'கணக்கு இல்லையா? ',
      'register': 'பதிவு செய்யுங்கள்',
      'create_account': 'கணக்கு உருவாக்குங்கள்',
      'register_subtitle': 'மண்டியில் உங்கள் விளைபொருளை விற்க இடங்களை முன்பதிவு செய்ய பதிவு செய்யுங்கள்',
      'next': 'அடுத்து',
      'verify_mobile': 'உங்கள் மொபைல் எண்ணை சரிபார்க்கவும்',
      'verify_continue': 'சரிபார்த்து தொடரவும்',
      'resend_otp': 'OTP மீண்டும் அனுப்பு',
      'change_mobile': 'மொபைல் எண் மாற்று',
      'register_now': 'இப்போது பதிவு செய்யுங்கள்',
      'try_another': 'வேறு எண் முயற்சிக்கவும்',
      'book_slot': 'இடம் முன்பதிவு செய்யுங்கள்',
      'view_details': 'விவரங்களைக் காண்க',
      'logout': 'வெளியேறு',
      'cancel': 'ரத்து',
      'close': 'மூடு',
      'scan_aadhaar': 'ஆதார் அட்டையை ஸ்கேன் செய்யுங்கள்',
      'enter_manually': 'கைமுறையாக உள்ளிடவும்',
      'try_again': 'மீண்டும் முயற்சிக்கவும்',
      'scan_again': 'மீண்டும் ஸ்கேன் செய்யுங்கள்',
      'use_details': 'இந்த விவரங்களைப் பயன்படுத்தவும்',
      'mandi': 'மண்டி',
      'crop': 'பயிர்',
      'date': 'தேதி',
      'time_slot': 'நேர இடம்',
      'farmer_name': 'விவசாயி பெயர்',
      'faq': 'அடிக்கடி கேட்கப்படும் கேள்விகள்',
      'nav_home': 'முகப்பு',
      'nav_my_bookings': 'என் முன்பதிவுகள்',
      'nav_live_queue': 'நேரடி வரிசை',
      'nav_price': 'விலை',
      'nav_profile': 'சுயவிவரம்',
    },
    'mr': {
      'app_title': 'ॲग्रीक्यू',
      'app_subtitle': 'स्मार्ट मंडी वळण आणि प्रोक्योरमेंट सिस्टम',
      'choose_language': 'तुमची भाषा निवडा',
      'save_language': 'भाषा जतना करा',
      'continue_': 'सुरू ठेवा',
      'welcome_back': 'पुन्हा स्वागत आहे',
      'login_subtitle': 'तुमचे मंडी स्लॉट व्यवस्थापित करा आणि वळणा ट्रॅक करा',
      'mobile_number': 'मोबाईल नंबर',
      'password': 'पासवर्ड',
      'login': 'लॉगिन',
      'continue_with_otp': 'OTP ने सुरू ठेवा',
      'no_account': 'खाते नाही? ',
      'register': 'नोंदणी करा',
      'create_account': 'खाते तयार करा',
      'register_subtitle':
          'मंडीत तुमचे उत्पादन विकण्यासाठी स्लॉट बुक करण्यासाठी नोंदणी करा',
      'next': 'पुढे',
      'verify_mobile': 'तुमचा मोबाईल नंबर पडताळा',
      'verify_continue': 'पडताळा आणि सुरू ठेवा',
      'resend_otp': 'OTP पुन्हा पाठवा',
      'change_mobile': 'मोबाईल नंबर बदला',
      'register_now': 'आत्ता नोंदणी करा',
      'try_another': 'दुसरा नंबर वापरून पहा',
      'book_slot': 'स्लॉट बुक करा',
      'view_details': 'तपशील पहा',
      'logout': 'लॉगआउट',
      'cancel': 'रद्द करा',
      'close': 'बंद करा',
      'scan_aadhaar': 'आधार कार्ड स्कॅन करा',
      'enter_manually': 'हस्तलिखित प्रविष्ट करा',
      'try_again': 'पुन्हा प्रयत्न करा',
      'scan_again': 'पुन्हा स्कॅन करा',
      'use_details': 'हा तपशील वापरा',
      'mandi': 'मंडी',
      'crop': 'पिक',
      'date': 'तारीख',
      'time_slot': 'वेळ स्लॉट',
      'farmer_name': 'शेतकरी नाव',
      'faq': 'वारंवार विचारले जाणारे प्रश्न',
      'nav_home': 'होम',
      'nav_my_bookings': 'माझी बुकिंग',
      'nav_live_queue': 'लाइव्ह वळण',
      'nav_price': 'भाव',
      'nav_profile': 'प्रोफाइल',
    },
    'bn': {
      'app_title': 'অ্যাগ্রিকিউ',
      'app_subtitle': 'স্মার্ট মন্ডি সারি ও সংগ্রহ ব্যবস্থা',
      'choose_language': 'আপনার ভাষা বেছে নিন',
      'save_language': 'ভাষা সংরক্ষণ করুন',
      'continue_': 'চালিয়ে যান',
      'welcome_back': 'ফিরে এসে স্বাগতম',
      'login_subtitle': 'আপনার মন্ডি স্লট পরিচালনা করুন এবং সারি ট্র্যাক করুন',
      'mobile_number': 'মোবাইল নম্বর',
      'password': 'পাসওয়ার্ড',
      'login': 'লগইন',
      'continue_with_otp': 'OTP দিয়ে চালিয়ে যান',
      'no_account': 'অ্যাকাউন্ট নেই? ',
      'register': 'নিবন্ধন করুন',
      'create_account': 'অ্যাকাউন্ট তৈরি করুন',
      'register_subtitle':
          'মন্ডিতে আপনার ফসল বিক্রি করতে স্লট বুক করতে নিবন্ধন করুন',
      'next': 'পরবর্তী',
      'verify_mobile': 'আপনার মোবাইল নম্বর যাচাই করুন',
      'verify_continue': 'যাচাই করুন এবং চালিয়ে যান',
      'resend_otp': 'OTP পুনরায় পাঠান',
      'change_mobile': 'মোবাইল নম্বর পরিবর্তন করুন',
      'register_now': 'এখনই নিবন্ধন করুন',
      'try_another': 'অন্য নম্বর চেষ্টা করুন',
      'book_slot': 'স্লট বুক করুন',
      'view_details': 'বিবরণ দেখুন',
      'logout': 'লগআউট',
      'cancel': 'বাতিল',
      'close': 'বন্ধ',
      'scan_aadhaar': 'আধার কার্ড স্ক্যান করুন',
      'enter_manually': 'ম্যানুয়ালি প্রবেশ করুন',
      'try_again': 'আবার চেষ্টা করুন',
      'scan_again': 'আবার স্ক্যান করুন',
      'use_details': 'এই তথ্য ব্যবহার করুন',
      'mandi': 'মন্ডি',
      'crop': 'ফসল',
      'date': 'তারিখ',
      'time_slot': 'সময় স্লট',
      'farmer_name': 'কৃষকের নাম',
      'faq': 'ঘন ঘন জিজ্ঞাসা',
      'nav_home': 'হোম',
      'nav_my_bookings': 'আমার বুকিং',
      'nav_live_queue': 'লাইভ সারি',
      'nav_price': 'মূল্য',
      'nav_profile': 'প্রোফাইল',
    },
    'gu': {
      'app_title': 'એગ્રીક્યુ',
      'app_subtitle': 'સ્માર્ટ મંડી કતાર અને પ્રોક્યુરમેન્ટ સિસ્ટમ',
      'choose_language': 'તમારી ભાષા પસંદ કરો',
      'save_language': 'ભાષા સાચવો',
      'continue_': 'ચાલુ રાખો',
      'welcome_back': 'પાછા આવવા બદલ સ્વાગત',
      'login_subtitle': 'તમારા મંડી સ્લૉટ્સ મેનેજ કરો અને કતાર ટ્રૅક કરો',
      'mobile_number': 'મોબાઈલ નંબર',
      'password': 'પાસવર્ડ',
      'login': 'લૉગિન',
      'continue_with_otp': 'OTP સાથે ચાલુ રાખો',
      'no_account': 'ખાતું નથી? ',
      'register': 'નોંધણી કરો',
      'create_account': 'ખાતું બનાવો',
      'register_subtitle':
          'મંડીમાં તમારું ઉત્પાદન વેચવા માટે સ્લૉટ્સ બુક કરવા નોંધણી કરો',
      'next': 'આગળ',
      'verify_mobile': 'તમારો મોબાઈલ નંબર ચકાસો',
      'verify_continue': 'ચકાસો અને ચાલુ રાખો',
      'resend_otp': 'OTP ફરીથી મોકલો',
      'change_mobile': 'મોબાઈલ નંબર બદલો',
      'register_now': 'હવે નોંધણી કરો',
      'try_another': 'બીજો નંબર અજમાવો',
      'book_slot': 'સ્લૉટ બુક કરો',
      'view_details': 'વિગતો જુઓ',
      'logout': 'લૉગઆઉટ',
      'cancel': 'રદ કરો',
      'close': 'બંધ કરો',
      'scan_aadhaar': 'આધાર કાર્ડ સ્કૅન કરો',
      'enter_manually': 'હસ્તલિખિત દાખલ કરો',
      'try_again': 'ફરી પ્રયાસ કરો',
      'scan_again': 'ફરી સ્કૅન કરો',
      'use_details': 'આ વિગતો ઉપયોગ કરો',
      'mandi': 'મંડી',
      'crop': 'પાક',
      'date': 'તારીખ',
      'time_slot': 'સમય સ્લૉટ',
      'farmer_name': 'ખેડૂત નામ',
      'faq': 'વારંવાર પૂછાતા પ્રશ્નો',
      'nav_home': 'હોમ',
      'nav_my_bookings': 'મારી બુકિંગ',
      'nav_live_queue': 'લાઇવ્ કતાર',
      'nav_price': 'ભાવ',
      'nav_profile': 'પ્રોફાઇલ',
    },
    'pa': {
      'app_title': 'ਐਗਰੀਕਿਊ',
      'app_subtitle': 'ਸਮਾਰਟ ਮੰਡੀ ਕਤਾਰ ਅਤੇ ਪ੍ਰੋਕਿਊਰਮੈਂਟ ਸਿਸਟਮ',
      'choose_language': 'ਆਪਣੀ ਭਾਸ਼ਾ ਚੁਣੋ',
      'save_language': 'ਭਾਸ਼ਾ ਸੰਭਾਲੋ',
      'continue_': 'ਜਾਰੀ ਰੱਖੋ',
      'welcome_back': 'ਵਾਪਸ ਆਉਣ ਤੇ ਜੀ ਆਇਆਂ ਨੂੰ',
      'login_subtitle': 'ਆਪਣੇ ਮੰਡੀ ਸਲਾਟ ਪ੍ਰਬੰਧਨ ਕਰੋ ਅਤੇ ਕਤਾਰ ਟ੍ਰੈਕ ਕਰੋ',
      'mobile_number': 'ਮੋਬਾਈਲ ਨੰਬਰ',
      'password': 'ਪਾਸਵਰਡ',
      'login': 'ਲੌਗਇਨ',
      'continue_with_otp': 'OTP ਨਾਲ ਜਾਰੀ ਰੱਖੋ',
      'no_account': 'ਖਾਤਾ ਨਹੀਂ ਹੈ? ',
      'register': 'ਰਜਿਸਟਰ ਕਰੋ',
      'create_account': 'ਖਾਤਾ ਬਣਾਓ',
      'register_subtitle':
          'ਮੰਡੀ ਵਿੱਚ ਆਪਣੀ ਫ਼ਸਲ ਵੇਚਣ ਲਈ ਸਲਾਟ ਬੁੱਕ ਕਰਨ ਲਈ ਰਜਿਸਟਰ ਕਰੋ',
      'next': 'ਅੱਗੇ',
      'verify_mobile': 'ਆਪਣਾ ਮੋਬਾਈਲ ਨੰਬਰ ਯਕੀਨੀ ਬਣਾਓ',
      'verify_continue': 'ਯਕੀਨੀ ਬਣਾਓ ਅਤੇ ਜਾਰੀ ਰੱਖੋ',
      'resend_otp': 'OTP ਮੁੜ ਭੇਜੋ',
      'change_mobile': 'ਮੋਬਾਈਲ ਨੰਬਰ ਬਦਲੋ',
      'register_now': 'ਹੁਣੇ ਰਜਿਸਟਰ ਕਰੋ',
      'try_another': 'ਹੋਰ ਨੰਬਰ ਅਜ਼ਮਾਓ',
      'book_slot': 'ਸਲਾਟ ਬੁੱਕ ਕਰੋ',
      'view_details': 'ਵੇਰਵੇ ਵੇਖੋ',
      'logout': 'ਲੌਗਆਊਟ',
      'cancel': 'ਰੱਦ ਕਰੋ',
      'close': 'ਬੰਦ ਕਰੋ',
      'scan_aadhaar': 'ਆਧਾਰ ਕਾਰਡ ਸਕੈਨ ਕਰੋ',
      'enter_manually': 'ਹੱਥ ਨਾਲ ਦਰਜ ਕਰੋ',
      'try_again': 'ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ',
      'scan_again': 'ਦੁਬਾਰਾ ਸਕੈਨ ਕਰੋ',
      'use_details': 'ਇਹ ਵੇਰਵੇ ਵਰਤੋ',
      'mandi': 'ਮੰਡੀ',
      'crop': 'ਫ਼ਸਲ',
      'date': 'ਮਿਤੀ',
      'time_slot': 'ਸਮਾਂ ਸਲਾਟ',
      'farmer_name': 'ਕਿਸਾਨ ਦਾ ਨਾਮ',
      'faq': 'ਅਕਸਰ ਪੁੱਛੇ ਜਾਣ ਵਾਲੇ ਸਵਾਲ',
      'nav_home': 'ਹੋਮ',
      'nav_my_bookings': 'ਮੇਰੀਆਂ ਬੁੱਕਿੰਗਾਂ',
      'nav_live_queue': 'ਲਾਈਵ ਕਤਾਰ',
      'nav_price': 'ਕੀਮਤ',
      'nav_profile': 'ਪ੍ਰੋਫਾਈਲ',
    },
    'kn': {
      // Language screen
      'app_title': 'ಅಗ್ರಿಕ್ಯೂ',
      'app_subtitle': 'ಸ್ಮಾರ್ಟ್ ಮಂಡಿ ಕ್ಯೂ ಮತ್ತು ಖರೀದಿ ವ್ಯವಸ್ಥೆ',
      'choose_language': 'ನಿಮ್ಮ ಭಾಷೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ',
      'save_language': 'ಭಾಷೆ ಉಳಿಸಿ',
      'continue_': 'ಮುಂದುವರಿಸಿ',
      // Auth
      'welcome_back': 'ಮರಳಿ ಸ್ವಾಗತ',
      'login_subtitle':
          'ನಿಮ್ಮ ಮಂಡಿ ಸ್ಲಾಟ್‌ಗಳನ್ನು ನಿರ್ವಹಿಸಿ, ಕ್ಯೂ ಅನ್ನು ಟ್ರ್ಯಾಕ್ ಮಾಡಿ',
      'mobile_number': 'ಮೊಬೈಲ್ ಸಂಖ್ಯೆ',
      'password': 'ಪಾಸ್ವರ್ಡ್',
      'enter_password': 'ನಿಮ್ಮ ಪಾಸ್ವರ್ಡ್ ನಮೂದಿಸಿ',
      'forgot_password': 'ಪಾಸ್ವರ್ಡ್ ಮರೆತಿರುವಿರಾ',
      'login': 'ಲಾಗಿನ್',
      'continue_with_otp': 'OTP ಮೂಲಕ ಮುಂದುವರಿಸಿ',
      'no_account': 'ಖಾತೆ ಇಲ್ಲವೇ? ',
      'register': 'ನೋಂದಣಿ',
      'reset_password': 'ಪಾಸ್ವರ್ಡ್ ಮರುಹೊಂದಿಸಿ',
      'close': 'ಮುಚ್ಚು',
      'use_otp_instead': 'ಬದಲಿಗೆ OTP ಬಳಸಿ',
      'otp_hint': 'OTP ಪಡೆಯಲು ನಿಮ್ಮ ಮೊಬೈಲ್ ಸಂಖ್ಯೆಯನ್ನು ನಮೂದಿಸಿ',
      // Registration
      'create_account': 'ಖಾತೆ ರಚಿಸಿ',
      'register_subtitle':
          'ಮಂಡಿಯಲ್ಲಿ ನಿಮ್ಮ ಉತ್ಪನ್ನ ಮಾರಾಟಕ್ಕಾಗಿ ಸ್ಲಾಟ್ ಬುಕ್ ಮಾಡಲು ನೋಂದಣಿ ಮಾಡಿ',
      'aadhaar_number': 'ಆಧಾರ್ ಸಂಖ್ಯೆ',
      'full_name': 'ಪೂರ್ಣ ಹೆಸರು',
      'date_of_birth': 'ಜನ್ಮ ದಿನಾಂಕ',
      'email_optional': 'ಇಮೇಲ್ (ಐಚ್ಛಿಕ)',
      'next': 'ಮುಂದೆ',
      'already_registered': 'ಈಗಾಗಲೇ ಖಾತೆ ಇದೆಯೇ? ',
      'please_enter_mobile': 'ಮೊದಲು ನಿಮ್ಮ ಮೊಬೈಲ್ ಸಂಖ್ಯೆಯನ್ನು ನಮೂದಿಸಿ',
      // OTP
      'verify_mobile': 'ನಿಮ್ಮ ಮೊಬೈಲ್ ಸಂಖ್ಯೆಯನ್ನು ಪರಿಶೀಲಿಸಿ',
      'verify_continue': 'ಪರಿಶೀಲಿಸಿ ಮತ್ತು ಮುಂದುವರಿಸಿ',
      'resend_otp': 'OTP ಮರುಕಳುಹಿಸಿ',
      'change_mobile': 'ಮೊಬೈಲ್ ಸಂಖ್ಯೆ ಬದಲಾಯಿಸಿ',
      'enter_all_digits': 'OTP ನ ಎಲ್ಲಾ 6 ಅಂಕಿಗಳನ್ನು ನಮೂದಿಸಿ',
      'register_now': 'ಈಗ ನೋಂದಣಿ ಮಾಡಿ',
      'try_another': 'ಮತ್ತೊಂದು ಸಂಖ್ಯೆ ಪ್ರಯತ್ನಿಸಿ',
      // Home
      'need_to_sell': 'ನಿಮ್ಮ ಉತ್ಪನ್ನ ಮಾರಾಟ ಮಾಡಬೇಕೇ?',
      'book_slot_now': 'ನಿಮ್ಮ ಸ್ಲಾಟ್ ಬುಕ್ ಮಾಡಿ',
      'book_slot': 'ಸ್ಲಾಟ್ ಬುಕ್',
      'open': 'ತೆರೆದಿದೆ',
      'current_gate_status': 'ಪ್ರಸ್ತುತ ಗೇಟ್ ಸ್ಥಿತಿ',
      'next_available_slot': 'ಮುಂದಿನ ಲಭ್ಯ ಸ್ಲಾಟ್',
      'your_token': 'ನಿಮ್ಮ ಟೋಕನ್',
      'view_details': 'ವಿವರ ನೋಡಿ',
      'view_all_prices': 'ಎಲ್ಲಾ ಬೆಲೆಗಳನ್ನು ನೋಡಿ',
      // Queue tracking
      'live_mandi_queue': 'ಲೈವ್ ಮಂಡಿ ಕ್ಯೂ',
      'your_live_token': 'ನಿಮ್ಮ ಲೈವ್ ಟೋಕನ್',
      'assigned_gate': 'ನಿಗದಿಪಡಿಸಿದ ಗೇಟ್',
      'farmers_ahead': 'ಮುಂದಿನ ರೈತರು',
      'estimated_wait': 'ಅಂದಾಜು ಕಾಯುವಿಕೆ',
      'procurement_timeline': 'ಖರೀದಿ ಹಂತದ ಟೈಮ್ಲೈನ್',
      // Slot booking
      'today': 'ಇಂದು',
      'tomorrow': 'ನಾಳೆ',
      'day_after': 'ನಾಳೆಯ ಮರುದಿನ',
      // Procurement
      'payment_history': 'ಪಾವತಿ ಇತಿಹಾಸ',
      'total_earnings': 'ಒಟ್ಟು ಗಳಿಕೆ',
      'paid': 'ಪಾವತಿಸಲಾಗಿದೆ',
      'processing_': 'ಪ್ರಕ್ರಿಯೆ',
      'pending': 'ಬಾಕಿ',
      'view_slip': 'ಸ್ಲಿಪ್ ನೋಡಿ',
      // Profile
      'farmer_profile': 'ರೈತ ಪ್ರೊಫೈಲ್',
      'personal_info': 'ವೈಯಕ್ತಿಕ ಮಾಹಿತಿ',
      'my_mandi': 'ನನ್ನ ಮಂಡಿ',
      'my_documents': 'ನನ್ನ ದಾಖಲೆಗಳು',
      'language_hindi': 'ಭಾಷೆ',
      'help_support': 'ಸಹಾಯ ಮತ್ತು ಬೆಂಬಲ',
      'logout': 'ಲಾಗ್ ಔಟ್',
      'cancel': 'ರದ್ದುಮಾಡಿ',
      // Aadhaar scanner
      'scan_aadhaar': 'ಆಧಾರ್ ಕಾರ್ಡ್ ಸ್ಕ್ಯಾನ್ ಮಾಡಿ',
      'enter_manually': 'ಹಸ್ತಚಾಲಿತವಾಗಿ ನಮೂದಿಸಿ',
      'try_again': 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ',
      'scan_again': 'ಮತ್ತೆ ಸ್ಕ್ಯಾನ್ ಮಾಡಿ',
      'use_details': 'ಈ ವಿವರಗಳನ್ನು ಬಳಸಿ',
      'mandi': 'ಮಂಡಿ',
      'crop': 'ಬೆಳೆ',
      'date': 'ದಿನಾಂಕ',
      'time_slot': 'ಸಮಯ ಸ್ಲಾಟ್',
      'farmer_name': 'ರೈತರ ಹೆಸರು',
      'nav_home': 'ಮುಖಪುಟ',
      'nav_my_bookings': 'ನನ್ನ ಬುಕಿಂಗ್‌ಗಳು',
      'nav_live_queue': 'ಲೈವ್ ಕ್ಯೂ',
      'nav_price': 'ಬೆಲೆ',
      'nav_profile': 'ಪ್ರೊಫೈಲ್',
      // Targeted
      'available': 'ಲಭ್ಯವಿದೆ',
      'filling_fast': 'ತ್ವರಿತವಾಗಿ ತುಂಬುತ್ತಿದೆ',
      'active': 'ಸಕ್ರಿಯ',
      'ten_min_ago': '10 ನಿಮಿಷಗಳ ಹಿಂದೆ',
      'one_hour_ago': '1 ಗಂಟೆ ಹಿಂದೆ',
      'farmer_id': 'ರೈತರ ಐಡಿ',
      'land_size': 'ಭೂಮಿ ಗಾತ್ರ',
      'acres': 'ಎಕರೆ',
      'village': 'ಹಳ್ಳಿ',
      'district': 'ಜಿಲ್ಲೆ',
      'state': 'ರಾಜ್ಯ',
      // Validators
      'v_mobile_required': 'ದಯವಿಟ್ಟು ನಿಮ್ಮ ಮೊಬೈಲ್ ಸಂಖ್ಯೆಯನ್ನು ನಮೂದಿಸಿ',
      'v_mobile_invalid': 'ದಯವಿಟ್ಟು ಮಾನ್ಯ 10-ಅಂಕಿಯ ಮೊಬೈಲ್ ಸಂಖ್ಯೆಯನ್ನು ನಮೂದಿಸಿ',
      'v_password_required': 'ದಯವಿಟ್ಟು ನಿಮ್ಮ ಪಾಸ್ವರ್ಡ್ ನಮೂದಿಸಿ',
      'v_password_short': 'ಪಾಸ್ವರ್ಡ್ ಕನಿಷ್ಠ 4 ಅಕ್ಷರಗಳಾಗಿರಬೇಕು',
      'v_name_required': 'ದಯವಿಟ್ಟು ನಿಮ್ಮ ಪೂರ್ಣ ಹೆಸರನ್ನು ನಮೂದಿಸಿ',
      'v_name_invalid': 'ದಯವಿಟ್ಟು ಮಾನ್ಯ ಹೆಸರನ್ನು ನಮೂದಿಸಿ',
      'v_email_invalid': 'ದಯವಿಟ್ಟು ಮಾನ್ಯ ಇಮೇಲ್ ವಿಳಾಸವನ್ನು ನಮೂದಿಸಿ',
      'v_dob_required': 'ದಯವಿಟ್ಟು ನಿಮ್ಮ ಜನ್ಮ ದಿನಾಂಕವನ್ನು ನಮೂದಿಸಿ',
      'v_dob_format': 'DD/MM/YYYY ಸ್ವರೂಪದಲ್ಲಿ ನಮೂದಿಸಿ',
      'v_dob_invalid': 'ದಯವಿಟ್ಟು ಮಾನ್ಯ ಜನ್ಮ ದಿನಾಂಕವನ್ನು ನಮೂದಿಸಿ',
      'v_aadhaar_required': 'ದಯವಿಟ್ಟು ನಿಮ್ಮ 12-ಅಂಕಿಯ ಆಧಾರ್ ಸಂಖ್ಯೆಯನ್ನು ನಮೂದಿಸಿ',
      'v_aadhaar_length': 'ಆಧಾರ್ ಸಂಖ್ಯೆ ನಿಖರವಾಗಿ 12 ಅಂಕಿಗಳಾಗಿರಬೇಕು',
      'v_aadhaar_start': 'ಆಧಾರ್ ಸಂಖ್ಯೆ 0 ಅಥವಾ 1 ರಿಂದ ಪ್ರಾರಂಭವಾಗುವಂತಿಲ್ಲ',
      'v_aadhaar_checksum': 'ಅಮಾನ್ಯ ಆಧಾರ್ ಸಂಖ್ಯೆ (ಚೆಕ್ಸಮ್ ವಿಫಲ)',
      // Units & tooltips
      'quintals': 'ಕ್ವಿಂಟಲ್',
      'qtl': 'ಕ್ವಿಂ',
      'show_full_number': 'ಪೂರ್ಣ ಸಂಖ್ಯೆ ತೋರಿಸಿ',
      'hide_number': 'ಸಂಖ್ಯೆ ಮರೆಮಾಡಿ',
      // Aadhaar scanner errors
      'no_camera_found': 'ಈ ಸಾಧನದಲ್ಲಿ ಕ್ಯಾಮೆರಾ ಕಂಡುಬಂದಿಲ್ಲ.',
      'camera_unavailable_desc': 'ಕ್ಯಾಮೆರಾ ಲಭ್ಯವಿಲ್ಲ. ದಯವಿಟ್ಟು ಸಾಧನ ಅನುಮತಿಗಳನ್ನು ಪರಿಶೀಲಿಸಿ ಅಥವಾ ನಿಮ್ಮ ಆಧಾರ್ ಸಂಖ್ಯೆಯನ್ನು ಹಸ್ತಚಾಲಿತವಾಗಿ ನಮೂದಿಸಿ.',
      'camera_preview_error': 'ಕ್ಯಾಮೆರಾ ಪ್ರಿವ್ಯೂ ಪ್ರಾರಂಭಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.',
      'verification_disclaimer': 'ಕೇವಲ ಸ್ವರೂಪದ ಪರಿಶೀಲನೆ. ಇದು UIDAI ಜೊತೆಗೆ ಗುರುತು ಅಥವಾ ದೃಢೀಕರಣವನ್ನು ಪರಿಶೀಲಿಸುವುದಿಲ್ಲ.',
    },
  };

  final LanguageProvider _langProvider;

  S(this._langProvider);

  String _t(String key) {
    final code = _langProvider.currentLanguage.code;
    final langMap = _translations[code];
    if (langMap != null && langMap.containsKey(key)) {
      return langMap[key]!;
    }
    final enMap = _translations['en']!;
    return enMap[key] ?? key;
  }

  static const Map<String, String> _errorKeyMap = {
    'Please enter your mobile number': 'v_mobile_required',
    'Please enter a valid 10-digit mobile number': 'v_mobile_invalid',
    'Please enter your password': 'v_password_required',
    'Password must be at least 4 characters': 'v_password_short',
    'Please enter your full name': 'v_name_required',
    'Please enter a valid name': 'v_name_invalid',
    'Please enter a valid email address': 'v_email_invalid',
    'Please enter your date of birth': 'v_dob_required',
    'Use DD/MM/YYYY format': 'v_dob_format',
    'Please enter a valid date of birth': 'v_dob_invalid',
    'Please enter your 12-digit Aadhaar number': 'v_aadhaar_required',
    'Aadhaar number must be exactly 12 digits': 'v_aadhaar_length',
    'Aadhaar number cannot start with 0 or 1': 'v_aadhaar_start',
    'Invalid Aadhaar number (checksum failed)': 'v_aadhaar_checksum',
    'Please enter your email address': 'email_required_msg',
    'Password must be at least 6 characters': 'password_min6_msg',
    'Passwords do not match': 'passwords_do_not_match',
    'Please confirm your password': 'password_required',
  };

  String translateValidation(String rawError) {
    final key = _errorKeyMap[rawError];
    if (key == null) return rawError;
    return _t(key);
  }

  static S of(BuildContext context) {
    final langProvider = context.read<LanguageProvider>();
    return S(langProvider);
  }

  // Language screen
  String get appTitle => _t('app_title');
  String get appSubtitle => _t('app_subtitle');
  String get chooseLanguage => _t('choose_language');
  String get saveLanguage => _t('save_language');
  String get continueText => _t('continue_');

  // Auth
  String get welcomeBack => _t('welcome_back');
  String get loginSubtitle => _t('login_subtitle');
  String get mobileNumber => _t('mobile_number');
  String get password => _t('password');
  String get enterPasswordHint => _t('enter_password');
  String get forgotPassword => _t('forgot_password');
  String get login => _t('login');
  String get continueWithOtp => _t('continue_with_otp');
  String get noAccount => _t('no_account');
  String get register => _t('register');
  String get resetPassword => _t('reset_password');
  String get resetPasswordDesc => _t('reset_password_desc');
  String get close => _t('close');
  String get useOtpInstead => _t('use_otp_instead');
  String get otpHint => _t('otp_hint');
  String get invalidLogin => _t('invalid_login');
  String get emailAddress => _t('email_address');
  String get loginWithEmail => _t('login_with_email');
  String get emailLoginHint => _t('email_login_hint');
  String get orDivider => _t('or_divider');
  String get continueWithGoogle => _t('continue_with_google');
  String get googleSignInUnavailable => _t('google_sign_in_unavailable');
  String get googleSignInFailed => _t('google_sign_in_failed');
  String get firebaseUnconfigured => _t('firebase_unconfigured');
  String get resetViaEmailTitle => _t('reset_via_email_title');
  String get resetViaEmailDesc => _t('reset_via_email_desc');
  String get sendResetLink => _t('send_reset_link');
  String get resetEmailSent => _t('reset_email_sent');
  String get confirmPassword => _t('confirm_password');
  String get retypePasswordHint => _t('retype_password_hint');
  String get passwordsDoNotMatch => _t('passwords_do_not_match');
  String get passwordRequired => _t('password_required');

  // Registration
  String get createAccount => _t('create_account');
  String get registerSubtitle => _t('register_subtitle');
  String get aadhaarNumber => _t('aadhaar_number');
  String get onDeviceOcr => _t('on_device_ocr');
  String get aadhaarPrivacyNote => _t('aadhaar_privacy_note');
  String get aadhaarDetected => _t('aadhaar_detected');
  String get fullName => _t('full_name');
  String get dateOfBirth => _t('date_of_birth');
  String get emailOptional => _t('email_optional');
  String get next => _t('next');
  String get alreadyRegistered => _t('already_registered');
  String get pleaseEnterMobile => _t('please_enter_mobile');

  // OTP
  String get verifyMobile => _t('verify_mobile');
  String otpSentTo(String masked) =>
      _t('otp_sent_to').replaceAll(r'$masked', masked);
  String get verifyContinue => _t('verify_continue');
  String get resendOtp => _t('resend_otp');
  String resendIn(int seconds) =>
      _t('resend_in').replaceAll(r'$_countdown', '$seconds');
  String get changeMobile => _t('change_mobile');
  String get enterAllDigits => _t('enter_all_digits');
  String get invalidOtp => _t('invalid_otp');
  String get accountCreated => _t('account_created');
  String get registrationFailed => _t('registration_failed');
  String get mobileNotRegistered => _t('mobile_not_registered');
  String notRegisteredDesc(String phone) =>
      _t('not_registered_desc').replaceAll(r'$_phone', phone);
  String redirectingTo(int seconds) =>
      _t('redirecting_to_registration').replaceAll(r'$_countdown', '$seconds');
  String get registerNow => _t('register_now');
  String get tryAnother => _t('try_another');

  // Demo mode
  String get demoModeTitle => _t('demo_mode_title');
  String get demoModeBody => _t('demo_mode_body');
  String get demoModeTitleReal => _t('demo_mode_title_real');
  String get demoModeBodyReal => _t('demo_mode_body_real');

  // Auth flow errors
  String get otpSendFailed => _t('otp_send_failed');
  String get mobileAlreadyRegistered => _t('mobile_already_registered');

  // Simulated data disclosures
  String get simulatedDataLabel => _t('simulated_data_label');
  String get simulatedQueueNotice => _t('simulated_queue_notice');
  String get simulatedPaymentNotice => _t('simulated_payment_notice');
  String get simulatedNotificationsNotice =>
      _t('simulated_notifications_notice');
  String get simulatedTelemetryNotice => _t('simulated_telemetry_notice');

  // Home
  String get goodMorning => _t('good_morning');
  String get goodAfternoon => _t('good_afternoon');
  String get goodEvening => _t('good_evening');
  String get mandiNotifications => _t('mandi_notifications');
  String get queueMoving => _t('queue_moving');
  String get queueMovingDesc => _t('queue_moving_desc');
  String get mspUpdate => _t('msp_update');
  String get mspUpdateDesc => _t('msp_update_desc');
  String get needToSell => _t('need_to_sell');
  String get bookSlotNow => _t('book_slot_now');
  String get bookSlot => _t('book_slot');
  String get selectedMandi => _t('selected_mandi');
  String get open => _t('open');
  String get currentGateStatus => _t('current_gate_status');
  String get gatesActive => _t('gates_active');
  String get nextAvailableSlot => _t('next_available_slot');
  String get yourToken => _t('your_token');
  String get viewDetails => _t('view_details');
  String get marketPriceToday => _t('market_price_today');
  String get viewAllPrices => _t('view_all_prices');
  String get mandiInsights => _t('mandi_insights');
  String get aiInsight => _t('ai_insight');
  String get liveGateCrowd => _t('live_gate_crowd');
  String get realtimeQueueLoad => _t('realtime_queue');
  String get refresh => _t('refresh');
  String get gateTelemetryUpdated => _t('gate_telemetry_updated');
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return goodMorning;
    if (hour < 17) return goodAfternoon;
    return goodEvening;
  }

  // Queue tracking
  String get liveMandiQueue => _t('live_mandi_queue');
  String get yourLiveToken => _t('your_live_token');
  String get assignedGate => _t('assigned_gate');
  String get farmersAhead => _t('farmers_ahead');
  String get estimatedWait => _t('estimated_wait');
  String get procurementTimeline => _t('procurement_timeline');
  String get beforeEnteringGate => _t('before_gate');
  String get originalAadhaar => _t('original_aadhaar');
  String get bankPassbook => _t('bank_passbook');
  String get landRecord => _t('land_record');
  String get grainSample => _t('grain_sample');
  String get queueUpdated => _t('queue_updated');

  // Slot booking
  String get bookProcurementSlot => _t('book_procurement_slot');
  String get todayLabel => _t('today');
  String get tomorrow => _t('tomorrow');
  String get dayAfter => _t('day_after');
  String get pickDate => _t('pick_date');
  String get noSlotsAvailable => _t('no_slots');
  String get tryDifferentSelection => _t('try_different');
  String get bookSlotButton => _t('book_slot_btn');
  String get slotFull => _t('slot_full');
  String get booked => _t('booked');

  // Procurement
  String get myBookingsPayments => _t('my_bookings_payments');
  String get paymentHistory => _t('payment_history');
  String get mandiBookings => _t('mandi_bookings');
  String get totalEarnings => _t('total_earnings');
  String get paid => _t('paid');
  String get processingLabel => _t('processing_');
  String get pendingLabel => _t('pending');
  String get procurementTransactions => _t('procurement_transactions');
  String get viewSlip => _t('view_slip');
  String get eProcurementSlip => _t('e_procurement_slip');
  String get transactionId => _t('transaction_id');
  String get cropProcured => _t('crop_procured');
  String get quantity => _t('quantity');
  String get ratePerQuintal => _t('rate_quintal');
  String get totalNetAmount => _t('total_amount');
  String get bankAccount => _t('bank_account');
  String get utrReference => _t('utr_reference');
  String get downloadPdf => _t('download_pdf');
  String get slipDownloaded => _t('slip_downloaded');
  String get utrPendingClearance => _t('utr_pending_clearance');
  String get utrAwaitingSlip => _t('utr_awaiting_slip');

  // Market prices
  String get mandiCropPrices => _t('mandi_crop_prices');
  String get searchCrops => _t('search_crops');
  String get noCropsMatch => _t('no_crops_match');
  String get ratesPerQuintal => _t('rates_per_quintal');

  // Profile
  String get farmerProfile => _t('farmer_profile');
  String get personalInformation => _t('personal_info');
  String get myMandi => _t('my_mandi');
  String get myDocuments => _t('my_documents');
  String get kccAadhaarBank => _t('kcc_aadhaar_bank');
  String get languageLabel => _t('language_hindi');
  String get notificationsAlerts => _t('notifications_alerts');
  String get smsMandiReminders => _t('sms_mandi_reminders');
  String get notificationsEnabled => _t('notifications_enabled');
  String get helpSupport => _t('help_support');
  String get tollFree => _t('toll_free');
  String get logoutLabel => _t('logout');
  String get logoutTitle => _t('logout_title');
  String get logoutDesc => _t('logout_desc');
  String get cancel => _t('cancel');
  String get selectedMandiLabel => _t('selected_mandi_label');

  // Aadhaar scanner
  String get scanAadhaarCard => _t('scan_aadhaar');
  String get alignCard => _t('align_card');
  String get aadhaarProcessedSecurely => _t('aadhaar_processed_securely');
  String get readingAadhaar => _t('reading_aadhaar');
  String get turnFlashlightOff => _t('turn_flashlight_off');
  String get turnFlashlightOn => _t('turn_flashlight_on');
  String get cameraPermissionRequired => _t('camera_permission_required');
  String get cameraPermissionDesc => _t('camera_permission_desc');
  String get grantPermission => _t('grant_permission');
  String get cameraUnavailable => _t('camera_unavailable');
  String get retryCamera => _t('retry_camera');
  String get tryAgain => _t('try_again');
  String get enterManually => _t('enter_manually');
  String get aadhaarDetectedTitle => _t('aadhaar_detected_title');
  String get verifyExtracted => _t('verify_extracted');
  String get useTheseDetails => _t('use_details');
  String get scanAgain => _t('scan_again');
  String get editDetailsHint => _t('edit_details_hint');
  String get couldntDetectAadhaar => _t('couldnt_detect');
  String get couldntReadAadhaar => _t('couldnt_read_aadhaar');

  // Booking confirmation
  String get bookingConfirmed => _t('booking_confirmed');
  String get slotSuccessfullyBooked => _t('slot_booked');
  String get tokenPassIssued => _t('token_pass_issued');
  String get yourTokenNumber => _t('your_token_number');
  String get trackLiveQueue => _t('track_live_queue');
  String get goToDashboard => _t('go_to_dashboard');
  String get arriveEarly => _t('arrive_early');
  String get mandi => _t('mandi');
  String get crop => _t('crop');
  String get date => _t('date');
  String get timeSlot => _t('time_slot');
  String get farmerName => _t('farmer_name');
  String get faq => _t('faq');

  // Nav bar
  String get home => _t('nav_home');
  String get myBookings => _t('nav_my_bookings');
  String get liveQueue => _t('nav_live_queue');
  String get price => _t('nav_price');
  String get profileTab => _t('nav_profile');

  // Misc
  String get now => _t('now');
  String get todayLabel2 => _t('today_label');
  String get scan => _t('scan');
  String get min => _t('min');
  String get max => _t('max');
  String get farmers => _t('farmers');
  String get capacity => _t('capacity');
  String get minPrice => _t('min_price');
  String get maxPrice => _t('max_price');
  String get govtMsp => _t('govt_msp');
  String get priceBanner => _t('price_banner');
  String get priceBannerLive => _t('price_banner_live');
  String get priceSourceGovt => _t('price_source_govt');
  String get simulatedPriceNotice => _t('simulated_price_notice');
  String get livePricesUnavailable => _t('live_prices_unavailable');
  String get sampleRatesCaption => _t('sample_rates_caption');

  // Targeted additions
  String get available => _t('available');
  String get fillingFast => _t('filling_fast');
  String get confirmed => _t('confirmed');
  String get inQueue => _t('in_queue');
  String get completed => _t('completed');
  String get cancelled => _t('cancelled');
  String get active => _t('active');
  String get tenMinAgo => _t('ten_min_ago');
  String get oneHourAgo => _t('one_hour_ago');
  String get predictiveMock => _t('predictive_mock');
  String get nextSlotMock => _t('next_slot_mock');
  String get farmerId => _t('farmer_id');
  String get landSize => _t('land_size');
  String get acres => _t('acres');
  String get village => _t('village');
  String get district => _t('district');
  String get state => _t('state');
  String get kccDocument => _t('kcc_document');
  String get aadhaarDocument => _t('aadhaar_document');
  String get helplineHours => _t('helpline_hours');
  String get faq1 => _t('faq_1');
  String get faq2 => _t('faq_2');
  String get faq3 => _t('faq_3');
  String get createPasswordHint => _t('create_password_hint');
  String get hintFullName => _t('hint_full_name');
  String get quintals => _t('quintals');
  String get qtl => _t('qtl');
  String get showFullNumber => _t('show_full_number');
  String get hideNumber => _t('hide_number');
  String get noCameraFound => _t('no_camera_found');
  String get cameraUnavailableDesc => _t('camera_unavailable_desc');
  String get cameraPreviewError => _t('camera_preview_error');
  String get verificationDisclaimer => _t('verification_disclaimer');

  // Crop names (stable IDs resolved through localization)
  String cropName(String cropId) {
    switch (cropId) {
      case 'wheat':
        return _t('crop_wheat');
      case 'paddy':
        return _t('crop_paddy');
      case 'mustard':
        return _t('crop_mustard');
      case 'maize':
        return _t('crop_maize');
      case 'sugarcane':
        return _t('crop_sugarcane');
      case 'potato':
        return _t('crop_potato');
      default:
        return cropId;
    }
  }

  String get allCrops => _t('crop_all');
  String get cropWheat => _t('crop_wheat');
  String get cropPaddy => _t('crop_paddy');
  String get cropMustard => _t('crop_mustard');
  String get cropMaize => _t('crop_maize');
  String get cropSugarcane => _t('crop_sugarcane');
  String get cropPotato => _t('crop_potato');

  // Market categories
  String categoryName(String categoryId) {
    switch (categoryId) {
      case 'cereals':
        return _t('category_cereals');
      case 'oilseeds':
        return _t('category_oilseeds');
      case 'vegetables':
        return _t('category_vegetables');
      case 'cash_crops':
        return _t('category_cash_crops');
      default:
        return categoryId;
    }
  }

  // Gate status
  String gateStatusName(String statusId) {
    switch (statusId) {
      case 'active':
        return _t('gate_status_active');
      case 'high_crowd':
        return _t('gate_status_high_crowd');
      case 'smooth':
        return _t('gate_status_smooth');
      default:
        return statusId;
    }
  }

  // Generic key-based translation (used for queue step titles/descriptions)
  String translate(String key) => _t(key);

  // Live queue
  String get liveBadge => _t('live_badge');
  String get lastUpdated => _t('last_updated');
  String get refreshingIn => _t('refreshing_in');
  String get secondsSuffix => _t('seconds_suffix');
  String refreshingInSeconds(int seconds) =>
      '$refreshingIn $seconds$secondsSuffix';
  String get autoRefresh30s => _t('auto_refresh_30s');
  String get fetchingLiveData => _t('fetching_live_data');
  String get queueRefreshError => _t('queue_refresh_error');
  String get tapToRetry => _t('tap_to_retry');

  // Booking confirmation
  String get bookingId => _t('booking_id');
  String get aiInsightText => _t('ai_insight_text');

  // Cancel booking
  String get cancelBookingAction => _t('cancel_booking_action');
  String get cancelBookingConfirm => _t('cancel_booking_confirm');
  String get keepBooking => _t('keep_booking');
  String get confirmCancel => _t('confirm_cancel');
  String get bookingCancelledSuccess => _t('booking_cancelled_success');
  String get bookingCancelled => _t('booking_cancelled');

  // Voice booking
  String get bookByVoice => _t('book_by_voice');
  String get voiceBookingSubtitle => _t('voice_booking_subtitle');
  String get listening => _t('listening');
  String get speakNow => _t('speak_now');
  String get whichTimeSlot => _t('which_time_slot');
  String get sayCropName => _t('say_crop_name');
  String get sayTime => _t('say_time');
  String get voiceUnavailable => _t('voice_unavailable');
  String get voiceError => _t('voice_error');
  String get noSpeechDetected => _t('no_speech_detected');
  String get microphonePermissionDenied => _t('microphone_permission_denied');
  String get checkingAvailability => _t('checking_availability');
  String get slotAvailable => _t('slot_available');
  String get slotUnavailable => _t('slot_unavailable');
  String get bestAvailableBooked => _t('best_available_booked');
  String get voiceBookingSuccess => _t('voice_booking_success');
  String get voiceBookingError => _t('voice_booking_error');
  String get noAvailableSlots => _t('no_available_slots');
  String get cropSelected => _t('crop_selected');
  String get invalidCrop => _t('invalid_crop');
  String get invalidTime => _t('invalid_time');
  String get tryManualBooking => _t('try_manual_booking');
  String get tokenDetails => _t('token_details');
  String get requestedSlot => _t('requested_slot');
  String get bookedSlot => _t('booked_slot');
  String get processingVoice => _t('processing_voice');
  // Voice booking flow
  String get pressMicToSpeak => _t('press_mic_to_speak');
  String get voiceExampleHint => _t('voice_example_hint');
  String get startVoice => _t('start_voice');
  String get initializingVoice => _t('initializing_voice');
  String get openSettings => _t('open_settings');
  String get requestedSlotUnavailableAuto =>
      _t('requested_slot_unavailable_auto');
  String get listenAgain => _t('listen_again');
  String get grantMicPermission => _t('grant_mic_permission');

  // Voice booking spoken announcements
  String get voiceCropPrompt => _t('voice_crop_prompt');
  String voiceTimePrompt(String crop) =>
      _t('voice_time_prompt').replaceAll('{crop}', crop);
  String voiceCheckingAnnouncement(String time) =>
      _t('voice_checking_announcement').replaceAll('{time}', time);
  String voiceSlotAvailableAnnouncement(String time) =>
      _t('voice_slot_available_announcement').replaceAll('{time}', time);
  String voiceFallbackAnnouncement(String requested, String booked) =>
      _t('voice_fallback_announcement')
          .replaceAll('{requested}', requested)
          .replaceAll('{booked}', booked);
  String voiceSuccessAnnouncement(String time, String token) =>
      _t('voice_success_announcement')
          .replaceAll('{time}', time)
          .replaceAll('{token}', token);
  String get voicePermissionDeniedSpeech =>
      _t('voice_permission_denied_speech');
  String get voiceNotUnderstood => _t('voice_not_understood');
  String get voiceRepeatCrop => _t('voice_repeat_crop');
  String get voiceRepeatTime => _t('voice_repeat_time');
  String get voiceNoSlotsAnnouncement => _t('voice_no_slots_announcement');
  String get voiceTtsError => _t('voice_tts_error');
  String get reasonLabel => _t('reason_label');
  String get fallbackReason => _t('fallback_reason');

  static const Map<int, String> _hiDigits = {
    0: '०',
    1: '१',
    2: '२',
    3: '३',
    4: '४',
    5: '५',
    6: '६',
    7: '७',
    8: '८',
    9: '९',
  };

  /// A spoken form of an hour (0-23) in the selected language, e.g.
  /// "9:00 AM" or "सुबह ९ बजे". Used for TTS announcements and chips.
  String spokenTime(int hour) {
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    if (_langProvider.currentLanguage.code == 'hi') {
      final dayPart = hour >= 6 && hour < 12
          ? 'सुबह'
          : hour >= 12 && hour < 16
          ? 'दोपहर'
          : hour >= 16 && hour < 20
          ? 'शाम'
          : 'रात';
      final digits = h12
          .toString()
          .split('')
          .map((d) => _hiDigits[int.parse(d)]!)
          .join();
      return '$dayPart $digits बजे';
    }
    final meridiem = hour < 12 ? 'AM' : 'PM';
    return '$h12:00 $meridiem';
  }
}

/// Extension for accessing S from BuildContext without needing provider access
extension SExtension on BuildContext {
  S get s => S.of(this);
}
