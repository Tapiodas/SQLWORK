USE [ElektronikaiBolt]
GO
/****** Object:  UserDefinedFunction [dbo].[akt_ár]    Script Date: 2019. 04. 16. 13:05:31 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[akt_ár]
(
    
	@bem int
)
RETURNS INT
AS
BEGIN

	declare @jajj int
    select @jajj = akt_ár from Eszkoz where term_id = (select Eszköz_ID from 
	Gep_alk where Gép=@bem)
	return @jajj

END
GO
/****** Object:  UserDefinedFunction [dbo].[eszkozmeny]    Script Date: 2019. 04. 16. 13:05:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- adott termékhez szükséges anyagok akt. készletei mennyi termék legyártásához elegendők

create FUNCTION [dbo].[eszkozmeny] 
(
		@termid int
)
RETURNS int
AS
BEGIN
	DECLARE @menny int
	SELECT @menny=akt_készlet from Eszkoz where term_id=@termid

	RETURN @menny

END
GO
/****** Object:  UserDefinedFunction [dbo].[ezatuti]    Script Date: 2019. 04. 16. 13:05:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[ezatuti]
(
   
	@gep int
)
RETURNS money
AS
BEGIN
declare @ar money
declare @i int
set @i=0
set @ar=0

while(select count(Eszköz_ID) from Gep_alk WHERE Gép=@gep)!=@i
select @ar+=a.akt_ár from dbo.valami(@gep) a, Gep_alk b where b.Gép=@gep
SET @i += 1
return @ar

END
GO
/****** Object:  UserDefinedFunction [dbo].[F12]    Script Date: 2019. 04. 16. 13:05:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[F12]
()
RETURNS INT
AS
BEGIN

declare @ez int
select @ez = Term_ID from Gep 
where akt_ár < (select dbo.Feladat11(Term_ID))
return @ez
END

GO
/****** Object:  UserDefinedFunction [dbo].[F14]    Script Date: 2019. 04. 16. 13:05:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[F14] (@input int)
RETURNS date
AS
BEGIN
	declare @date date
    select @date=meddig from Árvált
	where régi_ár = 
   (select MIN(régi_ár) FROM Árvált WHERE term_id=@input) 
	return @date
END
GO
/****** Object:  UserDefinedFunction [dbo].[Feladat11]    Script Date: 2019. 04. 16. 13:05:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Feladat11](@input int)
RETURNS MONEY
AS
BEGIN

declare @ara money
    SELECT @ara = (b.akt_ár*c.Hány) from Gep a, Eszkoz b, Gep_alk c 
	where a.Term_ID = @input and a.Term_ID=c.Gép and c.Eszköz_ID=b.term_id
	return @ara
END
GO
/****** Object:  UserDefinedFunction [dbo].[feladat17]    Script Date: 2019. 04. 16. 13:05:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[feladat17]
(
    @ugyfel int
	
)
RETURNS int
AS
BEGIN
return (select o.Gép from B_Fej b,Onallogep o where b.Ügyfél_ID=@ugyfel and b.ÁTVÉTEL_DÁTUM=(select max(ÁTVÉTEL_DÁTUM) from B_Fej) and o.Bf_id=b.BF_ID
)end
GO
/****** Object:  UserDefinedFunction [dbo].[feladat8]    Script Date: 2019. 04. 16. 13:05:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[feladat8]
(
    @term int,
	@napon date
)
RETURNS money
AS
BEGIN
declare @eredm money
if exists(select régi_ár from Árvált where term_id=@term and meddig like @napon)
begin
select @eredm=régi_ár  from Árvált where term_id=@term and meddig like @napon
end else if exists(Select*from Eszkoz e where term_id=@term )
begin
Select @eredm=akt_ár from Eszkoz  where term_id=2 
end else if exists(Select*from Gep  where term_id=@term )
begin
Select @eredm=akt_ár from Gep where term_id=@term 
end

    RETURN @eredm 

END
GO
/****** Object:  UserDefinedFunction [dbo].[Fizetendo]    Script Date: 2019. 04. 16. 13:05:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Fizetendo](@input int)
RETURNS MONEY
AS
BEGIN
declare @fizetendo money
select @fizetendo = (a.akt_ár*b.Mennyiség) from Eszkoz a, B_Tétel b where BF_ID=@input
    RETURN @fizetendo

END
GO
/****** Object:  UserDefinedFunction [dbo].[GEPONARA]    Script Date: 2019. 04. 16. 13:05:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GEPONARA]
(@input int)
RETURNS MONEY
AS
BEGIN

declare @ennyi MONEY
declare @db int

select @ennyi=b.akt_ár*a.Hány

from Gep_alk a, Eszkoz b
where a.Gép=@input
return @ennyi
END
GO
/****** Object:  UserDefinedFunction [dbo].[legolcsobbTERMEK]    Script Date: 2019. 04. 16. 13:05:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--1. Adott termék mikor volt a legolcsóbb
CREATE FUNCTION [dbo].[legolcsobbTERMEK] (@input int)
RETURNS date
AS
BEGIN
	declare @date date
    select @date=meddig from Árvált
	where régi_ár = 
   (select MIN(régi_ár) FROM Árvált WHERE term_id=@input) 
	return @date
END
GO
/****** Object:  UserDefinedFunction [dbo].[LEK1]    Script Date: 2019. 04. 16. 13:05:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[LEK1] (@input char(30))
RETURNS INT
AS 
BEGIN
	 DECLARE @VAR char(30)
	 SET @VAR = @input
	 

	 DECLARE @ESZK INT



	 SET @ESZK = (SELECT Eszköz_ID 
	 FROM Gep_alk 
	 where Gép_név = (SELECT Term_ID FROM Gep WHERE Gép_név=@VAR))

RETURN @ESZK
END




GO
/****** Object:  UserDefinedFunction [dbo].[lek2]    Script Date: 2019. 04. 16. 13:05:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[lek2](@param1 int)
RETURNS INT
AS
BEGIN


	declare @id int
	set @id = @param1;


	declare @param2 int
	

	set @param2 =
	(select Eszköz_ID 
	from Gep_alk where
	Gép_név=@id)
	



    RETURN @param2

END
GO
/****** Object:  UserDefinedFunction [dbo].[termeklegolcsobb]    Script Date: 2019. 04. 16. 13:05:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[termeklegolcsobb] ( @input int)
RETURNS date
AS
BEGIN
	declare @date date
    select @date=meddig from Árvált
	where régi_ár = 
   (select MIN(régi_ár) FROM Árvált WHERE term_id=@input) 
	return @date
END
GO
/****** Object:  UserDefinedFunction [dbo].[BESZ_EL]    Script Date: 2019. 04. 16. 13:05:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[BESZ_EL]
(
    @input int
    
)
RETURNS TABLE AS RETURN
(
    select a.mennyiség as Beszerezve, b.Mennyiség as Eladva from Beszerzés1 a, B_Tétel b where a.eszköz_id=@input and b.Term_ID=@input
	
)
GO
/****** Object:  UserDefinedFunction [dbo].[eszkozokara]    Script Date: 2019. 04. 16. 13:05:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[eszkozokara]
(
    @param1 int
    
)
RETURNS TABLE AS RETURN
(
    
    select Format(akt_ár, '#,0') AS ENNYI from Eszkoz where term_id = (select * from milyeneszkozok(@param1))
	 
)
GO
/****** Object:  UserDefinedFunction [dbo].[F16]    Script Date: 2019. 04. 16. 13:05:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[F16](@a date, @b date)
RETURNS TABLE AS RETURN
(
    select a.Term_ID as Termék, a.Mennyiség as Mennyiség
	from B_Tétel a, B_Fej b
	where b.Kelt between @a and @b
)
GO
/****** Object:  UserDefinedFunction [dbo].[feladat10]    Script Date: 2019. 04. 16. 13:05:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[feladat10]()
RETURNS TABLE AS RETURN
(
    Select e_tipus as Eszköz_tipus from Eszkoz where garancia_ido
	=(SELECT max(garancia_ido) from Eszkoz)
)
GO
/****** Object:  UserDefinedFunction [dbo].[HibasBizonylatok]    Script Date: 2019. 04. 16. 13:05:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[HibasBizonylatok]
()
RETURNS TABLE AS RETURN
(
select a.BF_ID from B_Tétel a, Gep b where a.Mennyiség<>b.Akt_készlet AND A.Term_ID=B.Term_ID
)
GO
/****** Object:  UserDefinedFunction [dbo].[HibasMunkalapok]    Script Date: 2019. 04. 16. 13:05:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[HibasMunkalapok]()
RETURNS TABLE AS RETURN
(
    SELECT a.azon from Munkalap a, B_Fej b, Gep c 
	where YEAR(a.Felv_datum)-YEAR(b.Kelt)>c.garancia_ido
	and a.önállógép=b.BF_ID
	       
)
GO
/****** Object:  View [dbo].[Feladat13]    Script Date: 2019. 04. 16. 13:05:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Feladat13]
AS


    Select * from Eszkoz e, Beszerzés1 b 
	where e.term_id=b.eszköz_id and e.akt_ár<b.beszerz_ár 
	and b.dátum in (select max(dátum)from Beszerzés1 group by eszköz_id)
GO
/****** Object:  View [dbo].[Feladat18]    Script Date: 2019. 04. 16. 13:05:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[Feladat18]
AS
    Select g.Term_ID from B_Fej bf, B_Tétel bt, Gep g where bf.BF_ID=bt.BF_ID and bt.Term_ID=g.Term_ID and (year(bf.ÁTVÉTEL_DÁTUM)+g.garancia_ido)>YEAR(getdate())
GO
/****** Object:  View [dbo].[Feladat19]    Script Date: 2019. 04. 16. 13:05:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[Feladat19]
AS
	SELECT e.term_id as minimaleszköz,g.term_id as minimalgep from Eszkoz e, Gep g where e.akt_ár=(select min(akt_ár)from Eszkoz) and g.akt_ár=(select min(akt_ár)from Gep)
GO
/****** Object:  View [dbo].[garis]    Script Date: 2019. 04. 16. 13:05:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[garis]
AS
    Select g.Term_ID from B_Fej bf, B_Tétel bt, Gep g where bf.BF_ID=bt.BF_ID and bt.Term_ID=g.Term_ID and (year(bf.ÁTVÉTEL_DÁTUM)+g.garancia_ido)>YEAR(getdate())
GO
/****** Object:  View [dbo].[ViewName]    Script Date: 2019. 04. 16. 13:05:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create View [dbo].[ViewName] AS
select 
   a.mennyiség,
   COALESCE(a.mennyiség, b.Mennyiség) AS col2
from Beszerzés1 a
  left join B_Tétel b 
  on  a.mennyiség=b.Term_ID;
GO
/****** Object:  StoredProcedure [dbo].[proc20]    Script Date: 2019. 04. 16. 13:05:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[proc20]
as
begin
	select Csere_eszkoz, sum(Mennyiseg) as hány INTO #segéd
	from Cseretétel
	group by Csere_eszkoz

	select * from #segéd
	where hány=(select max(hány) from #segéd)

	drop table #segéd

end

CREATE TRIGGER [dbo].[Csökk]
   ON  [dbo].[B_Tétel]
   AFTER insert
   
AS 
BEGIN
declare @menny int,@term int;
	select @menny=Mennyiség from inserted
	select @term=Term_ID from inserted


	if EXISTS(select* from Eszkoz where term_id=@term)
	begin
	update Eszkoz
	set akt_készlet=akt_készlet-@menny from Eszkoz where term_id=@term;

	end else if EXISTS(select* from Eszkoz where term_id=@term)
	begin
	update Gep
	set Akt_készlet=Akt_készlet-@menny from Gep where term_ID=@term;
	

	end else
	raiserror('nincs elég eszköz', 10, 1)



END
GO
ALTER TABLE [dbo].[B_Tétel] ENABLE TRIGGER [Csökk]
GO
/****** Object:  Trigger [dbo].[korlat]    Script Date: 2019. 04. 16. 11:24:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[korlat]
   ON  [dbo].[B_Tétel]
   after insert,UPDATE
   
AS 
BEGIN
declare @menny int,@term int;
	select @menny=Mennyiség from inserted
	select @term=Term_ID from inserted



	if not(@menny<=(select akt_készlet from Eszkoz where term_id=@term))
	begin 
		raiserror('nincs elég eszköz', 10, 1)
	rollback tran
	end	
		if not(@menny<=(select Akt_készlet from Gep where Term_ID=@term))
	begin 
		raiserror('nincs elég gép', 10, 1)
	rollback tran
	end	



END
GO
ALTER TABLE [dbo].[B_Tétel] ENABLE TRIGGER [korlat]
GO
/****** Object:  Trigger [dbo].[Keszlet_nov]    Script Date: 2019. 04. 16. 11:24:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[Keszlet_nov]
ON [dbo].[Beszerzés1]
after INSERT, UPDATE

AS

BEGIN 




	declare @mennyi int, @eid int;
	select @mennyi=mennyiség from inserted;
	select @eid=eszköz_id from inserted;

	--set @mennyi = (select mennyiség from Beszerzés1
	--							where Besz_id = (select max(Besz_id) from Beszerzés1))

	--set @eid  = (select eszköz_id from Beszerzés1 b, Eszkoz e
	--							where b.eszköz_id=e.term_id and b.Besz_id=(select max(Besz_id) from Beszerzés1))
																
	UPDATE Eszkoz 
	SET akt_készlet = (akt_készlet + @mennyi) from Eszkoz
	WHERE term_id=@eid
	
	
	END


	
GO
ALTER TABLE [dbo].[Beszerzés1] ENABLE TRIGGER [Keszlet_nov]
GO
/****** Object:  Trigger [dbo].[Csökk.e]    Script Date: 2019. 04. 16. 11:24:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[Csökk.e]
   ON  [dbo].[Cseretétel]
   AFTER insert
   
AS 
BEGIN
declare @menny int,@cserszk int;
	select @menny=Mennyiseg from inserted
	select @cserszk=Csere_eszkoz from inserted


	if(select akt_készlet from Eszkoz where term_id=@cserszk)>=@menny
	begin
	update Eszkoz
	set selejt=selejt+@menny from Eszkoz where term_id=@cserszk;
	update Eszkoz
	set akt_készlet=akt_készlet-@menny from Eszkoz where term_id=@cserszk;
	end else raiserror('nincs elég eszköz', 10, 1)



END
GO
ALTER TABLE [dbo].[Cseretétel] ENABLE TRIGGER [Csökk.e]
GO
/****** Object:  Trigger [dbo].[arvalt]    Script Date: 2019. 04. 16. 11:24:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[arvalt]
ON [dbo].[Eszkoz]
after UPDATE

AS

BEGIN 




	declare @aktar money, @termid int, @delar int;
	select @aktar=akt_ár from inserted;
	select @termid=term_id from inserted;
	select @delar=akt_ár from deleted
	
	if(@aktar!=@delar)begin
	INSERT INTO Árvált(
term_id	,
meddig	,
régi_ár)
		
VALUES (@termid,getdate(),@aktar)
end
	
	
	END


	
GO
ALTER TABLE [dbo].[Eszkoz] ENABLE TRIGGER [arvalt]
GO
/****** Object:  Trigger [dbo].[tulaj]    Script Date: 2019. 04. 16. 11:24:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[tulaj]
ON [dbo].[Eszköz_tulajdonsagok]
after insert

AS

BEGIN 




	declare @tulaj int, @eszkoz int;
	select @tulaj=tulaj from inserted;
	select @eszkoz=Eszköz from inserted;

	--if not @tulaj=(select tulaj from Eszköz_tulajdonsagok where tulaj in(select Tulaj_ID from Tulajdonságok where e_tipus in(select e_tipus from Eszkoz where term_id=@eszkoz) and Eszköz=@eszkoz))

	if not @tulaj=1
	begin
	 raiserror('nincs ilyen paraméter', 10, 1)
		rollback tran
	end
	end






	
GO
ALTER TABLE [dbo].[Eszköz_tulajdonsagok] ENABLE TRIGGER [tulaj]
GO
/****** Object:  Trigger [dbo].[arvalt.g]    Script Date: 2019. 04. 16. 11:24:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create TRIGGER [dbo].[arvalt.g]
ON [dbo].[Gep]
after UPDATE

AS

BEGIN 




	declare @aktar money, @termid int, @delar int;
	select @aktar=akt_ár from inserted;
	select @termid=term_id from inserted;
	select @delar=akt_ár from deleted
	
	if(@aktar!=@delar)begin
	INSERT INTO Árvált(
term_id	,
meddig	,
régi_ár)
		
VALUES (@termid,getdate(),@aktar)
end
	
	
	END


	
GO
ALTER TABLE [dbo].[Gep] ENABLE TRIGGER [arvalt.g]
GO
/****** Object:  Trigger [dbo].[munkalaptorles]    Script Date: 2019. 04. 16. 11:24:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[munkalaptorles]
ON [dbo].[Munkalap]
instead of delete
AS
BEGIN
SET NOCOUNT ON;
raiserror('nem szabad', 10, 1)
END
GO
ALTER TABLE [dbo].[Munkalap] ENABLE TRIGGER [munkalaptorles]
GO
/****** Object:  Trigger [dbo].[t11]    Script Date: 2019. 04. 16. 11:24:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[t11]
    ON [dbo].[Munkalap]
    FOR INSERT
    AS
    BEGIN
	
	
	select *
	from B_Fej a, B_Tétel b, Gep c, Munkalap d 
	where b.Term_ID=c.Term_ID and (year(a.Kelt)+c.garancia_ido)>=year(GETDATE())
	

    
    END
GO
ALTER TABLE [dbo].[Munkalap] ENABLE TRIGGER [t11]
GO
/****** Object:  Trigger [dbo].[TriggerName]    Script Date: 2019. 04. 16. 11:24:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TRIGGER [dbo].[TriggerName]
    ON [dbo].[Munkalap]
    FOR INSERT
    AS
    BEGIN
	select year(a.Kelt)-year(c.garancia_ido) from B_Fej a, B_Tétel b, Gep c where b.Term_ID=c.Term_ID
    
    END
GO
ALTER TABLE [dbo].[Munkalap] ENABLE TRIGGER [TriggerName]
GO
/****** Object:  Trigger [dbo].[onallogepvalt]    Script Date: 2019. 04. 16. 11:24:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create TRIGGER [dbo].[onallogepvalt]
   ON  [dbo].[Onallogep]
   after insert,UPDATE
   
AS 
BEGIN
declare @allapot Varchar(1),@term int;
	select @allapot=Állapot from inserted;
	select @term=Gép from inserted
	if(@allapot='K')
	begin
	update Eszkoz
	SET akt_készlet = (akt_készlet -1) from Eszkoz
	WHERE term_id=(select Eszköz_ID from Gep_alk where Gép=@term) 
	

		update Gep
	SET Akt_készlet = (Akt_készlet +1) from Gep
	WHERE Term_ID=@term
	end 




END
GO
ALTER TABLE [dbo].[Onallogep] ENABLE TRIGGER [onallogepvalt]
GO
/****** Object:  Trigger [dbo].[Ujsor]    Script Date: 2019. 04. 16. 11:24:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create TRIGGER[dbo].[Ujsor]
   ON  [dbo].[Termek]
   AFTER insert
  
AS 
BEGIN
declare @e char(1),@id int
select @e=fajta from inserted
select @id=term_id from inserted


if (@e='E')
BEGIN
INSERT INTO Eszkoz( term_id	,
eszköz_név	,
e_tipus	,
garancia_ido,	
akt_készlet	)
VALUES (@id,'','','','')
end
else if  (@e='G')
BEGIN
INSERT INTO Gep( Term_id	,
Gép_név	,
Akt_készlet	,
Kateg	
	)
VALUES (@id,'a',1,1)
end

END
GO
ALTER TABLE [dbo].[Termek] ENABLE TRIGGER [Ujsor]
GO
USE [master]
GO
ALTER DATABASE [ElektronikaiBolt] SET  READ_WRITE 
GO




GO
