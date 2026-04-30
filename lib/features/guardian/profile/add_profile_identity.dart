import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:q_link/features/guardian/profile/add_medical_info.dart';
import 'package:q_link/core/state/app_state.dart';
import 'package:q_link/features/shared/widgets/bottom_nav_widget.dart';
import 'package:q_link/features/shared/widgets/header_widget.dart';

class AddProfileIdentityPage extends StatefulWidget {
  final int? editIndex;
  final ProfileData? existingProfile;

  const AddProfileIdentityPage({
    super.key,
    this.editIndex,
    this.existingProfile,
  });

  @override
  State<AddProfileIdentityPage> createState() => _AddProfileIdentityPageState();
}

class _AddProfileIdentityPageState extends State<AddProfileIdentityPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();
  final TextEditingController _birthYearController = TextEditingController();
  final List<TextEditingController> _contactControllers = [];
  String? _imagePath;
  Uint8List? _imageBytes;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imagePath = image.path;
        _imageBytes = bytes;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.existingProfile != null) {
      _nameController.text = widget.existingProfile!.name;
      _relationshipController.text = widget.existingProfile!.relationship;
      _birthYearController.text = widget.existingProfile!.birthYear;
      _imagePath = widget.existingProfile!.imagePath;
      for (var contact in widget.existingProfile!.emergencyContacts) {
        _contactControllers.add(TextEditingController(text: contact));
      }
    }
    // Ensure at least one contact field
    if (_contactControllers.isEmpty) {
      _contactControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _relationshipController.dispose();
    _birthYearController.dispose();
    for (var controller in _contactControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildAppBar() {
    return const HeaderWidget();
  }

  Widget _buildBackButton() {
    final w = MediaQuery.sizeOf(context).width;
    final short = MediaQuery.sizeOf(context).shortestSide;
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Row(
        children: [
          Icon(
            Icons.arrow_back,
            color: Colors.grey.shade500,
            size: (short * 0.052).clamp(18.0, 22.0),
          ),
          SizedBox(width: (w * 0.012).clamp(3.0, 6.0)),
          Text(
            AppState().tr('Cancel', 'إلغاء'),
            style: TextStyle(
              fontSize: (w * 0.04).clamp(14.0, 17.0),
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentityTitle() {
    final w = MediaQuery.sizeOf(context).width;
    return Text(
      AppState().tr('Generate Patient Profile', 'إنشاء ملف المريض'),
      style: TextStyle(
        fontSize: (w * 0.055).clamp(18.0, 24.0),
        fontWeight: FontWeight.w800,
        color: const Color(0xFF1E3A8A),
      ),
    );
  }

  Widget _buildIdentityStepLabel() {
    final w = MediaQuery.sizeOf(context).width;
    return Text(
      AppState().tr('Step 1 of 3: Identity', 'الخطوة 1 من 3: الهوية'),
      style: TextStyle(
        fontSize: (w * 0.04).clamp(14.0, 17.0),
        color: Colors.grey.shade600,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildContinueToMedicalButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddMedicalInfoPage(
              name: _nameController.text,
              relationship: _relationshipController.text,
              birthYear: _birthYearController.text,
              emergencyContacts: _contactControllers.map((c) => c.text).where((t) => t.isNotEmpty).toList(),
              avatarUrl: _imagePath,
              avatarBytes: _imageBytes,
              editIndex: widget.editIndex,
              existingProfile: widget.existingProfile,
            ),
          ),
        );
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final short = MediaQuery.sizeOf(context).shortestSide;
          final w = MediaQuery.sizeOf(context).width;
          final btnH = (short * 0.135).clamp(48.0, 58.0);
          return Container(
            width: double.infinity,
            height: btnH,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0066CC), Color(0xFF273469)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(btnH * 0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    AppState().tr('Continue to Medical Info', 'متابعة للمعلومات الطبية'),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: (w * 0.04).clamp(14.0, 17.0),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: (w * 0.02).clamp(6.0, 10.0)),
                Icon(Icons.arrow_forward, color: Colors.white, size: (short * 0.05).clamp(18.0, 22.0)),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppState(),
      builder: (context, _) {
        final mq = MediaQuery.of(context);
        final short = mq.size.shortestSide;
        final w = mq.size.width;
        final hPad = (w * 0.055).clamp(16.0, 28.0);
        final vPad = (short * 0.028).clamp(12.0, 20.0);
        final bottomPad =
            mq.viewInsets.bottom + mq.padding.bottom + (short * 0.06).clamp(18.0, 28.0);
        final gapL = (short * 0.055).clamp(18.0, 28.0);
        final gapM = (short * 0.045).clamp(14.0, 22.0);
        final gapS = (short * 0.02).clamp(6.0, 10.0);
        final avatarD = (short * 0.30).clamp(100.0, 132.0);
        final personIcon = (avatarD * 0.45).clamp(44.0, 64.0);
        final camIcon = (short * 0.05).clamp(18.0, 22.0);

        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          extendBody: true,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(hPad, vPad, hPad, bottomPad),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - mq.padding.vertical,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildAppBar(),
                        SizedBox(height: gapL),
                        _buildBackButton(),
                        SizedBox(height: gapM),
                        _buildIdentityTitle(),
                        SizedBox(height: gapS + 8),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E3A8A),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: gapS),
                        _buildIdentityStepLabel(),
                        SizedBox(height: gapL),
                        const Divider(color: Color(0xFFE5E7EB), thickness: 1),
                        SizedBox(height: gapL),

                  // Profile Picture Section
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: avatarD,
                          height: avatarD,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF1E3A8A), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _imagePath != null
                                ? (_imagePath!.startsWith('http') || _imagePath!.startsWith('blob:')
                                    ? Image.network(_imagePath!, fit: BoxFit.cover)
                                    : (_imagePath!.startsWith('assets')
                                      ? Image.asset(_imagePath!, fit: BoxFit.cover)
                                      : (!kIsWeb
                                        ? Image.file(File(_imagePath!), fit: BoxFit.cover)
                                        : Icon(Icons.person, size: personIcon, color: const Color(0xFF1B64F2)))))
                                : Container(
                                    color: const Color(0xFFE6F0FE),
                                    child: Icon(Icons.person, size: personIcon, color: const Color(0xFF1B64F2)),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: EdgeInsets.all((short * 0.02).clamp(6.0, 10.0)),
                              decoration: const BoxDecoration(
                                color: Color(0xFF1B64F2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.camera_alt, color: Colors.white, size: camIcon),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: gapS),
                  Center(
                    child: Text(
                      AppState().tr('Add Profile Picture', 'إضافة صورة الملف الشخصي'),
                      style: TextStyle(
                        fontSize: (w * 0.035).clamp(12.0, 15.0),
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(height: gapL),
                  
                  _buildLabelAndTextField(AppState().tr('Patient\'s Full Name', 'الاسم الكامل للمريض'), AppState().tr('e.g., Mohamed Saber', 'مثال: محمد صابر'), controller: _nameController),
                  const SizedBox(height: 16),
                  
                  _buildLabelAndTextField(AppState().tr('Relationship to You', 'صلة القرابة'), AppState().tr('e.g., Grandfather', 'مثال: الجد'), controller: _relationshipController),
                  const SizedBox(height: 16),
                  
                  _buildLabelAndTextField(AppState().tr('Birth Year', 'سنة الميلاد'), AppState().tr('e.g., 1945', 'مثال: 1945'), controller: _birthYearController),
                  const SizedBox(height: 24),
                  Text(
                    AppState().tr('EMERGENCY CONTACTS', 'جهات اتصال الطوارئ'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1E3A8A)),
                  ),
                  const SizedBox(height: 12),
                  ..._contactControllers.asMap().entries.map((entry) {
                    int index = entry.key;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildContactField(index),
                    );
                  }),
                  SizedBox(height: gapS),
                  Container(
                    width: double.infinity,
                    height: (short * 0.12).clamp(44.0, 54.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _contactControllers.add(TextEditingController());
                        });
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_box, color: Color(0xFF1B64F2)),
                          const SizedBox(width: 8),
                          Text(
                            AppState().tr('Add More Contact Number', 'إضافة رقم اتصال إضافي'),
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: (short * 0.07).clamp(24.0, 36.0)),
                  _buildContinueToMedicalButton(),
                  SizedBox(height: (short * 0.03).clamp(8.0, 16.0)),
                ],
                    ),
                  ),
                );
              },
            ),
          ),
          bottomNavigationBar: const BottomNavWidget(),
        );
      },
    );
  }

  Widget _buildContactField(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          index == 0 ? AppState().tr('Primary Guardian', 'الوصي الأساسي') : AppState().tr('Additional Contact $index', 'جهة اتصال إضافية $index'),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _contactControllers[index],
                decoration: InputDecoration(
                  hintText: AppState().tr('e.g., 01119988299', 'مثال: 01119988299'),
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
                  ),
                ),
              ),
            ),
            if (index > 0) ...[
              const SizedBox(width: 12),
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE8E8),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade400, width: 1.5),
                ),
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.red.shade600, size: 20),
                  onPressed: () {
                    setState(() {
                      _contactControllers[index].dispose();
                      _contactControllers.removeAt(index);
                    });
                  },
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildLabelAndTextField(String label, String hintText, {TextEditingController? controller, TextInputAction textInputAction = TextInputAction.next}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          textInputAction: textInputAction,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
            ),
          ),
        ),
      ],
    );
  }
}
