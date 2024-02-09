-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE Lock.CreateCardLog
(
	@CardState nvarchar(150),
	@UserId int,
	@RoomNumber int,
	@ErrorMessage nvarchar(max)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @IsSuccess int=0;
	declare @Message varchar(100);

    -- Insert statements for procedure here
    INSERT INTO [Lock].[CardLog] ([RoomNumber],[CardStatus],[UserId],[Datetime],[Message])VALUES(@RoomNumber,@CardState,@UserId,GETDATE(),@ErrorMessage);

	set @IsSuccess=1
	set @Message='Log Created Successfully';

Select @IsSuccess As IsSuccess, @Message As Message
END
