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
