# Library Management System using SQL Project --P2

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library_project_2`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Library_project](https://github.com/Ramteke-Rajat/Library_management_system/blob/main/Library%20image.jpg?raw=true)

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/Ramteke-Rajat/Library_management_system/blob/main/ERD.pgerd.png?raw=true)

- **Database Creation**: Created a database named `library_project_2`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
CREATE DATABASE library_project_2;

-- creating branch table
DROP TABLE IF EXISTS branch;
CREATE TABLE branch
	(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(50),
            contact_no VARCHAR(10)
	);

-- creating employees table
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
	(
            emp_id VARCHAR(10) PRIMARY KEY,
	emp_name VARCHAR(25),
	position VARCHAR(15),
	salary INT,
	branch_id VARCHAR(10)  --FK
	);

-- creating books table
DROP TABLE IF EXISTS books;
CREATE TABLE books
	(
            isbn VARCHAR(20) PRIMARY KEY,
	book_title VARCHAR(60),
	category VARCHAR(20),
	rental_price FLOAT,
	status VARCHAR(10),
	author VARCHAR(30),
	publisher VARCHAR(30)
	);

-- creating members table
DROP TABLE IF EXISTS members;
CREATE TABLE members
	(
	member_id VARCHAR(10) PRIMARY KEY,
	member_name VARCHAR(30),
	member_address VARCHAR(30),
	reg_date DATE
	);

-- creating issued_status table
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
	(
	issued_id VARCHAR(10) PRIMARY KEY,
	issued_member_id VARCHAR(10),  --FK
	issued_book_name VARCHAR(75),
	issued_date DATE,
	issued_book_isbn VARCHAR(20),  --FK
	issued_emp_id VARCHAR(10)  --FK
	);

-- creating return_status table
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
	(
	return_id VARCHAR(10) PRIMARY KEY,
	issued_id VARCHAR(10),  --FK
	return_book_name VARCHAR(75),
	return_date DATE,
	return_book_isbn VARCHAR(20)  
	);
```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

### 3. Created relationships between table using foreign keys

```sql
ALTER TABLE issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY (issued_member_id)
REFERENCES members(member_id);


ALTER TABLE issued_status
ADD CONSTRAINT fk_books
FOREIGN KEY (issued_book_isbn)
REFERENCES books(isbn);


ALTER TABLE issued_status
ADD CONSTRAINT fk_employees
FOREIGN KEY (issued_emp_id)
REFERENCES employees(emp_id);


ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY (branch_id)
REFERENCES branch(branch_id);

ALTER TABLE return_status
ADD CONSTRAINT fk_issued_status
FOREIGN KEY (issued_id)
REFERENCES issued_status(issued_id);
```

### 4. Porject Tasks

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;
```
**Task 2: Update an Existing Member's Address**

```sql
UPDATE members
SET member_name = 'Rajat Ramteke'
WHERE member_id = 'C102'
SELECT * FROM members
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
DELETE FROM issued_status
WHERE   issued_id =   'IS121';
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'
```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT 
	issued_emp_id,
	COUNT(issued_id) as total_books_issued
FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT(issued_id) > 1
```

### 5. CTAS (Create Table As Select)

**Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
CREATE TABLE book_count
AS
SELECT 
	b.isbn,
	b.book_title,
	COUNT(ist.issued_id) as no_issued
FROM
	books as b
JOIN
	issued_status as ist
	ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, 2;
```


### 6. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category**:

```sql
SELECT * FROM books
WHERE category = 'Classic';
```

8. **Task 8: Find Total Rental Income by Category**:

```sql
SELECT
	b.category,
	SUM(rental_price) as total_rent,
	COUNT(*)
FROM
	books as b
JOIN
	issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY category
ORDER by total_rent
```

9. **List Members Who Registered in the Last 180 Days**:
```sql
SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 days';
```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
SELECT 
	e1.emp_name,
	e1.emp_id,
	e1.branch_id,
	b.manager_id,
	e2.emp_name as manager
FROM
	employees as e1
JOIN
	branch as b
ON b.branch_id = e1.branch_id
JOIN
	employees as e2
ON b.manager_id = e2.emp_id
```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
CREATE TABLE books_over6
AS
SELECT * FROM books
WHERE rental_price > 6

SELECT * FROM books_over6
```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
SELECT 
	ist.issued_id,
	ist.issued_book_name,
	ist.issued_date
FROM
	issued_status as ist
LEFT JOIN
	return_status as rst
ON ist.issued_id = rst.issued_id
WHERE rst.return_id is NULL
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
SELECT 
	ist.issued_member_id,
	m.member_name,
	b.book_title,
	ist.issued_date,
	rst.return_date,
	CURRENT_DATE - ist.issued_date as days_overdue
FROM
	issued_status as ist
JOIN
	members as m
ON m.member_id=ist.issued_member_id
JOIN
	books as b
ON b.isbn = ist.issued_book_isbn
LEFT JOIN
	return_status as rst
ON ist.issued_id = rst.issued_id
WHERE 
	rst.return_date is NULL
	AND
	CURRENT_DATE - ist.issued_date > 30
```

**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).

```sql

CREATE OR REPLACE PROCEDURE add_return_record(p_return_id VARCHAR(10), p_issued_id VARCHAR(10), p_book_quality VARCHAR(15))
LANGUAGE plpgsql
AS 
$$

DECLARE
	v_isbn VARCHAR(50);
	v_book_title VARCHAR(75);

BEGIN
	-- logic and code
	-- Insert into return_status based on users input
	INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
	VALUES(p_return_id, p_issued_id, CURRENT_DATE, p_book_quality);

	SELECT
		issued_book_isbn,
		issued_book_name
		INTO
		v_isbn,
		v_book_title
	FROM
		issued_status
	WHERE
		issued_id = p_issued_id;
	UPDATE books
	SET status = 'Yes'
	WHERE isbn = v_isbn;

	RAISE NOTICE 'Thank you for returning the book: %', v_book_title;
END;
$$

-- calling fucntions
CALL add_return_record('RS135', 'IS135', 'Good');

CALL add_return_record('RS138', 'IS140', 'Damaged');

```

**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
CREATE TABLE branch_report
AS
SELECT 
	b.branch_id,
	COUNT(ist.issued_id) as num_books_issued,
	COUNT(rs.return_id) as num_books_returned,
	SUM(bk.rental_price) as total_revenue
FROM
	issued_status as ist
JOIN
	employees as e
ON e.emp_id = ist.issued_emp_id
JOIN
	branch as b
ON b.branch_id = e.branch_id
JOIN
	books as bk
ON bk.isbn = ist.issued_book_isbn
LEFT JOIN
	return_status as rs
ON rs.issued_id = ist.issued_id

GROUP BY b.branch_id
ORDER BY SUM(bk.rental_price) DESC;

SELECT * FROM branch_report;
```

**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql
CREATE TABLE avtive_members
AS
SELECT
	ist.issued_member_id as member_id,
	m.member_name,
	ist.issued_date
FROM
	issued_status as ist
JOIN
	members as m
ON m.member_id = ist.issued_member_id
WHERE
	issued_date >= CURRENT_DATE - INTERVAL '6 month';

SELECT * FROM avtive_members
```

**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
SELECT
	emp.emp_id,
	emp.emp_name,
	COUNT(ist.issued_id) as number_of_books_processed,
	emp.branch_id
FROM
	issued_status as ist
JOIN
	employees as emp
ON emp.emp_id = ist.issued_emp_id
GROUP BY emp.emp_id
ORDER BY COUNT(ist.issued_id) DESC
LIMIT 3;
```

**Task 18: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql

CREATE OR REPLACE PROCEDURE issued_book(p_issued_id VARCHAR(10), p_issued_member_id VARCHAR(10), p_issued_book_isbn VARCHAR(20), p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS
$$

DECLARE
-- all the variables
	v_status VARCHAR(10);

BEGIN
-- all code and logic
	-- checking if the book is available
	
	SELECT status
		INTO
		v_status	
	FROM
		books
	WHERE
		isbn = p_issued_book_isbn;
	IF
		v_status = 'yes'
	THEN
		INSERT INTO issued_status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
		VALUES(p_issued_id, p_issued_member_id, CURRENT_DATE, p_issued_book_isbn, p_issued_emp_id);

		UPDATE books
		SET status = 'no'
		WHERE isbn = p_issued_book_isbn;

		RAISE NOTICE 'Book record added successfully for book ISBN: %', p_issued_book_isbn;

	ELSE
		RAISE NOTICE 'The book is currently not available.';

	END IF;
END;
$$

-- testing
-- "978-0-7432-7357-1" -- no
-- "978-0-7434-7679-3" -- yes


CALL issued_book('IS156', 'C110', '978-0-7434-7679-3', 'E105');

SELECT * FROM books
WHERE isbn = '978-0-7434-7679-3';
```

## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.

Thank you for your interest in this project!
