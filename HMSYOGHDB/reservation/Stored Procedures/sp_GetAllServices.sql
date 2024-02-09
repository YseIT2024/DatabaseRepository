
CREATE PROCEDURE [reservation].[sp_GetAllServices]-- 0,0,10415

@userId int=0,   
@LocationID int=0,
@ReservationID int
			
AS 
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON 

	SELECT  gc.CompanyName,gc.CompanyID,gc.ReservationTypeID,rr.ReservationID,rr.GuestID FROM [guest].[GuestCompany] gc 
		INNER JOIN reservation.Reservation rr on gc.ReservationTypeId=rr.ReservationTypeID and gc.CompanyID=rr.CompanyTypeID
		where ReservationID=@ReservationID

--SELECT ROW_NUMBER() OVER (ORDER BY st.ServiceTypeID) AS SerialNo, st.ServiceTypeID,st.ServiceName
--FROM [service].[Type] st
IF EXISTS (SELECT 1 FROM [guest].[OTAServices] WHERE ReservationID = @ReservationID)
BEGIN
    -- Select data when ReservationID exists
   	SELECT 
    ROW_NUMBER() OVER (ORDER BY st.ServiceTypeID) AS SerialNo, 
    st.ServiceTypeID, 
    st.ServiceName, 
    --gs.ServicePercent AS ServicePercent
	CAST(gs.ServicePercent AS INT) AS ServicePercent
FROM 
    [service].[Type] st
    INNER JOIN [guest].[OTAServices] gs ON st.ServiceTypeID = gs.ServiceID 
WHERE 
    ReservationID = @ReservationID AND st.IsActive = 1 AND gs.ReservationTypeID <= 0;

END
ELSE
BEGIN

DECLARE @ServicePercent INT;
    -- Select data when ReservationID doesn't exist
    SELECT ROW_NUMBER() OVER (ORDER BY st.ServiceTypeID) AS SerialNo, st.ServiceTypeID, st.ServiceName,
	--ISNULL(@ServicePercent,'') as ServicePercent
	COALESCE(CONVERT(VARCHAR(10), @ServicePercent), '') AS ServicePercent
    FROM [service].[Type] st
	where IsActive = 1;
END;




		

END	