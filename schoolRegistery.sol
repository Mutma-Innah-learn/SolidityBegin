//SPDX-Liscense-Identifier:MIT

pragma solidity ^0.8.0;

//school registery

contract schoolReg{

  struct teacher{
    uint256 Tid;
    uint256 Tage;
    string  Tname;
  }

  teacher[] public teachers;
   mapping(uint256 => teacher) public teacherID;
  

  struct student{
    uint256 Sid;
    uint256 Sage;
    string Sname;
  }
  
  student[] public students;
  mapping(uint256 => student) public studentID;

  struct course{
    
    uint256 Cid;
    string Cname;
  }
  
  course[] public courses;
  mapping(uint256 => teacher) public courseIDToTeacher;
  mapping(string => teacher) public courseNameToTeacher;

  address admin;

  //register teachers

  function TeacherReg(uint256 _tid, uint256 _tage, string memory _tname) public{
    teachers.push(teacher({ Tid: _tid, Tage: _tage, Tname: _tname})); 
    teacherID[_tid] = teacher({Tid: _tid, Tage: _tage,Tname: _tname});

  }

  function getTeacher(uint256 _tid) public view returns(teacher memory) {  
    return teacherID[_tid];
  }

  function teacherCount() public view returns(uint256){
    return teachers.length;
  }

  function getAllTeachers() public view returns(teacher[] memory){
    return teachers;
  }


//register students

function studentReg(uint256 _sid, uint256 _sage, string memory _sname) public{
  students.push(student({Sid: _sid, Sage: _sage, Sname: _sname}));
  studentID[_sid] = student({Sid: _sid, Sage: _sage, Sname: _sname});
}

function getStudent(uint256 _sid) public view returns(student memory){
  return studentID[_sid];
}

function studentCount() public view returns(uint256){
  return students.length;
}

function getAllStudent() public view returns(student[] memory){
  return students;
}


//register courses

function courseReg(uint256 _cid, string memory _cname) public{
  courses.push(course({Cid: _cid, Cname: _cname}));
}

//assign teacher to a class

modifier onlyAdmin(){
  require(msg.sender == admin, "Not authorised");
  _;
}

function assignTeacherToCourse(uint256 _cid, uint256 _tid) public onlyAdmin {
  require(bytes(teacherID[_tid].Tname).length > 0, "Teacher not registered");
  courseIDToTeacher[_cid] = teacherID[_tid];
}

function getTeacherForCourse(uint256 _cid) public view returns (teacher memory) {
  return courseIDToTeacher[_cid];
}

}
