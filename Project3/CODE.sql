/************** Project 3 *********************
 * Hreiðar Ólafur Arnarsson - hreidara14@ru.is
 * Maciej Sierzputowski - maciej15@ru.is       
 **********************************************/
 
/* Task 1 */
CREATE VIEW AllAccountRecords
AS
SELECT A.aid, A.pid, A.adate, A.abalance, A.aover, R.rid, R.rdate, R.rtype, R.ramount, R.rbalance
FROM accounts A
LEFT JOIN accountrecords R
ON A.aid = R.aid;

/* Task 2 */
CREATE VIEW DebtorStatus
AS
SELECT A.pid, P.pname, SUM(A.abalance) AS abalance, SUM(A.aover) AS aover
FROM accounts A
JOIN people P
ON A.pid = P.pid
WHERE A.abalance < 0
GROUP BY A.pid, P.pname
ORDER BY A.pid;

/* Task 3 */
create or replace view FinancialStatus (PID, pName, total, unpaid)
as
select P.PID, P.pName, B.total, U.unpaid
from People P
	join (		-- this finds all accounts and joins it with people table (fullfills 1+ accounts)
		select pid, sum(abalance) as total
		from accounts
		group by pid
		) B on B.pid = P.pid
	left join (	-- use left join because some people have accounts and no unpaid bills
		select pid, sum(bamount) as unpaid
		from bills
		where bispaid = false
		group by pid
		) U on U.pid = P.pid
;

/* Task 4 */
CREATE OR REPLACE FUNCTION CheckBills() RETURNS trigger AS $bills_check$
    BEGIN
        IF(TG_OP = 'INSERT') THEN 
		IF NEW.bamount < 0 THEN
			RAISE EXCEPTION 'Bill must be of a positive amount';
		ELSIF NEW.bduedate <= now() THEN
			RAISE EXCEPTION 'Due date must be in the future!';
		END IF;
        RETURN NEW;
        
        ELSIF (TG_OP = 'UPDATE') THEN
		IF NEW.bid != OLD.bid THEN
			RAISE EXCEPTION 'Its not allowed to update bills!';
		ELSIF NEW.pid != OLD.pid THEN
			RAISE EXCEPTION 'Its not allowed to update bills!';
		ELSIF NEW.bduedate != OLD.bduedate THEN
			RAISE EXCEPTION 'Its not allowed to update bills!';
		ELSIF NEW.bamount != OLD.bamount THEN
			RAISE EXCEPTION 'Its not allowed to update bills!';
		END IF;
	RETURN NEW;
		
        ELSIF (TG_OP = 'DELETE') THEN
            RAISE EXCEPTION 'Its not allowed to delete bills!';
        END IF;
    END;
$bills_check$ LANGUAGE plpgsql;

CREATE TRIGGER bills_check
BEFORE INSERT OR UPDATE OR DELETE ON bills
    FOR EACH ROW EXECUTE PROCEDURE CheckBills();

/* Task 5 */
CREATE OR REPLACE FUNCTION AccountRecords() RETURNS trigger AS $account_records$
    DECLARE
        theBalance int;
        checkBalance int;
        checkOverdraft int;
        totalAmount int;
    BEGIN
        IF(TG_OP = 'INSERT') THEN 
		IF NEW.ramount < 0 THEN
			checkBalance := (select abalance from accounts where aid = NEW.aid);
			checkOverdraft:= (select aover from accounts where aid = NEW.aid);
			totalAmount:= (checkBalance + checkOverdraft) + NEW.ramount;
			
			IF (totalAmount < 0) THEN
				RAISE EXCEPTION 'Not enough money on the account being withdrawn from!';
			ELSE
				UPDATE accounts SET abalance = abalance + NEW.ramount WHERE aid = NEW.aid;
				UPDATE accounts SET adate = now() WHERE aid = NEW.aid;
				theBalance := (select abalance from accounts where aid = NEW.aid);
				NEW.rbalance := theBalance;
			END IF;
			RETURN NEW;
		ELSIF NEW.ramount > 0 THEN
			UPDATE accounts SET abalance = abalance + NEW.ramount WHERE aid = NEW.aid;
			UPDATE accounts SET adate = now() WHERE aid = NEW.aid;
			
			theBalance := (select abalance from accounts where aid = NEW.aid);
			NEW.rbalance = theBalance;
			NEW.rdate = now();
		END IF;
        RETURN NEW;
        
        ELSIF (TG_OP = 'UPDATE') THEN
            RAISE EXCEPTION 'Its not allowed to update account records!';          
        ELSIF (TG_OP = 'DELETE') THEN
            RAISE EXCEPTION 'Its not allowed to delete account records!';
        END IF;
    END;
$account_records$ LANGUAGE plpgsql;

CREATE TRIGGER account_records
BEFORE INSERT OR UPDATE OR DELETE ON accountrecords
    FOR EACH ROW EXECUTE PROCEDURE AccountRecords();

/* Task 6 */
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

/* Task 7 */

/* Task 8 */

/* Task 9 */

/* Task 10 */
