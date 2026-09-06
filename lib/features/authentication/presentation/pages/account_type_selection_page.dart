// lib/features/authentication/presentation/pages/account_type_selection_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routing/route_names.dart';

class AccountTypeSelectionPage extends StatelessWidget {
  const AccountTypeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.kitchen_rounded,
                    size: 52,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'KitchenFlow',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'مرحباً بك في مطبخ تدفق',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 48),
                Text(
                  'اختر نوع الحساب',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.push(RouteNames.kRegisterPage);
                    },
                    icon: const Icon(Icons.business_center_rounded),
                    label: const Text(
                      'تسجيل كـ مالك ورشة',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.push(RouteNames.kWorkerLoginPage);
                    },
                    icon: const Icon(Icons.engineering_rounded),
                    label: const Text(
                      'تسجيل كـ عامل',
                      style: TextStyle(fontSize: 18),
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                TextButton(
                  onPressed: () {
                    context.push(RouteNames.kLoginPage);
                  },
                  child: const Text('لديك حساب بالفعل؟ سجل الدخول'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}