--Duel Mode: Pack Opening
local s,id=GetID()
function s.initial_effect(c)
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	Xyz.AddProcedure(c,nil,4,2)
	Pendulum.AddProcedure(c,false)
	--skill
	local e1=Effect.CreateEffect(c) 
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetRange(0x5f)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp)
	Duel.SendtoDeck(e:GetHandler(),tp,-2,REASON_RULE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Delete Your Cards
	s.DeleteDeck(tp)

	--Choose Game Mode
	local Option1={}
	table.insert(Option1,aux.Stringid(id,1)) --Check Deck/Pack
	table.insert(Option1,aux.Stringid(id,2)) --Rush Battle: Pick 1 Strongest Battle Deck, then pick any number of Deck Modification Packs
	table.insert(Oprion1,aux.Stringid(id,3)) --Rush Custom Deck: Choose 1 pre-constructed deck.
	local gamemod=Duel.SelectOption(tp,false,table.unpack(Option1))+1

	--If Special then Special Mode
	if gamemod==1 then s.CheckPack(e,tp) return end
	if gamemod==2 then s.RushBattle(e,tp) return end
	if gamemod==3 then s.CustomDeck(e,tp) return end
end
function s.DeleteDeck(tp)
	local del=Duel.GetFieldGroup(tp,LOCATION_EXTRA+LOCATION_HAND+LOCATION_DECK,0)
	Duel.SendtoDeck(del,tp,-2,REASON_RULE)
end
function s.CheckPack(e,tp,format,series)
	--Choose Pack
	local packlist={}
	for i=1,#s.Pack[format][series] do
		table.insert(packlist,s.Pack[format][series][i][0])
	end
	repeat
			local packopen={}
			local packid=Duel.SelectCardsFromCodes(tp,1,1,false,false,table.unpack(packlist))
			local formatid=format*10000
			local seriesid=series*100
			local pack=packid-id-formatid-seriesid
			for rarity=1,5 do
				for i=1,#s.Pack[format][series][pack][rarity] do
					table.insert(packopen,s.Pack[format][series][pack][rarity][i])
				end
			end
			Duel.SelectCardsFromCodes(tp,1,1,false,false,table.unpack(packopen))
	until Duel.SelectYesNo(tp,aux.Stringid(id,3))==0
end
function s.RushBattle(e,tp)
	--Choose Battle Deck
	local decklist={}
	for i=1,#s.Pack[2][2] do
		table.insert(decklist,s.Pack[2][2][i][0])
	end
	local deckid=Duel.SelectCardsFromCodes(tp,0,1,false,false,table.unpack(decklist))
	if deckid~=nil then
		local deck=deckid-id-20000-200
		local tc=Duel.CreateToken(tp,s.Pack[2][2][deck][0])
		Duel.MoveToField(tc,tp,tp,LOCATION_MZONE,POS_FACEUP_ATTACK,true,(1<<5))
		for code,code2 in ipairs(s.Pack[2][2][deck][1]) do
			local tc=Duel.CreateToken(tp,code2)
			Duel.SendtoDeck(tc,tp,1,REASON_RULE)
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id+10103,1))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			e1:SetValue(0)
			tc:RegisterEffect(e1)
		end
		local dg=Duel.GetFieldGroup(tp,LOCATION_DECK+LOCATION_EXTRA,0)
		Duel.ConfirmCards(tp,dg)
	end
	--Choose Deck Modification
	local num=Duel.AnnounceNumberRange(tp,1,24)
	local packlist={}
	for i=1,#s.Pack[2][3] do
		table.insert(packlist,s.Pack[2][3][i][0])
	end
	for ip=1,num do
		--Choose Pack
		local packid=Duel.SelectCardsFromCodes(tp,1,1,false,false,table.unpack(packlist))
		local pack=packid-id-20000-300
		local tc=Duel.CreateToken(tp,s.Pack[2][3][pack][0])
		Duel.MoveToField(tc,tp,tp,LOCATION_MZONE,POS_FACEUP_ATTACK,true,(1<<6))
		local cpp=s.Pack[2][3][pack][10]
		for ic=1,cpp do
			--Pack Rarity (3 Common, 1 Rare, 1 Rare+)
			local chance=Duel.GetRandomNumber(1,100)
			local rarity=1
			if ic==cpp-1 then
				rarity=2
			elseif ic==cpp then
				--Chance 4%
				if chance>0 and #s.Pack[2][3][pack][4]>0 then rarity=4 end
				--Chance 8%
				if chance>4 and #s.Pack[2][3][pack][3]>0 then rarity=3 end
				--Chance 88%
				if chance>12 and #s.Pack[2][3][pack][2]>0 then rarity=2 end
				if ip==num then rarity=4 end
			end
			--Guaraanteed 1 Ultra Rare
			--Open Pack
			local card=Duel.GetRandomNumber(1,#s.Pack[2][3][pack][rarity])
			local tc=Duel.CreateToken(tp,s.Pack[2][3][pack][rarity][card])
			if ic<4 then
				Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP_ATTACK,true,(1<<ic))
			else
				Duel.MoveToField(tc,tp,tp,LOCATION_MZONE,POS_FACEUP_ATTACK,true,(1<<ic-3))
			end
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id+10103,rarity))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			e1:SetValue(0)
			tc:RegisterEffect(e1)
		end
		local add=Duel.GetFieldGroup(tp,LOCATION_MZONE+LOCATION_SZONE,0):Filter(Card.IsSequence,nil,0,1,2,3,4):Select(tp,0,5,nil)
		Duel.SendtoDeck(add,tp,1,REASON_RULE)
		local del=Duel.GetFieldGroup(tp,LOCATION_MZONE+LOCATION_SZONE,0):Filter(Card.IsSequence,nil,0,1,2,3,4)
		Duel.SendtoDeck(del,tp,-2,REASON_RULE)
		Duel.SendtoGrave(tc,REASON_RULE)
	end

	--Add Fusion card
	local fusion=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_EXTRA,0,nil,TYPE_FUSION)
	local FusionOption={}
	if fusion>0 then
		table.insert(FusionOption,aux.Stringid(id+20102,1))
	end
	if fusion>1 then
		table.insert(FusionOption,aux.Stringid(id+20102,2))
	end
	if fusion>2 then
		table.insert(FusionOption,aux.Stringid(id+20102,3))
	end
	local FusionCount=Duel.SelectOption(tp,false,table.unpack(FusionOption))+1
	for i=1,FusionCount do
		local tc=Duel.CreateToken(tp,160204050)
		Duel.SendtoDeck(tc,tp,1,REASON_RULE)
	end
	--Delete Packs
	local del=Duel.GetFieldGroup(tp,LOCATION_ONFIELD+LOCATION_GRAVE,0)
	Duel.SendtoDeck(del,tp,-2,REASON_RULE)
end
function s.CustomDeck(e,tp)
	--Choose Battle Deck
	local decklist={}
	for i=1,#s.Pack[2][11] do
		table.insert(decklist,s.Pack[2][11][i][0])
	end
	local deckid=Duel.SelectCardsFromCodes(tp,0,1,false,false,table.unpack(decklist))
	if deckid~=nil then
		local deck=deckid-id-20000-200
		local tc=Duel.CreateToken(tp,s.Pack[2][11][deck][0])
		Duel.MoveToField(tc,tp,tp,LOCATION_MZONE,POS_FACEUP_ATTACK,true,(1<<5))
		for code,code2 in ipairs(s.Pack[2][11][deck][1]) do
			local tc=Duel.CreateToken(tp,code2)
			Duel.SendtoDeck(tc,tp,1,REASON_RULE)
		end
		if #s.Pack[2][11][deck][2]>0 then
			for code,code2 in ipairs(s.Pack[2][11][deck][2]) do
				local tc=Duel.CreateToken(tp,code2)
				Duel.SendtoDeck(tc,tp,1,REASON_RULE)
			end
		end
		local dg=Duel.GetFieldGroup(tp,LOCATION_DECK+LOCATION_EXTRA,0)
		Duel.ConfirmCards(tp,dg)
	end
end























s.Pack={}
--[Format][Series][Pack][Rarity]=ID




--Format
s.Pack[1]={} --Main Booster
s.Pack[2]={} --Rush Duel
--Series
s.Pack[1][1]={} --Series 1
s.Pack[2][1]={} --Starter Deck
s.Pack[2][2]={} --Strongest Battle Deck
s.Pack[2][3]={} --Deck Modification Pack
s.Pack[2][11]={} --Custom Deck





--Luke - Dragon's Dragons
s.Pack[2][2][2]={}
s.Pack[2][2][2][0]=1999020202
s.Pack[2][2][2][1]={160003025,160001026,160304003,160002021,160004016,160406009,160002001,160002001,160402002,160001015,160002020,160002020,160003021,160003021,160304012,160001002,160001002,160001002,160001025,160003007,160003007,160001001,160001001,160002019,160002019,160001024,160302010,160302010,160302010,160002042,160001037,160304022,160304023,160003043,160001044,160003056,160001046,160003058,160001047,160304030}
s.Pack[2][2][2][2]={}
s.Pack[2][2][2][3]={}
s.Pack[2][2][2][4]={}
s.Pack[2][2][2][5]={}
s.Pack[2][2][2][10]=40


--Gavin - Fiendish Commander Three Legions
s.Pack[2][2][3]={}
s.Pack[2][2][3][0]=1999020203
s.Pack[2][2][3][1]={160001029,160201001,160004020,160403001,160005021,160305006,160005020,160201002,160201005,160201006,160002026,160002026,160002026,160201004,160201004,160201004,160001012,160201007,160305015,160004038,160004019,160004018,160004018,160406006,160001003,160001003,160001003,160201008,160201008,160201008,160201010,160003044,160201011,160304022,160201012,160305027,160002046,160201014,160305030,160001050}
s.Pack[2][2][3][2]={}
s.Pack[2][2][3][3]={}
s.Pack[2][2][3][4]={}
s.Pack[2][2][3][5]={}
s.Pack[2][2][3][10]=40


--Romin - Psychic Beat
s.Pack[2][2][4]={}
s.Pack[2][2][4][0]=1999020204
s.Pack[2][2][4][1]={160001028,160002025,160306003,160002024,160002024,160201029,160201032,160201032,160201032,160201030,160201030,160201030,160004014,160306009,160201031,160201031,160201033,160201033,160306012,160201034,160201034,160002003,160002003,160002002,160002002,160002023,160005018,160201035,160201035,160201035,160002042,160201038,160406004,160304022,160201012,160002037,160201039,160306026,160201040,160002049}
s.Pack[2][2][4][2]={}
s.Pack[2][2][4][3]={}
s.Pack[2][2][4][4]={}
s.Pack[2][2][4][5]={}
s.Pack[2][2][4][10]=40


--Roa - Demon's Rock
s.Pack[2][2][5]={}
s.Pack[2][2][5][0]=1999020205
s.Pack[2][2][5][1]={160002031,160307002,160005003,160307004,160003013,160003013,160003013,160402004,160402004,160201018,160201018,160201019,160307009,160001011,160001011,160001011,160201020,160201020,160201020,160201021,160201021,160005023,160005023,160002033,160004012,160201022,160201022,160201023,160201023,160004041,160002042,160201024,160304022,160005041,160005042,160001046,160201026,160307026,160201027,160002048}
s.Pack[2][2][5][2]={}
s.Pack[2][2][5][3]={}
s.Pack[2][2][5][4]={}
s.Pack[2][2][5][5]={}
s.Pack[2][2][5][10]=40


--Nail - Maximum Haven
s.Pack[2][2][6]={}
s.Pack[2][2][6][0]=1999020206
s.Pack[2][2][6][1]={160202011,160202010,160202012,160308004,160308005,160202049,160202049,160202049,160202013,160202013,160202013,160006033,160308009,160202014,160202014,160202014,160203022,160203022,160203022,160202015,160202015,160202015,160202016,160202016,160202016,160202017,160202017,160202017,160308015,160002042,160202018,160202050,160202024,160005043,160001046,160003058,160002048,160303032,160202029,160202020}
s.Pack[2][2][6][2]={}
s.Pack[2][2][6][3]={}
s.Pack[2][2][6][4]={}
s.Pack[2][2][6][5]={}
s.Pack[2][2][6][10]=40


--Asana - Pride of the Heavy Mequestrian Style
s.Pack[2][2][7]={}
s.Pack[2][2][7][0]=1999020207
s.Pack[2][2][7][1]={160004022,160004021,160004023,160004024,160004032,160006026,160005034,160004003,160004003,160004003,160006007,160309010,160309011,160005037,160005037,160005037,160004002,160004002,160005008,160412008,160004006,160309017,160004025,160004001,160004001,160004001,160406007,160309021,160002042,160412004,160406010,160001043,160203030,160309027,160002046,160004053,160004053,160004054,160203033,160303032}
s.Pack[2][2][7][2]={}
s.Pack[2][2][7][3]={}
s.Pack[2][2][7][4]={}
s.Pack[2][2][7][5]={}
s.Pack[2][2][7][10]=40


--Hyperspeed Rush Road!!
s.Pack[2][3][1]={}
s.Pack[2][3][1][0]=1999020301
s.Pack[2][3][1][1]={160001001,160001002,160001003,160001004,160001005,160001006,160001007,160001008,160001009,160001010,160001019,160001020,160001032,160001035,160001037,160001038,160001040,160001042,160001043,160001044,160001048,160001050}
s.Pack[2][3][1][2]={160001011,160001012,160001013,160001014,160001015,160001016,160001017,160001024,160001025,160001031,160001033,160001034,160001039,160001045,160001046,160001047}
s.Pack[2][3][1][3]={160001000,160301001,160302001,160001018,160001022,160001030,160001036,160001041,160001049}
s.Pack[2][3][1][4]={160401001,160001026,160001028,160001029}
s.Pack[2][3][1][5]={}
s.Pack[2][3][1][10]=5


--Shocking Lightning Attack!!
s.Pack[2][3][2]={}
s.Pack[2][3][2][0]=1999020302
s.Pack[2][3][2][1]={160002002,160002003,160002004,160002006,160002007,160002009,160002010,160002012,160002013,160002014,160002015,160002024,160002026,160002037,160002038,160002040,160002041,160002043,160002044,160002045,160002049,160002050}
s.Pack[2][3][2][2]={160002001,160002005,160002008,160002011,160002019,160002020,160002023,160301004,160002033,160002034,160002035,160002036,160002039,160002042,160002046,160002048}
s.Pack[2][3][2][3]={160002000,160002017,160002031,160002016,160002027,160002028,160002029,160002030,160002047}
s.Pack[2][3][2][4]={160002018,160002021,160002022,160002025}
s.Pack[2][3][2][5]={}
s.Pack[2][3][2][10]=5


--Fantastrike Mirage Impact!!
s.Pack[2][3][3]={}
s.Pack[2][3][3][0]=1999020303
s.Pack[2][3][3][1]={160003002,160003003,160003004,160003005,160003006,160003007,160003008,160003012,160003015,160003017,160003020,160003026,160003027,160003028,160003030,160003036,160003039,160003043,160003044,160003046,160003045,160003048,160003049,160003050,160003051,160003055,160003057,160003059,160003060}
s.Pack[2][3][3][2]={160003001,160003009,160003010,160003011,160003013,160003019,160003021,160003029,160003034,160003035,160003037,160003038,160003047,160003052,160003053,160003056,160003058}
s.Pack[2][3][3][3]={160003000,160003018,160003025,160003014,160003016,160003022,160003023,160003032,160003042}
s.Pack[2][3][3][4]={160003054,160003024,160003031,160003033,160003040}
s.Pack[2][3][3][5]={}
s.Pack[2][3][3][10]=5


--Destined Power Destruction!!
s.Pack[2][3][4]={}
s.Pack[2][3][4][0]=1999020304
s.Pack[2][3][4][1]={160004001,160004003,160004004,160004006,160004007,160004008,160004009,160004010,160004011,160004012,160004013,160004014,160004016,160004018,160004026,160004027,160004033,160004035,160004036,160004039,160004045,160004046,160004047,160004054,160004055,160004056,160004057,160004058,160004059}
s.Pack[2][3][4][2]={160004002,160004005,160004019,160004025,160004028,160004030,160004031,160004034,160004037,160004038,160004040,160004041,160004043,160004044,160004048,160004050,160004053}
s.Pack[2][3][4][3]={160004000,160004015,160004024,160004017,160004032,160004042,160004049,160004051,160004052,160004060}
s.Pack[2][3][4][4]={160004020,160004021,160004022,160004023,160004029}
s.Pack[2][3][4][5]={}
s.Pack[2][3][4][10]=5


--Dynamic Eternal Live!!
s.Pack[2][3][5]={}
s.Pack[2][3][5][0]=1999020305
s.Pack[2][3][5][1]={160005003,160005004,160005006,160005007,160005008,160005009,160005010,160005012,160005018,160005021,160005023,160005027,160005028,160005033,160005036,160005037,160005040,160005041,160005043,160005045,160005048,160005049,160005050,160005051,160005055,160005056,160005058,160005059,160005060,160005063,160005064}
s.Pack[2][3][5][2]={160005001,160005005,160005011,160005017,160005020,160005022,160005025,160005030,160005032,160005034,160005039,160005042,160005046,160005047,160005053,160005054,160005057,160005062}
s.Pack[2][3][5][3]={160005000,160401004,160403002,160005029,160005035,160005038,160005044,160005052,160005061,160005065}
s.Pack[2][3][5][4]={160005014,160005015,160005016,160005031,160005013,160005019,160005024}
s.Pack[2][3][5][5]={}
s.Pack[2][3][5][10]=5


--Fierce Thunder Storm!!
s.Pack[2][3][6]={}
s.Pack[2][3][6][0]=1999020306
s.Pack[2][3][6][1]={160006002,160006003,160006004,160006005,160006007,160006008,160006009,160006011,160006012,160006016,160006020,160006023,160006029,160006031,160006032,160006033,160006034,160006044,160006047,160006048,160006049,160006050,160006051,160006052,160006056,160006057,160006058,160006059,160006062,160006063,160006065}
s.Pack[2][3][6][2]={160006001,160006006,160006010,160006013,160006021,160006026,160006027,160006028,160006030,160006035,160006036,160006039,160006042,160006043,160006046,160006054,160006055,160006061}
s.Pack[2][3][6][3]={160006000,160006014,160006018,160006019,160006025,160006037,160006041,160006045,160006053,160006060}
s.Pack[2][3][6][4]={160006024,160006038,160006040,160006064,160006015,160006017,160006022}
s.Pack[2][3][6][5]={}
s.Pack[2][3][6][10]=5


--Chaotic Omega Rising!!
s.Pack[2][3][7]={}
s.Pack[2][3][7][0]=1999020307
s.Pack[2][3][7][1]={160007001,160007003,160007004,160007005,160007006,160007007,160007008,160007010,160007012,160007013,160007018,160007019,160007021,160007023,160007025,160007026,160007029,160007031,160007042,160007046,160007049,160007051,160007054,160007055,160007057,160007058,160007059,160007060,160007061,160007062,160007063}
s.Pack[2][3][7][2]={160007002,160007009,160007014,160007016,160007022,160007030,160007033,160007038,160007039,160007040,160007041,160007043,160007044,160007047,160007048,160007050,160007056,160007064}
s.Pack[2][3][7][3]={160007000,160007011,160007015,160007017,160007024,160007027,160007034,160007037,160007045,160007065}
s.Pack[2][3][7][4]={160007028,160007032,160007052,160007053,160007020,160007035,160007036}
s.Pack[2][3][7][5]={}
s.Pack[2][3][7][10]=5


--Genesis Master Road!!
s.Pack[2][3][8]={}
s.Pack[2][3][8][0]=1999020308
s.Pack[2][3][8][1]={160008002,160008003,160008005,160008006,160008008,160008013,160008015,160008020,160008023,160008024,160008025,160008028,160008029,160008035,160008040,160008041,160008042,160008045,160008046,160008047,160008049,160008050,160008054,160008055,160008056,160008058,160008059,160008061,160008063,160008064,160008065}
s.Pack[2][3][8][2]={160008001,160008004,160008007,160008009,160008010,160008017,160008019,160008021,160008027,160008030,160008037,160008038,160008039,160008043,160008044,160008052,160008053,160008060}
s.Pack[2][3][8][3]={160008000,160008011,160008012,160008014,160008016,160008018,160008034,160008048,160008051,160008062}
s.Pack[2][3][8][4]={160008026,160008031,160008036,160008057,160008022,160008032,160008033}
s.Pack[2][3][8][5]={}
s.Pack[2][3][8][10]=5





















--Constructor Fusion
s.Pack[2][11][1]={}
s.Pack[2][11][1][0]=1999021101
s.Pack[2][11][1][1]={160203029,160203029,160004003,160004003,160004002,160004002,160004002,160421037,160421037,160421037,160004024,160004024,160004024,160309010,160309010,160309010,160204044,160204044,160309017,160309017,160004025,160004025,160004025,160004044,160004044,160004044,160204045,160204045,160204050,160204050,160004042,160004042,160004042,160203030,160008062,160008062,160008062,160202029,160202029,160418003}
s.Pack[2][11][1][2]={160421014,160421014,160421014,160009038,160009038,160009038}
s.Pack[2][11][1][3]={}
s.Pack[2][11][1][4]={}
s.Pack[2][11][1][5]={}
s.Pack[2][11][1][10]=40

--Cyberse Beatdown
s.Pack[2][11][2]={}
s.Pack[2][11][2][0]=1999021102
s.Pack[2][11][2][1]={160008001,160008001,160008001,160308009,160308009,160308009,160202014,160202014,160202014,160421013,160421013,160421013,160203021,160203021,160203021,160308005,160308005,160308005,160421021,160421021,160421021,160006033,160006033,160006033,160007032,160005035,160005035,160202015,160202015,160202015,160007052,160007052,160007052,160308015,160308015,160308015,160009058,160009058,160009058,160418003}
s.Pack[2][11][2][2]={160008039,160008039,160008039,160204001,160204001,160204001,160204002,160204002,160204002,160204003,160204003,160204003,160204004,160204004,160204004}
s.Pack[2][11][2][3]={}
s.Pack[2][11][2][4]={}
s.Pack[2][11][2][5]={}
s.Pack[2][11][2][10]=40

--Dino Beatdown
s.Pack[2][11][3]={}
s.Pack[2][11][3][0]=1999021103
s.Pack[2][11][3][1]={160203013,160203013,160203013,160203012,160203012,160203012,160203009,160203009,160203009,160203011,160203011,160203011,160006037,160006037,160006037,160002029,160002029,160002029,160203008,160203008,160203008,160203020,160203020,160203020,160203019,160203019,160203019,160203016,160203016,160203016,160203017,160203017,160203017,160203015,160203015,160203015,160001041,160001041,160001041,160202048}
s.Pack[2][11][3][2]={}
s.Pack[2][11][3][3]={}
s.Pack[2][11][3][4]={}
s.Pack[2][11][3][5]={}
s.Pack[2][11][3][10]=40

--Dragias Burst Maximum: Turbo
s.Pack[2][11][4]={}
s.Pack[2][11][4][0]=1999021104
s.Pack[2][11][4][1]={160007009,160008010,160008010,160008010,160003003,160007008,160007008,160007008,160422002,160422002,160422002,160002021,160422001,160422001,160422001,160422003,160422003,160422003,160406003,160406003,160406003,160008012,160008012,160008012,160303019,160303019,160303019,160302009,160302009,160302009,160007051,160007051,160007051,160007052,160007052,160007052,160202050,160202050,160202050,160411003}
s.Pack[2][11][4][2]={}
s.Pack[2][11][4][3]={}
s.Pack[2][11][4][4]={}
s.Pack[2][11][4][5]={}
s.Pack[2][11][4][10]=40

--Dragias Burst Maximum: Combo
s.Pack[2][11][5]={}
s.Pack[2][11][5][0]=1999021105
s.Pack[2][11][5][1]={160302005,160302005,160422002,160422002,160422002,160003025,160302001,160302001,160422001,160422001,160422001,160422003,160422003,160422003,160001025,160001025,160001025,160302009,160302009,160302009,160001024,160001024,160001024,160003043,160003043,160003043,160007052,160007052,160007052,160009053,160009053,160009053,160202050,160202050,160202050,160302011,160302011,160411003,160006058,160006058}
s.Pack[2][11][5][2]={}
s.Pack[2][11][5][3]={}
s.Pack[2][11][5][4]={}
s.Pack[2][11][5][5]={}
s.Pack[2][11][5][10]=40

--Dragoncasters
s.Pack[2][11][6]={}
s.Pack[2][11][6][0]=1999021106
s.Pack[2][11][6][1]={160003001,160003001,160003001,160003009,160003009,160410002,160410002,160410002,160301001,160301001,160301001,160301002,160005035,160005035,160005035,160301006,160301006,160301006,160001018,160001018,160001018,160002016,160002016,160002016,160001031,160001031,160302009,160302009,160302009,160202007,160202007,160301012,160301012,160301012,160302012,160417004,160006064,160301013,160301013,160301013}
s.Pack[2][11][6][2]={}
s.Pack[2][11][6][3]={}
s.Pack[2][11][6][4]={}
s.Pack[2][11][6][5]={}
s.Pack[2][11][6][10]=40

--Galaxy Gate Order
s.Pack[2][11][7]={}
s.Pack[2][11][7][0]=1999021107
s.Pack[2][11][7][1]={160009002,160009002,160009002,160415001,160415001,160009001,160009001,160009001,160425001,160425001,160425001,160009017,160009017,160009017,160009014,160009014,160009014,160303019,160303019,160303019,160009013,160009013,160009013,160005052,160005052,160007052,160007052,160007052,160007055,160007055,160008057,160008057,160421024,160421024,160421024,160421029,160421029,160421029,160009054,160418003}
s.Pack[2][11][7][2]={}
s.Pack[2][11][7][3]={}
s.Pack[2][11][7][4]={}
s.Pack[2][11][7][5]={}
s.Pack[2][11][7][10]=40

--Order Baseball
s.Pack[2][11][8]={}
s.Pack[2][11][8][0]=1999021108
s.Pack[2][11][8][1]={160001016,160001016,160001016,160403001,160403001,160007006,160007006,160007006,160005008,160005008,160005008,160008016,160008016,160008016,160204031,160204031,160204031,160007033,160007033,160007033,160421038,160421038,160421038,160006032,160006032,160203011,160203011,160005035,160005035,160005053,160005053,160005053,160008057,160421024,160421024,160421024,160009056,160009056,160009056,160418003}
s.Pack[2][11][8][2]={}
s.Pack[2][11][8][3]={}
s.Pack[2][11][8][4]={}
s.Pack[2][11][8][5]={}
s.Pack[2][11][8][10]=40

--Gate Order Rules
s.Pack[2][11][9]={}
s.Pack[2][11][9][0]=1999021109
s.Pack[2][11][9][1]={160009002,160009002,160009002,160009006,160009006,160009006,160415001,160415001,160415001,160009001,160009001,160009001,160001041,160001041,160001041,160005052,160005052,160005052,160007052,160007052,160007052,160007055,160007055,160007055,160008057,160008057,160008057,160202050,160310010,160310010,160310010,160421024,160421024,160421024,160421029,160421029,160421029,160009059,160009059,160418003}
s.Pack[2][11][9][2]={}
s.Pack[2][11][9][3]={}
s.Pack[2][11][9][4]={}
s.Pack[2][11][9][5]={}
s.Pack[2][11][9][10]=40

--Insects Infection
s.Pack[2][11][10]={}
s.Pack[2][11][10][0]=1999021110
s.Pack[2][11][10][1]={160006010,160006010,160006010,160009010,160009010,160009010,160009036,160009036,160009036,160009034,160009034,160009034,160009032,160009032,160009030,160009030,160009030,160009023,160009023,160009023,160009028,160009028,160009028,160009025,160009025,160009025,160006053,160007052,160007052,160009050,160009050,160009051,160009051,160009051,160009062,160009062,160009062,160009063,160009063,160418003}
s.Pack[2][11][10][2]={}
s.Pack[2][11][10][3]={}
s.Pack[2][11][10][4]={}
s.Pack[2][11][10][5]={}
s.Pack[2][11][10][10]=40

--Light Machine
s.Pack[2][11][11]={}
s.Pack[2][11][11][0]=1999021111
s.Pack[2][11][11][1]={160415002,160415002,160415002,160006002,160004032,160004032,160411001,160411001,160411001,160004015,160004015,160004015,160007032,160007032,160007032,160005035,160005035,160005035,160006030,160006030,160006030,160414001,160414001,160414001,160303019,160303019,160303019,160415003,160415003,160415003,160006054,160006054,160006054,160417004,160002039,160004060,160004060,160006062,160006063,160007065}
s.Pack[2][11][11][2]={}
s.Pack[2][11][11][3]={}
s.Pack[2][11][11][4]={}
s.Pack[2][11][11][5]={}
s.Pack[2][11][11][10]=40

--Machine Mach Aggro
s.Pack[2][11][12]={}
s.Pack[2][11][12][0]=1999021112
s.Pack[2][11][12][1]={160415002,160415002,160415002,160009000,160009019,160009019,160009019,160004015,160004015,160004015,160005013,160005013,160005013,160204041,160204041,160204041,160009017,160009017,160009017,160005017,160005017,160007032,160005035,160005035,160005035,160006030,160006030,160006030,160203010,160203010,160203010,160008012,160008012,160008012,160303019,160303019,160303019,160415003,160415003,160415003}
s.Pack[2][11][12][2]={}
s.Pack[2][11][12][3]={}
s.Pack[2][11][12][4]={}
s.Pack[2][11][12][5]={}
s.Pack[2][11][12][10]=40

--Metallion
s.Pack[2][11][13]={}
s.Pack[2][11][13][0]=1999021113
s.Pack[2][11][13][1]={160009002,160009002,160009002,160415001,160204008,160204008,160204008,160204009,160204009,160204009,160204010,160204010,160204010,160204006,160204006,160204006,160402009,160002021,160002021,160002021,160303019,160303019,160303019,160302009,160302009,160302009,160007052,160007052,160007052,160204045,160204045,160204045,160204050,160204050,160204050,160421024,160421024,160421024,160421029,160418003}
s.Pack[2][11][13][2]={160008039,160008039,160008039,160204001,160204001,160204001,160204002,160204002,160204002,160204003,160204003,160204003,160204004,160204004,160204004}
s.Pack[2][11][13][3]={}
s.Pack[2][11][13][4]={}
s.Pack[2][11][13][5]={}
s.Pack[2][11][13][10]=40

--Order Fire Beast
s.Pack[2][11][14]={}
s.Pack[2][11][14][0]=1999021114
s.Pack[2][11][14][1]={160007009,160007009,160007009,160008010,160008010,160008010,160006006,160006006,160007008,160007008,160007008,160006005,160006005,160006005,160006004,160006004,160006004,160006025,160006025,160006025,160002030,160006032,160006032,160006032,160303019,160303019,160006048,160007051,160007051,160007051,160007052,160007052,160204045,160204050,160204050,160204050,160417004,160421024,160421024,160421024}
s.Pack[2][11][14][2]={160008043,160008043,160008043,160007038,160007038,160007038,160007039,160007039,160007039,160008042,160008042,160008042,160419001,160419001,160419001}
s.Pack[2][11][14][3]={}
s.Pack[2][11][14][4]={}
s.Pack[2][11][14][5]={}
s.Pack[2][11][14][10]=40

--Pressure Order Dragias
s.Pack[2][11][15]={}
s.Pack[2][11][15][0]=1999021115
s.Pack[2][11][15][1]={160405001,160405001,160405001,160005001,160005001,160302005,160302005,160304012,160304012,160006017,160006017,160302001,160302001,160409001,160409001,160005017,160005017,160005017,160001025,160001025,160001025,160302009,160302009,160302009,160001024,160001024,160001024,160007052,160007052,160007052,160008057,160302011,160302011,160302011,160302012,160302012,160421024,160421024,160421024,160418003}
s.Pack[2][11][15][2]={}
s.Pack[2][11][15][3]={}
s.Pack[2][11][15][4]={}
s.Pack[2][11][15][5]={}
s.Pack[2][11][15][10]=40

--Pressure Order Blue-Eyes
s.Pack[2][11][16]={}
s.Pack[2][11][16][0]=1999021116
s.Pack[2][11][16][1]={160001000,160009002,160009002,160405001,160405001,160405001,160005001,160005001,160302005,160302005,160304012,160304012,160304012,160002021,160002021,160002021,160005017,160005017,160005017,160003020,160003020,160302009,160302009,160302009,160007052,160007052,160007052,160008057,160008057,160008057,160302011,160302011,160302011,160302012,160302012,160421024,160421024,160421024,160421029,160421029}
s.Pack[2][11][16][2]={}
s.Pack[2][11][16][3]={}
s.Pack[2][11][16][4]={}
s.Pack[2][11][16][5]={}
s.Pack[2][11][16][10]=40

--Royal Fiends
s.Pack[2][11][17]={}
s.Pack[2][11][17][0]=1999021117
s.Pack[2][11][17][1]={160307004,160307004,160307004,160002031,160002031,160002031,160005024,160005024,160005024,160201016,160201016,160201023,160201023,160201023,160201020,160201020,160201020,160307009,160307009,160307009,160004012,160004012,160004012,160005023,160005023,160005023,160204051,160204051,160204051,160204045,160005042,160005042,160005042,160004041,160004041,160004041,160204049,160201026,160201026,160201026}
s.Pack[2][11][17][2]={160204034,160204034,160204034}
s.Pack[2][11][17][3]={}
s.Pack[2][11][17][4]={}
s.Pack[2][11][17][5]={}
s.Pack[2][11][17][10]=40

--Spellcasters
s.Pack[2][11][18]={}
s.Pack[2][11][18][0]=1999021118
s.Pack[2][11][18][1]={160003001,160003001,160003001,160003009,160003009,160003009,160301001,160301001,160301001,160301002,160301002,160401001,160401001,160008011,160008011,160008011,160001019,160001019,160001019,160301006,160301006,160301006,160002016,160002016,160002016,160001037,160001037,160001041,160001041,160001041,160204049,160301011,160301011,160301012,160301012,160301012,160421027,160301013,160301013,160301013}
s.Pack[2][11][18][2]={}
s.Pack[2][11][18][3]={}
s.Pack[2][11][18][4]={}
s.Pack[2][11][18][5]={}
s.Pack[2][11][18][10]=40

--Thunderbold
s.Pack[2][11][19]={}
s.Pack[2][11][19][0]=1999021119
s.Pack[2][11][19][1]={160415001,160007009,160203029,160006013,160201035,160201035,160411001,160302001,160421010,160006015,160006015,160006015,160204031,160204031,160204031,160004017,160004017,160004017,160007032,160007032,160005035,160005035,160008027,160008012,160008012,160008012,160303019,160303019,160303019,160002023,160002023,160002023,160007052,160007052,160007052,160204049,160421024,160421024,160421024,160421029}
s.Pack[2][11][19][2]={}
s.Pack[2][11][19][3]={}
s.Pack[2][11][19][4]={}
s.Pack[2][11][19][5]={}
s.Pack[2][11][19][10]=40

--Umi
s.Pack[2][11][20]={}
s.Pack[2][11][20][0]=1999021120
s.Pack[2][11][20][1]={160007002,160007002,160007002,160003041,160003041,160007000,160007024,160007024,160007024,160005013,160005013,160007032,160007032,160007032,160005035,160005035,160005035,160007022,160007022,160007022,160007031,160007031,160007031,160303019,160303019,160303019,160004049,160004049,160004049,160007045,160007045,160007046,160007046,160003052,160003052,160003052,160007058,160007058,160007065,160007065}
s.Pack[2][11][20][2]={}
s.Pack[2][11][20][3]={}
s.Pack[2][11][20][4]={}
s.Pack[2][11][20][5]={}
s.Pack[2][11][20][10]=40
