--Deck Random: Almatik Hope
local s,id=GetID()
function s.initial_effect(c)
	--skill
	local e1=Effect.CreateEffect(c) 
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetRange(0x5f)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Delete Your Cards
	local c=e:GetHandler()
	Duel.SendtoDeck(c,tp,-2,REASON_RULE)
	local g=Duel.GetFieldGroup(tp,LOCATION_ALL,0)
	Duel.SendtoDeck(g,tp,-2,REASON_RULE)

	--Add Random Deck
	local decknum=Duel.GetRandomNumber(1,1)
	local deck=s.deck[decknum][1]+s.deck[decknum][2]
	for code,codex in ipairs(deck) do
		Debug.AddCard(codex,tp,tp,LOCATION_DECK,1,POS_FACEDOWN)
	end
	Debug.ReloadFieldEnd()

	--Add Covers
	local dg=Duel.GetFieldGroup(tp,LOCATION_ALL,0)
	local tc=dg:GetFirst()
	local coverid=decknum+2021020000
	while tc do
		--generate a cover for a card
		tc:Cover(coverid)
		tc=dg:GetNext()
	end
	Duel.ConfirmCards(tp,dg)
	Duel.ShuffleDeck(tp)
	Duel.ShuffleExtra(tp)
end

s.deck={}
	--"Albuz Dogmatik"
	s.deck[1]={}
	s.deck[1][1]={
			--Main Deck
	22073844,69680031,69680031,69680031,13694209,95679145,68468459,68468459,45484331,45484331,45484331,55273560,55273560,60303688,60303688,60303688,14558127,14558127,14558127,40352445,40352445,48654323,48654323,1984618,1984618,1984618,34995106,44362883,31002402,31002402,60921537,24224830,65589010,10045474,10045474,10045474,29354228,82956214,82956214,82956214}
			--Extra Deck
	s.deck[1][2]={
	44146295,44146295,34848821,41373230,41373230,41373230,87746184,87746184,80532587,80532587,80532587,79606837,79606837,79606837,70369116}


	--"Albuz Springans"
	s.deck[2]={
			--Main Deck
	25451383,29601381,29601381,29601381,83203672,83203672,20424878,20424878,68468459,68468459,45484331,45484331,45484331,55273560,67436768,67436768,67436768,56818977,14558127,14558127,14558127,23499963,23499963,23499963,34995106,44362883,73628505,29948294,29948294,29948294,7496001,7496001,7496001,60884672,60884672,60884672,25415161,25415161,25415161,17751597,
			--Extra Deck
	44146295,44146295,70534340,1906812,1906812,1906812,41373230,87746184,90448279,62941499,62941499,62941499,48285768,48285768,70369116}
	

	--"Albuz Swordsoul"
	s.deck[3]={
			--Main Deck
	25451383,93490856,93490856,93490856,56495147,56495147,56495147,82489470,82489470,68468459,68468459,20001443,20001443,20001443,45484331,45484331,45484331,55273560,55273560,14558127,14558127,14558127,34995106,44362883,56465981,56465981,56465981,93850690,93850690,93850690,10045474,10045474,10045474,14821890,14821890,14821890,99137266,17751597,17751597,17751597,
			--Extra Deck
	44146295,44146295,70534340,87746184,96633955,96633955,84815190,47710198,47710198,92519087,9464441,69248256,69248256,69248256,70369116}


	--"Albuz Tr-Brigade"
	s.deck[4]={
			--Main Deck
	25451383,87209160,87209160,87209160,68468459,68468459,45484331,45484331,45484331,55273560,55273560,19096726,19096726,19096726,14558127,14558127,14558127,50810455,50810455,50810455,56196385,56196385,14816857,14816857,14816857,34995106,44362883,24224830,29948294,29948294,29948294,51097887,51097887,51097887,10045474,10045474,10045474,40975243,40975243,40975243,
			--Extra Deck
	44146295,44146295,34848821,34848821,34848821,87746184,99726621,99726621,4280259,52331012,52331012,47163170,47163170,26847978,70369116}


	--"Marincess"
	s.deck[5]={
			--Main Deck
	57541158,57541158,57541158,91953000,91953000,91953000,99885917,99885917,99885917,21057444,21057444,21057444,31059809,31059809,31059809,36492575,36492575,36492575,60643554,60643554,60643554,28174796,57160136,57160136,57160136,57329501,57329501,57329501,83764718,24224830,91027843,91027843,91027843,10045474,10045474,10045474,52945066,52945066,52945066,23002292,
			--Extra Deck
	67557908,94942656,94942656,47910940,94207108,20934852,84546257,79130389,79130389,59859086,67712104,67712104,43735670,43735670,30691817,}


	--"Evil Twin Phoenix Eforcer"
	s.deck[6]={
			--Main Deck
	81866673,63362460,14558127,14558127,14558127,36326160,36326160,36326160,54257392,54257392,73810864,73810864,73810864,81078880,81078880,73642296,73642296,73642296,25311006,25311006,25311006,52947044,52947044,52947044,57160136,57160136,57160136,61976639,61976639,61976639,8083925,8083925,8083925,24224830,37582948,37582948,37582948,10045474,10045474,10045474,
			--Extra Deck
	60461804,90448279,36776089,98127546,93672138,93672138,93672138,21887175,86066372,9205573,9205573,9205573,36609518,36609518,36609518}


	--"Naphil Asylum Chaos Knight"
	s.deck[7]={
			--Main Deck
	61496006,61496006,61496006,98881700,98881700,98881700,7150545,7150545,7150545,70156946,70156946,70156946,31059809,31059809,31059809,14558128,14558128,14558128,6625096,6625096,6625096,19885332,19885332,19885332,23153227,23153227,23153227,57734012,81439173,97769122,97769122,97769122,14602126,10045474,10045474,10045474,847915,68630939,68630939,68630939,
			--Extra Deck
	99469936,61374414,61374414,20785975,12744567,34876719,34876719,440556,37279508,94380860,48739166,67557908,94942656,94942656,90809975}


	--"Umi Fisherman"
	s.deck[8]={
			--Main Deck
	11012154,96546575,44968687,19801646,19801646,23931679,23931679,23931679,95824983,95824983,95824983,69436288,31059809,31059809,31059809,57511992,14558128,14558128,14558128,22819092,22819092,22819092,63854005,63854005,63854005,58203736,58203736,295517,295517,295517,10045474,10045474,10045474,53582587,53582587,53582587,95602345,95602345,95602345,19089195,
			--Extra Deck
	96334243,96334243,96633955,9464441,42566602,39964797,440556,67557908,67557908,94942656,94942656,94942656,90809975,79130389,79130389}