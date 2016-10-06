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
	insert into People (pName, pGender, pHeight)		-- nota serial fyrir PID til að halda númeraröð ef það skyldi koma upp villa?
	values (iName, iGender, iHeight);			-- adding input values into People table, should start trigger from #6

	nAID := lastval();					-- get the value of unique ID from trigger

	insert into AccountRecords (AID, rDate, rType, rAmount)	-- balance is not specified because trigger from #5 should take care of adding things up
	values (nAID, current_date, 'O', iAmount);		-- uses type (O)ther because this is not a (B)ill, (T)ransfer or (L)oan
end;
$$
language 'plpgsql';

/* Task 8 */
create or replace function PayOneBill (IN iBID int)
returns void
as
$$
declare
	billPID int;
	AIDtoBill int;
	acntAmount int;
	billAmount int;
begin
	-- Person ID to find person's accounts
	billPID := (select PID from Bills where BID = iBID);
	
	-- finding the MAX amount on an account
	acntAmount := (select MAX(ACT.balance) from (
		select AID, SUM(aBalance + aOver) as balance from Accounts where PID = billPID group by AID) as ACT);
	
	-- which account to bill, since it doesn't matter which one in case of more than 1 with same amount we just take the first one
	AIDtoBILL := (select AID from Accounts where PID = 103 group by AID having SUM(abalance+aover) = (select MAX(ACT.balance) from (
		select AID, SUM(aBalance + aOver) as balance from Accounts where PID = 103 group by AID) as ACT) FETCH FIRST 1 ROW ONLY);

	-- the money amount on a bill
	billAmount := (select bAmount from Bills where BID = iBID);

	-- making sure only to try payment when account has enough money for bill (tvíverknaður út af trigger úr no 5?)
	if billAmount <= acntAmount THEN
	
		-- take money off account through AccountRecords
		insert into AccountRecords (AID, rDate, rType, rAmount)
		values (AIDtoBill, current_date, 'B', -billAmount);
	
		-- change bill to true for bIsPaid in Bills
		update Bills
		set bIsPaid = true
		where BID = iBID;
	else
		raise exception 'Not enough money on account';
	end if;
	
end;
$$
language 'plpgsql';

/* Task 9 */
create or replace function Transfer (
	IN iToAID int,
	IN iFromAID int,
	IN iAmount int)
returns void
as
$$
begin
	if iAmount = 0 then		-- making sure you don't transfer zero money
		raise exception 'Can not transfer no money';
	elsif iAmount < 0 then		-- making sure you don't transfer minus money (a reverse transfer)
		raise exception 'Can not transfer minus money';
	elsif iAmount > 0 then
		/* Should be no need to make other checks since trigger from #5 should take care of checking if
		   iAmount is more than exists on given iFromAID account. */
		insert into AccountRecords (AID, rDate, rType, rAmount)		-- We don't insert balance because trigger #5 finds the balance and inserts it
		values 
		(iFromAID, current_date, 'T', -iAmount),			-- iFromAID, transfer iAmount from account
		(iToAID, current_date, 'T', iAmount);			-- iToAID, transfer iAmount to account
	end if;
end;
$$
language 'plpgsql';

/* Task 10 */
create or replace function LoanMoney (
	IN iAID int,
	IN iAmount int,
	IN iDueDate date)
returns void
as
$$
declare
	billPID int;
begin
	/*************************************************************************** 
	 * We check if iAmount is greater than zero since it does not make sense to 
	 * loan an amount of money of zero or less 
	 ***************************************************************************/
	if iAmount = 0 then
		raise exception 'Can not loan zero amount of money!';
	
	elsif iAmount < 0 then
		raise exception 'Can not loan negative amount of money!';
	
	elsif iAmount > 0 then
		insert into AccountRecords (AID, rDate, rType, rAmount)		-- no insert of balance since we assume that trigger from #5 will add it up for us
		values (iAID, current_date, 'L', iAmount);

		billPID := (select PID from Accounts where AID = iAID);		-- getting the PID for the account in question so we know who get the bill
	
		insert into Bills (PID, bDueDate, bAmount, bIsPaid)		-- trigger from #4 should check if this insert is okay
		values (billPID, iDueDate, iAmount, false);
	end if;
end;
$$
language 'plpgsql';
