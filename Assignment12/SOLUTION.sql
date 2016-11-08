1.	CREATE USER Stakeholder password 'easy';				--Creates an user account named 'Stakeholder' with a password 'easy'

2.	SELECT *								--Tests if 'Stakeholder' can use the Customers view(Should result in failure)
	FROM Customers;										

	SELECT *								--Tests if 'Stakeholder' can use the Records view(Should result in failure)
	FROM Records;
	
3.	GRANT SELECT								--Grants permission to see the Customers view to 'Stakeholder'
	ON TABLE Customers
	TO stakeholder;

	GRANT SELECT								--Grants permission to see the Records view to 'Stakeholder'
	ON TABLE Records
	TO stakeholder;
	
4.	SELECT *								--Tests if 'Stakeholder' can use the Customers view(Should now result in success)
	FROM Customers;										

	SELECT *								--Tests if 'Stakeholder' can use the Records view(Should now result in success)
	FROM Records;

	INSERT INTO people
	VALUES (555, 'TestName', 'M', 1.88);					--Tests if 'Stakeholder' can insert into the People table(Should result in failure)
	
5.	CREATE USER Manager PASSWORD '123';					--Creates an user account named 'Manager' with a password '123'

	GRANT ALL PRIVILEGES 							--Grants the user 'Manager' privileges to use SELECT, INSERT and DELETE on all
	ON ALL TABLES 								--tables in the A_12 database
	IN SCHEMA PUBLIC 
	TO manager;
	
6.	SELECT NewCustomer(555, 'TestName', 'M', 1.88);				--Tests if 'Manager' can use the NewCustomer procedure(Should result in failure)

7.	GRANT EXECUTE 									--Grants the user 'Manager' privileges to execute the NewCustomer procedure
	ON FUNCTION newcustomer(integer, character varying, character, double precision)
	TO manager;
	
8.	SELECT NewCustomer(555, 'TestName', 'M', 1.88);				--Tests if 'Manager' can use the NewCustomer procedure(Should result in success)

9.	
	REVOKE SELECT 								--Revokes privileges from user 'Stakeholder' to see the Customers and Records views
	ON Customers, Records 
	FROM stakeholder;
	
	REVOKE ALL PRIVILEGES 							--Revokes privileges from user 'Manager' to modify the tables
	ON ALL TABLES 
	IN SCHEMA PUBLIC 
	FROM manager;
	
	REVOKE EXECUTE 									--Revokes privileges from user 'Manager' to execute the NewCustomer function
	ON FUNCTION newcustomer(integer, character varying, character, double precision)
	FROM manager;
	
	SELECT *								--Tests if 'Stakeholder' can use the Customers view(Should result in failure)
	FROM Customers;										

	SELECT *								--Tests if 'Stakeholder' can use the Records view(Should result in failure)
	FROM Records;
	
	INSERT INTO people							--Tests if 'Manager' can insert into the People table(Should result in failure)
	VALUES (555, 'TestName', 'M', 1.88);
	
	SELECT NewCustomer(555, 'TestName', 'M', 1.88);				--Tests if 'Manager' can use the NewCustomer procedure(Should result in failure)
	
10.
	DROP USER IF EXISTS manager;						--Deletes the user 'Manager', the user should now not be able to login as 'Manager'
	
	DROP USER IF EXISTS stakeholder;					--Deletes the user 'Manager', the user should now not be able to login as 'Stakeholder'
