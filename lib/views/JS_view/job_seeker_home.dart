import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:only_job/views/constants/constants.dart';
import 'package:only_job/services/auth.dart';
import 'package:only_job/services/user_service.dart';
import 'package:only_job/models/user.dart';
import 'package:only_job/models/education.dart';
import 'package:only_job/views/constants/loading.dart';
import 'package:only_job/services/job_service.dart';
import 'package:only_job/models/jobs.dart';
import 'package:only_job/services/job_recommendation_controller.dart';
import 'package:only_job/services/job_matcher.dart';

import '../../chatFeature/chat_page.dart';

class HomePage extends StatefulWidget {
  Function changePage;
  HomePage({super.key, required this.changePage});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String uid;
  late AuthService _auth;
  late UserService _userService;
  late JobService _jobService;
  late List<JobData> _jobs;
  late final JobRecommendationController jobRecommendationController;
  late final JobMatcher jobMatcher;
  final PageController _pageController = PageController();

  bool _isJobLoading = false;
  bool _isJobLoadingMore = false;
  bool _hasMore = true;

  Education? education;
  List<dynamic>? skills = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _auth = AuthService();
    String uid = _auth.getCurrentUserId()!;
    this.uid = uid;
    _userService = UserService(uid: uid);
    _jobService = JobService(uid: uid);
    jobRecommendationController = JobRecommendationController(
        userService: _userService,
        jobService: _jobService,
        jobMatcher: JobMatcher());
    _pageController.addListener(_onPageChanged);
    _loadInitialJobs();
    getSkills();
    getEducation();
  }

  void getEducation() async {
    final education = await _userService.getFirstUserEducation();
    setState(() {
      this.education = education;
      _isLoading = false;
    });
  }

  void getSkills() async {
    final skills = await _userService.getSkills();
    setState(() {
      this.skills = skills;
      _isLoading = false;
    });
  }

  void _onPageChanged() {
    if (_pageController.page == _jobs.length - 1 && _hasMore) {
      _loadMoreJobs(); // Load more jobs when on the last page
    }
  }

  void _loadMoreJobs() async {
    if (_isJobLoadingMore || !_hasMore) return;

    setState(() {
      _isJobLoadingMore = true;
    });

    List<JobData> moreJobs =
        await jobRecommendationController.fetchInitialJobsRecommendations(uid);

    setState(() {
      _jobs.addAll(moreJobs);
      _isJobLoadingMore = false;
      _hasMore = jobRecommendationController.hasMore;
    });
  }

  void _loadInitialJobs() async {
    setState(() {
      _isJobLoading = true;
    });

    List<JobData> jobs =
        await jobRecommendationController.fetchInitialJobsRecommendations(uid);

    setState(() {
      _jobs = jobs;
      _isJobLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Loading()
        : Scaffold(
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset(
                        'Logo.png',
                        height: 60,
                      ),
                      StreamBuilder<UserData>(
                        stream: _userService.userData,
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          if (snapshot.hasData) {
                            return GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (BuildContext context) {
                                    return FractionallySizedBox(
                                      heightFactor: 0.5,
                                      alignment: Alignment.topRight,
                                      child: _buildProfileModal(
                                          context, snapshot.data!),
                                    );
                                  },
                                );
                              },
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.grey[300],
                                child: ClipOval(
                                    child: Image.network(
                                        snapshot.data!.profilePicture!,
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover)),
                              ),
                            );
                          }

                          return const CircularProgressIndicator();
                        },
                      ),
                    ],
                  ),
                ),
                if (skills!.isEmpty)
                  Padding(
                      padding: const EdgeInsets.all(8),
                      child: Container(
                        height: 60, // Fixed height
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.yellow[100],
                          border:
                              Border.all(color: Colors.amber[300]!, width: 1),
                        ),

                        padding: const EdgeInsets.symmetric(
                            horizontal: 16), // Optional padding
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment
                              .spaceBetween, // Align text to the left and button to the right
                          children: [
                            Text(
                              'Set up profile to get started',
                              style: TextStyle(
                                  fontSize: 16), // Customize the text style
                            ),
                            ElevatedButton(
                              onPressed: () {
                                widget.changePage(0);
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber[300],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  )),
                              child: const Text(
                                'Set-up',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      )),
                Expanded(
                  child: _isJobLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : _jobs.isNotEmpty ? PageView.builder(
                          controller: _pageController,
                          scrollDirection: Axis.vertical,
                          itemCount: _jobs.length,
                          itemBuilder: (context, index) {
                            JobData job = _jobs[index];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CustomBodyWidget(currentUserName: _auth, jobData: job),
                            );
                          },
                        ) : const Center(
                          child: Text('No jobs available for you at the moment'),
                        ),
                ),
              ],
            ),
          );
  }

  Widget _buildProfileModal(BuildContext context, UserData userData) {
    final skillsString = userData.skills!.map((skill) => '- $skill').join('\n');
    return Container(
      decoration: const BoxDecoration(
        color: backgroundwhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey[300],
                  child: ClipOval(
                    child: Image.network(
                      userData.profilePicture!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userData.name!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (education != null)
                        Text(
                          education!.degree!,
                          style: const TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      if (education == null)
                        const Text(
                          'No education details',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Skills:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            if (skillsString.isNotEmpty)
              Text(
                skillsString,
                style: TextStyle(fontSize: 16),
              ),
            if (skillsString.isEmpty)
              const Text(
                'No skills added',
                style: TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}

class CustomBodyWidget extends StatefulWidget {
  const CustomBodyWidget({super.key, required this.jobData, required this.currentUserName});

  final JobData jobData;
  final AuthService currentUserName;

  @override
  State<CustomBodyWidget> createState() => _CustomBodyWidgetState();
}

class _CustomBodyWidgetState extends State<CustomBodyWidget> {
  final AuthService authService = AuthService();


  String? jobUid;
  String? receiverUid;

  String? currentUserName;

  @override
  void initState() {
    super.initState();
    fetchCurrentUserName();
    jobUid = widget.jobData.jobUid;
    receiverUid = widget.jobData.owner;


  }

  void fetchCurrentUserName() async {
    currentUserName = await authService.getCurrentUserName();
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      // Increased height to accommodate the job description section
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: Column(
        children: [
          // Job Title section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.jobData.jobTitle!, // Replace with actual job title
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4), // Vertical spacing
                  Text(
                    'Company Name:', // Replace with actual company name
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Image section
          Container(
            height: 250, // Fixed height for the image
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              image: DecorationImage(
                image: AssetImage('sample_image.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 8), // Spacing

          // Location section
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 8.0, vertical: 4.0), // Padding for location
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.red), // Location icon
                const SizedBox(width: 4), // Space between icon and text
                Text(
                  widget.jobData.location!, // Replace with actual location
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Meet the Hiring Team Section
          Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              border: Border.all(color: Colors.grey), // Added border here
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    'Meet the hiring manager',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Row for avatar, name, role, and message button
                Row(
                  children: [
                    // Avatar picture
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage(
                          'sample_image_person.jpg'), // Replace with your image asset
                    ),
                    const SizedBox(width: 8), // Space between avatar and column

                    // Column for name and role
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'John Doe', // Replace with actual name
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2), // Vertical spacing
                        Text(
                          'Senior Developer', // Replace with actual role
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(), // Pushes the message button to the right

                    // Message button
                    ElevatedButton(
                      onPressed: () {
                        print('Apply button clicked');

                        // Get the receiver's user ID and name from jobData
                        String? receiverName = widget.jobData.owner; // Replace with actual job owner name

                        // Navigate to ChatPage with the user information
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              user: {
                                'name': receiverName, // Pass the receiver's name
                                'uid': receiverUid, // Pass the receiver's UID
                              },
                            ),
                          ),
                        );
                      },
                      child: Text('Message'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Job Description Section (snapping scroll with PageView)
          Container(
            margin: const EdgeInsets.all(8.0),
            height: 140, // Height for the job description container
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: PageController(
                        viewportFraction:
                            0.95), // Add viewportFraction for slight space between pages
                    children: [
                      _buildDescriptionSection(
                          'Job Description', widget.jobData.jobDescription!),
                      _buildDescriptionSection(
                          'Requirements', widget.jobData.otherRequirements!),
                      _buildDescriptionSection('Salary Range',
                          '\$${widget.jobData.minSalaryRange} - \$${widget.jobData.maxSalaryRange}'),
                    ],
                  ),
                ),
                // Indicator Circles
              ],
            ),
          ),
          smallSizedBox_H,
          // Apply Button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                print('Apply button clicked');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: Size(double.infinity, 40),
              ),
              child: Text(
                'Apply',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(String title, String content) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        border: Border.all(color: Colors.grey), // Added border here
      ),
      padding: const EdgeInsets.all(8.0),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 300, // Fixed width for each section
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4), // Vertical spacing
          Text(
            content,
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

