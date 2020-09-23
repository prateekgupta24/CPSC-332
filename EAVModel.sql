CREATE TABLE Entity (
    EntityID INT IDENTITY NOT NULL,
    Entity NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_EntityID PRIMARY KEY (EntityID)
);
GO

CREATE TABLE Attribute (
    AttributeID BIGINT IDENTITY NOT NULL,
    Attribute NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_Attribute PRIMARY KEY (AttributeID)
);
GO

CREATE TABLE Value (
    ValueID BIGINT IDENTITY NOT NULL,
    Value NVARCHAR(255) NOT NULL,
    CONSTRAINT PK_Value PRIMARY KEY (ValueID)
);
GO

CREATE TABLE EntityAttributeValue (
    EntityID INT NOT NULL,
    AttributeID BIGINT NOT NULL,
    SurrogateKeyID BIGINT NOT NULL,
    ValueID BIGINT NOT NULL,
    CONSTRAINT PK_EntityAttributeValue PRIMARY KEY (EntityID, AttributeID, SurrogateKeyID, ValueID),
    CONSTRAINT FK_EntityAttributeValue_Entity FOREIGN KEY (EntityID) REFERENCES Entity (EntityID),
    CONSTRAINT FK_EntityAttributeValue_Attribute FOREIGN KEY (AttributeID) REFERENCES Attribute (AttributeID),
    CONSTRAINT FK_EntityAttributeValue_Value FOREIGN KEY (ValueID) REFERENCES Value (ValueID)
);
GO

-- Employee
INSERT INTO Entity (Entity) VALUES ('EMPLOYEE');
INSERT INTO Attribute (Attribute) VALUES ('Fname');
INSERT INTO Attribute (Attribute) VALUES ('Minit');
INSERT INTO Attribute (Attribute) VALUES ('Lname');
INSERT INTO Attribute (Attribute) VALUES ('Ssn');
INSERT INTO Attribute (Attribute) VALUES ('Bdate');
INSERT INTO Attribute (Attribute) VALUES ('Address');
INSERT INTO Attribute (Attribute) VALUES ('Sex');
INSERT INTO Attribute (Attribute) VALUES ('Salary');
INSERT INTO Attribute (Attribute) VALUES ('Super_ssn');
INSERT INTO Attribute (Attribute) VALUES ('Dno');
GO
INSERT INTO Value (Value) VALUES ('Jennifer');
INSERT INTO Value (Value) VALUES ('S');
INSERT INTO Value (Value) VALUES ('Wallace');
INSERT INTO Value (Value) VALUES ('987654321');
INSERT INTO Value (Value) VALUES ('1941-06-20');
INSERT INTO Value (Value) VALUES ('291 Berry, Bellaire, TX');
INSERT INTO Value (Value) VALUES ('F');
INSERT INTO Value (Value) VALUES ('43000');
INSERT INTO Value (Value) VALUES ('888665555');
INSERT INTO Value (Value) VALUES ('4');
GO
INSERT INTO EntityAttributeValue (EntityID, AttributeID, SurrogateKeyID, ValueID)
    SELECT e.EntityID, a.AttributeID, 1, v.ValueID
        FROM Entity AS e, Attribute AS a, Value AS v
    WHERE e.Entity = 'EMPLOYEE'
        AND (
            (a.Attribute = 'Fname' AND v.Value = 'Jennifer')
            OR (a.Attribute = 'Minit' AND v.Value = 'S')
            OR (a.Attribute = 'Lname' AND v.Value = 'Wallace')
            OR (a.Attribute = 'SSN' AND v.Value = '987654321')
            OR (a.Attribute = 'Bdate' AND v.Value = '1941-06-20')
            OR (a.Attribute = 'Address' AND v.Value = '291 Berry, Bellaire, TX')
            OR (a.Attribute = 'Sex' AND v.Value = 'F')
            OR (a.Attribute = 'Salary' AND v.Value = '43000')
            OR (a.Attribute = 'Super_ssn' AND v.Value = '888665555')
            OR (a.Attribute = 'Dno' AND v.Value = '4')
        );
GO
-- Department
INSERT INTO Entity (Entity) VALUES ('DEPARTMENT');
INSERT INTO Attribute (Attribute) VALUES ('Dname');
INSERT INTO Attribute (Attribute) VALUES ('Dnumber');
INSERT INTO Attribute (Attribute) VALUES ('Mgr_ssn');
INSERT INTO Attribute (Attribute) VALUES ('Mgr_start_date');
GO
INSERT INTO Value (Value) VALUES ('Administration');
-- INSERT INTO Value (Value) VALUES ('4');
-- INSERT INTO Value (Value) VALUES ('987654321');
INSERT INTO Value (Value) VALUES ('1995-01-01');
GO
INSERT INTO EntityAttributeValue (EntityID, AttributeID, SurrogateKeyID, ValueID)
    SELECT e.EntityID, a.AttributeID, 1, v.ValueID
        FROM Entity AS e, Attribute AS a, Value AS v
    WHERE e.Entity = 'DEPARTMENT'
        AND (
            (a.Attribute = 'Dname' AND v.Value = 'Administration')
            OR (a.Attribute = 'Dnumber' AND v.Value = '4')
            OR (a.Attribute = 'Mgr_ssn' AND v.Value = '987654321')
            OR (a.Attribute = 'Mgr_start_date' AND v.Value = '1995-01-01')
        );
GO
-- Project
INSERT INTO Entity (Entity) VALUES ('PROJECT');
INSERT INTO Attribute (Attribute) VALUES ('Pname');
INSERT INTO Attribute (Attribute) VALUES ('Pnumber');
INSERT INTO Attribute (Attribute) VALUES ('Plocation');
INSERT INTO Attribute (Attribute) VALUES ('Dnum');
GO
INSERT INTO Value (Value) VALUES ('Computerization');
INSERT INTO Value (Value) VALUES ('10');
INSERT INTO Value (Value) VALUES ('Stafford');
--INSERT INTO Value (Value) VALUES ('4');
INSERT INTO Value (Value) VALUES ('Newbenefits');
INSERT INTO Value (Value) VALUES ('30');
--INSERT INTO Value (Value) VALUES ('Stafford');
--INSERT INTO Value (Value) VALUES ('4');
GO
INSERT INTO EntityAttributeValue (EntityID, AttributeID, SurrogateKeyID, ValueID)
    SELECT e.EntityID, a.AttributeID, 1, v.ValueID
        FROM Entity AS e, Attribute AS a, Value AS v
    WHERE e.Entity = 'PROJECT'
        AND (
            (a.Attribute = 'Pname' AND v.Value = 'Computerization')
            OR (a.Attribute = 'Pnumber' AND v.Value = '10')
            OR (a.Attribute = 'Plocation' AND v.Value = 'Stafford')
            OR (a.Attribute = 'Dnum' AND v.Value = '4')
        );
GO
INSERT INTO EntityAttributeValue (EntityID, AttributeID, SurrogateKeyID, ValueID)
    SELECT e.EntityID, a.AttributeID, 2, v.ValueID
        FROM Entity AS e, Attribute AS a, Value AS v
    WHERE e.Entity = 'PROJECT'
        AND (
            (a.Attribute = 'Pname' AND v.Value = 'Computerization')
            OR (a.Attribute = 'Pnumber' AND v.Value = '30')
            OR (a.Attribute = 'Plocation' AND v.Value = 'Stafford')
            OR (a.Attribute = 'Dnum' AND v.Value = '4')
        );
GO

SELECT
    Pnumber,
    Dnum,
    Fname
    FROM (
        SELECT Pnumber, Plocation, Dnum FROM (
            SELECT e.Entity, a.Attribute, eav.SurrogateKeyID, v.Value
                FROM EntityAttributeValue AS eav
                INNER JOIN Entity AS e
                ON eav.EntityID = e.EntityID
                INNER JOIN Attribute AS a
                ON eav.AttributeID = a.AttributeID
                INNER JOIN Value AS v
                ON eav.ValueID = v.ValueID
            WHERE e.Entity = 'PROJECT'
            AND a.Attribute IN ('Pnumber', 'Plocation', 'Dnum')
            ) AS p
            PIVOT (
                MAX(p.Value) FOR p.Attribute IN (
                    [Pnumber], [Plocation], [Dnum]
                )
            ) AS pvt
    ) AS PROJECT
    INNER JOIN (
        SELECT Dnumber, Mgr_ssn FROM (
            SELECT e.Entity, a.Attribute, eav.SurrogateKeyID, v.Value
                FROM EntityAttributeValue AS eav
                INNER JOIN Entity AS e
                ON eav.EntityID = e.EntityID
                INNER JOIN Attribute AS a
                ON eav.AttributeID = a.AttributeID
                INNER JOIN Value AS v
                ON eav.ValueID = v.ValueID
            WHERE e.Entity = 'DEPARTMENT'
            AND a.Attribute IN ('Dnumber', 'Mgr_ssn')
            ) AS p
            PIVOT (
                MAX(p.Value) FOR p.Attribute IN (
                    [Dnumber], [Mgr_ssn]
                )
            ) AS pvt
    ) AS DEPARTMENT
    ON Dnum = Dnumber
    INNER JOIN (
        SELECT Fname, Ssn FROM (
            SELECT e.Entity, a.Attribute, eav.SurrogateKeyID, v.Value
                FROM EntityAttributeValue AS eav
                INNER JOIN Entity AS e
                ON eav.EntityID = e.EntityID
                INNER JOIN Attribute AS a
                ON eav.AttributeID = a.AttributeID
                INNER JOIN Value AS v
                ON eav.ValueID = v.ValueID
            WHERE e.Entity = 'EMPLOYEE'
            AND a.Attribute IN ('Fname', 'Ssn')
            ) AS p
            PIVOT (
                MAX(p.Value) FOR p.Attribute IN (
                    [Fname], [Ssn]
                )
            ) AS pvt
    ) AS EMPLOYEE
    ON Mgr_ssn = Ssn
WHERE Plocation = 'Stafford';
GO
