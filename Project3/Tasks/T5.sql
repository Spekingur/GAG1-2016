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
