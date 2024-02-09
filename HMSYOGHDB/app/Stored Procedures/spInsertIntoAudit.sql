
CREATE PROCEDURE [app].[spInsertIntoAudit]
(	    
    @Description varchar(max)
)
AS
BEGIN
	INSERT INTO [app].[Audit]      
	([Description], [DateTime])
	VALUES(@Description, GETDATE())
END
