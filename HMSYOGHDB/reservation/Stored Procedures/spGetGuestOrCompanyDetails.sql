-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [reservation].[spGetGuestOrCompanyDetails]
(
	@DrawerID INT,
	@ReservationID INT =0
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @CompanyID int=0;
	DECLARE @GuestTypeID int =1;
	DECLARE @CompanyTypeID int=0;

	SET @CompanyID=(Select CompanyTypeID from reservation.Reservation where ReservationID=@ReservationID)
	SET @CompanyTypeID=(Select ReservationTypeID from reservation.Reservation where ReservationID=@ReservationID)


    if(exists(select * from [guest].[OTAServices] where ReservationID=@ReservationID))
	 begin
		select distinct  
		GuestID_CompanyID as GuestIDOrCompanyID,
		case 
		when [Type]='Guest' then (select FirstName from [guest].[vwGuestDetails] where GuestID=GuestID_CompanyID)  
		when [Type]='Company' then (select CompanyName from guest.GuestCompany where CompanyID=GuestID_CompanyID)  
		else '' end as NameOrCompany,
		case 
		when [Type]='Guest' then 1
		when [Type]='Company' then (select ReservationTypeId from guest.GuestCompany where CompanyID=GuestID_CompanyID)  
		else '' end as GuestOrCompanyTypeID
		from [guest].[OTAServices] where ReservationID=@ReservationID 
	 end
	 else
	 begin
		select GuestID as GuestIDOrCompanyID , FirstName as NameOrCompany, @GuestTypeID as GuestOrCompanyTypeID   from [reservation].[ReservationGuestMates] where ReservationID=@ReservationID
		union all
		select CompanyID as GuestIDOrCompanyID ,CompanyName  as NameOrCompany, @CompanyTypeID as GuestOrCompanyTypeID from guest.GuestCompany where CompanyID=@CompanyID
	 end

END
