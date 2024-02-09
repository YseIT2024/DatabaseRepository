
CREATE PROCEDURE [reservation].[spAutoChangeCheckInDateForFlexibleGuest]--1,1
(	
	@LocationID int,
	@UserID int
)
AS
BEGIN
	DECLARE @CurrentDate DATE;
	DECLARE @ExpectedCheckIn DATETIME;
	DECLARE @ExpectedCheckOut DATE;
	DECLARE @temp table (IDs int, RowID int, ExpectedCheckOut Date);
	DECLARE @ReservationID int;
	DECLARE @Nights int;
	DECLARE @Count int;
	DECLARE @Init int;

	BEGIN TRY	
		SET @CurrentDate = GETDATE()
		SET @ExpectedCheckIn = (SELECT CONVERT(DATETIME, (FORMAT(@CurrentDate,'yyyy-MM-dd') +' '+ (SELECT [reservation].[fnGetStandardCheckInTime]()))));		
	END TRY  
	BEGIN CATCH    
		
		---------------------------- Insert into activity log---------------	
		DECLARE @Act VARCHAR(MAX) = (SELECT app.fngeterrorinfo());		
		EXEC [app].[spInsertActivityLog]3,@LocationID,@Act,@UserID	
	END CATCH;  
END




