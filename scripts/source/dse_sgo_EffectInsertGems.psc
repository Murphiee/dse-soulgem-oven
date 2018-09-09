ScriptName dse_sgo_EffectInsertGems extends ActiveMagicEffect

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_sgo_QuestController_Main Property Main Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnEffectStart(Actor Who, Actor From)

	ObjectReference Box = Who.PlaceAtMe(Main.ContainInsertGems,1,FALSE,TRUE)
	Actor Target = Game.GetCurrentCrosshairRef() as Actor

	If(Target != None)
		Who = Target
	EndIf

	StorageUtil.SetFormValue(Box,"SGO4.InsertInto",Who)
	Box.Enable()	

	Return
EndEvent