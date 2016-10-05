CREATE VIEW AllAccountRecords
AS
SELECT A.aid, A.pid, A.adate, A.abalance, A.aover, R.rid, R.rdate, R.rtype, R.ramount, R.rbalance
FROM accounts A
LEFT JOIN accountrecords R
ON A.aid = R.aid
