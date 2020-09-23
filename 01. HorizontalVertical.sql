-- Vertical vs Horizontal
IF OBJECT_ID('dbo.R1', 'U') IS NOT NULL
	DROP TABLE dbo.R1;
IF OBJECT_ID('dbo.R2', 'U') IS NOT NULL
	DROP TABLE dbo.R2;
GO

DECLARE @v_Query NVARCHAR(MAX);
DECLARE @v_Count INT;
DECLARE @v_MaxCount INT = 1024;

SET @v_Count = 1;
SET @v_Query = 'CREATE TABLE dbo.R1 (';
WHILE @v_Count <= @v_MaxCount
BEGIN
	SET @v_Query = @v_Query + '[' + CAST(@v_Count AS VARCHAR) + '] INT NULL,'
	SET @v_Count = @v_Count + 1;
END;
SET @v_Query = @v_Query + ');';
EXECUTE sp_executesql @v_Query;
SET @v_Query = 'SELECT * INTO dbo.R2 FROM dbo.R1;';
EXECUTE sp_executesql @v_Query;

SET @v_Count = 1;
WHILE @v_Count <= @v_MaxCount
BEGIN
	SET @v_Query = 'INSERT INTO dbo.R1 ([' + CAST(@v_Count AS VARCHAR) + ']) VALUES (' + CAST(@v_Count AS VARCHAR) + ');';
	SET @v_Query = @v_Query + 'INSERT INTO dbo.R2 ([' + CAST(@v_Count AS VARCHAR) + ']) VALUES (' + CAST(@v_Count AS VARCHAR) + ');';
	EXECUTE sp_executesql @v_Query;
	SET @v_Count = @v_Count + 1;
END;
GO
CREATE INDEX IX_R2 ON dbo.R2 ([512]);
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT [512] FROM dbo.R1;
SELECT * FROM dbo.R1 WHERE [512] = 512;

SELECT [512] FROM dbo.R2;
SELECT * FROM dbo.R2 WHERE [512] = 512;

-- Join
IF OBJECT_ID('dbo.R1', 'U') IS NOT NULL
	DROP TABLE dbo.R1;
IF OBJECT_ID('dbo.R2', 'U') IS NOT NULL
	DROP TABLE dbo.R2;
GO

CREATE TABLE dbo.R1 (KeyCol BIGINT IDENTITY PRIMARY KEY, ValueCol BIGINT NULL);
CREATE TABLE dbo.R2 (KeyCol BIGINT IDENTITY PRIMARY KEY, ValueCol BIGINT NULL);
GO

DECLARE @v_MaxCount INT;

SET @v_MaxCount = 1000;
WITH SEQ (Number) AS (
	SELECT 1 AS Number
	UNION ALL
	SELECT Number + 1
		FROM SEQ
	WHERE Number < @v_MaxCount
)
INSERT INTO dbo.R1 (ValueCol) SELECT Number FROM SEQ OPTION (MAXRECURSION 1000);
INSERT INTO dbo.R2 (ValueCol)
	SELECT ROW_NUMBER() OVER(ORDER BY t1.KeyCol) AS Number
		FROM dbo.R1 AS t1
		CROSS JOIN dbo.R1 AS t2;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
	FROM dbo.R1
	INNER LOOP JOIN dbo.R2
	ON R1.KeyCol = R2.KeyCol
	OPTION (MAXDOP 1);

SELECT *
	FROM dbo.R2
	INNER LOOP JOIN dbo.R1
	ON R2.KeyCol = R1.KeyCol
	OPTION (MAXDOP 1);

SELECT *
	FROM dbo.R1
	INNER MERGE JOIN dbo.R2
	ON R1.KeyCol = R2.KeyCol
	OPTION (MAXDOP 1);

SELECT *
	FROM dbo.R2
	INNER MERGE JOIN dbo.R1
	ON R2.KeyCol = R1.KeyCol
	OPTION (MAXDOP 1);

SELECT *
	FROM dbo.R1
	INNER HASH JOIN dbo.R2
	ON R1.KeyCol = R2.KeyCol
	OPTION (MAXDOP 1);

SELECT *
	FROM dbo.R2
	INNER HASH JOIN dbo.R1
	ON R2.KeyCol = R1.KeyCol
	OPTION (MAXDOP 1);

SELECT *
    FROM dbo.R1
    INNER JOIN (
        SELECT
            KeyCol % 10 AS Md
            FROM dbo.R2
        GROUP BY KeyCol % 10
    ) AS t
    ON R1.KeyCol % 10 = Md
ORDER BY R1.KeyCol;

SELECT *
    FROM dbo.R1
    INNER JOIN (
        SELECT
            KeyCol % 10 AS Md
            FROM dbo.R2
        WHERE KeyCol <= 1000
        GROUP BY KeyCol % 10
    ) AS t
    ON R1.KeyCol % 10 = Md
ORDER BY R1.KeyCol;
