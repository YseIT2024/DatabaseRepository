-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [reservation].[spCreateSplitBillGuestOrCompany]-- 6344,83,'Guest'
(
@ReservationID int,
@CompanyOrGestTypeID int,
@GuestType varchar(50)
)
AS
BEGIN

DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	if(not exists(select * from [guest].[OTAServices] where ReservationID=@ReservationID and GuestID_CompanyID=@CompanyOrGestTypeID and [Type]=@GuestType))
	begin
	INSERT INTO [guest].[OTAServices] (ReservationID, GuestID_CompanyID, ServiceID, ServicePercent, ReservationTypeID,[Type])
			(select @ReservationID, @CompanyOrGestTypeID,ServiceTypeID , 0, 0,@GuestType
			FROM Service.Type WHERE IsActive = 1);

			SET @Message = 'Saved Success' ;
			SET @IsSuccess = 1; 
			end
			else
			begin
			SET @Message = 'Guest or Company Name Already Exits';
			SET @IsSuccess = 0;
			end
	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]
END
