CREATE TABLE EMPLOYEE (
    Fname VARCHAR(15) NOT NULL,
    Minit CHAR(1) NULL,
    Lname VARCHAR(15) NOT NULL,
    Ssn CHAR(9) NOT NULL,
    Bdate DATE NULL,
    Address VARCHAR(30) NULL,
    Sex CHAR(1) NULL,
    Salary DECIMAL(10, 2) NULL,
    Super_ssn CHAR(9) NULL,
    Dno INT NOT NULL,
    CONSTRAINT PK_EMPLOYEE PRIMARY KEY (Ssn),
    CONSTRAINT FK_EMPLOYEE_EMPLOYEE FOREIGN KEY (Super_ssn) REFERENCES EMPLOYEE (Ssn)
);

CREATE TABLE PROJECT (
    Pname VARCHAR(15) NOT NULL,
    Pnumber INT NOT NULL,
    Plocation VARCHAR(15) NULL,
    Dnum INT NOT NULL,
    CONSTRAINT PK_PROJECT PRIMARY KEY (Pnumber),
    CONSTRAINT UK_PROJECT UNIQUE (Pname)
);

CREATE TABLE WORKS_ON (
    Essn CHAR(9) NOT NULL,
    Pno INT NOT NULL,
    Hours DECIMAL(3, 1) NULL,
    CONSTRAINT PK_WORKS_ON PRIMARY KEY (Essn, Pno),
    CONSTRAINT FK_WORKS_ON_EMPLOYEE FOREIGN KEY (Essn) REFERENCES EMPLOYEE (Ssn),
    CONSTRAINT FK_WORKS_ON_PROJECT FOREIGN KEY (Pno) REFERENCES PROJECT (Pnumber)
);

INSERT INTO EMPLOYEE (Fname, Minit, Lname, Ssn, Bdate, Address, Sex, Salary, Super_ssn, Dno) VALUES
    ('James', 'E', 'Borg', '888665555', '1937-11-10', '450 Stone, Houston, TX', 'M', 55000, NULL, 1),
    ('Franklin', 'T', 'Wong', '333445555', '1955-12-08', '638 Voss, Houston, TX', 'M', 40000, '888665555', 5),
    ('Jennifer', 'S', 'Wallace', '987654321', '1941-06-20', '291 Berry, Bellaire, TX', 'F', 43000, '888665555', 4),
    ('Alicia', 'J', 'Zelaya', '999887777', '1968-01-19', '3321 Castle, Spring, TX', 'F', 25000, '987654321', 4),
    ('Ahmad', 'V', 'Jabbar', '987987987', '1969-03-29', '980 Dallas, Houston, TX', 'M', 25000, '987654321', 4),
    ('John', 'B', 'Smith', '123456789', '1965-01-09', '731 Fonden, Houston, TX', 'M', 30000, '333445555', 5),
    ('Ramesh', 'K', 'Narayan', '666884444', '1962-09-15', '975 Fire Oak, Humble, TX', 'M', 38000, '333445555', 5),
    ('Joyce', 'A', 'English', '453453453', '1972-07-31', '5631 Rice, Houston, TX', 'F', 25000, '333445555', 5);

INSERT INTO PROJECT (Pname, Pnumber, Plocation, Dnum) VALUES
    ('ProductX', 1, 'Bellaire', 5),
    ('ProductY', 2, 'Sugarland', 5),
    ('ProductZ', 3, 'Houston', 5),
    ('Computerization', 10, 'Stafford', 4),
    ('Reorganization', 20, 'Houston', 1),
    ('Newbenefits', 30, 'Stafford', 4);

INSERT INTO WORKS_ON (Essn, Pno, Hours) VALUES
    ('123456789', 1, 32.5),
    ('123456789', 2, 7.5),
    ('666884444', 3, 40.0),
    ('453453453', 1, 20.0),
    ('453453453', 2, 20.0),
    ('333445555', 2, 10.0),
    ('333445555', 3, 10.0),
    ('333445555', 10, 10.0),
    ('333445555', 20, 10.0),
    ('999887777', 30, 30.0),
    ('999887777', 10, 10.0),
    ('987987987', 10, 35.0),
    ('987987987', 30, 5.0),
    ('987654321', 30, 20.0),
    ('987654321', 20, 15.0),
    ('888665555', 20, NULL);
GO

-- Find the names of employees who work on *all* the projects "John Smith" works on.
SELECT Fname, Lname
    FROM EMPLOYEE
WHERE Fname + ' ' + Lname <> 'John Smith'
AND NOT EXISTS(
    SELECT *
        FROM PROJECT
    WHERE EXISTS(
        SELECT *
	    FROM WORKS_ON
	    INNER JOIN EMPLOYEE
            ON Essn = Ssn
        WHERE Fname + ' ' + Lname = 'John Smith'
        AND Pno = Pnumber
    )
    AND NOT EXISTS(
        SELECT *
            FROM WORKS_ON
        WHERE Pno = Pnumber
        AND Essn = Ssn
    )
);

SELECT Fname, Lname
    FROM EMPLOYEE
WHERE Fname + ' ' + Lname <> 'John Smith'
AND Ssn IN (
    SELECT
        Ssn
        FROM EMPLOYEE
        INNER JOIN WORKS_ON
        ON Ssn = Essn
        INNER JOIN Project
        ON Pno = Pnumber
    WHERE Pnumber IN (
        SELECT Pnumber
            FROM PROJECT
            INNER JOIN WORKS_ON
            ON Pnumber = Pno
	        INNER JOIN EMPLOYEE
            ON Essn = Ssn
        WHERE Fname + ' ' + Lname = 'John Smith'
    )
    GROUP BY Ssn
    HAVING COUNT(DISTINCT Pnumber) = (
        SELECT COUNT(Pnumber)
            FROM PROJECT
            INNER JOIN WORKS_ON
            ON Pnumber = Pno
	        INNER JOIN EMPLOYEE
            ON Essn = Ssn
        WHERE Fname + ' ' + Lname = 'John Smith'
    )
);
