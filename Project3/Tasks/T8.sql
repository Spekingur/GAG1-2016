create or replace function PayOneBill (IN iBID int)
returns void
as
$$
declare
	billPID int;
	AIDtoBill int;
	numOfAID int;
	acntAmount int;
	billAmount int;
begin
	-- what do we need? we need the AID and we need the amount on the account
	-- we need to know the PID to check the accounts
	-- we need to know what account to select
	-- then we need to check if the amount on the bill is less or equal to the one on account
	-- if so then 
	billPID := (select PID from Bills where BID = iBID);	-- Person ID to find person's accounts
	
	acntAmount := (select MAX(ACT.balance) from (
		select AID, SUM(aBalance + aOver) as balance from Accounts where PID = billPID group by AID) as ACT);	-- finding the MAX amount on an account
	
	--AIDtoBill := (select AID, SUM(aBalance + aOver) as balance from Accounts where PID = billPID);
	AIDtoBILL := (select AID from Accounts where PID = 103 group by AID having SUM(abalance+aover) = (select MAX(ACT.balance) from (
		select AID, SUM(aBalance + aOver) as balance from Accounts where PID = 103 group by AID) as ACT) FETCH FIRST 1 ROW ONLY);

	billAmount := (select bAmount from Bills where BID = iBID);	-- the money amount on a bill
	--numOfAID := (select count(*) from billNUM);

	if billAmount <= acntAmount THEN
	
		--(b) take money off account through AccountRecords
		insert into AccountRecords (AID, rDate, rType, rAmount)
		values (AIDtoBill, current_date, 'B', -billAmount);
	
		--(c) change bill to true for bIsPaid in Bills
		update Bills
		set bIsPaid = true
		where BID = iBID;
	else
		raise exception 'Not enough money on account';
	end if;
	
end;
$$
language 'plpgsql';
