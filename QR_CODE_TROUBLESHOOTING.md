# 🔧 QR Code Troubleshooting Guide

## ✅ **Fixed Issues:**

### **1. Default Settings Changed**
**Problem:** `showQRCode` was set to `false` by default  
**Fix:** Changed default to `true` in:
- `document_settings_entity.dart`
- `document_settings_model.dart`
- `document_settings_page.dart`
- `pdf_service.dart`
- `invoice_detail_page.dart`

---

## 📋 **QR Code Checklist:**

### **For QR to Show in PDF, You Need:**

1. ✅ **UPI ID Added**
   - Go to: **More → Business Details → Edit**
   - Or: **More → Business Logo → Bank Details Section**
   - Add UPI ID (e.g., `yourshop@paytm`)
   - UPI format: `name@bank`

2. ✅ **Show QR Code Enabled** (Now ON by default)
   - Go to: **More → Document Settings → Templates Tab**
   - Find: "Show QR Code" toggle
   - Ensure it's turned **ON** ✅

3. ✅ **Create New Invoice**
   - Old invoices won't have QR
   - Create a NEW invoice
   - Download PDF
   - QR should appear!

---

## 🧪 **How to Test:**

### **Step 1: Add UPI ID**
```
More → Business Details → Edit Business
   ↓
Scroll to Bank Details
   ↓
Enter UPI ID: test@paytm
   ↓
Save
```

### **Step 2: Verify Settings**
```
More → Document Settings → Templates
   ↓
Look for "Show QR Code" toggle
   ↓
Should be ON (now default)
```

### **Step 3: Create Invoice**
```
Home → Create Sales Invoice
   ↓
Add party, products, amount
   ↓
Save Invoice
   ↓
Open invoice → Download PDF
   ↓
Check bottom of PDF → QR code should appear!
```

---

## 🔍 **Where QR Code Appears:**

### **1. In Downloaded PDF Invoice:**
```
┌─────────────────────────────────────┐
│ TAX INVOICE                         │
│ ...invoice details...               │
│ ...items table...                   │
│ Total: Rs. 5,000                    │
│                                     │
│ ┌──────────────────────────────┐   │
│ │ [QR]  |  UPI Payment          │   │
│ │ Code  |  UPI ID: test@paytm   │   │
│ │       |  Amount: Rs. 5,000    │   │
│ │       |  Ref: INV-001         │   │
│ └──────────────────────────────┘   │
└─────────────────────────────────────┘
```

### **2. In Invoice Detail Screen (In App):**
```
Payment Section
   ↓
Quick Payment via UPI
   ↓
[Large QR Code 200x200]
   ↓
UPI ID: test@paytm
Amount: Rs. 5,000
```

### **3. In Business Details Page:**
```
More → Business Details
   ↓
UPI Payment Details Section
   ↓
[Static QR Code 180x180]
(Customer enters amount)
```

---

## ❗ **Why QR Might Not Show:**

### **Reason 1: No UPI ID Set**
**Check:**
```dart
Business Profile → UPI ID field is empty
```
**Fix:**
```
Add UPI ID in business profile
Format: yourshop@paytm
```

### **Reason 2: Invalid UPI Format**
**Check:**
```
UPI ID doesn't contain '@'
Example: "myshop" ❌
```
**Fix:**
```
Correct format: myshop@paytm ✅
```

### **Reason 3: Settings Cached**
**Check:**
```
Old settings saved with showQRCode: false
```
**Fix:**
```
Go to Document Settings
Toggle "Show QR Code" OFF then ON
Save Settings
```

### **Reason 4: Testing with OLD Invoice**
**Check:**
```
Viewing invoice created before UPI setup
```
**Fix:**
```
Create a NEW invoice
QR is generated per invoice
```

---

## 🔧 **Quick Fix (If Still Not Working):**

### **Option 1: Toggle QR Setting**
```
More → Document Settings → Templates
Toggle "Show QR Code" OFF
Save
Toggle "Show QR Code" ON
Save
```

### **Option 2: Verify UPI ID**
```
More → Business Details → View UPI ID
Should show: yourshop@paytm
If empty → Edit → Add UPI ID
```

### **Option 3: Create Fresh Invoice**
```
Delete test invoice
Create brand new invoice
Download PDF
Check for QR
```

---

## 📊 **QR Code Logic Flow:**

```
Generate Invoice PDF
   ↓
Check: settings?.showQRCode ?? true
   ↓ YES
Get UPI ID: business?.upiId ?? settings?.upiId
   ↓ EXISTS
Validate UPI Format: name@bank
   ↓ VALID
Generate UPI Link:
  upi://pay?pa=shop@paytm&pn=BusinessName&am=5000&tn=INV-001
   ↓
Generate QR Code in PDF
   ↓ SUCCESS
QR appears at bottom of invoice!
```

---

## ✅ **What's Been Fixed:**

1. ✅ Default `showQRCode` changed to `true`
2. ✅ Entity default changed to `true`
3. ✅ Model default changed to `true`
4. ✅ Page default changed to `true`
5. ✅ PDF service default changed to `true`
6. ✅ Invoice detail default changed to `true`

---

## 🚀 **Expected Behavior Now:**

- **New Users:** QR code ON by default
- **Existing Users:** Need to toggle once (if cached)
- **If UPI ID present:** QR shows automatically
- **If UPI ID missing:** QR gracefully hidden

---

## 📞 **Still Not Working?**

Check these in order:

1. ✅ Business has UPI ID?
2. ✅ UPI format valid (name@bank)?
3. ✅ Document settings "Show QR Code" ON?
4. ✅ Creating NEW invoice (not old one)?
5. ✅ Invoice has grand total > 0?

If all YES and still no QR → There might be a Firebase/settings sync issue.

**Solution:**
- Logout
- Login again
- Check business details loaded
- Try creating invoice again

---

**Status:** ✅ **QR Code Now Enabled by Default!**

QR will show in PDFs for all new invoices if UPI ID is set! 🎉


