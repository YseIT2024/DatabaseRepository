CREATE PROC [Housekeeping].[usp_Pickupanddrop_Select]--null, null, 1, '2023-01-01', '2023-01-01'
	@pickupdropid int= null,
	@ReservationID int= null,
	@UserId int,
	@FromDate datetime=null,
	@Todate datetime=null	 
AS 
BEGIN
    SET NOCOUNT ON
   if(@FromDate!='')  
	begin
		  SELECT Distinct PD.pickupdropid,pd.Type,PD.PickupdropDate,PD.PickupDropAddress,
		  CASE 
		  WHEN pd.Transport=1 THEN 'In-House' ELSE 'Outside' END as Transport,
		  --pd.VehicleType,
		  CASE 
		  WHEN pd.VehicleType =1 THEN 'Sedan'  
		  WHEN pd.VehicleType =2 THEN 'SUV'  
		  WHEN pd.VehicleType =3 THEN 'Station Wagon' 
		  WHEN pd.VehicleType =4 THEN 'Hatchback'
		  END AS VehicleType,

		  PD.ReservationID,pd.TobeCharge,
		  --CASE WHEN pd.Staus ='' THEN 1 ELSE  ISNULL(pd.Staus,1) END AS StatusName,
		  CASE 
		  WHEN LTRIM(pd.Staus) =1 THEN 'Pending'  
		  WHEN pd.Staus =2 THEN 'Completed'  
		  WHEN pd.Staus =3 THEN 'Cancelled' 
		  --ELSE  ISNULL(pd.Staus,1) 
		  END AS StatusName,

		   RR.[GuestID],RR.FolioNumber,
		  [Title] +' '+ [FirstName] + (CASE When LEN([LastName]) > 0 THEN ' '+ [LastName] ELSE '' END) as [Name],
		  (CASE WHEN LEN([Street]) > 0 THEN [Street] +', ' ELSE '' END) + (CASE When LEN([City]) > 0 THEN [City] +', ' ELSE '' END) 
			+ (CASE WHEN LEN([State]) > 0 THEN [State] +', ' ELSE '' END)  + [CountryName] as [Address],
			isnull([Email],'')[Email]
			,CA.[PhoneNumber],ISNull([complementary],0) as complementary,PD.[FlightDetails],PD.[Amount],
			RR.ExpectedCheckIn,RR.ExpectedCheckOut,PD.PickUpDropTime,
			(select [reservation].[fnGetReserveredRoom](rr.ReservationID)) as RoomNos,(case when AT.AccountTypeID=97 then AT.Amount else 0 end) as CashPaid
			FROM [Housekeeping].[PickupAndDrop] PD
	
			INNER JOIN [HMSYOGH].[reservation].[Reservation] RR on PD.ReservationID=RR.ReservationID
			inner join guest.Guest GG on GG.GuestID=RR.GuestID
			inner join contact.Details CD on CD.ContactID=GG.ContactID
			inner join person.Title PT on PT.TitleID=CD.TitleID
			inner join contact.Address CA on CA.ContactID=CD.ContactID
			inner join general.Country GC on GC.CountryID=CA.CountryID 
			 Left Join account.[Transaction] AT on PD.pickupdropid=AT.ReferenceNo
			where CAST(pd.PickupdropDate AS DATE) BETWEEN @FromDate AND  @Todate  Order by PD.pickupdropid desc 
    END
	
	else 
	begin
	  
	     SELECT Distinct PD.pickupdropid,pd.Type,PD.PickupdropDate,PD.PickupDropAddress,
		  CASE 
		  WHEN pd.Transport=1 THEN 'In-House' ELSE 'Outside' END as Transport,
		  --pd.VehicleType,
		  CASE 
		  WHEN pd.VehicleType =1 THEN 'Sedan'  
		  WHEN pd.VehicleType =2 THEN 'SUV'  
		  WHEN pd.VehicleType =3 THEN 'Station Wagon' 
		  WHEN pd.VehicleType =4 THEN 'Hatchback'
		  END AS VehicleType,

		  PD.ReservationID,pd.TobeCharge,
		  --CASE WHEN pd.Staus ='' THEN 1 ELSE  ISNULL(pd.Staus,1) END AS StatusName,
		  CASE 
		  WHEN LTRIM(pd.Staus) =1 THEN 'Pending'  
		  WHEN pd.Staus =2 THEN 'Completed'  
		  WHEN pd.Staus =3 THEN 'Cancelled' 
		  --ELSE  ISNULL(pd.Staus,1) 
		  END AS StatusName,

		   RR.[GuestID],RR.FolioNumber,
		  [Title] +' '+ [FirstName] + (CASE When LEN([LastName]) > 0 THEN ' '+ [LastName] ELSE '' END) as [Name],
		  (CASE WHEN LEN([Street]) > 0 THEN [Street] +', ' ELSE '' END) + (CASE When LEN([City]) > 0 THEN [City] +', ' ELSE '' END) 
			+ (CASE WHEN LEN([State]) > 0 THEN [State] +', ' ELSE '' END)  + [CountryName] as [Address],
			isnull([Email],'')[Email]
			,CA.[PhoneNumber],ISNull([complementary],0) as complementary,[FlightDetails],PD.[Amount],RR.ExpectedCheckIn,RR.ExpectedCheckOut
			,PD.PickUpDropTime,(select [reservation].[fnGetReserveredRoom](rr.ReservationID)) as RoomNos,(case when AT.AccountTypeID=97 then AT.Amount else 0 end) as CashPaid
			FROM [Housekeeping].[PickupAndDrop] PD
	
			Left JOIN [reservation].[Reservation] RR on PD.ReservationID=RR.ReservationID
			inner join guest.Guest GG on GG.GuestID=RR.GuestID
			inner join contact.Details CD on CD.ContactID=GG.ContactID
			inner join person.Title PT on PT.TitleID=CD.TitleID
			inner join contact.Address CA on CA.ContactID=CD.ContactID
			Left Join account.[Transaction] AT on PD.pickupdropid=AT.ReferenceNo
			inner join general.Country GC on GC.CountryID=CA.CountryID where PD.Staus=1 Order by PD.pickupdropid desc
	end
END	


