-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [reservation].[sp_GetReservationAllSevice] --6355,75,1
(
@ReservationID int,
@userId int=0,   
@LocationID int=0
)
AS
BEGIN

	SET NOCOUNT ON;

	    SELECT ROW_NUMBER() OVER (ORDER BY st.ServiceTypeID) AS SerialNo, st.ServiceTypeID, st.ServiceName 
		 
		FROM [service].[Type] st
		where IsActive = 1;
	

		--select RG.GuestID as ID,  cd.FirstName+' '+ COALESCE(cd.LastName,'') as [Name], 'Guest' as [Type],
		--convert(nvarchar(50),RG.GuestID) +'-'+cd.FirstName+'-'+ COALESCE(cd.LastName,'') + '-Guest' as ColumnName
		--from [reservation].[Reservation] RS 
		--Inner Join  [reservation].[ReservationGuestMates] RGM on RS.ReservationID=RGM.ReservationID
		--Inner join  guest.Guest RG On RG.GuestID = RGM.GuestID 
		--inner join contact.Details  cd on RG.ContactID=cd.ContactID
		--where RS.ReservationID = @ReservationID
			
		--Union all

		--Select GC.CompanyID as ID, GC.CompanyName as [Name], 'Company' as [Type], 
		--convert(nvarchar(50),GC.CompanyID )+'-'+GC.CompanyName +'-'+ 'Company'  as ColumnName
		--from [reservation].[Reservation] RS 
		--inner join [guest].[GuestCompany] GC on RS.CompanyTypeID = GC.CompanyID
		--where RS.ReservationID = @ReservationID

		select distinct RG.GuestID as ID,  cd.FirstName+' '+ COALESCE(cd.LastName,'') as [Name], 'Guest' as [Type],
		convert(nvarchar(50),RG.GuestID) +'-'+cd.FirstName+'-'+ COALESCE(cd.LastName,'') + '-Guest' as ColumnName
		from guest.OTAServices RS 
		--Inner Join  [reservation].[ReservationGuestMates] RGM on RS.ReservationID=RGM.ReservationID
		Inner join  guest.Guest RG On RG.GuestID =RS.GuestID_CompanyID 
		inner join contact.Details  cd on RG.ContactID=cd.ContactID
		where RS.ReservationID = @ReservationID and [Type]='Guest'
			
		Union all

		Select distinct GC.CompanyID as ID, GC.CompanyName as [Name], 'Company' as [Type], 
		convert(nvarchar(50),GC.CompanyID )+'-'+GC.CompanyName +'-'+ 'Company'  as ColumnName
		from guest.OTAServices RS 
		inner join [guest].[GuestCompany] GC on RS.GuestID_CompanyID = GC.CompanyID
		where RS.ReservationID = @ReservationID and [Type]='Company'
		
		select ReservationID,ServiceID,ServicePercent,[Type],GuestID_CompanyID	from guest.OTAServices where ReservationID=@ReservationID

END





