import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/core/utils/toastification_helper.dart';
import 'package:custom_books/core/widgets/custom_sliver_appbar.dart';
import 'package:custom_books/core/widgets/skeletons/skeletons.dart';
import 'package:custom_books/core/widgets/unsaved_changes_dialog.dart';
import 'package:custom_books/features/customers/models/customer_draft.dart';
import 'package:custom_books/features/customers/widgets/add_contact_salutation_selecter.dart';
import 'package:flutter/material.dart';

class AddContactPersonPage extends StatefulWidget {
  const AddContactPersonPage({super.key});

  @override
  State<AddContactPersonPage> createState() => _AddContactPersonPageState();
}

class _AddContactPersonPageState extends State<AddContactPersonPage>
    with UnsavedChangesMixin {
  String _selectedSalutation = '';

  final List<String> _salutationOptions = [
    'Mr.',
    'Mrs.',
    'Ms.',
    'Miss.',
    'Dr.',
  ];

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _workPhoneController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();

  String _workPhoneCountryCode = '+91';
  String _mobileCountryCode = '+91';
  bool _isLoading = true;
  String? _emailError;

  bool get _isEmailValid {
    final email = _emailController.text.trim();
    return email.isEmpty || (email.contains('@') && email.contains('.com'));
  }

  @override
  void initState() {
    super.initState();
    _load();
    _firstNameController.addListener(markDirty);
    _lastNameController.addListener(markDirty);
    _emailController.addListener(markDirty);
    _workPhoneController.addListener(markDirty);
    _mobileController.addListener(markDirty);
    _designationController.addListener(markDirty);
    _departmentController.addListener(markDirty);
  }

  @override
  void dispose() {
    _firstNameController.removeListener(markDirty);
    _lastNameController.removeListener(markDirty);
    _emailController.removeListener(markDirty);
    _workPhoneController.removeListener(markDirty);
    _mobileController.removeListener(markDirty);
    _designationController.removeListener(markDirty);
    _departmentController.removeListener(markDirty);
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _workPhoneController.dispose();
    _mobileController.dispose();
    _designationController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: onPopInvokedWithResult,
      child: Scaffold(
        backgroundColor: context.colors.background,
        body: _isLoading
            ? const FormPageSkeleton(sectionFieldCounts: [3])
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  CustomSliverAppBar(
                    title: 'Add Contact Person',
                    leadingType: AppBarLeadingType.back,
                    onLeadingPressed: () => onPopInvokedWithResult(false, null),
                    actions: [
                      AppBarIconButton(
                        icon: Icons.contacts_outlined,
                        color: context.colors.textSecondary,
                        onPressed: () {
                          appLog(
                            '📱 Contacts button tapped',
                            name: 'AddContactPersonPage',
                          );
                          ToastificationHelper.showInfo(
                            context,
                            'Importing from device contacts is coming soon.',
                          );
                        },
                      ),
                      SizedBox(width: Dimensions.width10),
                      AppBarElevatedButton(
                        label: 'SAVE',
                        onPressed: () {
                          appLog(
                            '💾 Save button tapped',
                            name: 'AddContactPersonPage',
                          );
                          if (!_isEmailValid) {
                            setState(() => _emailError = 'Enter a valid mail');
                            ToastificationHelper.showError(
                              context,
                              'Enter a valid mail',
                            );
                            return;
                          }
                          final result = CustomerContactPersonDraft(
                            salutation:
                                CustomerFieldMaps.keyFor(
                                  CustomerFieldMaps.salutation,
                                  _selectedSalutation,
                                ) ??
                                '',
                            firstName: _firstNameController.text,
                            lastName: _lastNameController.text,
                            email: _emailController.text,
                            workPhoneCountryCode: _workPhoneCountryCode,
                            workPhone: _workPhoneController.text,
                            mobileCountryCode: _mobileCountryCode,
                            mobile: _mobileController.text,
                            designation: _designationController.text,
                            department: _departmentController.text,
                          );
                          ToastificationHelper.showSuccess(
                            context,
                            'Contact person saved.',
                          );
                          markClean();
                          Navigator.pop(context, result);
                        },
                      ),
                      SizedBox(width: Dimensions.width20),
                    ],
                  ),

                  SliverPadding(
                    padding: EdgeInsets.all(Dimensions.width20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        Container(
                          padding: EdgeInsets.all(Dimensions.width20),
                          decoration: BoxDecoration(
                            color: context.colors.card,
                            borderRadius: BorderRadius.circular(
                              Dimensions.radius20,
                            ),
                            border: Border.all(color: context.colors.border),
                            boxShadow: [
                              BoxShadow(
                                color: context.colors.border.withValues(
                                  alpha: 0.5,
                                ),
                                blurRadius: Dimensions.radius15 * 0.67,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Contact Person',
                                style: TextStyle(
                                  fontSize: Dimensions.font16 * 0.95,
                                  fontWeight: FontWeight.w700,
                                  color: context.colors.textPrimary,
                                ),
                              ),
                              SizedBox(height: Dimensions.height20),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: AddContactSalutationSelecter(
                                      selectedSalutation: _selectedSalutation,
                                      options: _salutationOptions,
                                      onSelected: (value) {
                                        setState(() {
                                          _selectedSalutation = value;
                                        });

                                        appLog(
                                          '✅ Salutation selected: $value',
                                          name: 'AddContactPersonPage',
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(width: Dimensions.width15),
                                  Expanded(
                                    flex: 2,
                                    child: _buildSimpleTextField(
                                      'First Name',
                                      _firstNameController,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: Dimensions.height15),
                              _buildSimpleTextField(
                                'Last Name',
                                _lastNameController,
                              ),
                              SizedBox(height: Dimensions.height15),
                              _buildSimpleTextField(
                                'Email',
                                _emailController,
                                keyboardType: TextInputType.emailAddress,
                                errorText: _emailError,
                                onChanged: (_) {
                                  if (_emailError != null) {
                                    setState(() => _emailError = null);
                                  }
                                },
                              ),
                              SizedBox(height: Dimensions.height20),
                              Text(
                                'Contact Phone',
                                style: TextStyle(
                                  fontSize: Dimensions.font16 * 0.85,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(height: Dimensions.height15),
                              _buildPhoneField(
                                'Work Phone',
                                _workPhoneController,
                                _workPhoneCountryCode,
                                (value) => setState(
                                  () => _workPhoneCountryCode = value!,
                                ),
                              ),
                              SizedBox(height: Dimensions.height15),
                              _buildPhoneField(
                                'Mobile',
                                _mobileController,
                                _mobileCountryCode,
                                (value) =>
                                    setState(() => _mobileCountryCode = value!),
                              ),
                              SizedBox(height: Dimensions.height20),
                              Text(
                                'Other Details',
                                style: TextStyle(
                                  fontSize: Dimensions.font16 * 0.85,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(height: Dimensions.height15),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildSimpleTextField(
                                      'Designation',
                                      _designationController,
                                    ),
                                  ),
                                  SizedBox(width: Dimensions.width15),
                                  Expanded(
                                    child: _buildSimpleTextField(
                                      'Department',
                                      _departmentController,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: Dimensions.height30),
                      ]),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSimpleTextField(
    String hint,
    TextEditingController controller, {
    TextInputType? keyboardType,
    String? errorText,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(
        fontSize: Dimensions.font16 * 0.85,
        color: context.colors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: context.colors.textTertiary,
          fontSize: Dimensions.font16 * 0.85,
        ),
        errorText: errorText,
        errorStyle: TextStyle(
          fontSize: Dimensions.font16 * 0.75,
          color: AppColors.error,
        ),
        filled: true,
        fillColor: context.colors.surfaceLight,
        contentPadding: EdgeInsets.symmetric(
          horizontal: Dimensions.width15,
          vertical: Dimensions.height15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          borderSide: BorderSide(color: context.colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          borderSide: BorderSide(color: context.colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radius15),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
      ),
    );
  }

  Widget _buildPhoneField(
    String label,
    TextEditingController controller,
    String countryCode,
    Function(String?) onCountryChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: Dimensions.font16 * 0.85,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
        SizedBox(height: Dimensions.height10),
        Row(
          children: [
            GestureDetector(
              onTap: () => onCountryChanged(countryCode),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width15,
                  vertical: Dimensions.height15,
                ),
                decoration: BoxDecoration(
                  color: context.colors.surfaceLight,
                  borderRadius: BorderRadius.circular(Dimensions.radius15),
                  border: Border.all(color: context.colors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      countryCode,
                      style: TextStyle(
                        fontSize: Dimensions.font16 * 0.85,
                        fontWeight: FontWeight.w600,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    SizedBox(width: Dimensions.width10 / 2),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: Dimensions.iconSize16 * 1.2,
                      color: context.colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: Dimensions.width10),
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                style: TextStyle(
                  fontSize: Dimensions.font16 * 0.85,
                  color: context.colors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: label,
                  hintStyle: TextStyle(
                    color: context.colors.textTertiary,
                    fontSize: Dimensions.font16 * 0.85,
                  ),
                  filled: true,
                  fillColor: context.colors.surfaceLight,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width15,
                    vertical: Dimensions.height15,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                    borderSide: BorderSide(color: context.colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Dimensions.radius15),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
