declare @m		 as int  =  1, --AY GİRİLİR
		@BaseDay as Date =	CAST(GETDATE()	 AS DATE),
		@d       AS INT  =  1,
		@DailySP AS Date =  CAST(GETDATE()-1 AS DATE)
		IF DAY(@BaseDay) = 1
		   BEGIN
		   SET @m = @m + 1
		   END
;
WITH UserBasedCTE AS
(
		select count(Id)							   TxCount
			  ,sum(Amount)							   TotalVolume
			  ,cast(CreateDate as date)			   	   [Date]
			  ,MAX(Age)			 Age 
			  ,MAX(TenureByYear) TenureByYear
			  ,UserKey
		--	  ,ISNULL(PosMerchantCategoryId			,10000) PosMerchantCategoryId		
			  ,ISNULL(RecognizedBrandId	,10000)	RecognizedBrandId
			  ,ISNULL(Is_Offline				,10000)	Is_Offline			
			  ,ISNULL(Is_Domestic					,10000)	Is_Domestic				
			  --,ISNULL(IsSplittedTransaction				,10000)	IsSplittedTransaction			
			  --,ISNULL(IsSplitTransactionFulfilled		,10000)	IsSplitTransactionFulfilled		
			  --,ISNULL(GenericPOSEntryMode			  ,'10000')	GenericPOSEntryMode			
			  ,ISNULL(HasCashbackReward			,10000)	HasCashbackReward		
			  --,ISNULL(IsOrderedCard					,10000)	IsOrderedCard				
			  --,ISNULL(CardCategoriesId			,10000)	CardCategoriesId		
			  --,ISNULL(Physical				,10000)	Physical				
			  --,ISNULL(CardPropertyType				,10000)	CardPropertyType				
			  --,ISNULL(CardVisualType				,10000)	CardVisualType
			  --,ISNULL(DIM_UserCards_CardPropertyTypeId  ,10000) DIM_UserCards_CardPropertyTypeId
			  ,ISNULL(CityCodeTR				,10000) CityCodeTR
		from (
				select '0' MetricType,l.Id,l.CreateDate,l.UserKey,l.Amount/*'A' Currency,*/
		--		 l.EntryType
				,ISNULL(cast(l.RecognizedBrandId as int),-100) RecognizedBrandId
			--	,ISNULL(cast(l.PosMerchantCategoryId		  as int),-100) PosMerchantCategoryId		
				,ISNULL(cast(l.Is_Offline			  as int),-100) Is_Offline			
				,ISNULL(cast(l.Is_Domestic			  as int),-100) Is_Domestic				
				--,ISNULL(cast(l.IsSplittedTransaction			  as int),-100) IsSplittedTransaction			
				--,ISNULL(cast(l.IsSplitTransactionFulfilled	  as int),-100) IsSplitTransactionFulfilled
				--,ISNULL(cast(ucc.Id				  as int),-100) DIM_UserCards_CardPropertyTypeId
				--,ISNULL(l.GenericPOSEntryMode			 ,'-100') GenericPOSEntryMode			
				,IIF(l.ConditionId					   IS NULL,0,1) HasCashbackReward
				,ISNULL(cast(l.CityCodeTR			  as int),-100) CityCodeTR
				,DATEDIFF(DAY,U.CreateDate,l.CreateDate)/365.25		TenureByYear		
				,CASE WHEN YEAR(DateOfBirth) >= 1900 AND YEAR(DateOfBirth) < 2020 THEN DATEDIFF(DAY,DateOfBirth,l.CreateDate) ELSE NULL END/365.25		Age		
--						,ISNULL(cast(ucc.CardCategoriesId as int),-100) CardCategoriesId
	--			,ISNULL(CAST(P.CardVisualType AS int),-100) CardVisualType--,ucc.Physical,ucc.CardPropertyType,ucc.CardVisualType,ucc.IsOrderedCard
				FROM (select l.Id,l.UserKey,l.Amount,l.CreateDate,IIF(l.RecognizedBrandId IS NULL,-80,L.RecognizedBrandId) RecognizedBrandId,/*l.PosMerchantCategoryId,*/l.Is_Offline,l.Is_Domestic,/*l.IsSplittedTransaction,l.IsSplitTransactionFulfilled,l.CompanyCardId,*/l.ConditionId
				,CASE
/*Adana*/     	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('1','01')																 OR upper(trim(LD.City)) like '%DANA%'	   ) then 1
/*Adıyaman*/  	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('2','02')																 OR upper(trim(LD.City)) like '%YAMAN%'	   ) then 2
/*Afyon*/     	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('3','03')																 OR upper(trim(LD.City)) like 'AFY%'	   ) then 3
/*Ağrı*/      	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('4','04','A?R?','DOGUBAYAZIT','A?RI')									 OR upper(trim(LD.City)) like 'AGR%'	or ((upper(trim(LD.City)) like 'A%R' OR upper(trim(LD.City)) like 'A%R%') and len(upper(trim(LD.City)))=4 and upper(trim(LD.City)) NOT like '%NK%') or (upper(trim(LD.City)) like 'A%R%' and upper(trim(LD.City)) not like '%NK%'and upper(trim(LD.City)) not like '%ANK' and upper(trim(LD.City)) not like '%URFA' and upper(trim(LD.City)) not like 'AK%'  and upper(trim(LD.City)) not like 'AR%'  and upper(trim(LD.City)) not like 'AD%'  and upper(trim(LD.City)) not like 'AT%')) then 4
/*Amasya*/    	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('5','05')																 OR upper(trim(LD.City)) like '%MASY%'	   ) then 5
/*Ankara*/    	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('6','06','CANKAYA','ETIMESGUT','KECIOREN','SINCAN','KAHRAMANKAZAN')	 OR upper(trim(LD.City)) like '%NKARA%'	   ) then 6
/*Antalya*/   	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('7','07','MURATPASA','KEMER','MANAVGAT','FINIKE','KEPEZ')				 OR upper(trim(LD.City)) like '%TALY%'	   ) then 7
/*Artvin*/    	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('8','08')																 OR upper(trim(LD.City)) like '%RTV%'	   ) then 8
/*Aydın*/     	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('9','09')																 OR upper(trim(LD.City)) like '%AYD%'	   ) then 9
/*Balıkesir*/ 	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('10','BANDIRMA')														 OR upper(trim(LD.City)) like 'BAL%KES%'   ) then 10
/*Bilecik*/   	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('11')																	 OR upper(trim(LD.City)) like 'B%LEC%K'	   ) then 11
/*Bingöl*/    	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('12')																	 OR upper(trim(LD.City)) like 'B%NG%L'	   ) then 12
/*Bitlis*/    	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('13')																	 OR upper(trim(LD.City)) like 'B%TL%S'	   ) then 13
/*Bolu*/      	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('14')																	 OR upper(trim(LD.City)) like 'BOL_%'	   ) then 14
/*Burdur*/    	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('15')																	 OR upper(trim(LD.City)) like '%BURDU%'	   ) then 15
/*Bursa*/     	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('16','NILUFER','GEMLIK','YENISEHIR','YILDIRIM')						 OR upper(trim(LD.City)) like '%BURS%'	   ) then 16
/*Çanakkale*/ 	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('17','CANAKLE','ÝANAKLE')												 OR upper(trim(LD.City)) like '%NAKKAL%' OR upper(trim(LD.City)) like '%NAKAL%'	 or upper(trim(LD.City)) like '%ANAKLE')  then 17
/*Çankırı*/   	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('18')																	 OR upper(trim(LD.City)) like '%ANK%R%'	   ) then 18
/*Çorum*/     	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('19')																	 OR upper(trim(LD.City)) like '%ORUM%'	   ) then 19
/*Denizli*/   	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('20','MERKEZEFENDI','MERKEZ')											 OR upper(trim(LD.City)) like 'DEN%ZL%'	   ) then 20
/*Diyarbakır*/	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('21')																	 OR upper(trim(LD.City)) like 'D%YARBAK%'  ) then 21
/*Edirne*/    	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('22','KESAN')															 OR upper(trim(LD.City)) like 'ED%RN%'	   ) then 22
/*Elazığ*/    	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('23')																	 OR upper(trim(LD.City)) like 'ELAZ%'	   ) then 23
/*Erzincan*/  	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('24')																	 OR upper(trim(LD.City)) like 'ERZ%NCAN%'  ) then 24
/*Erzurum*/   	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('25','YAKUTIYE')														 OR upper(trim(LD.City)) like 'ERZ_RUM%'   ) then 25
/*Eskişehir*/    when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('26','SEYITGAZI')														 OR upper(trim(LD.City)) like 'ESK%EH%'	   ) then 26
/*Gaziantep*/    when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('27','SEHITKAMIL','SAHINBEY')											 OR upper(trim(LD.City)) like 'GAZ%ANT%'   ) then 27
/*Giresun*/   	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('28')																	 OR upper(trim(LD.City)) like 'G%RES%'	   ) then 28
/*Gümüşhane*/    when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('29')																	 OR upper(trim(LD.City)) like 'G%M%HANE%'  ) then 29
/*Hakkari*/   	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('30')																	 OR upper(trim(LD.City)) like 'HAKKAR%'	   ) then 30
/*Hatay*/   	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('31','ANTAKYA','DORTYOL')												 OR upper(trim(LD.City)) like 'HATAY%'	   ) then 31
/*Isparta*/ 	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('32')																	 OR upper(trim(LD.City)) like '_SPART%'	   ) then 32
/*Mersin*/   	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('33','ICEL')															 OR upper(trim(LD.City)) like 'MERS%' OR (upper(trim(LD.City)) like '%EL' and upper(trim(LD.City)) not like 'K%')) then 33
/*İstanbul*/     when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('34','GAZIOSMANPASA','IST','USKUDAR','PENDIK','TUZLA','KUCUKCEKMECE','BUYUKCEKMECE','CEKMEKOY','BEYKOZ','KADIKOY','ATASEHIR','ADALAR','BAKIRKOY','BAGCILAR','BEYLIKDUZU','FATIH','ESENYURT','ESENLER','EYUPSULTAN','MALTEPE','UMRANIYE','SISLI','BAHCELIEVLER') OR upper(trim(LD.City)) like '%STANBU%')  then 34
/*İzmir*/   	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('35','BORNOVA','URLA','MENEMEN','CIGLI','BEYDAG','BALCOVA','KARSIYAKA') OR upper(trim(LD.City)) like '%ZM%R'	   ) then 35
/*Kars*/   		 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('36')																	 OR upper(trim(LD.City)) like 'KARS'	   ) then 36
/*Kastamonu*/    when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('37')																	 OR upper(trim(LD.City)) like 'KASTAM%'	   ) then 37
/*Kayseri*/  	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('38','MELIKGAZI','TALAS','DEVELI')										 OR upper(trim(LD.City)) like 'KAYSER%'	   ) then 38
/*Kırklareli*/   when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('39','LULEBURGAZ')														 OR upper(trim(LD.City)) like 'K%RKLARE%'  ) then 39
/*Kırşehir*/   	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('40','KÙRÚEHIR')														 OR upper(trim(LD.City)) like 'K%R%EH%R'   ) then 40
/*Kocaeli*/  	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('41','IZMIT','KORFEZ','DARICA')										 OR upper(trim(LD.City)) like 'KOCAEL%'	   ) then 41
/*Konya*/		 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('42','SELCUKLU')														 OR upper(trim(LD.City)) like 'KONY%'	   ) then 42
/*Kütahya*/ 	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('43','TAVSANLI','KUTAHTA')												 OR upper(trim(LD.City)) like 'K%TAHY%'	   ) then 43
/*Malatya*/ 	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('44','BATTALGAZI')														 OR upper(trim(LD.City)) like 'MALATY%'	   ) then 44
/*Manisa*/  	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('45')																	 OR upper(trim(LD.City)) like 'MAN%S%'	   ) then 45
/*Kahramanmaraş*/when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('46','GOKSUN','ONIKISUBAT','KAHRAMANMAR')								 OR upper(trim(LD.City)) like '%MARA%'	   ) then 46
/*Mardin*/   	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('47')																	 OR upper(trim(LD.City)) like 'MARD%'	   ) then 47
/*Muğla*/   	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('48','BODRUM')															 OR upper(trim(LD.City)) like 'MU%LA%'	   ) then 48
/*Muş*/   		 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('49')																	 OR upper(trim(LD.City)) like 'MU%'		   ) then 49
/*Nevşehir*/     when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('50')																	 OR upper(trim(LD.City)) like 'NEV%EH%'	   ) then 50
/*Niğde*/   	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('51')																	 OR upper(trim(LD.City)) like 'N%DE%'	   ) then 51
/*Ordu*/   		 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('52')																	 OR upper(trim(LD.City)) like 'ORD%'	   ) then 52
/*Rize*/   		 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('53')																	 OR upper(trim(LD.City)) like 'R%ZE%'	   ) then 53
/*Sakarya*/   	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('54','ADAPAZARI','KOCAALI')											 OR upper(trim(LD.City)) like 'SAKARY%'	   ) then 54
/*Samsun*/   	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('55','TEKKEKOY','ILKADIM','SALIPAZARI')								 OR upper(trim(LD.City)) like 'SAMS%'	   ) then 55
/*Siirt*/   	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('56')																	 OR upper(trim(LD.City)) like 'S%RT%'	   ) then 56
/*Sinop*/   	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('57')																	 OR upper(trim(LD.City)) like 'S_NOP%'	   ) then 57
/*Sivas*/   	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('58')																	 OR upper(trim(LD.City)) like 'S%VAS%'	   ) then 58
/*Tekirdağ*/   	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('59','CORLU','SARAY','CERKEZKOY')										 OR upper(trim(LD.City)) like 'TEK%RD%'	   ) then 59
/*Tokat*/   	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('60','ERBAA')															 OR upper(trim(LD.City)) like 'TOKA%'	   ) then 60
/*Trabzon*/   	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('61','ORTAHISAR')														 OR upper(trim(LD.City)) like 'TRABZ%'	   ) then 61
/*Tunceli*/   	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('62')																	 OR upper(trim(LD.City)) like 'TUNCE%'	   ) then 62
/*Urfa*/     	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('63','HALILIYE','KARAKOPRU')											 OR upper(trim(LD.City)) like '%URFA%'	   ) then 63
/*Uşak*/   		 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('64')																	 OR upper(trim(LD.City)) like 'U%AK%'	   ) then 64
/*Van*/   		 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('65')																	 OR upper(trim(LD.City)) like 'VAN%'	   ) then 65
/*Yozgat*/   	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('66')																	 OR upper(trim(LD.City)) like 'YOZG%'	   ) then 66
/*Zonguldak*/    when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('67')																	 OR upper(trim(LD.City)) like 'ZONG%'	   ) then 67
/*Aksaray*/   	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('68')																	 OR upper(trim(LD.City)) like 'AKSAR%'	   ) then 68
/*Bayburt*/   	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('69')																	 OR upper(trim(LD.City)) like 'BAYB%'	   ) then 69
/*Karaman*/   	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('70')																	 OR upper(trim(LD.City)) like 'KARAM%'	   ) then 70
/*Kırıkkale*/    when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('71')																	 OR upper(trim(LD.City)) like 'K%R%KK%'	   ) then 71
/*Batman*/   	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('72')																	 OR upper(trim(LD.City)) like 'BATM%'	   ) then 72
/*Şırnak*/   	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('73')																	 OR upper(trim(LD.City)) like '__RNAK%'	   ) then 73
/*Bartın*/   	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('74')																	 OR upper(trim(LD.City)) like 'BART%N'	   ) then 74
/*Ardahan*/   	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('75')																	 OR upper(trim(LD.City)) like 'ARDAH%'	   ) then 75
/*Iğdır*/   	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('76','I?D?R')															 OR upper(trim(LD.City)) like '_%D%R'	   ) then 76
/*Yalova*/   	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('77')																	 OR upper(trim(LD.City)) like 'YALOV%'	   ) then 77
/*Karabük*/   	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('78')																	 OR upper(trim(LD.City)) like 'KARAB%'	   ) then 78
/*Kilis*/   	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('79')																	 OR upper(trim(LD.City)) like 'K%L%S'	   ) then 79
/*Osmaniye*/     when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('80')																	 OR upper(trim(LD.City)) like 'OSMAN%Y%'   ) then 80
/*Düzce*/   	 when Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('81')																	 OR upper(trim(LD.City)) like 'D%ZC%'	   ) then 81
/*KKTC*/		 WHEN Is_Offline = 1 and Is_Domestic = 0 AND (upper(trim(LD.City)) IN ('GUZELYURT','KUZEY KIBRIS','G?RNE','KIBRIS','MAGUSA','K.K.T.C.','LEFKOSA','MAGOSA','ISKELE','KKTC','LEFKE','GIRNE','GAZIMAGUSA')) then 99
else -99
END CityCodeTR
				
					  from [DWH_Company].[dbo].[FACT_Transactions] l WITH (Nolock)
					  join [DWH_Company].dbo.[FACT_Transactions_Details] ld  with (nolock) on l.Id = ld.Id 
					  where EntryType = 2 and CompanyCardTxType = 1 AND IsCancellation = 0 AND OperatorUserKey IS NULL AND CreateDate >= dateadd(day, 1, eomonth(@BaseDay, -@m)) AND CreateDate < @BaseDay /*and UserKey = 12058754*/) L
	--			JOIN DIM_CompanyCards p			with (nolock) on L.CompanyCardId = p.Id
	--			JOIN DIM_UserCards_CardPropertyType ucc with (nolock) on p.[Type]	    = ucc.CardPropertyType AND p.CardVisualType = ucc.CardVisualType	
				JOIN DIM_Users u with (nolock)  on u.User_Key = l.UserKey
			 ) m1																							
		group by  UserKey
				 ,cast(m1.CreateDate as date)
				 ,cube(
					  -- PosMerchantCategoryId
					   RecognizedBrandId
					  ,Is_Offline
					  ,Is_Domestic
					  --,IsSplittedTransaction
					  --,IsSplitTransactionFulfilled
				--	  ,GenericPOSEntryMode
					  ,HasCashbackReward
					  --,DIM_UserCards_CardPropertyTypeId
					  ,CityCodeTR
				--	  ,IsOrderedCard
				--    ,CardCategoriesId
					  ----,Physical
					  ----,CardPropertyType
						--,CardVisualType
					  )
), DailyWithAndWithoutMTD AS
					(
					Select
						 [Date]
						,CityCodeTR/*,PosMerchantCategoryId*/,RecognizedBrandId,Is_Offline,Is_Domestic,HasCashbackReward
						,COUNT(DISTINCT UserKey) UUDaily
						,SUM(TxCount)			 TxCountDaily
						,SUM(ABS(TotalVolume))	 TxVolumeDaily
						,SUM(Age)/count(case when Age IS NOT NULL THEN 1 else NULL END)			AvgAge
						,AVG(TenureByYear)		 AvgTenureByYear
						,SUM(SUM(TxCount))			OVER (PARTITION BY YEAR([Date]),MONTH([Date]),CityCodeTR,RecognizedBrandId,Is_Offline,Is_Domestic,HasCashbackReward ORDER BY [Date]) TxCountMTD
						,SUM(SUM(ABS(TotalVolume))) OVER (PARTITION BY YEAR([Date]),MONTH([Date]),CityCodeTR,RecognizedBrandId,Is_Offline,Is_Domestic,HasCashbackReward ORDER BY [Date]) TxVolumeMTD
					From UserBasedCTE
					--Where [Date] = @DailySP
					Group By [Date],CityCodeTR/*,PosMerchantCategoryId*/,RecognizedBrandId,Is_Offline,Is_Domestic,HasCashbackReward
					)
 , DailyWithMTDForUU  AS
				    (
					SELECT [Date]
						   ,CityCodeTR/*,PosMerchantCategoryId*/,RecognizedBrandId,Is_Offline,Is_Domestic,HasCashbackReward
						   ,MAX(Ranker) UUMTD
					FROM
							(
							select
								 [Date]
								,UserKey
								,CityCodeTR/*,PosMerchantCategoryId*/,RecognizedBrandId,Is_Offline,Is_Domestic,HasCashbackReward
								,RANK() OVER (Partition by YEAR([Date]),MONTH([Date]),CityCodeTR/*,PosMerchantCategoryId*/,RecognizedBrandId,Is_Offline,Is_Domestic,HasCashbackReward Order By [Date],UserKey) Ranker
							from
									(
									select MIN([Date]) [Date]
										  ,UserKey
										  ,CityCodeTR/*,PosMerchantCategoryId*/,RecognizedBrandId,Is_Offline,Is_Domestic,HasCashbackReward
									from UserBasedCTE
									group by UserKey,CityCodeTR/*,PosMerchantCategoryId*/,RecognizedBrandId,Is_Offline,Is_Domestic,HasCashbackReward
									) z
							  ) T
					GROUP BY [Date],CityCodeTR/*,PosMerchantCategoryId*/,RecognizedBrandId,Is_Offline,Is_Domestic,HasCashbackReward
				    )
					INSERT INTO DWH_Workspace..FACT_RecognizedBrandAndCityAnalysis
				    select m1.[Date]
						  ,m1.CityCodeTR,m1.RecognizedBrandId,m1.Is_Offline,m1.Is_Domestic,m1.HasCashbackReward
						  ,m1.UUDaily
						  ,m1.TxCountDaily
						  ,m1.TxVolumeDaily
						  ,m2.UUMTD
						  ,m1.TxCountMTD
						  ,m1.TxVolumeMTD
						  ,m1.AvgAge
						  ,m1.AvgTenureByYear
			--		INTO DWH_Workspace..FACT_RecognizedBrandAndCityAnalysis
					from DailyWithAndWithoutMTD m1
	/*FULL?*/		LEFT join DailyWithMTDForUU m2 on m1.[Date] = m2.[Date] and m1.CityCodeTR = m2.CityCodeTR and m1.RecognizedBrandId = m2.RecognizedBrandId and m1.Is_Offline = m2.Is_Offline and m1.Is_Domestic = m2.Is_Domestic and m1.HasCashbackReward = m2.HasCashbackReward
					where m1.[Date] = @DailySP
;
WITH RawData AS
	(
			SELECT 
				DISTINCT D.CreateDatee/*@DailySP*/ [Date], CityCodeTR, RecognizedBrandId, Is_Offline, Is_Domestic, HasCashbackReward
			FROM (SELECT * FROM  DWH_Workspace..FACT_RecognizedBrandAndCityAnalysis WITH (NOLOCK) WHERE Date >= dateadd(day, 1, eomonth(@BaseDay, -@m)) AND Date < @BaseDay) x
			CROSS JOIN DIM_Date D WITH (NOLOCK) 
			WHERE D.CreateDatee >= dateadd(day, 1, eomonth(@BaseDay, -@m)) AND D.CreateDatee < @BaseDay
	), RD2 AS 
	(
			SELECT
				 RJ.[Date]
				,RJ.CityCodeTR
				,RJ.RecognizedBrandId
				,RJ.Is_Offline
				,RJ.Is_Domestic
				,RJ.HasCashbackReward
				,ISNULL(SK.UUDaily				,0) UUDaily	
				,ISNULL(SK.TxCountDaily 		,0)	TxCountDaily 		
				,ISNULL(SK.TxVolumeDaily		,0)	TxVolumeDaily		
				,SK.UUMTD
				,SK.TxCountMTD
				,SK.TxVolumeMTD
				,ISNULL(SK.AvgAge				,0)	AvgAge	
				,ISNULL(SK.AvgTenureByYear		,0)	ApprovedUUTxCount
	FROM RawData RJ
	LEFT JOIN  DWH_Workspace..FACT_RecognizedBrandAndCityAnalysis SK ON SK.[Date] = RJ.[Date] AND SK.CityCodeTR = RJ.CityCodeTR AND SK.RecognizedBrandId = RJ.RecognizedBrandId AND SK.Is_Offline = RJ.Is_Offline AND SK.Is_Domestic = RJ.Is_Domestic AND SK.HasCashbackReward = RJ.HasCashbackReward
																	--	AND SK.[Date] = @DailySP
	)
		INSERT INTO  DWH_Workspace..FACT_RecognizedBrandAndCityAnalysis
		SELECT
			R.*
		FROM RD2 R
		LEFT JOIN (SELECT * FROM  DWH_Workspace..FACT_RecognizedBrandAndCityAnalysis WHERE [Date] >= dateadd(day, 1, eomonth(@BaseDay, -@m)) and [Date] < @BaseDay) ETM
		ON 
			R.[Date]					= ETM.[Date]
		AND R.CityCodeTR				= ETM.CityCodeTR
		AND R.RecognizedBrandId	= ETM.RecognizedBrandId
		AND R.Is_Offline				= ETM.Is_Offline
		AND R.Is_Domestic					= ETM.Is_Domestic
		AND R.HasCashbackReward			= ETM.HasCashbackReward
		WHERE ETM.CityCodeTR			 IS NULL
		  AND ETM.RecognizedBrandId IS NULL
		  AND ETM.Is_Offline			 IS NULL
		  AND ETM.Is_Domestic				 IS NULL
		  AND ETM.HasCashbackReward 	 IS NULL


		--SELECT * FROM RD2		
		--EXCEPT
		--SELECT * FROM  DWH_Workspace..FACT_RecognizedBrandAndCityAnalysis WHERE [Date] >= dateadd(day, 1, eomonth(getdate(), -@m)) and [Date] < @BaseDay--= @DailySP--

--DELETE A FROM  DWH_Workspace..FACT_RecognizedBrandAndCityAnalysis A
--	   JOIN
--			(
--				SELECT RecognizedBrandId,CityCodeTR, Is_Offline, Is_Domestic, HasCashbackReward, MoneyTransferType, EntrySubType, Is_Offline, YEAR([Date]) YD,MONTH([Date]) MD FROM  DWH_Workspace..FACT_RecognizedBrandAndCityAnalysis GROUP BY RecognizedBrandId,CityCodeTR, Is_Offline, Is_Domestic, HasCashbackReward, MoneyTransferType, EntrySubType, Is_Offline, YEAR([Date]), MONTH([Date]) HAVING COUNT(UUMTD) = 0
--			) B ON MONTH(A.[Date]) = MD AND YEAR(A.[Date]) = YD AND A.CityCodeTR = B.CityCodeTR AND A.RecognizedBrandId = B.RecognizedBrandId AND A.Is_Offline = B.Is_Offline AND A.Is_Domestic = B.Is_Domestic AND A.HasCashbackReward = B.HasCashbackReward AND A.MoneyTransferType = B.MoneyTransferType AND A.EntrySubType = B.EntrySubType AND A.Is_Offline = B.Is_Offline

--SELECT * FROM FACT_Is_OfflineMetricAnalysiswithMTD WHERE UUMTD IS NULL



	UPDATE  DWH_Workspace..FACT_RecognizedBrandAndCityAnalysis
		SET UUMTD = 0
	FROM  DWH_Workspace..FACT_RecognizedBrandAndCityAnalysis
	WHERE UUMTD is null AND [Date] = dateadd(day, 1, eomonth(@BaseDay, -@m))

	UPDATE  DWH_Workspace..FACT_RecognizedBrandAndCityAnalysis
		SET TxCountMTD = 0
	FROM  DWH_Workspace..FACT_RecognizedBrandAndCityAnalysis
	WHERE TxCountMTD is null AND [Date] = dateadd(day, 1, eomonth(@BaseDay, -@m))
	
	UPDATE  DWH_Workspace..FACT_RecognizedBrandAndCityAnalysis
		SET TxVolumeMTD = 0
	FROM  DWH_Workspace..FACT_RecognizedBrandAndCityAnalysis
	WHERE TxVolumeMTD is null AND [Date] = dateadd(day, 1, eomonth(@BaseDay, -@m))

		WHILE (SELECT COUNT([Date]) FROM  DWH_Workspace..FACT_RecognizedBrandAndCityAnalysis WHERE UUMTD IS NULL AND [Date] >= dateadd(day, 1, eomonth(@BaseDay, -@m)) AND [Date] < @BaseDay) != 0
		BEGIN
		UPDATE Z1
		set Z1.UUMTD = Z2.UUMTD    
		from  DWH_Workspace..FACT_RecognizedBrandAndCityAnalysis Z1
		join  DWH_Workspace..FACT_RecognizedBrandAndCityAnalysis Z2 on dateadd(DAY,1,Z2.[Date]) = Z1.[Date] AND YEAR(dateadd(DAY,1,Z2.[Date])) = YEAR(Z1.[Date]) AND MONTH(dateadd(DAY,1,Z2.[Date])) = MONTH(Z1.[Date]) AND Z1.Is_Offline = Z2.Is_Offline AND Z1.HasCashbackReward = Z2.HasCashbackReward AND Z1.Is_Domestic = Z2.Is_Domestic AND Z1.CityCodeTR = Z2.CityCodeTR AND Z1.RecognizedBrandId = Z2.RecognizedBrandId
		where  Z1.UUMTD is null AND Z2.UUMTD IS NOT NULL and z1.[Date] >= dateadd(day, 1, eomonth(@BaseDay, -@m)) AND Z1.[Date] < @BaseDay and z2.[Date] >= dateadd(day, 1, eomonth(@BaseDay, -@m)) AND Z2.[Date] < @BaseDay
		end

		WHILE (SELECT COUNT([Date]) FROM  DWH_Workspace..FACT_RecognizedBrandAndCityAnalysis WHERE TxCountMTD IS NULL AND [Date] >= dateadd(day, 1, eomonth(@BaseDay, -@m)) AND [Date] < @BaseDay) != 0
		BEGIN
		UPDATE Z1
		set Z1.TxCountMTD = Z2.TxCountMTD    
		from  DWH_Workspace..FACT_RecognizedBrandAndCityAnalysis Z1
		join  DWH_Workspace..FACT_RecognizedBrandAndCityAnalysis Z2 on dateadd(DAY,1,Z2.[Date]) = Z1.[Date] AND YEAR(dateadd(DAY,1,Z2.[Date])) = YEAR(Z1.[Date]) AND MONTH(dateadd(DAY,1,Z2.[Date])) = MONTH(Z1.[Date]) AND Z1.Is_Offline = Z2.Is_Offline AND Z1.HasCashbackReward = Z2.HasCashbackReward AND Z1.Is_Domestic = Z2.Is_Domestic AND Z1.CityCodeTR = Z2.CityCodeTR AND Z1.RecognizedBrandId = Z2.RecognizedBrandId
		where  Z1.TxCountMTD is null AND Z2.TxCountMTD IS NOT NULL and z1.[Date] >= dateadd(day, 1, eomonth(@BaseDay, -@m)) AND Z1.[Date] < @BaseDay and z2.[Date] >= dateadd(day, 1, eomonth(@BaseDay, -@m)) AND Z2.[Date] < @BaseDay
		end

		WHILE (SELECT COUNT([Date]) FROM  DWH_Workspace..FACT_RecognizedBrandAndCityAnalysis WHERE TxVolumeMTD IS NULL AND [Date] >= dateadd(day, 1, eomonth(@BaseDay, -@m)) AND [Date] < @BaseDay) != 0
		BEGIN
		UPDATE Z1
		set Z1.TxVolumeMTD = Z2.TxVolumeMTD    
		from  DWH_Workspace..FACT_RecognizedBrandAndCityAnalysis Z1
		join  DWH_Workspace..FACT_RecognizedBrandAndCityAnalysis Z2 on dateadd(DAY,1,Z2.[Date]) = Z1.[Date] AND YEAR(dateadd(DAY,1,Z2.[Date])) = YEAR(Z1.[Date]) AND MONTH(dateadd(DAY,1,Z2.[Date])) = MONTH(Z1.[Date]) AND Z1.Is_Offline = Z2.Is_Offline AND Z1.HasCashbackReward = Z2.HasCashbackReward AND Z1.Is_Domestic = Z2.Is_Domestic AND Z1.CityCodeTR = Z2.CityCodeTR AND Z1.RecognizedBrandId = Z2.RecognizedBrandId
		where  Z1.TxVolumeMTD is null AND Z2.TxVolumeMTD IS NOT NULL and z1.[Date] >= dateadd(day, 1, eomonth(@BaseDay, -@m)) AND Z1.[Date] < @BaseDay and z2.[Date] >= dateadd(day, 1, eomonth(@BaseDay, -@m)) AND Z2.[Date] < @BaseDay
		end