
CREATE PROCEDURE [dbo].[spDisableNote]
(
	@NoteID int,
	@LocationID int,
	@UserID int
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @IsSuccess bit = 0;

	UPDATE [dbo].[Notes]
	SET IsEnabled = 0
	WHERE NoteID = @NoteID

	SET @IsSuccess = 1;

	SELECT @IsSuccess [IsSuccess]
END
