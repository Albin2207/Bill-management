# 🚀 Pre-Release Checklist - Billing Management App

**Complete this checklist before building your release bundle!**

---

## ✅ **App Identity**

### App Name
- [x] **Display Name**: "Billing Management" ✅
  - Location: `AndroidManifest.xml` → `android:label="Billing Management"`
  - Verified in: Login, Splash, More pages

### Package Name
- [x] **Package ID**: `com.growblic.billing_management` ✅
  - Location: `build.gradle.kts` → `applicationId`
  - Cannot be changed after first release!

### Version
- [x] **Version Name**: `1.0.0` ✅ (What users see)
- [x] **Version Code**: `1` ✅ (Internal, must increment with each release)
  - Location: `pubspec.yaml` → `version: 1.0.0+1`
  - Format: `versionName+versionCode`

---

## 🎨 **App Icon**

### Launcher Icon
- [x] **Icon Image**: `assets/billing-management-logo.png` ✅
- [x] **Icon Generation**: Configured with `flutter_launcher_icons` ✅
- [ ] **Generated Icons**: Run `flutter pub run flutter_launcher_icons`

**To Generate Icons:**
```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

**Check Generated Icons:**
- `android/app/src/main/res/mipmap-*/ic_launcher.png`
- `android/app/src/main/res/mipmap-*/ic_launcher_foreground.png`

---

## 🔐 **Signing & Security**

### App Signing
- [x] **Keystore Created**: `android/app/billing-management-key.jks` ✅
- [x] **Key Properties**: `android/key.properties` ✅
- [x] **Build Config**: Release signing configured ✅
- [x] **Keystore Backup**: 📋 **BACKUP YOUR KEYSTORE NOW!**

**⚠️ CRITICAL**: Save keystore to:
- [ ] External hard drive
- [ ] Cloud storage (encrypted)
- [ ] Password manager (keystore passwords)

**If you lose the keystore, you can NEVER update your app!**

---

## 📱 **Permissions & Manifest**

### Permissions (Verified)
- [x] ✅ Internet (Firebase)
- [x] ✅ Network State
- [x] ✅ Storage/Media (PDFs, images)
- [x] ✅ Camera (logos, signatures)
- [x] ✅ Google Sign-In (GET_ACCOUNTS)
- [x] ❌ Biometric (REMOVED - not implemented)
- [x] ❌ Notifications (REMOVED - not implemented)

### Manifest Check
- [x] App name correct ✅
- [x] Icon reference correct ✅
- [x] No debug/test permissions ✅
- [x] FileProvider configured ✅
- [x] Network security config ✅

---

## 📄 **Legal & Privacy**

### Privacy Policy
- [ ] **Created Google Sites** with privacy policy
- [ ] **Published** and got URL
- [ ] **URL Ready** for Play Store: `_______________________`

### Account Deletion
- [ ] **Created deletion guide** page on Google Sites
- [ ] **Email ready** to handle deletion requests

### Files Created
- [x] `PRIVACY_POLICY_WEBSITE.md` ✅
- [x] `ACCOUNT_DELETION_GUIDE.md` ✅
- [x] `GOOGLE_SITES_FORMATTING_GUIDE.md` ✅

---

## 🧹 **Code Cleanup**

### Debug Code
- [x] Removed verbose debug prints ✅
- [x] ProGuard configured to strip debug code ✅
- [x] No TODO comments in critical paths ✅

### Unused Dependencies
- [x] Commented out `local_auth` ✅
- [x] Commented out `firebase_messaging` ✅
- [x] All dependencies synced ✅

---

## 🎯 **App Functionality**

### Core Features Working
- [ ] Sign Up (Email + Google)
- [ ] Sign In (Email + Google)
- [ ] Business Onboarding (with Skip option)
- [ ] Dashboard loads correctly
- [ ] Create Invoice
- [ ] Create Bill/Purchase
- [ ] Add Customers/Vendors
- [ ] Add Products
- [ ] Generate PDF
- [ ] Share PDF (WhatsApp, Email)
- [ ] Payment tracking
- [ ] GST calculations
- [ ] Dark/Light theme toggle

### Critical Fixes Applied
- [x] Google Sign-In crash fixed ✅
- [x] Keyboard closing issue fixed ✅
- [x] Stock validation for purchases fixed ✅
- [x] Business onboarding skippable ✅
- [x] QR code in PDFs working ✅

---

## 📊 **Play Store Assets**

### Required
- [ ] **App Icon**: 512x512 PNG (high-res)
- [ ] **Feature Graphic**: 1024x500 PNG
- [ ] **Screenshots**: At least 2, up to 8
  - Recommended: 1080x1920 or 1920x1080
  - Show: Dashboard, Invoice creation, PDF preview, Business details

### Recommended Screenshots
1. Dashboard with analytics
2. Create Invoice screen
3. Generated invoice (PDF preview)
4. Business Details page
5. Products/Customers list
6. Theme toggle (dark/light)

---

## 📝 **Play Store Listing**

### App Description (Short)
```
GST-compliant billing and invoicing app for Indian businesses. 
Create professional invoices, track payments, manage inventory, 
and generate GST reports - all in one app!
```

### App Description (Full)
```
Billing Management - Complete Business Solution for Indian SMEs

FEATURES:
✅ GST-Compliant Invoicing
✅ Customer & Vendor Management
✅ Inventory Tracking
✅ Payment Recording
✅ Professional PDF Generation
✅ UPI QR Code on Invoices
✅ Business Reports & Analytics
✅ Dark/Light Theme
✅ Secure Cloud Backup

Create invoices, bills, quotations, delivery challans, and more. 
Track payments, manage stock, and stay GST-compliant effortlessly.

Perfect for:
• Retail Shops
• Wholesalers
• Service Providers
• Small Manufacturers
• Freelancers

Your data is encrypted and securely stored on Firebase.
```

### Keywords/Tags
```
billing, invoice, GST, accounting, business, 
inventory, stock, payment, receipt, quotation,
Indian business, GSTIN, tax invoice
```

### Category
- **Primary**: Business
- **Secondary**: Finance

### Content Rating
- **Target Audience**: Everyone
- **Age Rating**: 3+ (business app)

---

## 🔒 **Data Safety (Play Console)**

### What to Declare
- [x] Collects financial info (OPTIONAL - bank/UPI)
- [x] Collects business info (GSTIN, address)
- [x] Collects customer/vendor data
- [x] Collects transaction records
- [x] Collects photos (logos - optional)
- [x] Uses camera
- [x] Encrypted in transit: YES
- [x] Can request deletion: YES (via email)

### Privacy Policy URL
```
[Your Google Sites URL here after publishing]
```

---

## 🧪 **Testing Checklist**

### Device Testing
- [ ] Test on Android 6.0 (min SDK 23)
- [ ] Test on Android 13/14 (target SDK 34)
- [ ] Test on small screen (5")
- [ ] Test on large screen (6.5"+)
- [ ] Test on tablet (optional)

### Network Testing
- [ ] Works with WiFi
- [ ] Works with mobile data
- [ ] Handles no internet gracefully
- [ ] Syncs data across devices

### User Flows
- [ ] New user signup → Onboarding → Dashboard
- [ ] Create invoice → Generate PDF → Share
- [ ] Add product → Use in invoice → Stock updates
- [ ] Record payment → Status updates
- [ ] Google Sign-In → Dashboard
- [ ] Theme toggle works everywhere

### Edge Cases
- [ ] What happens with no internet?
- [ ] What if Firebase is slow?
- [ ] Empty states (no invoices, no products)
- [ ] Very long business names
- [ ] Large invoice amounts
- [ ] Many products (100+)

---

## 📦 **Build Configuration**

### Release Build Settings
- [x] **Minify**: Disabled (for stability)
- [x] **Shrink Resources**: Disabled
- [x] **ProGuard**: Configured (removes debug code)
- [x] **Multi-Dex**: Enabled ✅

### Build Commands

**Standard APK** (for testing):
```bash
flutter build apk --release
```

**App Bundle** (for Play Store):
```bash
flutter build appbundle --release
```

**Split APKs** (smaller size):
```bash
flutter build apk --release --split-per-abi
```

---

## 📂 **Output Files**

After building, you'll find:

### APK
```
build/app/outputs/flutter-apk/app-release.apk
```

### App Bundle (AAB)
```
build/app/outputs/bundle/release/app-release.aab
```

### Split APKs
```
build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
build/app/outputs/flutter-apk/app-x86_64-release.apk
```

---

## 🚀 **Final Steps**

### Before Building
1. [ ] Run `flutter clean`
2. [ ] Run `flutter pub get`
3. [ ] Run `flutter pub run flutter_launcher_icons`
4. [ ] Verify app name in `AndroidManifest.xml`
5. [ ] Verify version in `pubspec.yaml`
6. [ ] Test on real device one more time

### Build for Play Store
```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

### After Building
1. [ ] Locate: `build/app/outputs/bundle/release/app-release.aab`
2. [ ] File size: ~15-30 MB (expected)
3. [ ] Test install on device (if possible)
4. [ ] Keep backup of AAB file

---

## 📤 **Play Store Submission**

### Required Information

**App Details:**
- App Name: Billing Management
- Short Description: (see above)
- Full Description: (see above)
- App Category: Business
- Email: thomasalbin35@gmail.com
- Privacy Policy URL: [Your Google Sites URL]

**Store Listing:**
- App Icon (512x512)
- Feature Graphic (1024x500)
- Screenshots (2-8 images)

**Content Rating:**
- Complete questionnaire
- Business app → Everyone

**Pricing:**
- Free (with no in-app purchases)
- Available in: India, All countries (your choice)

**Data Safety:**
- Complete form using `PLAY_STORE_DATA_SAFETY.md` guide

**App Access:**
- No special access needed
- No restrictions

**Upload AAB:**
- Upload `app-release.aab`
- Google will generate APKs for different devices

---

## ⚠️ **Common Issues to Avoid**

### DON'T
- ❌ Build without testing on real device
- ❌ Submit without privacy policy URL
- ❌ Forget to complete Data Safety section
- ❌ Use same version code as before
- ❌ Lose your keystore file!

### DO
- ✅ Test thoroughly on different Android versions
- ✅ Backup keystore in 3 places
- ✅ Test PDF generation and sharing
- ✅ Test Google Sign-In
- ✅ Complete all Play Store fields

---

## 📋 **Version Management**

### For Future Updates

When releasing updates, increment version:

**Bug Fix**: 1.0.0 → 1.0.1
```yaml
version: 1.0.1+2
```

**New Feature**: 1.0.0 → 1.1.0
```yaml
version: 1.1.0+2
```

**Major Update**: 1.0.0 → 2.0.0
```yaml
version: 2.0.0+2
```

**Always increment the build number (+1, +2, +3...)!**

---

## ✅ **Final Checklist**

**Before Submitting:**

- [ ] App tested and working perfectly
- [ ] All features functional
- [ ] No crashes or major bugs
- [ ] Privacy policy published
- [ ] Keystore backed up (3 copies!)
- [ ] App bundle built successfully
- [ ] Screenshots ready
- [ ] App icon generated
- [ ] Store listing written
- [ ] Data safety form ready

**You're Ready!** 🎉

---

## 🆘 **Need Help?**

**Play Store Resources:**
- https://support.google.com/googleplay/android-developer

**Flutter Resources:**
- https://docs.flutter.dev/deployment/android

**Your Files:**
- `android/KEYSTORE_INFO.md` - Keystore details
- `android/PLAY_STORE_DATA_SAFETY.md` - Data safety guide
- `PRIVACY_POLICY_WEBSITE.md` - Privacy policy content
- `ACCOUNT_DELETION_GUIDE.md` - Deletion guide content

---

**Good Luck with Your Launch! 🚀**

**App**: Billing Management  
**Version**: 1.0.0 (1)  
**Package**: com.growblic.billing_management  
**Developer**: Albin Thomas @ Growblic


