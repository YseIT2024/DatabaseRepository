
CREATE PROCEDURE [dbo].[spAddNewNote]
(
	@LocationID int,
	@UserID int
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @IsSuccess bit = 0;

	INSERT INTO [dbo].[Notes]
	([LocationID],[UserID],[Notes],[DateTime],[IsEnabled])
	VALUES(@LocationID,@UserID,'',GETDATE(),1)

	SET @IsSuccess = 1;

	SELECT @IsSuccess [IsSuccess]
END
