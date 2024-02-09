-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE reservation.spGetReservationSptitInvoiceList
(
	@ReservationID int
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select 
	distinct ReservationID,
	(select top(1) FolioNumber from reservation.Reservation where ReservationID=@ReservationID) as  FolioNumber,
	GuestID_CompanyID,
	case when [Type]='Company' then (select top(1) CompanyName from [guest].[GuestCompany] g where g.CompanyID=o.GuestID_CompanyID)
	when [Type] ='Guest' then (select  top(1) CONCAT(FirstName, ' ',LastName)  from  [reservation].[ReservationGuestMates] where GuestID=o.GuestID_CompanyID)  
	else '' end GuestName,
	[Type] as GuesType
	from [guest].[OTAServices] o where o.ReservationID=@ReservationID

END
