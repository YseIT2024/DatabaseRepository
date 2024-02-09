-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE reservation.spDeleteplitBillGuestOrCompany
(
@ReservationID int,
@GuestIdOrCompanyId int,
@GuestType varchar(50)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @IsSuccess bit = 0;
	DECLARE @Message varchar(max) = '';


    delete [guest].[OTAServices] where ReservationID=@ReservationID and GuestID_CompanyID=@GuestIdOrCompanyId and [Type]=@GuestType


	SET @Message = 'Saved Success' ;
	SET @IsSuccess = 1; 

	SELECT @IsSuccess AS [IsSuccess], @Message AS [Message]

END
