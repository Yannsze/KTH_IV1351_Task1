INSERT INTO 'course_layout' ('course_code','course_name','min_student','max_student','hp')
VALUES
  ("AL7106","Digital design",23,37,7.5),
  ("OM9831","Calculus",24,35,4.5),
  ("HW1213","Linear Algebra",18,53,3.5),
  ("OB4248","Signal processing",18,54,6.5),
  ("HW4527","Embeded system",17,59,3.5),
  ("NJ2179","Data storage",25,36,5.5),
  ("TT5533","Discrete Mathematics",22,51,6.5),
  ("WX3742","Algebra and Geometry",22,41,5.5),
  ("QR3473","Basic Economics",17,57,7.5),
  ("GL2258","Advance Economics",21,51,5.5);


INSERT INTO 'course_instance' ('instance_id', 'num_students', 'study_period', 'study_year', 'course_layout_id')
VALUES
  ("AL7106ht25", 30, "P1", 2025, 1),
  ("HW1213ht25", 35, "P1", 2025, 3),
  ("OM9831ht25", 25, "P1", 2025, 2),
  ("OB4248ht25", 40, "P1", 2025, 4),
  ("HW4527ht25", 22, "P1", 2025, 5),
  ("NJ2179ht25", 29, "P2", 2025, 6),
  ("TT5533ht25", 38, "P2", 2025, 7),
  ("WX3742ht25", 26, "P2", 2025, 8),
  ("QR3473ht25", 32, "P2", 2025, 9),
  ("GL2258ht25", 33, "P2", 2025, 10);

INSERT INTO 'job_title' ('job_title')
VALUES
  ("Professor"),
  ("Associate Professor"),
  ("Lecturer"),
  ("Research Assistant"),
  ("Lab Technician"),
  ("Course Coordinator"),
  ("Department Head"),
  ("Administrator"),
  ("HR Manager"),
  ("Teaching Assistant");


INSERT INTO 'person' ('personal_number', 'first_name', 'last_name', 'address')
VALUES
  ("12345678901", "John", "Doe", "123 Main St, Cityville"),
  ("23456789012", "Jane", "Smith", "456 Oak St, Townsville"),
  ("34567890123", "Alice", "Johnson", "789 Pine St, Villageburg"),
  ("45678901234", "Bob", "Brown", "101 Maple St, Suburbia"),
  ("56789012345", "Carol", "White", "202 Birch St, Countryside"),
  ("67890123456", "David", "Green", "303 Cedar St, Metrocity"),
  ("78901234567", "Eve", "Black", "404 Elm St, Urbania"),
  ("89012345678", "Frank", "Blue", "505 Redwood St, Lakeside"),
  ("90123456789", "Grace", "Yellow", "606 Fir St, Coastcity"),
  ("12345678902", "Henry", "Red", "707 Palm St, Hilltop");

INSERT INTO 'phone' ('phone_no')
VALUES
  ("123-456-7890"),
  ("234-567-8901"),
  ("345-678-9012"),
  ("456-789-0123"),
  ("567-890-1234"),
  ("678-901-2345"),
  ("789-012-3456"),
  ("890-123-4567"),
  ("901-234-5678"),
  ("012-345-6789");

INSERT INTO 'person_phone' ('phone_id', 'person_id')
VALUES
  (1, 1),
  (2, 2),
  (3, 3),
  (4, 4),
  (5, 5),
  (6, 6),
  (7, 7),
  (8, 8),
  (9, 9),
  (10, 10);


INSERT INTO 'teaching_activity' ('factor', 'activity_name')
VALUES
  (1.0, "Lecture"),
  (0.5, "Lab Session"),
  (0.2, "Seminar"),
  (0.8, "Tutorial"),
  (0.6, "Workshop"),
  (1.0, "Guest Lecture"),
  (1.0, "Field Trip"),
  (0.9, "Practical"),
  (0.1, "Online Lecture"),
  (0.7, "Group Discussion");

INSERT INTO 'employee' ('employment_id', 'interest_or_skill_set', 'salary', 'person_id', 'job_title_id', 'department_id', 'supervisor_or_manager')
VALUES
  ("1", "Machine Learning, AI", 80000, 1, 1, 1, 2),
  ("2", "Calculus, Analysis", 75000, 2, 2, 2, 3),
  ("3", "Digital Design, Embedded Systems", 72000, 3, 3, 3, 4),
  ("4", "Signal Processing, Algorithms", 78000, 4, 4, 1, 5),
  ("5", "Networking, Databases", 74000, 5, 5, 2, 6),
  ("6", "Econometrics, Finance", 80000, 6, 6, 3, 7),
  ("7", "Quantum Physics, Optics", 77000, 7, 7, 1, 8),
  ("8", "Construction Engineering, Project Management", 76000, 8, 8, 2, 9),
  ("9", "Business Strategy, Marketing", 79000, 9, 9, 3, 10),
  ("0", "Legal Studies, Ethics", 82000, 10, 10, 1, 1);

INSERT INTO 'employee_planned_activity' ('employee_id', 'course_isntance_id')
VALUES
  (1, 1),
  (2, 2),
  (3, 3),
  (4, 4),
  (5, 5),
  (6, 6),
  (7, 7),
  (8, 8),
  (9, 9),
  (10, 10);


INSERT INTO 'department' ('department_name', 'manager')
VALUES
  ("Computer Science", 1),
  ("Mathematics", 2),
  ("Electrical Engineering", 3),


