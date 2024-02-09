CREATE PROCEDURE [reservation].[GetProductRateDetails_New]
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
			 

			if(@CompanyID < 1)
			BEGIN
				select PRP.ItemID,ItemName,Name as SubCategory,SUB.SubCategoryID,FromDate,
			 
				ISNULL(@NoOfAdults,0) as Adult,
				ISNULL(@NoOfChilds,0) as Child	
				,@IntExAdult ExAdult,
				@IntExChild ExChild,
				@IntExChildSr ExChildSr,
				@NoOfRooms RoomCount,
				case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END as SalePrice, --as UnitBaseRate, 
				case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END as FixSaleprice,
				(@DiscountPercentage * (case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END) /100) as Discount,--as UnitDiscountAmt,
				(case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END)-(@DiscountPercentage * (case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END) /100) as BeforeTax, --as UnitBaserateAD, --Baseprice after discount
				isnull(max(GT.TaxRate),0) as TotalTax,--TotalTaxPer,
				DT.RoomCount*(isnull(max(GT.TaxRate),0) * ((case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END)-(@DiscountPercentage * (case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END) /100)) /100) as  TaxAmount,-- as UnitTaxAmt,
				((case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END)-(@DiscountPercentage * (case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END) /100)+(isnull(max(GT.TaxRate),0) * ((case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END)-(@DiscountPercentage * (case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END) /100)) /100)) as NetTotal,-- as UnitNetRate,  --After discount and with Tax
				((case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END)-(@DiscountPercentage * (case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END) /100)+(isnull(max(GT.TaxRate),0) * ((case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END)-(@DiscountPercentage * (case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END) /100)) /100)) * DT.RoomCount as LineTotal
				,@NoOfRooms RoomCount
				from Products.Item PIT				
				inner join @dtProducts DT on PIT.ItemID=DT.ProductId				
				inner join Products.RoomPriceNew PRP on DT.ProductId=PRP.ItemID	and PRP.IsApproved=1	
				inner join Products.SubCategory SUB on PIT.SubCategoryID=SUB.SubCategoryID			
				inner join Products.Tax PT on PIT.ItemID=PT.ItemID				
			
				inner join general.Tax GT on PT.TaxID=GT.TaxID
				where PRP.FromDate between CONVERT(VARCHAR(10),@ExpectedCheckInDate,111) and DATEADD(DAY,-1,CONVERT(VARCHAR(10),@ExpectedCheckOutDate,111))
				and PRP.IsApproved=1
				group by  PRP.ItemID,ItemName,Name,SUB.SubCategoryID,FromDate,BasePrice,SalePriceSingle,AddPax,AddChild,Discount
				,DT.RoomCount,ISNULL(prp.AddChildSr,0)	order by ItemID			
				
						
			
				select DT.ProductId,TaxName,PT.TaxID,10 as TaxRate
				, CASE WHEN @NoOfAdults>1 OR @NoOfChilds>0 THEN ((BasePrice+AddPax* @ExAdult+AddChild*@ExChild)*ISNULL(GT.TaxRate,0))/100  ELSE ((SalePriceSingle+AddPax* @ExAdult+AddChild*@ExChild)*ISNULL(GT.TaxRate,0))/100 END TaxAmount
				from @dtProducts DT
				inner join Products.RoomPriceNew PRP on PRP.ItemID=DT.ProductId
				inner join Products.Tax PT on DT.ProductId=PT.ItemID
				inner join general.Tax GT on GT.TaxID=PT.TaxID
				and PRP.IsApproved=1
				group by DT.ProductId,TaxName,PT.TaxID,TaxRate,BasePrice,SalePriceSingle,AddPax,AddChild

			END

			ELSE --Corporate and Company
			BEGIN
				select PRP.ItemID,ItemName,Name as SubCategory,SUB.SubCategoryID,FromDate,
			 
				ISNULL(@NoOfAdults,0) as Adult,
				ISNULL(@NoOfChilds,0) as Child	
				,@IntExAdult ExAdult,
				@IntExChild ExChild,
				@IntExChildSr ExChildSr,
				@NoOfRooms RoomCount,
				case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END as SalePrice, --as UnitBaseRate, 
				case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END as FixSaleprice,
				(@DiscountPercentage * (case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END) /100) as Discount,--as UnitDiscountAmt,
				(case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END)-(@DiscountPercentage * (case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END) /100) as BeforeTax, --as UnitBaserateAD, --Baseprice after discount
				isnull(max(GT.TaxRate),0) as TotalTax,--TotalTaxPer,
				DT.RoomCount*(isnull(max(GT.TaxRate),0) * ((case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END)-(@DiscountPercentage * (case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END) /100)) /100) as  TaxAmount,-- as UnitTaxAmt,
				((case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END)-(@DiscountPercentage * (case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END) /100)+(isnull(sum(GT.TaxRate),0) * ((case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END)-(@DiscountPercentage * (case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END) /100)) /100)) as NetTotal,-- as UnitNetRate,  --After discount and with Tax
				((case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END)-(@DiscountPercentage * (case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END) /100)+(isnull(sum(GT.TaxRate),0) * ((case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END)-(@DiscountPercentage * (case when @IntExAdult>0 OR @IntExChild>0 OR @IntExChildSr>0 then PRP.BasePrice + (@IntExAdult*ISNULL(prp.AddPax,0)) + (@IntExChild*ISNULL(prp.AddChild,0)) + (@IntExChildSr*ISNULL(prp.AddChildSr,0)) else PRP.BasePrice END) /100)) /100)) * DT.RoomCount as LineTotal
				,@NoOfRooms RoomCount
				from Products.Item PIT				
				inner join @dtProducts DT on PIT.ItemID=DT.ProductId				
				inner join [company].[RoomPriceNew] PRP on DT.ProductId=PRP.ItemID			
				inner join Products.SubCategory SUB on PIT.SubCategoryID=SUB.SubCategoryID			
				inner join Products.Tax PT on PIT.ItemID=PT.ItemID				
			
				inner join general.Tax GT on PT.TaxID=GT.TaxID
				where PRP.FromDate between CONVERT(VARCHAR(10),@ExpectedCheckInDate,111) and DATEADD(DAY,-1,CONVERT(VARCHAR(10),@ExpectedCheckOutDate,111)) 
				and PRP.IsApproved=1
				group by  PRP.ItemID,ItemName,Name,SUB.SubCategoryID,FromDate,BasePrice,SalePriceSingle,AddPax,AddChild,Discount
				,DT.RoomCount,ISNULL(prp.AddChildSr,0)	order by ItemID			
				

				select DT.ProductId,TaxName,PT.TaxID,TaxRate
				, CASE WHEN @NoOfAdults>1 OR @NoOfChilds>0 THEN ((PRP.BasePrice)*ISNULL(GT.TaxRate,0))/100  ELSE ((PRP.BasePrice)*ISNULL(GT.TaxRate,0))/100 END TaxAmount
				from @dtProducts DT
				inner join company.RoomPriceNew PRP on PRP.ItemID=DT.ProductId
				inner join Products.Tax PT on DT.ProductId=PT.ItemID
				inner join general.Tax GT on GT.TaxID=PT.TaxID
				where PRP.IsApproved=1
				group by DT.ProductId,TaxName,PT.TaxID,TaxRate,BasePrice
		 
			END
END
