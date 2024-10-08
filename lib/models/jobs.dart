
class Jobs {
  String? uid;

  Jobs({
    required this.uid,
  });
}

class JobData {
  String? uid;
  String? jobTitle;
  String? jobDescription;
  String? location;
  String? minSalaryRange;
  String? maxSalaryRange;
  String? jobType;
  List<String?> skillsRequired;
  bool? isOpened;

  JobData({
    required this.uid,
    required this.jobTitle,
    required this.jobDescription,
    required this.location,
    required this.minSalaryRange,
    required this.maxSalaryRange,
    required this.jobType,
    required this.skillsRequired,
    required this.isOpened,
  });
}
