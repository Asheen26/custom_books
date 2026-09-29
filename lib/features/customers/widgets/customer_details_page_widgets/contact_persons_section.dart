import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/features/customers/models/customer_draft.dart';
import 'package:custom_books/features/customers/models/customer_model.dart';
import 'package:custom_books/features/customers/views/add_contact_person_page.dart';
import 'package:flutter/material.dart';

class ContactPersonsSection extends StatefulWidget {
  final CustomerModel customer;

  const ContactPersonsSection({super.key, required this.customer});

  @override
  State<ContactPersonsSection> createState() => _ContactPersonsSectionState();
}

class _ContactPersonsSectionState extends State<ContactPersonsSection> {
  bool _isContactPersonsExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        Dimensions.width20,
        Dimensions.height15,
        Dimensions.width20,
        0,
      ),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        border: Border.all(color: context.colors.border),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _isContactPersonsExpanded = !_isContactPersonsExpanded;
                });
                appLog(
                  '👥 Contact Persons section tapped: ${_isContactPersonsExpanded ? "expanded" : "collapsed"}',
                  name: 'ContactPersonsSection',
                );
              },
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              child: Padding(
                padding: EdgeInsets.all(Dimensions.width20),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: Dimensions.iconSize24,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: Dimensions.width15),
                    Expanded(
                      child: Text(
                        'Contact Persons',
                        style: TextStyle(
                          fontSize: Dimensions.font16,
                          fontWeight: FontWeight.w700,
                          color: context.colors.textPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      _isContactPersonsExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: Dimensions.iconSize24,
                      color: context.colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isContactPersonsExpanded) ...[
            Divider(height: 1, color: context.colors.border),
            Padding(
              padding: EdgeInsets.all(Dimensions.width20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.customer.contactPersons.isEmpty)
                    Text(
                      'You haven\'t added any contact persons for this contact yet.',
                      style: TextStyle(
                        fontSize: Dimensions.font16 * 0.85,
                        color: context.colors.textTertiary,
                        height: 1.5,
                      ),
                    )
                  else
                    ...widget.customer.contactPersons.map(
                      (p) => _contactTile(context, p),
                    ),
                  SizedBox(height: Dimensions.height20),
                  GestureDetector(
                    onTap: () {
                      appLog(
                        '➕ Add Contact Person tapped',
                        name: 'ContactPersonsSection',
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddContactPersonPage(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.add_circle_outline_rounded,
                          color: AppColors.primary,
                          size: Dimensions.iconSize24,
                        ),
                        SizedBox(width: Dimensions.width10),
                        Text(
                          'Add Contact Person',
                          style: TextStyle(
                            fontSize: Dimensions.font16 * 0.85,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _contactTile(BuildContext context, CustomerContactPersonDraft person) {
    final salutationLabel = CustomerFieldMaps.labelFor(
      CustomerFieldMaps.salutation,
      person.salutation,
    );
    final name = [
      ?salutationLabel,
      person.firstName.trim(),
      person.lastName.trim(),
    ].where((s) => s.isNotEmpty).join(' ');

    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.height15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (name.isNotEmpty)
            Text(
              name,
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.95,
                fontWeight: FontWeight.w700,
                color: context.colors.textPrimary,
              ),
            ),
          if (person.designation.trim().isNotEmpty ||
              person.department.trim().isNotEmpty) ...[
            SizedBox(height: Dimensions.height10 / 3),
            Text(
              [
                person.designation.trim(),
                person.department.trim(),
              ].where((s) => s.isNotEmpty).join(' · '),
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.8,
                color: context.colors.textTertiary,
              ),
            ),
          ],
          if (person.email.trim().isNotEmpty) ...[
            SizedBox(height: Dimensions.height10 / 2),
            _iconLine(context, Icons.email_outlined, person.email.trim()),
          ],
          if (person.workPhone.trim().isNotEmpty) ...[
            SizedBox(height: Dimensions.height10 / 2),
            _iconLine(
              context,
              Icons.phone_outlined,
              '${person.workPhoneCountryCode}-${person.workPhone.trim()}',
            ),
          ],
          if (person.mobile.trim().isNotEmpty) ...[
            SizedBox(height: Dimensions.height10 / 2),
            _iconLine(
              context,
              Icons.smartphone_outlined,
              '${person.mobileCountryCode}-${person.mobile.trim()}',
            ),
          ],
          SizedBox(height: Dimensions.height15),
          Divider(height: 1, color: context.colors.border),
        ],
      ),
    );
  }

  Widget _iconLine(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: Dimensions.iconSize16,
          color: context.colors.textSecondary,
        ),
        SizedBox(width: Dimensions.width10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: Dimensions.font16 * 0.85,
              color: context.colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
