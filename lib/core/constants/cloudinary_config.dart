class CloudinaryConfig {
  // Cloudinary Configuration
  static const String cloudName = 'dzfepmtdw';
  static const String apiKey = '923553774544911';
  static const String apiSecret = 'BbzydwVChmEHo8XZCPEaLKtwBwE'; // ⚠️ Should be stored on backend
  
  // Cloudinary Upload URL
  static const String uploadUrl = 'https://api.cloudinary.com/v1_1/$cloudName/image/upload';
  
  // Upload Preset (for unsigned uploads)
  static const String? uploadPreset = 'bill management';
  
  // Security Note:
  // For production, API Secret should NEVER be in the client app.
  // Options:
  // 1. Use unsigned upload presets (set uploadPreset above)
  // 2. Create a backend service to handle uploads
  // 3. Use signed uploads from your backend
}


