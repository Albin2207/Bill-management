# 🔐 Billing Management App - Keystore Information

## Keystore Details

**⚠️ IMPORTANT: Keep this information secure and private!**

### Release Signing Configuration

- **Keystore File**: `android/app/billing-management-key.jks`
- **Keystore Password**: `billing123`
- **Key Alias**: `billing-management`
- **Key Password**: `billing123`
- **Validity**: 10,000 days (~27 years)
- **Algorithm**: RSA 2048-bit
- **Certificate**: SHA384withRSA

### Certificate Details

- **Common Name (CN)**: Billing Management
- **Organizational Unit (OU)**: Development
- **Organization (O)**: Growblic
- **Locality (L)**: India
- **State (ST)**: Kerala
- **Country (C)**: IN

---

## 📝 Configuration Files

### 1. `android/key.properties`
Contains the keystore credentials used during the build process.

### 2. `android/app/build.gradle.kts`
Configured to use the release signing configuration.

---

## 🚀 Building Release APK/AAB

### Build Release APK
```bash
flutter build apk --release
```

### Build Release App Bundle (AAB) for Play Store
```bash
flutter build appbundle --release
```

### Build Split APKs (Smaller size)
```bash
flutter build apk --release --split-per-abi
```

---

## 🔒 Security Best Practices

1. **Never commit keystore files to version control**
   - The `.gitignore` is configured to exclude keystore files
   
2. **Backup your keystore securely**
   - Store the keystore file in a secure location
   - Keep multiple encrypted backups
   - **If you lose this keystore, you cannot update your app on Play Store!**

3. **Use environment variables in CI/CD**
   - For production, use secure environment variables
   - Never hardcode passwords in scripts

4. **Change default passwords**
   - The current passwords (`billing123`) are development defaults
   - For production release, consider changing them to stronger passwords

---

## 📁 File Locations

```
billing_management/
├── android/
│   ├── key.properties          # Keystore configuration (DO NOT COMMIT)
│   ├── app/
│   │   └── billing-management-key.jks  # Keystore file (DO NOT COMMIT)
│   └── app/build.gradle.kts    # Build configuration
```

---

## 🔄 Updating Keystore Password

If you need to change the keystore password:

1. Change password in `android/key.properties`
2. Update the keystore using keytool:
   ```bash
   keytool -storepasswd -keystore android/app/billing-management-key.jks
   keytool -keypasswd -alias billing-management -keystore android/app/billing-management-key.jks
   ```

---

## 📱 Play Store Upload

When ready to publish to Google Play Store:

1. Build the app bundle:
   ```bash
   flutter build appbundle --release
   ```

2. The signed AAB will be at:
   ```
   build/app/outputs/bundle/release/app-release.aab
   ```

3. Upload to Play Console

---

**Created**: November 6, 2025  
**App Version**: 1.0.0

