CREATE TABLE GenericTree (
    NodeID INT NOT NULL,
    ParentNodeID INT NULL,
    CONSTRAINT PK_GenericTree PRIMARY KEY (NodeID),
    CONSTRAINT FK_GenericTree_Parent FOREIGN KEY (ParentNodeID) REFERENCES GenericTree (NodeID)
);
GO

INSERT INTO GenericTree (NodeID, ParentNodeID) VALUES (1, NULL);
INSERT INTO GenericTree (NodeID, ParentNodeID) VALUES (2, 1);
INSERT INTO GenericTree (NodeID, ParentNodeID) VALUES (3, 1);
INSERT INTO GenericTree (NodeID, ParentNodeID) VALUES (4, 1);
INSERT INTO GenericTree (NodeID, ParentNodeID) VALUES (5, 2);
INSERT INTO GenericTree (NodeID, ParentNodeID) VALUES (6, 2);
INSERT INTO GenericTree (NodeID, ParentNodeID) VALUES (7, 3);
INSERT INTO GenericTree (NodeID, ParentNodeID) VALUES (8, 3);
INSERT INTO GenericTree (NodeID, ParentNodeID) VALUES (9, 3);
INSERT INTO GenericTree (NodeID, ParentNodeID) VALUES (10, 6);
INSERT INTO GenericTree (NodeID, ParentNodeID) VALUES (11, 6);
INSERT INTO GenericTree (NodeID, ParentNodeID) VALUES (12, 6);
INSERT INTO GenericTree (NodeID, ParentNodeID) VALUES (13, 6);
INSERT INTO GenericTree (NodeID, ParentNodeID) VALUES (14, 7);
INSERT INTO GenericTree (NodeID, ParentNodeID) VALUES (15, 8);
INSERT INTO GenericTree (NodeID, ParentNodeID) VALUES (16, 8);
INSERT INTO GenericTree (NodeID, ParentNodeID) VALUES (17, 11);
INSERT INTO GenericTree (NodeID, ParentNodeID) VALUES (18, 11);
INSERT INTO GenericTree (NodeID, ParentNodeID) VALUES (19, 16);
INSERT INTO GenericTree (NodeID, ParentNodeID) VALUES (20, 16);
GO

CREATE PROCEDURE usp_DFS_PreOrder
@NodeID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    /*
        EXECUTE usp_DFS_PreOrder;
    */

    DECLARE @v_NodeID INT;
    DECLARE c_CUR CURSOR FAST_FORWARD LOCAL FOR
        SELECT NodeID
            FROM GenericTree
        WHERE ISNULL(ParentNodeID, 0) = ISNULL(@NodeID, 0)
        ORDER BY NodeID;
    OPEN c_CUR;
    FETCH FROM c_CUR INTO @v_NodeID;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT @v_NodeID;
        EXECUTE usp_DFS_PreOrder @v_NodeID;
        FETCH FROM c_CUR INTO @v_NodeID;
    END;
    CLOSE c_CUR;
    DEALLOCATE c_CUR;
END;
GO
