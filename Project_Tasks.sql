-- Project Tasks

SELECT * FROM books
SELECT * FROM branch
SELECT * FROM employees
SELECT * FROM members
SELECT * FROM issued_status
SELECT * FROM return_status
WHERE book_quality = 'Damaged'

-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES ('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')

-- Task 2: Update an Existing Member's Address

UPDATE members
SET member_name = 'Rajat Ramteke'
WHERE member_id = 'C102'
SELECT * FROM members

-- Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

DELETE FROM  issued_status
WHERE issued_id = 'IS121'

--Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'

-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT 
		issued_emp_id,
		COUNT(issued_id) as total_books_issued
FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT(issued_id) > 1

-- CTAS
-- Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**
CREATE TABLE book_count
AS
SELECT 
	b.isbn,
	b.book_title,
	COUNT(ist.issued_id) as no_issued
FROM books as b
JOIN
issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, 2;

SELECT * FROM book_count

-- Task 7. Retrieve All Books in a Specific Category:

SELECT * FROM books
WHERE category = 'Classic'

-- Task 8: Find Total Rental Income by Category:

SELECT
	b.category,
	SUM(rental_price) as total_rent,
	COUNT(*)
FROM books as b
JOIN
issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY category
ORDER by total_rent

-- Tack 9: List Members Who Registered in the Last 180 Days:
-- adding recent members
INSERT INTO members(member_id, member_name, member_address, reg_date)
VALUES
('C122', 'Manas Pazare', '125 Samta st', '2025-12-07')
('C120', 'Deep Katkar', '121 Samta st', '2025-05-07'),
('C121', 'Sahil Katkar', '123 Samta st', '2025-02-11')

SELECT * FROM members
WHERE reg_date > CURRENT_DATE - INTERVAL '180 days'

-- Task 10: List Employees with Their Branch Manager's Name and their branch details:

SELECT 
	e1.emp_name,
	e1.emp_id,
	e1.branch_id,
	b.manager_id,
	e2.emp_name as manager
FROM employees as e1
JOIN branch as b
ON b.branch_id = e1.branch_id
JOIN
employees as e2
ON b.manager_id = e2.emp_id

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:

CREATE TABLE books_over6
AS
SELECT * FROM books
WHERE rental_price > 6

SELECT * FROM books_over6

-- Task 12: Retrieve the List of Books Not Yet Returned

SELECT 
	ist.issued_id,
	ist.issued_book_name,
	ist.issued_date
FROM issued_status as ist
LEFT JOIN
return_status as rst
ON ist.issued_id = rst.issued_id
WHERE rst.return_id is NULL

-- Advanced SQL Operations

-- Task 13: Identify Members with Overdue Books. Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

-- issued_status == members = books == return_status
-- filter books that are returned
-- overdue > 30 days

SELECT 
	ist.issued_member_id,
	m.member_name,
	b.book_title,
	ist.issued_date,
	rst.return_date,
	CURRENT_DATE - ist.issued_date as days_overdue
FROM issued_status as ist
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

	

-- Task 14: Update Book Status on Return. Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).

SELECT * FROM books
WHERE isbn = '978-0-330-25864-8'

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-679-76489-8'

UPDATE books
SET status = 'no'
WHERE isbn = '978-0-330-25864-8'

SELECT * FROM return_status
WHERE issued_id = 'IS140'

--

INSERT INTO return_status(return_id, issued_id, return_date, book_quality)
VALUES('RS125', 'IS139', CURRENT_DATE, 'Good');

UPDATE books
SET status = 'Yes'
WHERE isbn = '978-0-679-76489-8'

-- Store Procedures

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
	FROM issued_status
	WHERE issued_id = p_issued_id;

	UPDATE books
	SET status = 'Yes'
	WHERE isbn = v_isbn;

	RAISE NOTICE 'Thank you for returning the book: %', v_book_title;
END;
$$

CALL add_return_record('RS135', 'IS135', 'Good');

CALL add_return_record('RS138', 'IS140', 'Damaged');

-- Task 15: Branch Performance Report. Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

CREATE TABLE branch_report
AS
SELECT 
	b.branch_id,
	COUNT(ist.issued_id) as num_books_issued,
	COUNT(rs.return_id) as num_books_returned,
	SUM(bk.rental_price) as total_revenue
FROM issued_status as ist
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

-- Task 16: CTAS: Create a Table of Active Members. Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 6 months.


CREATE TABLE avtive_members
AS
SELECT
	ist.issued_member_id as member_id,
	m.member_name,
	ist.issued_date
FROM issued_status as ist
JOIN
members as m
ON m.member_id = ist.issued_member_id
WHERE
	issued_date >= CURRENT_DATE - INTERVAL '6 month';

SELECT * FROM avtive_members

-- Task 17: Find Employees with the Most Book Issues Processed. Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

SELECT
	emp.emp_id,
	emp.emp_name,
	COUNT(ist.issued_id) as number_of_books_processed,
	emp.branch_id
FROM issued_status as ist
JOIN employees as emp
ON emp.emp_id = ist.issued_emp_id
GROUP by emp.emp_id
ORDER BY COUNT(ist.issued_id) DESC
LIMIT 3

/* Task 18: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system.

Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 

The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 

The procedure should first check if the book is available (status = 'yes'). 

If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 

If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/

SELECT * FROM books

SELECT * FROM issued_status

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
	FROM books
	WHERE isbn = p_issued_book_isbn;
	
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




-- Task 20: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines. Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include: The number of overdue books. The total fines, with each day's fine calculated at $0.50. The number of books issued by each member. The resulting table should show: Member ID Number of overdue books Total fines

