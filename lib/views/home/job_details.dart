import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:only_job/models/jobs.dart';
import 'package:only_job/views/constants/constants.dart';

import '../../services/job_service.dart';
import 'employer_positions.dart';

class JobDetailsPage extends StatefulWidget {
  final JobData jobData;


  JobDetailsPage({required this.jobData});

  @override
  _JobDetailsPageState createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  bool isEditing = false;

  TextEditingController titleController = TextEditingController();
  TextEditingController minSalaryController = TextEditingController();
  TextEditingController maxSalaryController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController skillsController = TextEditingController();
  TextEditingController jobDescriptionController = TextEditingController();
  String? jobUid; // Declare jobUid here
  List<String> selectedSkills = [];



  @override
  void initState() {
    super.initState();

    titleController.text = widget.jobData.jobTitle!;
    minSalaryController.text = widget.jobData.minSalaryRange.toString();
    maxSalaryController.text = widget.jobData.maxSalaryRange.toString();
    locationController.text = widget.jobData.location!;
    skillsController.text = widget.jobData.skillsRequired!.join(', ');
    jobDescriptionController.text = widget.jobData.jobDescription!;

    jobUid = widget.jobData.jobUid;
    if (jobUid != null) {
      JobService jobService = JobService(uid: jobUid!); // Use jobUid here
    }

    selectedSkills = List<String>.from(widget.jobData.skillsRequired ?? []);
  }

  @override
  void dispose() {
    titleController.dispose();
    minSalaryController.dispose();
    maxSalaryController.dispose();
    locationController.dispose();
    skillsController.dispose();
    jobDescriptionController.dispose();
    super.dispose();
  }

  Future<List<String>> searchSkills(String query) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Skills')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThanOrEqualTo: query + '\uf8ff')
        .get();

    List<String> skills = querySnapshot.docs.map((doc) => doc['skills'] as String).toList();
    return skills;
  }

  // Function to add skill to Firestore if not found
  Future<void> addSkillToFirestore(String skill) async {
    await FirebaseFirestore.instance.collection('Skills').add({'skills': skill});
  }

  Future<void> updateJobInFirebase() async {
    try {
      await FirebaseFirestore.instance
          .collection('User')
          .doc(widget.jobData.owner)
          .collection('JobOpenings')
          .doc(jobUid)
          .update({
        'jobTitle': titleController.text,
        'minSalaryRange': double.tryParse(minSalaryController.text),
        'maxSalaryRange': double.tryParse(maxSalaryController.text),
        'location': locationController.text,
      'skillsRequired': selectedSkills,
        'description': jobDescriptionController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Job details updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update job: $e')),
      );
    }
  }

  Future<void> removeJobFromFirebase() async {
    try {
      await FirebaseFirestore.instance
          .collection('User')
          .doc(widget.jobData.owner)
          .collection('JobOpenings')
          .doc(jobUid)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Job deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete job: $e')),
      );
    }
  }
  List<String> teamMembers = [
    "John Doe",
    "Jane Smith",
    'Bilat',
    'Meg',
    'Peter',
    'BumbleBee',
  ];

  Future<void> _openSkillsSearchDialog() async {
    List<String> foundSkills = await searchSkills('');
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Search and Select Skills'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) async {
                      List<String> skills = await searchSkills(value);
                      setState(() {
                        foundSkills = skills;
                      });
                    },
                    decoration: InputDecoration(hintText: 'Search for a skill'),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: foundSkills.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(foundSkills[index]),
                          onTap: () {
                            setState(() {
                              selectedSkills.add(foundSkills[index]);
                            });
                            Navigator.pop(context); // Close the dialog
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    // Add new skill if not found in Firestore
                    if (!foundSkills.contains('new_skill')) {
                      addSkillToFirestore('new_skill');
                    }
                    Navigator.pop(context);
                  },
                  child: Text('Add Skill'),
                ),
              ],
            );
          },
        );
      },
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Details'),
        titleTextStyle: headingStyle_white,
        backgroundColor: primarycolor,
      ),
      body: Column(
        children: [
          // Fixed Job Info Container
          Container(
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Job Title
                      isEditing
                          ? TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'Job Title',
                          border: OutlineInputBorder(),
                        ),
                      )
                          : Text(
                        'Job Title: ${titleController.text}',
                        style: TextStyle(

                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Salary Range
                      isEditing
                          ? Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: minSalaryController,
                              decoration: InputDecoration(
                                labelText: 'Min Salary',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: maxSalaryController,
                              decoration: InputDecoration(
                                labelText: 'Max Salary',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      )
                          : Text(
                        'Salary Range: \$${minSalaryController
                            .text} - \$${maxSalaryController.text}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),

                      // Location
                      isEditing
                          ? TextField(
                        controller: locationController,
                        decoration: InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(),
                        ),
                      )
                          : Text(
                        'Location: ${locationController.text}',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),

                      // Skills Required
                      const Text(
                        'Skills Required:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 8.0,
                        children: selectedSkills
                            .map((skill) => Chip(
                          label: Text(skill),
                          onDeleted: () {
                            setState(() {
                              selectedSkills.remove(skill);
                            });
                          },
                        ))
                            .toList(),
                      ),
                      TextButton(
                        onPressed: _openSkillsSearchDialog,
                        child: Text('Add or Edit Skills'),
                      ),
                      const SizedBox(height: 10),

                      // Job Description
                      isEditing
                          ? TextField(
                        controller: jobDescriptionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Job Description',
                          border: OutlineInputBorder(),
                        ),
                      )
                          : Text(
                        'Job Description: ${jobDescriptionController
                            .text}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Edit button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(isEditing
                                ? Icons.check
                                : Icons.edit),
                            onPressed: () {
                              setState(() {
                                if (isEditing) {
                                  updateJobInFirebase(); // Save updates
                                }
                                isEditing = !isEditing;
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                        'Delete the ${widget.jobData.jobTitle} Job Opening?'),
                                    content: Text(
                                        'This will also delete all job seeker applications'),
                                    actions: [
                                      TextButton(
                                      onPressed: () {
                                        removeJobFromFirebase();
                                        Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => EmployerPositions()),
                                    );
                                  },
                                      child: Text(
                                          'Yes',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('No'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),

                        ],
                      ),
                      SizedBox(height: 2,),
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(
                                    'Close the ${widget.jobData.jobTitle} Job Opening?'),
                                content: Text(
                                    'Job seekers will no longer find this Job Opening'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Yes'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('No'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text('Close this Job Opening'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Scrollable list of applicants (team members)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: teamMembers
                    .map(
                      (member) => Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(color: Colors.black),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    member,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text('Skill'),
                                ],
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: accent1),
                                onPressed: () {
                                  setState(() {
                                    teamMembers.remove(member);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
