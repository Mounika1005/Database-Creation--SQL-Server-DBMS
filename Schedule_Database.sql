use master
drop database schedule
create database schedule
use schedule;

---create Student table
drop table student_t;

Create table student_t
(NetID varchar(10) not null,
FirstName varchar(50),
LastName varchar(50),
Major varchar(50),
CourseSemester varchar(10),
CourseYear integer,
GradSem varchar(10),
GradYear integer,
Constraint Student_PK primary key(NetID));

-- Bulk insert table student data

BULK
INSERT student_t
FROM 'C:\Users\student\Downloads\StudentDetails.csv'
WITH
(FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n')
GO

--create Instructor table
drop table instructor_t;

Create table instructor_t
(InstructorID varchar(10) not null,
InstructorName varchar(50),
InstructorOffice varchar(25),
Constraint Instructor_PK primary key(InstructorID));

-- Bulk insert table instructor data

BULK
INSERT instructor_t
FROM 'C:\Users\student\Downloads\InstructorDetails.csv'
WITH
(FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n')
GO

 

--Create Book table
drop table book_t;

Create table book_t
(BookID varchar(50) not null,
BookName varchar(100),
Bookpublisher varchar(50),
Constraint Book_PK primary key(BookID));

-- Bulk insert table book data

BULK
INSERT book_t
FROM 'C:\Users\student\Downloads\BookDetails.csv'
WITH
(FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n')
GO


--Create Course table
 drop table course_t;

Create table course_t
(CourseID varchar(10) not null,
CourseName varchar(50),
CreditHours integer,
BookID varchar(50),
Constraint Course_PK primary key(CourseID),
Constraint Book_FK1 foreign key(BookID) references Book_t(BookID));

-- Bulk insert table course data

BULK
INSERT course_t
FROM 'C:\Users\student\Downloads\CourseDetails.csv'
WITH
(FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n')
GO
 

--Create Summary table
drop table summary_t;

Create table summary_t
(NetID varchar(10) not null,
InstructorId varchar(10) not null,
CourseId varchar(10) not null, 
CourseClassRoom varchar(20),
Constraint Summary_PK primary key(NetID,InstructorID,CourseID),
Constraint student_FK1 foreign key(NetID)references student_t(NetID),
Constraint Instructor_FK2 foreign key(InstructorID)references Instructor_t(InstructorID),
Constraint Course_FK3 foreign key(CourseID)references Course_t(CourseID));

-- Bulk insert table summary data

BULK
INSERT summary_t
FROM 'C:\Users\student\Downloads\SummaryTable.csv'
WITH
(FIELDTERMINATOR = ',',
ROWTERMINATOR = '\n')
GO


-- QUERIES--------------------------------------------------------------------------------------------

-- 1. Count the number of students who are graduating in the same semester.

select CONCAT(GradSem, ' ', GradYear) as Graduation, COUNT(NetID) as No_of_Students
from student_t
group by GradSem,GradYear;


-- 2.	Display the students name and major who have taken BAN 610

select CONCAT(a.FirstName, ' ', a.LastName) as Student_Name, a.Major
from student_t a, summary_t b
where a.NetID=b.NetID and b.CourseId = 'BAN610';


-- 3.	Display the NetID and student name of the students who have taken more than 7 courses in year 2019
-- (adjust the number of courses taken so that the query returns at least one result).

select distinct(a.NetID), CONCAT(b.FirstName, ' ' , b.LastName) as Student_Name, COUNT(a.NetID) as No_of_Courses_in_2019
from summary_t a, student_t b
where a.NetID = b.NetID
group by a.NetID,b.FirstName,b.LastName
having count(a.NetID) > 7;


-- 4.	Display the NetID and the total credit hours taken by each student in 2019

select a.NetID,  sum(b.CreditHours) as Total_Credit_Hours
from summary_t a
left join
course_t b
on a.CourseId = b.CourseID
left join
student_t c
on a.NetID = c.NetID
where c.CourseYear = 2019
Group by a.NetID;


-- 5.	Display the instructors name and the number of course books prescribed by each instructor

select d.InstructorName, count(distinct c.BookName)
from summary_t a
left join 
course_t b
on a.CourseId = b.CourseID
left join
book_t c
on c.BookID = b.BookID
left join
instructor_t d
on d.InstructorID = a.InstructorId
group by d.InstructorName;