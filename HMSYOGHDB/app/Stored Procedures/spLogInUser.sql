

CREATE PROCEDURE [app].[spLogInUser] --'3','3',1
(
	@UserName varchar(50),
	@Password varchar(30),
	@DrawerID INT = 0 	
)
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @UserID int;	
	DECLARE @LocationName varchar(50);
	DECLARE @LocationCode varchar(5);
	DECLARE @MainCurrencyID int;
	DECLARE @LocalCurrencyID int=0;
	DECLARE @LocationID int;	
	DECLARE @AccountingDateID int; 
	DECLARE @AccountingDate date; 
	DECLARE @CountryID int;	
	DECLARE @Drawer varchar(50);
	DECLARE @MainCurrencyCode varchar(5);
	DECLARE @MainCurrencySymbol varchar(3);
	DECLARE @LocalCurrencyCode varchar(5)='';
	DECLARE @LocalCurrencySymbol varchar(3)='';
	DECLARE @RateCurrencyID int=0;
	DECLARE @RateCurrencyCode varchar(5)='';
	DECLARE @RateCurrencySymbol varchar(3)='';
	DECLARE @UserShiftID int;
	DECLARE @DrawerCount int;
	DECLARE @ReportLogo varchar(100);
	DECLARE @EnableImportCustomerFromCMS bit = 0;
	DECLARE @ConnectionStringCMS varchar(250);
	DECLARE @ConnectionStringForFundTransfer varchar(250);
	DECLARE @CMSCustomerImagePath varchar(150);
	DECLARE @ServiceCurrencyID int;
	DECLARE @HMSCDNDocPath varchar(250);
	DECLARE @HMSCDNImagePath varchar(250);
	DECLARE @HMSCDNUserID varchar(25);
	DECLARE @HMSCDNPassword varchar(25);
	DECLARE @UserManual varchar(30)='';
	DECLARE @AddressLine1 varchar(500)='';
	DECLARE @AddressLine2 varchar(500)='';
	DECLARE @AddressLine3 varchar(500)='';
	DECLARE @AddressLine4 varchar(500)='';
	DECLARE @AddressLine5 varchar(500)='';
	DECLARE @AddressLine6 varchar(500)='';


	-----------Self Host Path, Added By Vasanth------------
	DECLARE @SelfHostAPIAppPath varchar(500)=(select top(1)ConfigValue from [general].[Config] where ConfigType=4 and IsActive=1);


	------------------------Vivevek Start---------------
	DECLARE @FromEmailID  varchar(200);
	DECLARE @FromEmailPswd  varchar(200);
	DECLARE @FromEmailDisplayName varchar(300);
	DECLARE @EmailHost varchar(200);
	DECLARE @EmailPort int;
	------------------------Vivevek End---------------

	------------------------Vasanth Start---------------
	DECLARE @CCEmailID  varchar(200)=null;
	DECLARE @BCCEmailID  varchar(200)=null;
	------------------------Vasanth End---------------
	DECLARE @MinCheckInDate date;
	set @MinCheckInDate=getdate()-30

	BEGIN TRY
		Set @UserID = 
		(
			SELECT UserID From  [app].[User] 
			Where [UserName] = @UserName COLLATE SQL_Latin1_General_CP1_CS_AS
			AND [Password] = @Password COLLATE SQL_Latin1_General_CP1_CS_AS
		);		
	
		IF(@DrawerID > 0)
			BEGIN
				Set @LocationID = (SELECT LocationID FROM  app.Drawer WHERE DrawerID = @DrawerID);
			END
		ELSE
			BEGIN
				Set @DrawerID = (SELECT Min(DrawerID) FROM  app.UserDrawer WHERE UserID = @UserID AND IsPrimary = 1);
				Set @LocationID = (SELECT LocationID FROM  app.UserAndLocation WHERE UserID = @UserID AND IsPrimary = 1);
			END

		IF (@UserID IS NULL OR @UserID = 0 OR @UserID < 0)
		Begin
			SELECT -1 [Status] -- User Name or Password did't match.
			Return
		End 
		IF NOT EXISTS(SELECT UserID FROM  [app].[User] WHERE UserID = @UserID AND IsActive = 1 )
		BEGIN
			SELECT -2 [Status] -- In-Active User.
			Return
		END
		IF NOT EXISTS(SELECT UserAndLocationID From  app.UserAndLocation WHERE UserID = @UserID AND LocationID = @LocationID)
		Begin
			SELECT -3 [Status] -- User has not access to this location.
			Return
		End

		IF NOT EXISTS(SELECT UserRightID FROM  app.[UserRight] WHERE UserID = @UserID) 
		Begin
			IF NOT EXISTS(SELECT Distinct RoleID FROM  app.[UserRoleObjects] WHERE RoleID IN (SELECT Distinct(RoleID) FROM  app.UsersAndRoles WHERE UserID = @UserID))
			Begin
				SELECT -4 [Status] -- User do not have any access.
				Return
			End
		End
		
		Set @Drawer = (SELECT Drawer FROM  app.Drawer WHERE DrawerID = @DrawerID);
		Set @AccountingDateID =  (SELECT AccountingDateId FROM account.AccountingDates WHERE DrawerID = @DrawerID AND IsActive = 1 );
		Set @AccountingDate = (SELECT AccountingDate FROM account.AccountingDates WHERE AccountingDateId = @AccountingDateID );

		SET @UserShiftID = 1;

		SET @HMSCDNDocPath = (SELECT [Value] FROM  app.Parameter WHERE ParameterID = 4);
		SET @HMSCDNImagePath = (SELECT [Value] FROM  app.Parameter WHERE ParameterID = 3);
		SET @HMSCDNUserID = (SELECT [Value] FROM  app.Parameter WHERE ParameterID = 5);
		SET @HMSCDNPassword = (SELECT [Value] FROM  app.Parameter WHERE ParameterID = 6);
		--SET @UserManual = (SELECT [DocName] FROM [app].[Document] WHERE IsActive = 1)

		IF (@AccountingDateID IS NULL)
		BEGIN
			Set @AccountingDateID = 0;
			--Set @AccountingDate = GETDATE();
			Set @AccountingDate = [dbo].[GetDatetimeBasedonTimezone] (getdate())
		END
		
		SELECT @LocationName = l.[LocationName]
		,@LocationCode = l.[LocationCode]
		,@MainCurrencyID = l.[MainCurrencyID]
		,@MainCurrencyCode = mc.CurrencyCode
		,@MainCurrencySymbol = mc.CurrencySymbol
		--,@LocalCurrencyID = l.[LocalCurrencyID]
		--,@LocalCurrencyCode = lc.CurrencyCode
		--,@LocalCurrencySymbol = lc.CurrencySymbol
		,@RateCurrencyID = l.RateCurrencyID
		,@RateCurrencyCode = rc.CurrencyCode
		,@RateCurrencySymbol = rc.CurrencySymbol
		,@CountryID = [CountryID]		
		,@ReportLogo = l.CommonReportLogo
		,@AddressLine1=l.AddressLine1
		,@AddressLine2=l.AddressLine2
		,@AddressLine3=l.AddressLine3
		,@AddressLine4=l.AddressLine4
		,@AddressLine5=l.AddressLine5
		,@AddressLine6=l.AddressLine6


		--,@EnableImportCustomerFromCMS = l.EnableImportCustomerFromCMS
		--,@ConnectionStringCMS = ISNULL(l.ConnectionStringCMS,'')
		--,@ConnectionStringForFundTransfer = ISNULL(l.ConnectionStringForFundTransfer,'')
		--,@CMSCustomerImagePath = ISNULL(l.CMSCustomerImagePath,'')
		--,@ServiceCurrencyID = l.ServiceCurrencyID
		FROM  general.[Location] l
		INNER JOIN  currency.Currency mc ON l.MainCurrencyID = mc.CurrencyID
		--INNER JOIN  currency.Currency lc ON l.LocalCurrencyID = lc.CurrencyID
		INNER JOIN  currency.Currency rc ON l.RateCurrencyID = rc.CurrencyID
		WHERE LocationID = @LocationID

	    ------------------------- Drawer Count ------------------------------------
		SELECT @DrawerCount =  COUNT(d.DrawerID) 
		FROM  [app].[Drawer] d
		INNER JOIN 
		 [app].[UserDrawer] ud ON d.DrawerID = ud.DrawerID AND ud.UserID = @UserID 
		WHERE IsActive=1 AND LocationID = @LocationID

		--------------------Token Key----------------
		declare @TokenKey varchar(100)=NEWID();
		update  app.[User]  set TokenKey=@TokenKey,TokenExpiry=GETUTCDATE()+1 where UserID =@UserID

		--------------------Email Configs----------------- Added by Vivek
		SELECT @FromEmailID  = [FromEmailID]
		,@FromEmailPswd = [FromEmailPswd]
		,@FromEmailDisplayName = [FromDisplayName]
		,@EmailHost = [Host]
		,@EmailPort = [Port]
		,@CCEmailID =ISNULL([CCEmailId],'')   ----- Added by Vasanth
		,@BCCEmailID =ISNULL([BCCEmailId],'')----- Added by Vasanth
		From [general].[Email]

		------------------------ User & Log In Info -------------------------------
		SELECT 1 [Status]
		,d.FirstName
		,ISNULL(d.LastName, '') [LastName]	
		,u.UserID
		,u.ContactID
		,@LocationID [LocationID]
		,@LocationName [LocationName]
		,@LocationCode [LocationCode]
		,@MainCurrencyID [MainCurrencyID]
		,@MainCurrencyCode [MainCurrencyCode]
		,@MainCurrencySymbol [MainCurrencySymbol]
		,@LocalCurrencyID [LocalCurrencyID]
		,@LocalCurrencyCode [LocalCurrencyCode]
		,@LocalCurrencySymbol [LocalCurrencySymbol]
		,@RateCurrencyID [RateCurrencyID] 
		,@RateCurrencyCode [RateCurrencyCode] 
		,@RateCurrencySymbol [RateCurrencySymbol] 
		--,Dateadd(HH,-3,getdate())-1 as [ServerDateTime]
		,Dateadd(HH,-3,getdate()) as [ServerDateTime]
		 
		,@DrawerID DrawerID
		,@AccountingDateID AccountingDateID
		,@AccountingDate AccountingDate
		,@CountryID CountryID
		,@Drawer [Drawer]		
		,@UserShiftID [UserShiftID]
		,@DrawerCount [DrawerCount]
		,@ReportLogo [ReportLogo]
		,[ApplicationModeID]
		,@EnableImportCustomerFromCMS [EnableImportCustomerFromCMS]
		,@CMSCustomerImagePath [CMSCustomerImagePath]
		,@ConnectionStringCMS [ConnectionStringCMS]
		,@ConnectionStringForFundTransfer [ConnectionStringForFundTransfer]
		,@ServiceCurrencyID [ServiceCurrencyID]
		,3 [OtherCurrency1ID]
		,'EUR' [OtherCurrency1Code]
		,'€' [OtherCurrency1Symbol]
		,@HMSCDNDocPath [HMSCDNDocPath]
		,@HMSCDNImagePath [HMSCDNImagePath]
		,@HMSCDNUserID [HMSCDNUserID]
		,@HMSCDNPassword [HMSCDNPassword]
		,@UserManual [UserManual]
		,TokenKey

		------------------------Vivevek Start---------------
		,@FromEmailID  [FromEmailID]
		,@FromEmailPswd [FromEmailPswd]
		,@FromEmailDisplayName [FromDisplayName]
		,@EmailHost [Host]
		,@EmailPort [Port]
		------------------------Vivevek End---------------

		------------------------Vasanth Start---------------
		,@CCEmailID [CCEmailID]
		,@BCCEmailID [BCCEmailID]
		------------------------Vasanth End---------------
		,@MinCheckInDate as MinCheckinDate
		,@AddressLine1 AddressLine1
		,@AddressLine2 AddressLine2
		,@AddressLine3 AddressLine3
		,@AddressLine4 AddressLine4
		,@AddressLine5 AddressLine5
		,@AddressLine6 AddressLine6
		,@SelfHostAPIAppPath as SelfHostAppPath  -- Added By Vasanth

		From  app.[User] u	
		INNER JOIN  contact.Details d ON u.ContactID = d.ContactID	
		Where u.UserID = @UserID AND u.IsActive = 1

		------------------------- Accessible Objects --------------------------		
		SELECT DISTINCT o.[ObjectID], [TabName], [TabGroupName], [ObjectName], [OperationID], o.[IsAutoObject]		
		FROM  [app].[UserRoleObjects] ur
		INNER JOIN  app.[Object] o ON ur.ObjectID = o.ObjectID
		INNER JOIN  app.[TabGroup] tg ON o.TabGroupID = tg.TabGroupID
		INNER JOIN  app.[Tab] t ON tg.TabID = t.TabID
		WHERE ur.RoleID IN (SELECT RoleID FROM  app.UsersAndRoles WHERE UserID = @UserID)	
		UNION
		SELECT DISTINCT o.[ObjectID], [TabName], [TabGroupName], [ObjectName], [OperationID], o.[IsAutoObject]	
		FROM  [app].[UserRight] ur
		INNER JOIN  app.[Object] o ON ur.ObjectID = o.ObjectID
		INNER JOIN  app.[TabGroup] tg ON o.TabGroupID = tg.TabGroupID
		INNER JOIN  app.[Tab] t ON tg.TabID = t.TabID
		WHERE ur.UserID = @UserID	

		------------------------- All Locations  --------------------------
		SELECT [LocationID]   	
		,LocationName  AS [LocationCode] ,ReportAddress,ISNULL(CommonReportLogo,'') as ReportLogo
		FROM  [general].[Location]	where LocationTypeID=1

		--------------------------- HMS Currency--------------------------
		SELECT CurrencyID, CurrencyCode, CurrencySymbol
		FROM  currency.Currency

		--------------------------- CMS Currency--------------------------
		SELECT CurrencyID, CurrencyCode, CurrencySymbol
		FROM  currency.Currency
		---------------------Genaral.Parameter----------------------------
		Select ParameterValue from [general].[Parameter]  where ParameterId=3
		------------------Insert Notifications---------------------------		

		Select Value FROM  [app].[Parameter]  where ParameterID=7

		DECLARE @User VARCHAR(200) = (SELECT d.FirstName + ' '+ ISNULL(d.LastName,'') 	
		FROM  app.[User] u 
		INNER JOIN  contact.[Details] d ON u.ContactID=d.ContactID
		WHERE u.UserID = @UserID)

		DECLARE @Title varchar(200) = 'Login User: ' +  @User + ' has logged into ' + @Drawer ;
		DECLARE @NotDesc varchar(max) = @Title + ' at ' + @Drawer + ' on ' + FORMAT(GETDATE(), 'dd-MMM-yyyy HH:mm') + '.  By User ID:' + CAST(@UserID as varchar(10));
		EXEC [dbo].[spInsertIntoNotification]@LocationID, @Title, @NotDesc	

		---------------------------- Insert into activity log---------------
		Declare @Act varchar(max) = 'Logged into the System by User-ID : ' + CAST(@UserID as varchar(30));
		Exec [app].[spInsertActivityLog] 1,@LocationID,@Act,@UserID		
	END TRY
	BEGIN CATCH			
		---------------------------- Insert into activity log---------------
		SET @Act = 'Login failure by User-ID : ' + CAST(@UserID as varchar(30)) + ', Error Message: ' + ERROR_MESSAGE();
		Exec [app].[spInsertActivityLog] 2,@LocationID,@Act,@UserID					
	END CATCH
END

