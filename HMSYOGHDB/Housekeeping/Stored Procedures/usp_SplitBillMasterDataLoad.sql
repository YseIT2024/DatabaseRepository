------------------------------------------------------------------------------------------------------------------------------------------------------------


CREATE PROC [Housekeeping].[usp_SplitBillMasterDataLoad]			
			@userId int=NULL,   
			@LocationID int=NULL,
			@ReservationID int =null
AS 
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON

	declare @IsCompanyType int ;
	SELECT @IsCompanyType = (SELECT case when CompanyTypeID > 0 Then 1 Else 0 End  as IsCompanyType from [reservation].[Reservation] where ReservationID = @ReservationID);
    
        
if(@IsCompanyType >0)
BEGIN
	--select RG.GuestMatesID as ID,  RG.FirstName +' '+ COALESCE(RG.LastName,'') as [Name], 'Guest' as [Type] from 
	--[reservation].[Reservation] RS 
	--Inner join [reservation].[ReservationGuestMates] RG On RS.ReservationID = RG.ReservationID 
	--where RS.ReservationID = @ReservationID

	--	select RG.GuestID as ID,  cd.FirstName+' '+ COALESCE(cd.LastName,'') as [Name], 'Company' as [Type] from 
	--[reservation].[Reservation] RS 
	--Inner join guest.Guest RG On RS.GuestID = RG.GuestID 
	--inner join contact.Details  cd on RG.ContactID=cd.ContactID
	--where RS.ReservationID = @ReservationID

	--Union

	--Select GC.CompanyID as ID, GC.CompanyName as [Name], 'Company' as [Type] from [reservation].[Reservation] RS 
	--inner join [guest].[GuestCompany] GC on RS.CompanyTypeID = GC.CompanyID
	--where RS.ReservationID = @ReservationID


		select RG.GuestID as ID,  cd.FirstName+' '+ COALESCE(cd.LastName,'') as [Name], 'Guest' as [Type] from  
			[reservation].[Reservation] RS 
			Inner Join  [reservation].[ReservationGuestMates] RGM on RS.ReservationID=RGM.ReservationID
			Inner join  guest.Guest RG On RG.GuestID = RGM.GuestID 
			inner join contact.Details  cd on RG.ContactID=cd.ContactID
			where RS.ReservationID = @ReservationID
			
			Union all

			Select GC.CompanyID as ID, GC.CompanyName as [Name], 'Company' as [Type] from [reservation].[Reservation] RS 
			inner join [guest].[GuestCompany] GC on RS.CompanyTypeID = GC.CompanyID
			where RS.ReservationID = @ReservationID

	END
	
Else
	BEGIN

	--select RG.GuestMatesID as ID,  RG.FirstName +' '+ COALESCE(RG.LastName,'') as [Name], 'Guest' as [Type] from 
	--[reservation].[Reservation] RS 
	--Inner join [reservation].[ReservationGuestMates] RG On RS.ReservationID = RG.ReservationID 
	--where RS.ReservationID = @ReservationID


	--select RG.GuestID as ID,  cd.FirstName+' '+ COALESCE(cd.LastName,'') as [Name], 'Guest' as [Type] from 
	--[reservation].[Reservation] RS 
	--Inner join guest.Guest RG On RS.GuestID = RG.GuestID 
	--inner join contact.Details  cd on RG.ContactID=cd.ContactID
	--where RS.ReservationID = @ReservationID

			select RG.GuestID as ID,  cd.FirstName+' '+ COALESCE(cd.LastName,'') as [Name], 'Guest' as [Type] from  
			[reservation].[Reservation] RS 
			Inner Join  [reservation].[ReservationGuestMates] RGM on RS.ReservationID=RGM.ReservationID
			Inner join  guest.Guest RG On RG.GuestID = RGM.GuestID 
			inner join contact.Details  cd on RG.ContactID=cd.ContactID
			where RS.ReservationID = @ReservationID

	END

END	

