import 'package:flutter/material.dart';
import 'package:q_link/core/state/app_state.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
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
                              appState.tr('Change Password', 'تغيير كلمة المرور'),
                              style: TextStyle(
                                fontSize: (w * 0.05).clamp(17.0, 22.0),
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF273469),
                              ),
                              maxLines: 1,
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
                          _buildPasswordField(
                            label: appState.tr('Current Password', 'كلمة المرور الحالية'),
                            hint: appState.tr('Enter current password', 'أدخل كلمة المرور الحالية'),
                            controller: _currentController,
                            obscure: _obscureCurrent,
                            onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                          ),
                          SizedBox(height: (short * 0.055).clamp(18.0, 28.0)),
                          _buildPasswordField(
                            label: appState.tr('New Password', 'كلمة المرور الجديدة'),
                            hint: appState.tr('At least 8 characters', '8 أحرف على الأقل'),
                            controller: _newController,
                            obscure: _obscureNew,
                            onToggle: () => setState(() => _obscureNew = !_obscureNew),
                          ),
                          SizedBox(height: (short * 0.055).clamp(18.0, 28.0)),
                          _buildPasswordField(
                            label: appState.tr('Confirm New Password', 'تأكيد كلمة المرور الجديدة'),
                            hint: appState.tr('Re-enter new password', 'أعد إدخال كلمة المرور الجديدة'),
                            controller: _confirmController,
                            obscure: _obscureConfirm,
                            onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          ),
                          SizedBox(height: (short * 0.07).clamp(28.0, 56.0)),

                          // Update Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_currentController.text != appState.currentUser.password) {
                                  _showMsg(appState.tr('Current password is incorrect', 'كلمة المرور الحالية غير صحيحة'));
                                  return;
                                }
                                if (_newController.text.length < 8) {
                                  _showMsg(appState.tr('New password is too short', 'كلمة المرور الجديدة قصيرة جداً'));
                                  return;
                                }
                                if (_newController.text != _confirmController.text) {
                                  _showMsg(appState.tr('Passwords do not match', 'كلمات المرور غير متطابقة'));
                                  return;
                                }

                                appState.updateCurrentUser(password: _newController.text);
                                _showMsg(appState.tr('Password updated successfully', 'تم تحديث كلمة المرور بنجاح'));
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
                                appState.tr('Update Password', 'تحديث كلمة المرور'),
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

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF273469)),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.grey.shade400, size: 20),
              onPressed: onToggle,
            ),
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
        ),
      ],
    );
  }
}
