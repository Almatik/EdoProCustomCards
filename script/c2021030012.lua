--Umbral Horror V
local s,id=GetID()
function s.initial_effect(c)
	Duel.EnableGlobalFlag(GLOBALFLAG_DECK_REVERSE_CHECK)
	--Declare a card name
	local me1=Effect.CreateEffect(c)
	me1:SetDescription(aux.Stringid(id,0))
	me1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	me1:SetType(EFFECT_TYPE_IGNITION)
	me1:SetRange(LOCATION_MZONE)
	me1:SetCountLimit(1)
	me1:SetCost(s.cost)
	me1:SetTarget(s.target)
	me1:SetOperation(s.operation)
	c:RegisterEffect(me1)
	--To the opponent's Deck
	local me2=Effect.CreateEffect(c)
	me2:SetDescription(aux.Stringid(id,1))
	me2:SetCategory(CATEGORY_TODECK)
	me2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	me2:SetCode(EVENT_TO_GRAVE)
	me2:SetProperty(EFFECT_FLAG_DELAY)
	me2:SetCountLimit(1)
	me2:SetCondition(s.gravecon)
	me2:SetTarget(s.gravetg)
	me2:SetOperation(s.graveop)
	c:RegisterEffect(me2)
	--Change XYZ Level
	local me3=Effect.CreateEffect(c)
	me3:SetType(EFFECT_TYPE_SINGLE)
	me3:SetCode(EFFECT_XYZ_LEVEL)
	me3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	me3:SetRange(LOCATION_MZONE)
	me3:SetValue(s.xyzlv)
	c:RegisterEffect(me3)
	--Change XYZ Restriction
	local me4=Effect.CreateEffect(c)
	me4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	me4:SetType(EFFECT_TYPE_SINGLE)
	me4:SetCode(EFFECT_XYZ_MAT_RESTRICTION)
	me4:SetValue(s.xyzmat)
	c:RegisterEffect(me4)

	--"Deck Effect"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DRAW)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.drcon)
	e1:SetTarget(s.drcon)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
	--Play a game
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_BANISH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_DECK)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.playcon)
	e2:SetOperation(s.playop)
	c:RegisterEffect(e2)

end
function s.filter(c)
	return c:IsSetCard(0x87) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
		and not c:IsCode(id)
end
function s.filter2(c,e,tp)
	return c:IsSetCard(0x87) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and not c:IsCode(id)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,e:GetHandler()):GetFirst()
	Duel.SendtoGrave(tc,REASON_EFFECT+REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if e:GetHandler():GetSequence()<5 then ft=ft+1 end
		local g=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_DECK,0,nil,e,tp)
		return ft>1 and g:GetClassCount(Card.GetCode)>=2
			and e:GetHandler():IsAbleToGrave()
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	if not e:GetHandler():IsAbleToGraveAs() then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	local g=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_DECK,0,nil,e,tp)
	if #g>=2 and g:GetClassCount(Card.GetCode)>=2 then
		local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.spcheck,1,tp,HINTMSG_SPSUMMON)
		if sg then
			Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
function s.gravecon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)
end
function s.gravetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	s.announce_filter={TYPE_EXTRA,OPCODE_ISTYPE,OPCODE_NOT}
	local ac=Duel.AnnounceCard(tp,table.unpack(s.announce_filter))
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD_FILTER)
end
function s.gravefilter(c,code)
	return c:IsCode(code) and c:IsAbleToGrave()
end
function s.graveop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_GRAVE) then return end
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_CONFIRM)
	local tac=Duel.GetFirstMatchingCard(s.gravefilter,tp,0,LOCATION_DECK,nil,ac)
	if tac then
		Duel.ConfirmCards(tp,tac)
		Duel.SendtoGrave(tac,REASON_EFFECT)
		Duel.SendtoDeck(c,1-tp,2,REASON_EFFECT)
		if c:IsLocation(LOCATION_DECK) then
			Duel.ShuffleDeck(1-tp)
			c:ReverseInDeck()
		end
	end
end
function s.xyzlv(e,c,rc)
	local lv=e:GetHandler():GetLevel()
	if rc:IsSetCard(0x48) then
		return 1,2,3,4,lv
	else
		return lv
	end
end
function s.xyzmat(e,c)
	return c:IsAttribute(ATTRIBUTE_DARK)
end




	--"Deck Effect"

function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsPreviousPosition(POS_FACEUP)
end
function s.drfilter(c)
	return c:IsControlerCanBeChanged() and c:IsFaceup() and c:IsSummonLocation(LOCATION_EXTRA)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:GetLocation()==LOCATION_MZONE and chkc:GetControler()==tp and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.drfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
			Duel.GetControl(tc,1-tp)
		end
		Duel.SendtoDeck(c,tp,1,REASON_EFFECT)
		if c:IsLocation(LOCATION_DECK) then
			c:ReverseInDeck()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
function s.playcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=eg:GetFirst()
	return c:IsFaceup()
		and ec:IsPreviousLocation(LOCATION_EXTRA) and ec:IsPreviousControler(tp) and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_EXTRA,0,1,nil)
end
function s.playop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_EXTRA,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end