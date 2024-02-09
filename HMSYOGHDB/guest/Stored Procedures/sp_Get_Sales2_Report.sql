CREATE proc guest.sp_Get_Sales2_Report --'2/1/2024' ,'2/7/2024'
@CheckInDate date ,
@CheckOutDate date 
as
begin
select 
s2.SlNo, 
s2.RoomCategory,
s2.TotalInventory,
s2.CashNoOfOccupancy,
s2.CashRoomCharges,
s2.CashNoOfNightsSold,
s2.CashRoomNightCharges,
s2.CreditNoOfOccupancy,
s2.CreditRoomCharges,
s2.CreditNoOfNightsSold,
s2.CreditRoomNightCharges,
s2.TotalNightsSold,
s2.TotalRoomCharges,
s2.TaxAmount,
s2.TotalAmount,
s2.RoomSoldInCash,
s2.RoomSoldOnCredit,
s2.TotalRoomSold
from
 --guest.Sales2  s2 cross apply guest.Sales1 s1
 guest.Sales2  s2 inner join guest.Sales1 s1
 on s2.RoomCategory=s1.RoomType
WHERE CheckInDate >= @CheckInDate
     AND CheckOutDate <= @CheckOutDate



end




--ALTER TABLE guest.Sales2
--ADD CashNoOfOccupancy int;

--ALTER TABLE guest.Sales2
--ADD CreditNoOfOccupancy int;



--insert into  guest.Sales2(CashNoOfOccupancy, CreditNoOfOccupancy )
--values (8,10)

--delete  guest.Sales2 
--where SlNo = 3

--alter table   guest.Sales2
--where CashNoOfOccupancy = 3


--UPDATE guest.Sales2
--SET CashNoOfOccupancy = 10, CreditNoOfOccupancy = 7
--WHERE SlNo = 4;