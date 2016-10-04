/* Task 6 
 * Trigger NewPerson should create a new account when a new person is inserted into People.
 * Each new customer gets an initial overdraft of 10,000 (ten thousand).
 */
create or replace function NewPerson()
returns trigger
as
$$
begin
	insert into Accounts (PID, aDate, aBalance, aOver)		-- nota serial fyrir AID?
	values (NEW.PID, current_date, 0, 10000);			-- adds values into table
	return NEW;
end;
$$
language 'plpgsql';

create trigger NewPerson
after insert on People
for each row 
execute procedure NewPerson();
