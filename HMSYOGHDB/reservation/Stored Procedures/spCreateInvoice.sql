CREATE PROCEDURE [reservation].[spCreateInvoice]  --1089,75
(
@ReservationId int,
@UserID int
)
AS
BEGIN

	 SET NOCOUNT ON; 

 	 
		 	DECLARE @RoomNo varchar(250);
			DECLARE @FOLIONUMBER INT;
			DECLARE @InvoiceNo INT;
			DECLARE @TAXEXCEMPTION nvarchar(250);
			DECLARE @SERVICETYPEID INT = 18;
			DECLARE @OTABookingId int=11;
			DECLARE @OTABookingServicePercentage decimal(18,2);

			DECLARE @TotalAmountBeforeTax decimal(18,2);
			DECLARE @TotalAmountAfterTax decimal(18,2);
			DECLARE @TotalAmountNet decimal(18,2);
			DECLARE @VatAmount decimal(18,2);
			DECLARE @Balance decimal(18,2);
			
			DECLARE @RoomChargeAdditionalDiscount decimal(18,2);
			DECLARE @DISCOUNTPERCENTAGE decimal(18,2);

			DECLARE @InvoiceNumber nvarchar(150);

			DECLARE @TempInvoiceDetails table 
					(InvoiceNo INT,
					TransDate DATETIME,
					ServiceId INT,
					ItemDescription NVARCHAR(250),
					ServiceRate DECIMAL(18,2),
					Qty INT,
					TaxId INT,
					TaxPer DECIMAL(18,2),
					AmtBeforeTax DECIMAL(18,2),
					AmtTax DECIMAL(18,2),
					AmtAfterTax DECIMAL(18,2),
					BillCode int,
					IsComplimentary bit,
					ComplimentaryPercentage DECIMAL(18,2)
					,UnitPriceBeforeDiscount DECIMAL(18,2)
					,Discount DECIMAL(18,2)
					,DiscountPercentage DECIMAL(18,2)
					);


			SET @RoomNo=(select [reservation].[fnGetReserveredRoom] (@ReservationId))
			SET @FOLIONUMBER= (SELECT FolioNumber FROM reservation.Reservation WHERE ReservationID=@ReservationId);
			SET @TAXEXCEMPTION =(SELECT TaxRefNo from [reservation].[TaxExemptionDetails] where  reservationid=@ReservationId)
			SET @DISCOUNTPERCENTAGE=(SELECT AdditionalDiscount FROM reservation.Reservation WHERE ReservationID=@ReservationId)
			 
			IF NOT EXISTS (SELECT * FROM [reservation].[Invoice] where FolioNumber=@FolioNumber )--If Invoice  available
				BEGIN
-- SPLIT INVOICE SAVE
					--IF EXISTS (SELECT * FROM [reservation].Reservation where FolioNumber=@FolioNumber AND ReservationTypeID=@OTABookingId)--If OTA  available
					--IF EXISTS (select ReservationID from [guest].[OTAServices] where ReservationID=@ReservationId)--IF Split Invoice
					IF ((select count(distinct GuestID_CompanyID) from [guest].[OTAServices] where ReservationID=@ReservationId)>1)--IF Split Invoice
						BEGIN
					
					--All Details Insert TO Temp Table 
					INSERT INTO @TempInvoiceDetails
				SELECT @InvoiceNo,
				FORMAT(gld.TransDate,'dd-MMM-yyyy')  as TransDate,
				gld.ServiceId
				,CASE WHEN gld.Remarks IS NOT NULL THEN gld.Remarks else CONCAT(st.ServiceName,' ',@RoomNo,' ',FORMAT(gld.TransDate,'MMM-dd')) END as ItemDescription
				,gld.AmtBeforeTax 
				,1
				,gld.TaxId
				,gld.TaxPer
				,gld.AmtBeforeTax
				,gld.AmtTax
				,gld.AmtAfterTax
				,gld.ServiceId
				,gld.IsComplimentary
				,gld.ComplimentaryPercentage
				,UnitPriceBeforeDiscount
				,Discount
				,DiscountPercentage
				FROM [account].[GuestLedgerDetails] gld
				Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
				WHERE gld.FolioNo=@FolioNumber AND st.ServiceTypeID=@SERVICETYPEID
					
				UNION ALL
					
				SELECT @InvoiceNo,
				FORMAT(gld.TransDate,'dd-MMM-yyyy')  as TransDate,
				gld.ServiceId
				,CASE WHEN gld.Remarks IS NOT NULL THEN CONCAT(st.ServiceName,' - ',gld.Remarks,' ',@RoomNo,' ',FORMAT(gld.TransDate,'MMM-dd')) else CONCAT( st.ServiceName,' ',@RoomNo,' ',FORMAT(gld.TransDate,'MMM-dd')) END as ItemDescription
				,gld.AmtBeforeTax
				,1
				,gld.TaxId
				,gld.TaxPer
				,gld.AmtBeforeTax
				,gld.AmtTax
				,gld.AmtAfterTax
				,gld.ServiceId
				,gld.IsComplimentary
				,gld.ComplimentaryPercentage
				,UnitPriceBeforeDiscount
				,Discount
				,DiscountPercentage
				FROM [account].[GuestLedgerDetails] gld
				Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
				WHERE gld.FolioNo=@FolioNumber AND st.ServiceTypeID<>@SERVICETYPEID
				  
		-- Cursor Start
 
		--DECLARE @ReservationTypeID int;
		DECLARE @GuestID int;
		DECLARE @GuestID_CompanyID int;
		DECLARE @Type nvarchar(50);

		--DECLARE myCursorReservationType CURSOR FOR SELECT DISTINCT ReservationTypeID FROM [guest].[OTAServices] where ReservationID=@ReservationId AND ServicePercent>0
		DECLARE myCursorReservationType CURSOR FOR SELECT DISTINCT os.GuestID_CompanyID,os.[Type] FROM [guest].[OTAServices] os
													inner join reservation.Reservation r on os.ReservationID=r.ReservationID
													inner join account.GuestLedgerDetails gs on gs.FolioNo = r.FolioNumber and os.ServiceID=gs.ServiceId
													where os.ReservationID=@ReservationId AND ServicePercent>0
		OPEN myCursorReservationType;
		FETCH NEXT FROM myCursorReservationType INTO @GuestID_CompanyID,@Type;
		WHILE @@FETCH_STATUS = 0
		BEGIN

		SET @GuestID =(SELECT GuestID FROM reservation.Reservation WHERE ReservationID=@ReservationId)
				SET @InvoiceNumber=(SELECT ProformaInvoiceNo FROM reservation.ProformaInvoice where ReservationId=@ReservationId and DocumentTypeId=2 and Guest_CompanyId=@GuestID_CompanyID and [Type]=@Type )
				 
				INSERT INTO reservation.Invoice(
				[InvoiceDate],[FolioNumber],[GuestID],
				[TotalAmountBeforeTax],[VatAmount],[ServiceTaxAmount],[TotalAmountAfterTax],[AdditionalDiscount],[RoundOffAmount],[TotalAmountNet],
				[InvoiceStatus],[PrintStatus],[Remarks],[CreatedBy],[Createdon],[BillToType],[TotalReceived],[Balance],[BillTo],[InvoiceNumber])
				SELECT 
				(select CreatedDate from reservation.ProformaInvoice where ReservationId=@ReservationId AND DocumentTypeId=2 and Guest_CompanyId=@GuestID_CompanyID and [Type]=@Type)
				,RS.FolioNumber,@GuestID_CompanyID,0,0,0,0,0,0,0,1,0,'Invoice Generated',@UserID,GETDATE(),@Type
				,ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=RS.ReservationID and GuestCompanyId=@GuestID_CompanyID),0)
				,0
				,@GuestID_CompanyID
				,@InvoiceNumber
				FROM [reservation].[Reservation] RS
				WHERE RS.ReservationID=@ReservationId
				
				SET @InvoiceNo = SCOPE_IDENTITY();
				
				SET @RoomChargeAdditionalDiscount=0
				--Nested Cursor Start
				DECLARE @ServicePercent decimal(18,2);
				DECLARE @ServiceID int;
				DECLARE myCursor CURSOR FOR SELECT ServicePercent,ServiceID FROM [guest].[OTAServices] where ReservationID=@ReservationId and GuestID_CompanyID=@GuestID_CompanyID and [Type]=@Type
				OPEN myCursor;
				FETCH NEXT FROM myCursor INTO @ServicePercent,@ServiceID;
				WHILE @@FETCH_STATUS = 0
					BEGIN
			
			IF @ServicePercent>0
			BEGIN
				IF EXISTS(SELECT * FROM  account.GuestLedgerDetails where FolioNo=@FolioNumber AND ServiceId=@ServiceID)
					BEGIN
						INSERT INTO reservation.InvoiceDetails
							([InvoiceNo]
							,[TransactionDate]
							,[ServiceId]
							,[ServiceDescription]
							,[ServiceRate]
							,[ServiceQty]
							,[TaxId]
							,[TaxPercent]
							,[AmountBeforeTax]
							,[TaxAmount]
							,[AmountAfterTax]
							,[BillingCode]
							,IsComplimentary
							,ComplimentaryPercentage
							,UnitPriceBeforeDiscount
							,Discount
							,DiscountPercentage)
							SELECT 
							@InvoiceNo,
							TransDate,
							ServiceId,
							ItemDescription,
							ServiceRate,
							Qty,
							TaxId,
							TaxPer,
						 --CASE WHEN @ServicePercent=100 THEN AmtBeforeTax ELSE (AmtBeforeTax - (@ServicePercent/100) * AmtBeforeTax) END,
						 --CASE WHEN @ServicePercent=100 THEN AmtTax ELSE	(AmtTax -(@ServicePercent/100) * AmtTax) END,
						 --CASE WHEN @ServicePercent=100 THEN AmtAfterTax ELSE (AmtAfterTax - (@ServicePercent/100) * AmtAfterTax) END,
						 CASE WHEN @ServicePercent=100 THEN AmtBeforeTax ELSE ((@ServicePercent/100) * AmtBeforeTax) END,
						 CASE WHEN @ServicePercent=100 THEN AmtTax ELSE	((@ServicePercent/100) * AmtTax) END,
						 CASE WHEN @ServicePercent=100 THEN AmtAfterTax ELSE ((@ServicePercent/100) * AmtAfterTax) END,
						 BillCode
						 ,IsComplimentary
						 ,ComplimentaryPercentage
						 ,CASE WHEN @ServicePercent=100 THEN isnull(UnitPriceBeforeDiscount,0) ELSE ((@ServicePercent/100) * isnull(UnitPriceBeforeDiscount,0)) END
						 ,CASE WHEN @ServicePercent=100 THEN ISNULL(Discount,0) ELSE ((@ServicePercent/100) * ISNULL(Discount,0)) END
						 ,ISNULL(DiscountPercentage,0)
						 FROM @TempInvoiceDetails where ServiceId=@ServiceID
						 -- Room Charge Service Percentage

						 IF(@ServiceID=@SERVICETYPEID)
						 BEGIN
							 SET @RoomChargeAdditionalDiscount=@ServicePercent
						 END

					END
			END
				FETCH NEXT FROM myCursor INTO @ServicePercent,@ServiceID;
				END
				CLOSE myCursor;
				DEALLOCATE myCursor;
				--Nested Cursor End
			--	 Update Amount
			 
				UPDATE reservation.Invoice SET 
				TotalAmountBeforeTax=(SELECT SUM(AmountBeforeTax) FROM reservation.InvoiceDetails WHERE InvoiceNo=@InvoiceNo)
				,TotalAmountAfterTax=(SELECT SUM(AmountAfterTax) FROM reservation.InvoiceDetails WHERE InvoiceNo=@InvoiceNo)
				,TotalAmountNet=((SELECT SUM(AmountAfterTax)-TotalReceived FROM reservation.InvoiceDetails WHERE InvoiceNo=@InvoiceNo))
				,ServiceTaxAmount=((SELECT SUM(TaxAmount) FROM reservation.InvoiceDetails WHERE InvoiceNo=@InvoiceNo))
				,VatAmount=((SELECT SUM(TaxAmount) FROM reservation.InvoiceDetails WHERE InvoiceNo=@InvoiceNo))
				,AdditionalDiscount=((@DISCOUNTPERCENTAGE/100) * (SELECT SUM(AmountAfterTax) FROM reservation.InvoiceDetails WHERE InvoiceNo=@InvoiceNo))
				,Balance=((SELECT SUM(AmountAfterTax)-TotalReceived FROM reservation.InvoiceDetails WHERE InvoiceNo=@InvoiceNo))
				WHERE InvoiceNo=@InvoiceNo
			 

		FETCH NEXT FROM myCursorReservationType INTO @GuestID_CompanyID,@Type;
		END
		CLOSE myCursorReservationType;
		DEALLOCATE myCursorReservationType;

				 
END
					ELSE
					BEGIN
-- NORMAL INVOICE SAVE
						SET @InvoiceNumber=(SELECT ProformaInvoiceNo FROM reservation.ProformaInvoice where ReservationId=@ReservationId and DocumentTypeId=2)
					 
						INSERT INTO reservation.Invoice(
						[InvoiceDate],[FolioNumber],[GuestID],
						[TotalAmountBeforeTax],[VatAmount],[ServiceTaxAmount],[TotalAmountAfterTax],[AdditionalDiscount],[RoundOffAmount],[TotalAmountNet],
						[InvoiceStatus],[PrintStatus],[Remarks],[CreatedBy],[Createdon],[BillToType],[TotalReceived],[Balance],[BillTo],[InvoiceNumber])
						SELECT 
						(select CreatedDate from reservation.ProformaInvoice where ReservationId=@ReservationId AND DocumentTypeId=2)
						,RS.FolioNumber
						,RS.GuestID
						,(SELECT SUM(AmtBeforeTax) FROM [account].[GuestLedgerDetails] WHERE FolioNo=@FOLIONUMBER)
						,(SELECT SUM(AmtTax) FROM [account].[GuestLedgerDetails] WHERE FolioNo=@FOLIONUMBER)
						,(SELECT SUM(AmtTax) FROM [account].[GuestLedgerDetails] WHERE FolioNo=@FOLIONUMBER)
						,(SELECT SUM(AmtAfterTax) FROM [account].[GuestLedgerDetails] WHERE FolioNo=@FOLIONUMBER)
						,RS.AdditionalDiscountAmount
						,0
						,CASE WHEN @TAXEXCEMPTION IS NOT NULL THEN ((SELECT SUM(AmtBeforeTax) FROM [account].[GuestLedgerDetails] WHERE FolioNo=@FOLIONUMBER)-ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=RS.ReservationID),0)-RS.AdditionalDiscountAmount)
						  ELSE ((SELECT SUM(AmtAfterTax) FROM [account].[GuestLedgerDetails] WHERE FolioNo=@FOLIONUMBER)-RS.AdditionalDiscountAmount)-ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=RS.ReservationID),0) END
						--,CASE WHEN @TAXEXCEMPTION IS NOT NULL THEN ((SELECT SUM(AmtBeforeTax) FROM [account].[GuestLedgerDetails] WHERE FolioNo=@FOLIONUMBER)-ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=RS.ReservationID),0)-((RS.AdditionalDiscount/100)*((SELECT SUM(AmtBeforeTax) FROM [account].[GuestLedgerDetails] WHERE FolioNo=@FOLIONUMBER)-ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=RS.ReservationID),0))))
							--  ELSE ((SELECT SUM(AmtAfterTax) FROM [account].[GuestLedgerDetails] WHERE FolioNo=@FOLIONUMBER)-ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=RS.ReservationID),0)-((RS.AdditionalDiscount/100)*((SELECT SUM(AmtAfterTax) FROM [account].[GuestLedgerDetails] WHERE FolioNo=@FOLIONUMBER)-ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=RS.ReservationID),0)))) END
						,1
						,0
						,'Invoice Generated'
						,@UserID
						,GETDATE()
						--,'Guest'	--
						,CASE WHEN RS.CompanyID=1 THEN 'Guest' WHEN RS.CompanyID=2 THEN 'Company' ELSE '' END
						,ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=RS.ReservationID),0)
						,CASE WHEN @TAXEXCEMPTION IS NOT NULL THEN 
							(SELECT SUM(AmtBeforeTax) FROM [account].[GuestLedgerDetails] WHERE FolioNo=@FOLIONUMBER)-ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=RS.ReservationID),0) - RS.AdditionalDiscountAmount
							ELSE
							(SELECT SUM(AmtAfterTax) FROM [account].[GuestLedgerDetails] WHERE FolioNo=@FOLIONUMBER)-ISNULL((select sum(ActualAmount) from account.[Transaction] where ReservationID=RS.ReservationID),0) - RS.AdditionalDiscountAmount
							END
						--,RS.GuestID
						,CASE WHEN RS.CompanyID=1 THEN RS.GuestID WHEN RS.CompanyID=2 THEN RS.CompanyTypeID ELSE '' END
						,@InvoiceNumber
						FROM [reservation].[Reservation] RS
						WHERE RS.ReservationID=@ReservationId

						SET @InvoiceNo = SCOPE_IDENTITY();

						INSERT INTO reservation.InvoiceDetails
					([InvoiceNo]
					,[TransactionDate]
					,[ServiceId]
					,[ServiceDescription]
					,[ServiceRate]
					,[ServiceQty]
					,[TaxId]
					,[TaxPercent]
					,[AmountBeforeTax]
					,[TaxAmount]
					,[AmountAfterTax]
					,[BillingCode]
					,IsComplimentary
					,ComplimentaryPercentage
					,UnitPriceBeforeDiscount
					,Discount
					,DiscountPercentage
					)
					
					SELECT @InvoiceNo,
					FORMAT(gld.TransDate,'dd-MMM-yyyy')  as TransDate,
					gld.ServiceId
					,CASE WHEN gld.Remarks IS NOT NULL THEN gld.Remarks else CONCAT(st.ServiceName,' ',@RoomNo,' ',FORMAT(gld.TransDate,'MMM-dd')) END as ItemDescription
					,gld.AmtBeforeTax
					,1
					,gld.TaxId
					,gld.TaxPer
					,gld.AmtBeforeTax
					,gld.AmtTax
					,gld.AmtAfterTax
					,gld.ServiceId
					,gld.IsComplimentary
					,gld.ComplimentaryPercentage
					,UnitPriceBeforeDiscount
					,Discount
					,DiscountPercentage
					FROM [account].[GuestLedgerDetails] gld
					Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
					WHERE gld.FolioNo=@FolioNumber AND st.ServiceTypeID=@SERVICETYPEID
					
					UNION ALL
					
					SELECT @InvoiceNo,
					FORMAT(gld.TransDate,'dd-MMM-yyyy')  as TransDate,
					gld.ServiceId
					,CASE WHEN gld.Remarks IS NOT NULL THEN CONCAT(st.ServiceName,' - ',gld.Remarks,' ',@RoomNo,' ',FORMAT(gld.TransDate,'MMM-dd')) else CONCAT( st.ServiceName,' ',@RoomNo,' ',FORMAT(gld.TransDate,'MMM-dd')) END as ItemDescription
					,gld.AmtBeforeTax
					,1
					,gld.TaxId
					,gld.TaxPer
					,gld.AmtBeforeTax
					,gld.AmtTax
					,gld.AmtAfterTax
					,gld.ServiceId
					,gld.IsComplimentary
					,gld.ComplimentaryPercentage
					,UnitPriceBeforeDiscount
					,Discount
					,DiscountPercentage
					FROM [account].[GuestLedgerDetails] gld
					Inner join service.Type st on gld.ServiceId=st.ServiceTypeID
					WHERE gld.FolioNo=@FolioNumber AND st.ServiceTypeID<>@SERVICETYPEID
				END
			END
END
