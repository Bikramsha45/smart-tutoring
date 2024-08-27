// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizedLMS {

    struct Course {
        string title;
        string description;
        uint cost; // Cost in tokens or ether
        address payable instructor;
        bool exists;
    }

    struct Student {
        address studentAddress;
        mapping(uint => bool) enrolledCourses; // Maps course ID to enrollment status
    }

    uint public courseCount = 0;
    mapping(uint => Course) public courses;
    mapping(address => Student) public students;

    event CourseCreated(uint indexed courseId, string title, uint cost, address indexed instructor);
    event CourseEnrolled(uint indexed courseId, address indexed studentAddress);
    event CourseCompleted(uint indexed courseId, address indexed studentAddress);

    // Create a new course
    function createCourse(string memory _title, string memory _description, uint _cost) public {
        courseCount++;
        courses[courseCount] = Course({
            title: _title,
            description: _description,
            cost: _cost,
            instructor: payable(msg.sender),
            exists: true
        });

        emit CourseCreated(courseCount, _title, _cost, msg.sender);
    }

    // Enroll in a course
    function enrollInCourse(uint _courseId) public payable {
        Course storage course = courses[_courseId];
        require(course.exists, "Course does not exist");
        require(msg.value >= course.cost, "Insufficient payment");
        require(!students[msg.sender].enrolledCourses[_courseId], "Already enrolled in this course");

        // Transfer the payment to the instructor
        course.instructor.transfer(course.cost);

        // Mark student as enrolled
        students[msg.sender].studentAddress = msg.sender;
        students[msg.sender].enrolledCourses[_courseId] = true;

        emit CourseEnrolled(_courseId, msg.sender);
    }

    // Check if a student is enrolled in a course
    function isEnrolled(uint _courseId, address _studentAddress) public view returns (bool) {
        return students[_studentAddress].enrolledCourses[_courseId];
    }

    // Complete a course (For simplicity, we just mark it as completed without verifying actual learning)
    function completeCourse(uint _courseId) public {
        require(isEnrolled(_courseId, msg.sender), "Not enrolled in this course");

        emit CourseCompleted(_courseId, msg.sender);
    }

    // View course details
    function viewCourse(uint _courseId) public view returns (string memory title, string memory description, uint cost, address instructor) {
        Course storage course = courses[_courseId];
        require(course.exists, "Course does not exist");

        return (course.title, course.description, course.cost, course.instructor);
    }
}