import 'package:flutter/material.dart';
import '/constants.dart';
import '/screens/sign_in/sign_in_screen.dart';
import '/size_config.dart';
import '../components/splash_content.dart';

class Body extends StatefulWidget {
  const Body({super.key});

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  int currentPage = 0;
  List<Map<String, String>> splashData = [
    {
      'text': '',
      'image': 'assets/images/splash_1.png'
    },
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: PageView.builder(
                onPageChanged: (int value) {
                  setState(() {
                    currentPage = value;
                  });
                },
                itemCount: splashData.length,
                itemBuilder: (BuildContext context, int index) => SplashContent(
                  image: splashData[index]['image'],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: getProportionateScreenWidth(20)),
                child: Column(
                  children: <Widget>[
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        splashData.length,
                        (int index) => buildDot(index: index),
                      ),
                    ),
                    const Spacer(flex: 3),
                    SizedBox(
                      width: double.infinity,
                      height: getProportionateScreenHeight(56),
                      child: ElevatedButton(
                        child: Text('Get Started' , style: TextStyle(fontSize: getProportionateScreenWidth(20),),),
                        style: TextButton.styleFrom(
                            backgroundColor: Color(0xFFfe6796),
                      shape:
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),


                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (BuildContext context) => const SignInScreen()),
                          );
                        },
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AnimatedContainer buildDot({int? index}) {
    return AnimatedContainer(
      duration: kAnimationDuration,
      margin: const EdgeInsets.only(right: 5),
      height: 6,
      width: currentPage == index ? 20 : 6,
      decoration: BoxDecoration(
        color: currentPage == index ? kPrimaryColor : const Color(0xFFD8D8D8),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
