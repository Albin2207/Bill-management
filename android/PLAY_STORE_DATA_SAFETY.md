# 📊 Google Play Store - Data Safety Declaration

## ⚠️ IMPORTANT: Complete this before publishing to Play Store

When submitting to Google Play Store, you MUST declare all data collection and usage in the **Data Safety** section.

---

## 🔐 Data Types Collected by Billing Management App

### ✅ **Financial Information** (COLLECTED & STORED - OPTIONAL)
**What**: Bank account details, UPI IDs, payment records  
**Why**: To generate invoices with payment information  
**How**: Stored in Firebase Firestore (encrypted in transit and at rest)  
**User Control**: OPTIONAL - Users can skip/edit/delete in Business Details page  
**Sharing**: NOT shared with third parties  

**Specific Fields:**
- Bank Name
- Account Number
- IFSC Code
- Account Holder Name
- Branch Name
- UPI ID

---

### ✅ **Business Information** (COLLECTED & STORED)
**What**: Business name, GSTIN, address, contact details  
**Why**: Required for generating GST-compliant invoices  
**How**: Stored in Firebase Firestore  
**User Control**: Users can edit/delete anytime  
**Sharing**: NOT shared with third parties  

**Specific Fields:**
- Business Name
- GSTIN (Tax ID)
- Business Address
- Phone Number
- Email Address
- Business Logo (optional)

---

### ✅ **Personal Information** (COLLECTED & STORED)
**What**: User name, email, authentication data  
**Why**: Account creation and authentication  
**How**: Stored in Firebase Authentication  
**User Control**: Users can delete account  
**Sharing**: Email shared with Firebase only  

**Specific Fields:**
- Full Name
- Email Address
- Password (hashed)
- Google Account (if using Google Sign-In)

---

### ✅ **Customer & Vendor Data** (COLLECTED & STORED)
**What**: Party information (customers/vendors)  
**Why**: Invoice generation and billing records  
**How**: Stored in Firebase Firestore  
**User Control**: Users can add/edit/delete  
**Sharing**: NOT shared with third parties  

**Specific Fields:**
- Party Name
- Phone Number
- Email Address
- Billing Address
- Shipping Address
- GSTIN (if applicable)

---

### ✅ **Transaction Data** (COLLECTED & STORED)
**What**: Invoices, bills, payments, receipts  
**Why**: Business accounting and GST compliance  
**How**: Stored in Firebase Firestore  
**User Control**: Users own all data, can export/delete  
**Sharing**: NOT shared with third parties  

**Specific Fields:**
- Invoice/Bill details
- Product/Service information
- Amounts and taxes
- Payment status
- Due dates

---

### ✅ **Files and Photos** (COLLECTED & STORED)
**What**: Business logos, signatures, receipt images  
**Why**: Customization and documentation  
**How**: Stored in Firebase Storage  
**User Control**: Users can upload/delete  
**Sharing**: NOT shared with third parties  

**Specific Types:**
- Business Logo (PNG/JPG)
- Digital Signatures (PNG)
- Receipt Photos (optional, if implemented)

---

### ✅ **Device Information** (COLLECTED - Analytics Only)
**What**: Device type, OS version, app version  
**Why**: Crash reporting and analytics  
**How**: Firebase Analytics  
**User Control**: Cannot disable  
**Sharing**: Shared with Google Firebase only  

---

## 🔒 Security Practices

### Data Encryption
- ✅ **In Transit**: All data encrypted with HTTPS/TLS
- ✅ **At Rest**: Firebase encryption at rest
- ✅ **Authentication**: Firebase Auth with secure tokens

### Data Retention
- ✅ User data retained as long as account is active
- ✅ Data deleted within 30 days of account deletion
- ✅ Backups removed from all servers

### User Rights
- ✅ Users can export their invoices/reports (PDF format)
- ⚠️ Users must email developer to request account deletion
- ✅ Users can edit all information anytime
- ✅ Bank/UPI details are OPTIONAL - users can skip them

---

## 📱 Play Store Data Safety Form - Quick Answers

### Does your app collect or share any of the required user data types?
**YES** ✅

### Is all of the user data collected by your app encrypted in transit?
**YES** ✅

### Do you provide a way for users to request that their data is deleted?
**NO** ❌ (Users must contact developer via email to request account deletion)

---

## 🎯 Data Safety Categories to Declare

Select these in Play Store Console:

### **Location** ❌ NOT COLLECTED

### **Personal info** ✅ COLLECTED
- [x] Name
- [x] Email address
- [x] User IDs (Firebase UID)

### **Financial info** ✅ COLLECTED
- [x] Purchase history (invoices/bills)
- [x] Payment info (bank details, UPI)
- [x] Other financial info (GST records)

### **Health and fitness** ❌ NOT COLLECTED

### **Messages** ❌ NOT COLLECTED

### **Photos and videos** ✅ COLLECTED (Optional)
- [x] Photos (business logos, signatures)

### **Audio files** ❌ NOT COLLECTED

### **Files and docs** ✅ COLLECTED
- [x] Files and docs (invoices, receipts generated)

### **Calendar** ❌ NOT COLLECTED

### **Contacts** ✅ COLLECTED
- [x] Contacts (customer/vendor information)

### **App activity** ❌ NOT COLLECTED

### **Web browsing** ❌ NOT COLLECTED

### **App info and performance** ✅ COLLECTED
- [x] Crash logs
- [x] Diagnostics

### **Device or other IDs** ✅ COLLECTED
- [x] Device or other IDs (for analytics)

---

## 📝 Data Usage Declaration

For EACH data type collected, declare:

### **Financial Information**
- ✅ **Collected**: YES (OPTIONAL)
- ✅ **Shared**: NO
- ✅ **Purpose**: App functionality (invoice generation)
- ✅ **Encrypted**: YES
- ✅ **Optional**: YES (users can skip bank/UPI details)
- ⚠️ **Deletable**: By contacting developer only

### **Business Information**
- ✅ **Collected**: YES
- ✅ **Shared**: NO
- ✅ **Purpose**: App functionality
- ✅ **Encrypted**: YES
- ✅ **Optional**: NO (required for GST invoicing)
- ⚠️ **Deletable**: By contacting developer only

### **Customer/Vendor Information**
- ✅ **Collected**: YES
- ✅ **Shared**: NO
- ✅ **Purpose**: App functionality
- ✅ **Encrypted**: YES
- ✅ **Optional**: NO (required for invoicing)
- ⚠️ **Deletable**: By contacting developer only

### **Photos (Logos, Signatures)**
- ✅ **Collected**: YES
- ✅ **Shared**: NO
- ✅ **Purpose**: App functionality, Personalization
- ✅ **Encrypted**: YES
- ✅ **Optional**: YES (users can skip logo upload)
- ⚠️ **Deletable**: By contacting developer only

---

## 🔗 Required Links for Play Store

### Privacy Policy URL
**Required**: YES  
**Current**: Include link to hosted privacy policy  
**Suggestion**: Host `lib/features/settings/presentation/pages/privacy_policy_page.dart` content on a website  
**Example**: `https://yourdomain.com/privacy-policy`

---

## ⚠️ SENSITIVE PERMISSIONS - Play Store Review

Google will ask why you need these permissions:

### **Camera**
**Reason**: "To capture business logos and digital signatures for invoice customization"

### **Storage/Photos**
**Reason**: "To select and upload business logos and save generated invoices/receipts as PDFs"

### **Biometric**
**NOT USED** - This permission was removed as biometric authentication is not implemented

### **Notifications**
**NOT USED** - This permission was removed as push notifications are not implemented

---

## 📋 Pre-Submission Checklist

Before submitting to Play Store:

- [ ] Complete Data Safety section in Play Console
- [ ] Declare all collected data types
- [ ] Mark financial data as encrypted
- [ ] Provide privacy policy URL
- [x] Users can edit/remove bank and UPI details
- [ ] Test account deletion process (via email to developer)
- [ ] Verify all sensitive data is encrypted
- [ ] Screenshot app showing data handling
- [ ] Prepare response for permission justification

---

## 🎥 Screenshots to Prepare

For Play Store review, prepare screenshots showing:

1. Business Details page (showing bank info fields are optional)
2. Privacy Policy page
3. Contact email for account deletion requests
4. Invoice export functionality (PDF)

---

## 📞 Declaration Statement

**For Play Store Console:**

> "Billing Management collects and stores business information (GSTIN, address), customer/vendor contact details, and transaction records to provide GST-compliant invoicing and accounting functionality. Financial information (bank accounts, UPI IDs) is OPTIONAL and only collected if users choose to provide it. All data is encrypted in transit (HTTPS) and at rest (Firebase). Users can request account deletion by contacting the developer via email (thomasalbin35@gmail.com). We do not share user data with any third parties except Firebase (Google Cloud) for storage and authentication purposes."

---

**Last Updated**: November 6, 2025  
**App Version**: 1.0.0  
**Review Status**: Pending Play Store submission

