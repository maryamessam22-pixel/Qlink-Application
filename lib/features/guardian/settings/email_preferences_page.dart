import 'package:flutter/material.dart';
import 'package:q_link/core/state/app_state.dart';

class EmailPreferencesPage extends StatefulWidget {
  const EmailPreferencesPage({super.key});

  @override
  State<EmailPreferencesPage> createState() => _EmailPreferencesPageState();
}

class _EmailPreferencesPageState extends State<EmailPreferencesPage> {
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: AppState().currentUser.email);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final appState = AppState();
        final mq = MediaQuery.of(context);
        final short = mq.size.shortestSide;
        final w = mq.size.width;
        final hPad = (w * 0.055).clamp(16.0, 28.0);
        final bottomPad =
            mq.viewInsets.bottom + mq.padding.bottom + (short * 0.08).clamp(20.0, 36.0);

        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: const Color(0xFFF7F9FC),
          body: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/bg.png'),
                        fit: BoxFit.cover,
                        opacity: 0.05,
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: (w * 0.035).clamp(8.0, 16.0),
                      vertical: (short * 0.012).clamp(6.0, 10.0),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, color: Color(0xFF273469)),
                        ),
                        Expanded(
                          child: Text(
                            appState.tr('Email Preferences', 'تفضيلات البريد الإلكتروني'),
                            style: TextStyle(
                              fontSize: (w * 0.045).clamp(16.0, 21.0),
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF273469),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFFF3F4F6), thickness: 1),

                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(hPad, (short * 0.02).clamp(8.0, 16.0), hPad, bottomPad),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minHeight: constraints.maxHeight),
                            child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appState.tr('Email Address', 'البريد الإلكتروني'),
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF273469)),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF9FAFB),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Color(0xFF1B64F2), width: 1.5),
                              ),
                            ),
                            style: const TextStyle(color: Color(0xFF4B5563), fontSize: 13),
                          ),
                          SizedBox(height: (short * 0.12).clamp(40.0, 80.0)),

                          // Save Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (!_emailController.text.contains('@')) {
                                   ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(appState.tr('Invalid email address', 'عنوان بريد إلكتروني غير صالح'))),
                                  );
                                  return;
                                }

                                appState.updateCurrentUser(email: _emailController.text);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(appState.tr('Email updated successfully', 'تم تحديث البريد الإلكتروني بنجاح'))),
                                );
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1B64F2),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: (short * 0.045).clamp(14.0, 20.0)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                elevation: 0,
                              ),
                              child: Text(
                                appState.tr('Save Preferences', 'حفظ التفضيلات'),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: (w * 0.04).clamp(14.0, 17.0),
                                ),
                              ),
                            ),
                          ),
                        ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            ],
          ),
        );
      },
    );
  }
}
