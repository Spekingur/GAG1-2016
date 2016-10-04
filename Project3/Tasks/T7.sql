/* Task 7 
 * Function InsertPerson takes four IN parameters (iName, iGender, iHeight and iAmount) and
 * inserts a new person into people table using those parameters. It also deposits iAmount into
 * the account created with the trigger in Task 6.
 */
create or replace function InsertPerson (
	IN iName varchar(50), 
	IN iGender char(1), 
	IN iHeight float, 
	IN iAmount int)
returns void
as
$$
declare
	nAID int;
begin
	insert into People (pName, pGender, pHeight)		-- nota serial fyrir PID?
	values (iName, iGender, iHeight);			-- adding input values into People table, should start trigger from #6

	nAID := lastval();					-- get the value of unique ID from trigger

	update Accounts						-- should we insert through AccountRecords using trigger from #5?
	set aBalance = iAmount					-- changes value from 0 to iAmount
	where AID = nAID;					-- assumes that there's only one ID of this type at the current time
end;
$$
language 'plpgsql';
