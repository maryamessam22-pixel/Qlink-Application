// EXAMPLE: How to update ANY screen for localization
// This shows the step-by-step process for converting hardcoded strings to translations

// ============ STEP 1: Add imports ============

import 'package:flutter/material.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/core/localization/app_localization.dart';
// ... other imports

// ============ STEP 2: Update State class ============

class ExamplePageState extends State<ExamplePage> {
  @override
  Widget build(BuildContext context) {
    // Initialize AppState
    final appState = AppState();

    // Wrap entire Scaffold with AnimatedBuilder
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        // Your normal Scaffold code goes inside the builder
        return Scaffold(
          appBar: AppBar(
            // Use appState properties for strings
            title: Text(appState.home), // instead of 'Home'
          ),
          body: Column(
            children: [
              // BEFORE: Text('Welcome to App')
              // AFTER:
              Text(appState.welcomeToQlink),

              // For dynamic strings with variables:
              Text(
                appState.tr(
                  'Hello ${widget.name}', // English version
                  'مرحبا ${widget.name}', // Arabic version
                ),
              ),

              // TextField with placeholder
              TextField(
                decoration: InputDecoration(
                  hintText: appState.emailAddress,
                  labelText: appState.emailAddress,
                ),
              ),

              // Buttons
              ElevatedButton(onPressed: () {}, child: Text(appState.signIn)),

              // Dialog
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(appState.appName),
                      content: Text(appState.profileUpdatedSuccessfully),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(appState.cancel),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============ STEP 3: Important Notes ============

/*
1. ALWAYS wrap build method with:
   ```
   return AnimatedBuilder(
     animation: appState,
     builder: (context, _) {
       return Scaffold(...);
     },
   );
   ```

2. For strings not yet in AppState, use the tr() method:
   ```
   appState.tr('English text', 'النص العربي')
   ```

3. For snackbars, dialogs, and dynamic messages:
   ```
   ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(content: Text(appState.profileUpdatedSuccessfully)),
   );
   ```

4. For placeholder text in TextField:
   ```
   TextField(
     decoration: InputDecoration(
       hintText: appState.emailAddress,
     ),
   )
   ```

5. For button labels:
   ```
   ElevatedButton(
     child: Text(appState.signIn), // NOT 'Sign In'
   ),
   ```

6. For TextSpans and mixed content:
   ```
   RichText(
     text: TextSpan(
       children: [
         TextSpan(text: appState.newToQlink),
         TextSpan(
           text: appState.createAccount,
           style: const TextStyle(fontWeight: FontWeight.bold),
         ),
       ],
     ),
   )
   ```

7. Always check autocomplete for available properties
   - Type: appState.
   - See all available properties in autocomplete
   - Use those instead of hardcoding strings
*/

// ============ COMPLETE PATTERN EXAMPLE ============

class SignInPageExample extends StatefulWidget {
  final String role;
  const SignInPageExample({super.key, required this.role});

  @override
  State<SignInPageExample> createState() => _SignInPageExampleState();
}

class _SignInPageExampleState extends State<SignInPageExample> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final appState = AppState();

    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: Text(appState.signIn), centerTitle: true),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo
                Center(child: Text(appState.qlink)),
                const SizedBox(height: 30),

                // Header
                Text(
                  appState.secureAccessRequired,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 30),

                // Email Field
                TextField(
                  decoration: InputDecoration(
                    labelText: appState.emailAddress,
                    hintText: appState.emailPlaceholder,
                  ),
                ),
                const SizedBox(height: 16),

                // Password Field
                TextField(
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: appState.password,
                    hintText: appState.passwordPlaceholder,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(appState.forgotPassword),
                  ),
                ),
                const SizedBox(height: 30),

                // Sign In Button
                ElevatedButton(onPressed: () {}, child: Text(appState.signIn)),
                const SizedBox(height: 30),

                // Create Account Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(appState.newToQlink),
                    TextButton(
                      onPressed: () {},
                      child: Text(appState.createAccount),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============ AVAILABLE SHORTCUTS ============
// These are the most common strings - use autocomplete to see all:

// appState.home                           // "الرئيسية"
// appState.map                            // "الخريطة"
// appState.vault                          // "الخزانة"
// appState.settings                       // "الإعدادات"
// appState.signIn                         // "تسجيل الدخول"
// appState.createAccount                  // "إنشاء حساب"
// appState.emailAddress                   // "عنوان البريد الإلكتروني"
// appState.password                       // "كلمة المرور"
// appState.forgotPassword                 // "هل نسيت كلمة المرور؟"
// appState.cancel                         // "إلغاء"
// appState.back                           // "رجوع"
// appState.delete                         // "حذف"
// appState.saveEdits                      // "حفظ التعديلات"
// appState.loading                        // "جاري التحميل.."
// appState.emergencyContacts              // "جهات الاتصال الطارئة"
// appState.bloodType                      // "فصيلة الدم"
// appState.allergies                      // "الحساسيات"
// ... and 100+ more (use autocomplete!)

// ============ TESTING YOUR CHANGES ============

/*
After updating a screen:

1. Run: flutter clean && flutter pub get
2. Open the app
3. Check that text displays correctly
4. Try switching language (using LanguageSwitcher widget)
5. Verify:
   - Text is correct in both languages
   - Font is Noto Kufi Arabic for Arabic
   - RTL direction for Arabic (buttons, text)
   - LTR direction for English
   - No hardcoded English strings remain
*/
