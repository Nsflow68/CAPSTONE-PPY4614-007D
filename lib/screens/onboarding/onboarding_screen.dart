import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'onboarding_data.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.8),
              Theme.of(context).colorScheme.secondary.withOpacity(0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: onboardingData.length,
                  itemBuilder: (context, index) {
                    final item = onboardingData[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: IntrinsicHeight(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                          Icon(
                            item.icon,
                            size: 100.h,
                            color: Colors.white,
                          )
                          .animate(onPlay: (controller) => controller.repeat())
                          .scale(
                            duration: const Duration(seconds: 2),
                            begin: const Offset(1, 1),
                            end: const Offset(1.2, 1.2),
                          ).then()
                          .scale(
                            duration: const Duration(seconds: 2),
                            begin: const Offset(1.2, 1.2),
                            end: const Offset(1, 1),
                          ),
                          SizedBox(height: 40.h),
                          Text(
                            item.title,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.3,
                            ),
                          ).animate().fadeIn(
                            duration: const Duration(milliseconds: 800),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            item.description,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              color: Colors.white.withOpacity(0.9),
                              height: 1.5,
                            ),
                          ).animate().fadeIn(
                            duration: const Duration(milliseconds: 800),
                            delay: const Duration(milliseconds: 200),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Column(
                children: [
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: onboardingData.length,
                    effect: WormEffect(
                      dotWidth: 10.w,
                      dotHeight: 10.h,
                      activeDotColor: Colors.white,
                      dotColor: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      children: [
                        _buildButton(
                          context,
                          _currentPage < onboardingData.length - 1 
                              ? 'Siguiente'
                              : 'Comenzar',
                          onPressed: () {
                            if (_currentPage < onboardingData.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            } else {
                              // TODO: Navegar a la siguiente pantalla
                            }
                          },
                        ),
                        if (_currentPage < onboardingData.length - 1) ...[
                          SizedBox(height: 16.h),
                          _buildButton(
                            context,
                            'Saltar',
                            onPressed: () {
                              // TODO: Navegar a la siguiente pantalla
                            },
                            isOutlined: true,
                          ),
                        ],
                      ].animate(interval: 200.ms)
                       .fadeIn(duration: 600.ms)
                       .slideY(begin: 0.3, end: 0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    String text, {
    required VoidCallback onPressed,
    bool isOutlined = false,
  }) {
    return Material(
      color: isOutlined ? Colors.transparent : Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: double.infinity,
          height: 56.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: isOutlined
                ? Border.all(color: Colors.white, width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: isOutlined
                    ? Colors.white
                    : Theme.of(context).colorScheme.primary,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}