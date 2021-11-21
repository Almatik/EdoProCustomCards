--Shen, the Master of Ninja
Duel.LoadScript("legend.lua")
local s,id=GetID()
function s.initial_effect(c)
	aux.LegendProcedure(c,id,0,s.mat,s.mark,EVENT_SPSUMMON_SUCCESS)
end
function s.mat(c)
	return c:IsCode(2022010002)
end
function s.filter(c,tp)
	return c:IsCode(2022010003) and c:IsControler(tp)
end
function s.mark(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFlagEffect(tp,id)>=3 and eg:IsExists(s.filter,1,nil,tp) then
		Duel.RegisterFlagEffect(tp,id,0,0,0)
	end
end