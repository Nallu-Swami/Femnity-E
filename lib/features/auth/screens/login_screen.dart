import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:femunity/core/common/loader.dart';
import 'package:femunity/core/constants/constants.dart';
import 'package:femunity/features/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/common/sign_in_button.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);

  void signInAsGuest(WidgetRef ref, BuildContext context) {
    ref.read(authControllerProvider.notifier).signInAsGuest(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(authControllerProvider);

    return Scaffold(
      body: isLoading
          ? const Loader()
          : SafeArea(
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        height: 30,
                        child: DefaultTextStyle(
                          style: const TextStyle(
                            fontFamily: 'FutureLight',
                            fontSize: 29,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 7.0,
                                color: Colors.white,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                          child: AnimatedTextKit(
                            repeatForever: true,
                            animatedTexts: [
                              FlickerAnimatedText('Unleash your power'),
                              FlickerAnimatedText('Connect with your community'),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 400.0,
                        child: TextLiquidFill(
                          text: 'Femunity',
                          waveColor: const Color(0xFFff48a5),
                          textStyle: const TextStyle(
                            fontFamily: 'AlBrush',
                            fontSize: 79.50,
                          ),
                          boxHeight: 150.0,
                        ),
                      ),
                      const SignInButton(),
                    ],
                  ),
                  Positioned.fill(
                    top: MediaQuery.of(context).size.height * 0.4,
                    child: Column(
                      children: [
                        CarouselSlider(
                          options: CarouselOptions(
                            height: 200.0,
                            autoPlay: true,
                            viewportFraction: 1.0,
                            onPageChanged: (index, reason) {
                              if (index == 2) {
                                // User reached the 3rd page
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LoginScreen(),
                                  ),
                                );
                              }
                            },
                          ),
                          items: [
                            Container(
                              color: Colors.red,
                              child: Center(
                                child: Text(
                                  'Intro Screen 1',
                                  style: TextStyle(fontSize: 24.0),
                                ),
                              ),
                            ),
                            Container(
                              color: Colors.green,
                              child: Center(
                                child: Text(
                                  'Intro Screen 2',
                                  style: TextStyle(fontSize: 24.0),
                                ),
                              ),
                            ),
                            Container(
                              color: Colors.blue,
                              child: Center(
                                child: Text(
                                  'Intro Screen 3',
                                  style: TextStyle(fontSize: 24.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        AnimatedSmoothIndicator(
                          activeIndex: 0,
                          count: 3,
                          effect: ScrollingDotsEffect(
                            activeDotColor: Colors.white,
                            dotColor: Colors.grey,
                            dotHeight: 8.0,
                            dotWidth: 8.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
