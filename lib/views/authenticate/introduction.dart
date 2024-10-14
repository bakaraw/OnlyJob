import 'package:flutter/material.dart';
import 'package:only_job/views/constants/constants.dart';
import 'package:only_job/services/user_service.dart';
import 'package:only_job/services/auth.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key, required this.setUserNotNew});
  final Function setUserNotNew;
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  PageController _pageController = PageController();
  final AuthService _auth = AuthService();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome"),
        actions: [
          TextButton(
            onPressed: () {
              _pageController.jumpToPage(2);
            },
            child: Text(
              'Skip',
              style: TextStyle(color: accent1, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  children: [
                    SwipePage(
                      'Page_1.png',
                      'Welcome to OnlyJobs',
                      'OnlyJobs is the job search app built for freelancers and employers. Whether you’re seeking new opportunities or looking for the perfect candidate, OnlyJobs connects you quickly and easily. Let’s get started on your journey to meaningful work!',
                    ),
                    SwipePage(
                      'Page_2.png',
                      'Browse and Swipe Through Jobs',
                      'Discover job opportunities that match your skills by simply swiping through listings. Like a job? Swipe right to apply or connect with the employer. It’s an engaging, hassle-free way to find the right job that suits your talents.',
                    ),
                    SwipePage(
                      'Page_3.png',
                      'Match and Communicate with Employers',
                      'After matching with a job, you can start a conversation with employers directly within the app. Discuss job details, qualifications, and expectations seamlessly—making your job hunt more interactive and personal.',
                    ),
                  ],
                ),
              ),
            ],
          ),
          smallSizedBox_H,
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: dotIndicator(),
          ),
          if (_currentPage == 2)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () async {
                  await UserService(uid: _auth.getCurrentUserId()!)
                      .setUserNotNew();
                  widget.setUserNotNew();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size.fromHeight(50),
                  foregroundColor: Colors.white,
                  backgroundColor: accent1,
                ),
                child: Text('Get Started'),
              ),
            ),
        ],
      ),
    );
  }

  Widget SwipePage(String imagePath, String title, String description) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            height: 250, // Big image size
            fit: BoxFit.contain,
          ),
          SizedBox(height: 20),
          Text(
            title,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Text(
            description,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget dotIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 12 : 8,
          height: _currentPage == index ? 12 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? accent1 : Colors.grey,
          ),
        );
      }),
    );
  }
}
