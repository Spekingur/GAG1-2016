/******* Assignment 8: Database Design ********* 
 * Hreiðar Ólafur Arnarsson - hreidara14@ru.is
 * Maciej Sierzputowski - maciej15@ru.is
 **********************************************/

/* TASK 1 */
CREATE TABLE Players (
	PID 		SERIAL PRIMARY KEY,
	pName 		VARCHAR(50),
	pGender 	CHAR(1),
	pSalary 	INTEGER,
	pBiography 	TEXT
);
 
/* TASK 2 */
CREATE TABLE Coaches (
	CID		SERIAL PRIMARY KEY,
	cName 		VARCHAR(50),
	cSalary 	INTEGER,
	cDegree 	VARCHAR(50),
	cDegreeDate 	DATE
);

/* TASK 3 */
CREATE TABLE Teams (
	TID		SERIAL PRIMARY KEY,
	tNickname 	VARCHAR(50) UNIQUE NOT NULL,
	tGender 	CHAR(1),
	tFoundation 	DATE
);

/* TASK 4 */
CREATE TABLE Divisions (
	dName 		VARCHAR(50),
	dGender 	CHAR(1),
	dSponsor 	VARCHAR(50),
	PRIMARY KEY (dName, dGender)
);

/* TASK 5 */
CREATE TABLE Matches (
	homeTID		INTEGER,
	awayTID		INTEGER,
	mDate		DATE,
	mTime		TIME,
	mVenue		VARCHAR(50),
	homeScore	INTEGER,
	awayScore	INTEGER,
 	PRIMARY KEY (homeTID, awayTID, mDate, mTime)
);
 
 /* RELATION TABLES */
 
 /* Relation between Coaches and Teams */
 CREATE TABLE Trains (
	CID		INTEGER,
	TID		INTEGER,
	salary		INTEGER,
	PRIMARY KEY (CID, TID),
	FOREIGN KEY (CID) REFERENCES Coaches,
	FOREIGN KEY (TID) REFERENCES Teams
);

/* Relation between Players and Teams */
/* Technically possible to have this as column in Players table */
CREATE TABLE PartOf (
	PID		INTEGER,
	TID		INTEGER,
	PRIMARY KEY (PID),
	FOREIGN KEY (PID) REFERENCES Players,
	FOREIGN KEY (TID) REFERENCES Teams
);

/* Relation between Teams and Divisions */
CREATE TABLE PlaysIn (
	TID		INTEGER,
	dName 		VARCHAR(50),
	dGender 	CHAR(1),
	PRIMARY KEY (TID),
	FOREIGN KEY (TID) REFERENCES Teams,
	FOREIGN KEY (dName, dGender) REFERENCES Divisions
);

/* Relation between Teams and Matches */
CREATE TABLE CompetesIn (
	TID		INTEGER,
	homeTID		INTEGER,
	PRIMARY KEY (TID, homeTID),
	FOREIGN KEY (TID) REFERENCES Teams,
	FOREIGN KEY (homeTID) REFERENCES Matches
);
