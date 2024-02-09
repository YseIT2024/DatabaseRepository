
CREATE PROCEDURE [reservation].[GetProductRateDetails_New_sp]
(	
	@dtProducts [reservation].[dtProductsRates] readonly,
	@ExpectedCheckInDate datetime,
	@ExpectedCheckOutDate datetime,
	@NoOfAdults int,
	@NoOfChilds int,
	@NoOfRooms int,
	@CompanyID int,	
	@IntExAdult int=0,
	@IntExChild int=0, 
	@IntExChildSr int=0,
	@DiscountPercentage decimal (18,4)=0,
	@DiscountAmount decimal (18,4)=0

)
AS
BEGIN
			Declare @ExAdult int=0,@ExChild int=0, @ExChildSr int=0
			Declare @decSalePrice decimal

			set @ExAdult= CASE WHEN (@NoOfAdults-2)<=0 THEN 0 ELSE @NoOfAdults-2 END  
			set @ExChild=CASE WHEN (@NoOfChilds-2)<=0 THEN 0 ELSE @NoOfChilds-2 END
			--SELECT @ExAdult,@ExChild

			DECLARE @TempDates table (startdate date);
			DECLARE @CompanyTable table 
			(
				ItemID int,ItemName nvarchar(250),SubCategory  nvarchar(250),SubCategoryID int,
				FromDate datetime,SalePrice decimal(18,6),FixSalePrice  decimal(18,6),Discount decimal(18,6),
				TotalTax decimal(18,6),TaxAmount decimal(18,6),NetTotal decimal(18,6),LineTotal decimal(18,6),
				Adult int,Child int,ExAdult int,ExChild int,ExChildSr int,
				RoomCount int,BeforeTax decimal(18,6)
			);


			if(@CompanyID < 1)
			BEGIN
			
				select PRP.ItemID,ItemName,Name as SubCategory,SUB.SubCategoryID,FromDate
				--,case when @NoOfAdults>1 OR @NoOfChilds>0 then SalePrice+AddPax* @ExAdult+AddChild*@ExChild else  SalePriceSingle+AddPax*@ExAdult+AddChild*@ExChild end as SalePrice
				--,case when @NoOfAdults>1 OR @NoOfChilds>0 then SalePrice+AddPax* @ExAdult+AddChild*@ExChild else  SalePriceSingle+AddPax* @ExAdult+AddChild*@ExChild end  as FixSalePrice
				
				--,PRP.SalePrice
				,case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.SalePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.SalePrice END as SalePrice

				--,case when @IntExChild>0 then PRP.SalePrice + (@IntExChild*ISNULL(prp.AddChild,0)) end as SalePrice
				--,case when @IntExChildSr>0 then PRP.SalePrice + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) end as SalePrice
						


				--,PRP.SalePrice as FixSalePrice --For coding perpose
				,case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.SalePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.SalePrice END as FixSalePrice
				--,AddPax,AddChild
				,Discount as Discount
				,isnull(sum(GT.TaxRate),0)TotalTax
				 ---COMMENTED BY ARABIND ON 12-07-2023---------
				 --,ISNULL(sum(GT.TaxRate*(SalePrice+ (AddPax* isnull(@ExAdult,0))+(AddChild*ISNULL(@ExChild,0)))/100),0) as TaxAmount -- TODO
				  , DT.RoomCount * ISNULL((case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.SalePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.SalePrice END) / ( 1+ sum(GT.TaxRate)),0) as TaxAmount -- TODO
				 --Total Price with Tax / (1 + Sales Tax Rate)
				
				 --,(SalePrice+ (AddPax* isnull(@ExAdult,0))+(AddChild*ISNULL(@ExChild,0))) + sum(GT.TaxRate*(SalePrice+ (AddPax* isnull(@ExAdult,0))+(AddChild*ISNULL(@ExChild,0)))/100) as NetTotal
				 --,((SalePrice+ (AddPax* isnull(@ExAdult,0))+(AddChild*ISNULL(@ExChild,0))) + sum(GT.TaxRate*(SalePrice+ (AddPax* isnull(@ExAdult,0))+(AddChild*ISNULL(@ExChild,0)))/100)) * DT.RoomCount as LineTotal
				  
				 ,case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.SalePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.SalePrice END as NetTotal
				 ,(case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.SalePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.SalePrice END) * DT.RoomCount as LineTotal
				 -----------End ---------
				
				,ISNULL(@NoOfAdults,0) as Adult,ISNULL(@NoOfChilds,0) as Child
				--,@ExAdult ExAdult,@ExChild ExChild
				,@IntExAdult ExAdult
				,@IntExChild ExChild
				,@IntExChildSr ExChildSr
				,@NoOfRooms RoomCount,
				(case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.SalePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.SalePrice END) - (ISNULL((case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.SalePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.SalePrice END) / ( 1+ sum(GT.TaxRate)),0)) - (1-@DiscountPercentage/100) as BeforeTax

				from Products.Item PIT
				--inner join @dtProducts DT on DT.ProductId=PIT.ItemID
				inner join @dtProducts DT on PIT.ItemID=DT.ProductId
				--inner join Products.RoomPrice PRP on PRP.ItemID=DT.ProductId
				inner join Products.RoomPrice PRP on DT.ProductId=PRP.ItemID

				--inner join Products.SubCategory SUB on SUB.SubCategoryID=PIT.SubCategoryID
				inner join Products.SubCategory SUB on PIT.SubCategoryID=SUB.SubCategoryID

				--left join Products.Room PR on PR.SubCategoryID=SUB.SubCategoryID
				inner join Products.Tax PT on PIT.ItemID=PT.ItemID				
				--inner join general.Tax GT on GT.TaxID=PT.TaxID
				inner join general.Tax GT on PT.TaxID=GT.TaxID
				where PRP.FromDate between CONVERT(VARCHAR(10),@ExpectedCheckInDate,111) and DATEADD(DAY,-1,CONVERT(VARCHAR(10),@ExpectedCheckOutDate,111)) 
				group by  PRP.ItemID,ItemName,Name,SUB.SubCategoryID,FromDate,SalePrice,SalePriceSingle,AddPax,AddChild,Discount
				--,MaxAdultCapacity,MaxChildCapacity
				,DT.RoomCount,ISNULL(prp.AddChildSr,0)
				order by ItemID				
			
				select DT.ProductId,TaxName,PT.TaxID,TaxRate
				, CASE WHEN @NoOfAdults>1 OR @NoOfChilds>0 THEN ((SalePrice+AddPax* @ExAdult+AddChild*@ExChild)*ISNULL(GT.TaxRate,0))/100  ELSE ((SalePriceSingle+AddPax* @ExAdult+AddChild*@ExChild)*ISNULL(GT.TaxRate,0))/100 END TaxAmount
				from @dtProducts DT
				inner join Products.RoomPrice PRP on PRP.ItemID=DT.ProductId
				inner join Products.Tax PT on DT.ProductId=PT.ItemID
				inner join general.Tax GT on GT.TaxID=PT.TaxID
				group by DT.ProductId,TaxName,PT.TaxID,TaxRate,SalePrice,SalePriceSingle,AddPax,AddChild

			END

			ELSE --Corporate and Company
			BEGIN

	;WITH cte (startdate)
	AS 
	(
	SELECT @ExpectedCheckInDate AS startdate
	UNION ALL
	SELECT
	DATEADD(DAY, 1, startdate) AS startdate
	FROM cte
	WHERE startdate < DATEADD(DAY, -1, @ExpectedCheckOutDate)
	)
	INSERT INTO @TempDates SELECT c.startdate FROM cte c

	-- Cursor Start
		DECLARE @startdate Date;
		DECLARE myCursor CURSOR FOR select startdate from @TempDates
		OPEN myCursor;
		FETCH NEXT FROM myCursor INTO @startdate;
		WHILE @@FETCH_STATUS = 0
		BEGIN

			INSERT  @CompanyTable (
			ItemID,			ItemName,			SubCategory,			SubCategoryID,			FromDate,
			SalePrice,			FixSalePrice,			Discount,			TotalTax,			TaxAmount,
			NetTotal,			LineTotal,			Adult,			Child,			ExAdult,
			ExChild,			ExChildSr,			RoomCount,			BeforeTax
			)
			select GC.ItemID,ItemName,Name as SubCategory,SUB.SubCategoryID,
			--GC.ContractFrom as FromDate
			@startdate as FromDate
			--,case when @NoOfAdults>1 OR @NoOfChilds>0 then SalePrice+AddPax* @ExAdult+AddChild*@ExChild else  SalePriceSingle+AddPax*@ExAdult+AddChild*@ExChild end as SalePrice
			--,case when @NoOfAdults>1 OR @NoOfChilds>0 then SalePrice+AddPax* @ExAdult+AddChild*@ExChild else  SalePriceSingle+AddPax* @ExAdult+AddChild*@ExChild end  as FixSalePrice
			,case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then GC.SellRate + (@IntExAdult*ISNULL(GC.AddPax,0)) + (@IntExChild*ISNULL(GC.AddChild,0)) + (@IntExChildSr*ISNULL(GC.AddChildSr,0)) else GC.SellRate END as SalePrice
			--,GC.SellRate as SalePrice
			--,GC.SellRate as FixSalePrice --For coding perpose
			,case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then GC.SellRate + (@IntExAdult*ISNULL(GC.AddPax,0)) + (@IntExChild*ISNULL(GC.AddChild,0)) + (@IntExChildSr*ISNULL(GC.AddChildSr,0)) else GC.SellRate END as FixSalePrice
			--,AddPax,AddChild
			,GC.DiscountPercent as Discount
			,isnull(sum(GT.TaxRate),0)TotalTax
			-- ,ISNULL(sum(GT.TaxRate*(GC.SellRate)/100),0) as TaxAmount  --commented by Arabinda on 12-07-2023
			----,ISNULL(sum(1+GT.TaxRate*(case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then GC.SellRate + (@IntExAdult*ISNULL(GC.AddPax,0)) + (@IntExChild*ISNULL(GC.AddChild,0)) + (@IntExChildSr*ISNULL(GC.AddChildSr,0)) else GC.SellRate END)/100),0) as TaxAmount 
			------20-Nov-23 Modified-------------------------
			, DT.RoomCount * ISNULL((case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then GC.SellRate + (@IntExAdult*ISNULL(GC.AddPax,0)) + (@IntExChild*ISNULL(GC.AddChild,0)) + (@IntExChildSr*ISNULL(GC.AddChildSr,0)) else GC.SellRate END) / ( 1+ sum(GT.TaxRate)),0) as TaxAmount -- TODO
			----,(case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then GC.SellRate + (@IntExAdult*ISNULL(GC.AddPax,0)) + (@IntExChild*ISNULL(GC.AddChild,0)) + (@IntExChildSr*ISNULL(GC.AddChildSr,0)) else GC.SellRate END+ sum(GT.TaxRate*(case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then GC.SellRate + (@IntExAdult*ISNULL(GC.AddPax,0)) + (@IntExChild*ISNULL(GC.AddChild,0)) + (@IntExChildSr*ISNULL(GC.AddChildSr,0)) else GC.SellRate END)/100)) as NetTotal
			------20-Nov-23 Modified-------------------------
			,case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then GC.SellRate + (@IntExAdult*ISNULL(GC.AddPax,0)) + (@IntExChild*ISNULL(GC.AddChild,0)) + (@IntExChildSr*ISNULL(GC.AddChildSr,0)) else GC.SellRate END as NetTotal
			----,((case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then GC.SellRate + (@IntExAdult*ISNULL(GC.AddPax,0)) + (@IntExChild*ISNULL(GC.AddChild,0)) + (@IntExChildSr*ISNULL(GC.AddChildSr,0)) else GC.SellRate END+ sum(GT.TaxRate*(case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then GC.SellRate + (@IntExAdult*ISNULL(GC.AddPax,0)) + (@IntExChild*ISNULL(GC.AddChild,0)) + (@IntExChildSr*ISNULL(GC.AddChildSr,0)) else GC.SellRate END)/100)))* DT.RoomCount as LineTotal
			------20-Nov-23 Modified-------------------------
				 ,(case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then GC.SellRate + (@IntExAdult*ISNULL(GC.AddPax,0)) + (@IntExChild*ISNULL(GC.AddChild,0)) + (@IntExChildSr*ISNULL(GC.AddChildSr,0)) else GC.SellRate END) * DT.RoomCount as LineTotal
			
			,ISNULL(@NoOfAdults,0) as Adult,ISNULL(@NoOfChilds,0) as Child
			--,@ExAdult ExAdult,@ExChild ExChild
			,@IntExAdult ExAdult
			,@IntExChild ExChild
			,@IntExChildSr ExChildSr
			,@NoOfRooms RoomCount,
			---------------Added by Arabinda on 20-nov-23-------------
			(case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then GC.SellRate + (@IntExAdult*ISNULL(GC.AddPax,0)) + (@IntExChild*ISNULL(GC.AddChild,0)) + (@IntExChildSr*ISNULL(GC.AddChildSr,0)) else GC.SellRate END) - (ISNULL((case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then GC.SellRate + (@IntExAdult*ISNULL(GC.AddPax,0)) + (@IntExChild*ISNULL(GC.AddChild,0)) + (@IntExChildSr*ISNULL(GC.AddChildSr,0)) else GC.SellRate END) / ( 1+ sum(GT.TaxRate)),0)) as BeforeTax

			
			from Products.Item PIT
			inner join @dtProducts DT on DT.ProductId=PIT.ItemID
			--inner join Products.RoomPrice PRP on PRP.ItemID=DT.ProductId
			inner join [guest].[GuestCompanyRateContract] GC on DT.ProductId = GC.ItemID
			inner join Products.SubCategory SUB on SUB.SubCategoryID=PIT.SubCategoryID
			--left join Products.Room PR on PR.SubCategoryID=SUB.SubCategoryID
			inner join Products.Tax PT on PIT.ItemID=PT.ItemID
			inner join general.Tax GT on GT.TaxID=PT.TaxID
			where
			ContractFrom<= CONVERT(VARCHAR(10),@ExpectedCheckInDate,111) AND ContractTo >= CONVERT(VARCHAR(10),@ExpectedCheckOutDate,111) 
			--GC.ContractFrom between CONVERT(VARCHAR(10),@ExpectedCheckInDate,111) and DATEADD(DAY,-1,CONVERT(VARCHAR(10),@ExpectedCheckOutDate,111)) 
			and GC.GuestCompanyID = @CompanyID
			group by  GC.ItemID,ItemName,Name,SUB.SubCategoryID,GC.ContractFrom,GC.SellRate,GC.DiscountPercent,GC.AddPax,GC.AddChild,GC.AddChildSr
			--,MaxAdultCapacity,MaxChildCapacity
			,DT.RoomCount
			order by ItemID	
	
		FETCH NEXT FROM myCursor INTO @startdate;
		END
		CLOSE myCursor;
		DEALLOCATE myCursor;
	-- Cursor End

			
				select * from @CompanyTable

				select DT.ProductId,TaxName,PT.TaxID,TaxRate
				, CASE WHEN @NoOfAdults>1 OR @NoOfChilds>0 THEN ((PRP.SellRate)*ISNULL(GT.TaxRate,0))/100  ELSE ((PRP.SellRate)*ISNULL(GT.TaxRate,0))/100 END TaxAmount
				from @dtProducts DT
				inner join [guest].[GuestCompanyRateContract] PRP on PRP.ItemID=DT.ProductId
				inner join Products.Tax PT on DT.ProductId=PT.ItemID
				inner join general.Tax GT on GT.TaxID=PT.TaxID
				group by DT.ProductId,TaxName,PT.TaxID,TaxRate,SellRate

			END

				--select DT.ProductId,TaxName,PT.TaxID,TaxRate
				--, CASE WHEN @NoOfAdults>1 OR @NoOfChilds>0 THEN ((SalePrice+AddPax* @ExAdult+AddChild*@ExChild)*ISNULL(GT.TaxRate,0))/100  ELSE ((SalePriceSingle+AddPax* @ExAdult+AddChild*@ExChild)*ISNULL(GT.TaxRate,0))/100 END TaxAmount
				--from @dtProducts DT
				--inner join Products.RoomPrice PRP on PRP.ItemID=DT.ProductId
				--inner join Products.Tax PT on DT.ProductId=PT.ItemID
				--inner join general.Tax GT on GT.TaxID=PT.TaxID
				--group by DT.ProductId,TaxName,PT.TaxID,TaxRate,SalePrice,SalePriceSingle,AddPax,AddChild

END


