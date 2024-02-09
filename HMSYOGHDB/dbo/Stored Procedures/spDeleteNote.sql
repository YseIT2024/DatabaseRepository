
CREATE PROCEDURE [dbo].[spDeleteNote]
(
	@NoteID int,
	@LocationID int,
	@UserID int
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @IsSuccess bit = 0;

	DELETE FROM [dbo].[Notes] WHERE NoteID = @NoteID;

	SET @IsSuccess = 1;

	SELECT @IsSuccess [IsSuccess]
END
