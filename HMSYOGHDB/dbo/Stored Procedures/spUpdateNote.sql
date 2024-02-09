
CREATE PROCEDURE [dbo].[spUpdateNote]
(
	@NoteID int,
    @Note varchar(max),
	@LocationID int,
	@UserID int
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @IsSuccess bit = 0;

	UPDATE [dbo].[Notes]
	SET [Notes] = @Note
	WHERE NoteID = @NoteID

	SET @IsSuccess = 1;

	SELECT @IsSuccess [IsSuccess]
END
