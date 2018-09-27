ScriptName dse_sgo_QuestDatabase_Main Extends Quest

dse_sgo_QuestController_Main Property Main Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

String Property FileRaces = "../../../configs/dse-soulgem-oven/races/Default.json" AutoReadOnly Hidden

String Property RaceDirectory = "../../../configs/dse-soulgem-oven/races" AutoReadOnly Hidden
String[] Property RaceFiles Auto Hidden
Int Property RaceCount Auto Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

String Property KeyGemStageData = "SGO.Gem.Stages" AutoReadOnly Hidden
{Global.FormList}

String Property KeyActorTracking = "SGO.Actor.Tracking" AutoReadOnly Hidden
{Global.FormList}

String Property KeyActorGemData = "SGO4.Actor.Gems" AutoReadOnly Hidden
{Actor.FloatList}

String Property KeyActorMilkData = "SGO4.Actor.Milk" AutoReadOnly Hidden
{Actor.FloatValue}

String Property KeyActorSemenData = "SGO4.Actor.Semen" AutoReadOnly Hidden
{Actor.FloatValue}

String Property KeyActorTimeUpdated = "SGO4.Actor.UpdateTime" AutoReadOnly Hidden
{Actor.FloatValue}

String Property KeyActorFertilityData = "SGO4.Actor.Fertility" AutoReadOnly Hidden
{Actor.FloatValue}

String Property KeyActorFeaturesCached = "SGO4.Actor.FeaturesCached" AutoReadOnly Hidden
{Actor.IntValue}

String Property KeyActorModListPrefix = "SGO4.Actor.Mod." AutoReadOnly Hidden
{Generates Actor.StringLists}

String Property KeyActorModValuePrefix = "SGO4.Actor.ModValue." AutoReadOnly Hidden
{Generates Actor.FloatValues}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnPlayerLoadGame()

	;;self.RaceLoadFiles()
	Return
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; idea: passing an actor to these could allow you to install custom birthing
;; lists to each actor so they can birth different things. in the case of
;; get and count if no data exists fallback to the global data.

Form[] Function GemStageGetList(Actor Who)
{get the list of of things this actor is producing.}

	Form[] Dataset = StorageUtil.FormListToArray(Who,self.KeyGemStageData)

	If(Dataset.Length == 0)
		;; fetch the default global list if actor list was empty.
		Dataset = StorageUtil.FormListToArray(None,self.KeyGemStageData)
	EndIf

	Return Dataset
EndFunction

Function GemStagePopulate()
{populate the gem dataset based on the the configuration.}

	Int Mode = Main.Config.GetInt("BirthGemsFilled")

	StorageUtil.FormListClear(None,self.KeyGemStageData)

	If(Mode == 0)
		StorageUtil.FormListCopy(None,self.KeyGemStageData,self.GetGemStagesEmpty())
	ElseIf(Mode == 1)
		StorageUtil.FormListCopy(None,self.KeyGemStageData,self.GetGemStagesFilled())
	EndIf

	Return
EndFunction

Form[] Function GetGemStagesFilled()
{fill the gem dataset with the empty gems.}

	Form[] Gems = new Form[6]
	Gems[0] = Main.Util.GetFormFrom("Skyrim.esm",0x2e4e3)
	Gems[1] = Main.Util.GetFormFrom("Skyrim.esm",0x2e4e5)
	Gems[2] = Main.Util.GetFormFrom("Skyrim.esm",0x2e4f3)
	Gems[3] = Main.Util.GetFormFrom("Skyrim.esm",0x2e4fb)
	Gems[4] = Main.Util.GetFormFrom("Skyrim.esm",0x2e4ff)
	Gems[5] = Main.Util.GetFormFrom("Skyrim.esm",0x2e504)

	Return Gems
EndFunction

Form[] Function GetGemStagesEmpty()
{fill the gem dataset with the empty gems.}

	Form[] Gems = new Form[6]
	Gems[0] = Main.Util.GetFormFrom("Skyrim.esm",0x2e4e2)
	Gems[1] = Main.Util.GetFormFrom("Skyrim.esm",0x2e4e4)
	Gems[2] = Main.Util.GetFormFrom("Skyrim.esm",0x2e4e6)
	Gems[3] = Main.Util.GetFormFrom("Skyrim.esm",0x2e4f4)
	Gems[4] = Main.Util.GetFormFrom("Skyrim.esm",0x2e4fc)
	Gems[5] = Main.Util.GetFormFrom("Skyrim.esm",0x2e500)

	Return Gems
EndFunction

Int Function GemStageCount(Actor Who=None)
{count how many gems are in the dataset.}

	Int Count

	If(Who != None)
		Count = StorageUtil.FormListCount(Who,self.KeyGemStageData)
	EndIf

	If(Count == 0)
		Count = StorageUtil.FormListCount(None,self.KeyGemStageData)
	EndIf

	Return Count
EndFunction

Form Function GemStageGet(Int Val)
{get the type of item for the selected stage.}

	If(Val < 1)
		Return None
	EndIf

	Return StorageUtil.FormListGet(None,KeyGemStageData,(Val - 1))
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function ActorDetermineFeatures(Actor Who)
{assuming y̶o̶u̶r̶ ̶g̶e̶n̶d̶e̶r̶ direct control.}

	;; the typical use case with my players are these:

	;; 0 peni
	;; 1 vagine n bobs
	;; 2 peni n bobs
	;; 3 peni with gems growing in teh boot

	;; these are cases people will ask about but to achieve they will need
	;; to use the wheel menu to customize the character this function will
	;; not return these values:

	;; 4 peni, bobs, vagine, all at once, greedy fucks.
	;; 5 vagoo only
	;; 6 the same as 2 but with a strap on instead of a real penor no semen.

	If(StorageUtil.GetIntValue(Who,self.KeyActorFeaturesCached) == 1)
		Return
	EndIf

	Int Gender = Main.Util.ActorGetGender(Who)

	If(Gender == 0)
		;; typical male.
		Who.AddToFaction(Main.FactionProduceSemen)
		Main.Util.PrintDebug(Who.GetDisplayName() + " defaulted to typical male.")
	ElseIf(Gender == 1)
		;; typical female.
		Who.AddToFaction(Main.FactionProduceMilk)
		Who.AddToFaction(Main.FactionProduceGems)
		Main.Util.PrintDebug(Who.GetDisplayName() + " defaulted to typical female.")
	ElseIf(Gender == 2)
		;; traps.
		Who.AddToFaction(Main.FactionProduceMilk)
		Who.AddToFaction(Main.FactionProduceSemen)
		Main.Util.PrintDebug(Who.GetDisplayName() + " defaulted to trap.")
	Elseif(Gender == 3)
		;; care bears.
		Who.AddToFaction(Main.FactionProduceSemen)
		Who.AddToFaction(Main.FactionProduceGems)
		Main.Util.PrintDebug(Who.GetDisplayName() + " defaulted to care bear.")
	EndIf

	StorageUtil.SetIntValue(Who,self.KeyActorFeaturesCached,1)

	Return
EndFunction

Function ActorReleaseFeatures(Actor Who)
{delete the cache to allow an actor to be redetermined.}

	StorageUtil.UnsetIntValue(Who,self.KeyActorFeaturesCached)
	Return
EndFunction

Bool Function ActorTrackingAdd(Actor Who)
{it does not matter why we want to track the actor. for any reason they get
added to this list.}

	Int Ev = ModEvent.Create("SGO4.Actor.Inspect")

	;; when we attempt to track an actor, regardless of if we already have
	;; or not, this is also a good time to notify other mods that they
	;; may want to inspect the actor if they intend to mod any of their
	;; datasets.

	ModEvent.PushForm(Ev,Who)

	self.ActorDetermineFeatures(Who)

	;;;;;;;;

	If(self.IsActorTracked(Who))
		;; if we are already tracking this actor give up now. send the
		;; inspection event in case a fourth party mod was installed
		;; after the game was running.
		ModEvent.Send(Ev)
		Return FALSE
	EndIf

	;;;;;;;;

	StorageUtil.FormListAdd(None,KeyActorTracking,Who,FALSE)

	;; persist hack.
	Who.UnregisterForUpdate()
	Who.RegisterForUpdate(600)

	Main.Util.PrintDebug(Who.GetDisplayName() + " is now being tracked.")
	ModEvent.Send(Ev)

	Return TRUE
EndFunction

Function ActorTrackingRemove(Actor Who)
{it does not matter why we want to track the actor. for any reason they get
added to this list.}

	StorageUtil.FormListRemove(None,KeyActorTracking,Who,TRUE)

	;; unpersist hack. (left for other mods.)
	;; Who.UnregisterForUpdate()

	;; untrack animations.
	Main.Body.UnregisterForCustomAnimationEvents(Who)

	Main.Util.PrintDebug(Who.GetDisplayName() + " is no longer being tracked.")
	Return
EndFunction

Actor Function ActorTrackingGet(Int Index)
{get the specified actor at the index.}

	Return StorageUtil.FormListGet(None,KeyActorTracking,Index) As Actor
EndFunction

Int Function ActorTrackingCount()
{count how many actors we are tracking.}

	Return StorageUtil.FormListCount(None,KeyActorTracking)
EndFunction

Function ActorTrackingCull()
{remove any actors that vanished.}

	StorageUtil.FormListRemove(None,KeyActorTracking,None,TRUE)

	Return
EndFunction

Bool function IsActorTracked(Actor Who)
{determine if we are tracking this actor or not.}

	Return StorageUtil.FormListHas(None,KeyActorTracking,Who)
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function ActorUpdate(Actor Who)
{update the progression of actor's bio data.}

	Float TimeSince = self.ActorGetHoursSinceUpdate(Who)
	Bool Gems
	Bool Milk
	Bool Semen
	Bool Fertility

	If(TimeSince < Main.Config.GetFloat("UpdateGameHours"))
		Main.Util.PrintDebug(Who.GetDisplayName() + " not ready for calc.")
		Return
	EndIf
	
	Gems = self.ActorGemUpdateData(Who,TimeSince)
	Milk = self.ActorMilkUpdateData(Who,TimeSince)
	Semen = self.ActorSemenUpdateData(Who,TimeSince)
	Fertility = self.ActorFertilityUpdateData(Who,TimeSince)

	If(!Gems && !Milk && !Semen)
		;; if we bailed all three updates then there is no point to be
		;; tracking this actor.
		self.ActorTrackingRemove(Who)
		self.ActorSetTimeUpdated(Who,0.0)
		Return
	EndIf

	self.ActorSetTimeUpdated(Who)
	Return
EndFunction

Float Function ActorGetHoursSinceUpdate(Actor Who)
{return how many game hours have passed since this actor was last updated.}

	Float Current = Utility.GetCurrentGameTime()
	Float Last = StorageUtil.GetFloatValue(Who,self.KeyActorTimeUpdated,0.0)

	If(Last == 0.0)
		self.ActorSetTimeUpdated(Who)
		Last = Current
	EndIf

	Return (Current - Last) * 24
EndFunction

Function ActorSetTimeUpdated(Actor Who, Float When=0.0)
{set this actor as having just been updated.}

	If(When == 0.0)
		When = Utility.GetCurrentGameTime()
	EndIf

	StorageUtil.SetFloatValue(Who,self.KeyActorTimeUpdated,When)
	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Float function ActorModGetFinal(Actor Who, String What, Float Base=1.0)
{get the final value which is the base plus/minus the buffs/debuffs.}

	Float Val = Base + self.ActorModGetBonus(Who,What,Base)

	Return Val
EndFunction

Float Function ActorModGetBonus(Actor Who, String What, Float Base=1.0)
{get the total additive bonus based off the base value.}

	Float Val = Base * self.ActorModGetTotal(Who,What)

	Return Val
EndFunction

Float Function ActorModGetTotal(Actor Who, String What)
{get the total bonus value from all the multiplier mods.}

	String ListName = KeyActorModListPrefix + What
	Int ModCount = StorageUtil.StringListCount(Who,ListName)
	Float Val = 0.0
	String ValueName

	While(ModCount > 0)
		ModCount -= 1

		ValueName = StorageUtil.StringListGet(Who,ListName,ModCount)
		Val += StorageUtil.GetFloatValue(Who,ValueName)
	EndWhile

	Return Val
EndFunction

Function ActorModSetValue(Actor Who, String What, String ModKey, Float Val=0.0)
{add/set a buff to the actor.}

	String ListName = KeyActorModListPrefix + What
	String ValueName = KeyActorModValuePrefix + What + "." + ModKey

	StorageUtil.StringListAdd(Who,ListName,ValueName,FALSE)
	StorageUtil.SetFloatValue(Who,ValueName,Val)

	Main.Util.PrintDebug("Mod " + Who.GetDisplayName() + " " + ValueName + "=" + Val + " Added")
	Return
EndFunction

Function ActorModUnsetValue(Actor Who, String What, String ModKey)
{remove a buff from an actor.}

	String ListName = KeyActorModListPrefix + What
	String ValueName = KeyActorModValuePrefix + What + "." + ModKey

	StorageUtil.StringListRemove(Who,ListName,ValueName,TRUE)
	StorageUtil.UnsetFloatValue(Who,ValueName)

	Main.Util.PrintDebug("Mod " + Who.GetDisplayName() + " " + ValueName + " Removed")
	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Bool Function ActorGemAdd(Actor Who, Float Val=0.0)
{insert a new gem into the dataset. returns if successful or not.}

	If(self.ActorGemCount(Who) >= self.ActorGemMax(Who))
		Return FALSE
	EndIf

	StorageUtil.FloatListAdd(Who,self.KeyActorGemData,Val)

	self.ActorTrackingAdd(Who)
	Main.Body.ActorUpdate(Who)

	Return TRUE
EndFunction

Function ActorGemClear(Actor Who)
{drop all gem data for this actor.}

	StorageUtil.FloatListClear(Who,self.KeyActorGemData)
	Main.Body.ActorUpdate(Who)

	Return
EndFunction

Float Function ActorGemGet(Actor Who, Int Index, Bool Limit=TRUE)
{get the value of a specific gem in an actor.}

	Int Max = self.GemStageCount(Who)
	Float Gem = StorageUtil.FloatListGet(Who,KeyActorGemData,Index)

	If(Limit && Gem > Max)
		Gem = Max as Float
	EndIf

	Return Gem
EndFunction

Float Function ActorGemInc(Actor Who, Int Index, Float Inc)
{get the value of a specific gem in an actor.}

	Float Val = StorageUtil.FloatListAdjust(Who,KeyActorGemData,Index,Inc)

	self.ActorTrackingAdd(Who)
	Main.Body.ActorUpdate(Who)

	Return Val
EndFunction

Int Function ActorGemCount(Actor Who)
{return how many gems an actor is currently incubating.}

	Return StorageUtil.FloatListCount(Who,self.KeyActorGemData)
EndFunction

Int Function ActorGemMax(Actor Who)
{return how many gems an actor can incubate at one time. it is rounded in the
event with mods its a fraction of a gem.}

	Int Base = Main.Config.GetInt("ActorGemsMax")
	Float Val = self.ActorModGetFinal(Who,"GemsMax",Base)
	
	Return Main.Util.RoundToInt(Val)
EndFunction

Float Function ActorGemTotalPercent(Actor Who, Bool Relative=FALSE)
{get the current state of fullness of the gems. if Relative is true then
the percent will be calculated against how many gems they currently have
instead of the max they can have.}

	;; if we get values larger than expected gracefully roll them down to
	;; their max. this could happen in the event if like a buff had expired
	;; right before updating.

	Int GemStages = self.GemStageCount(Who)
	Int GemCount = self.ActorGemCount(Who)
	Int ValueMax = (self.ActorGemMax(Who) * GemStages)
	Int GemIter = 0
	Float Value = 0.0
	Float Current = 0.0

	If(Relative == TRUE)
		ValueMax = GemCount * GemStages

		If(ValueMax == 0)
			Return 0.0
		EndIf
	EndIf

	While(GemIter < GemCount)
		Current = self.ActorGemGet(Who,GemIter)

		Value += Current
		GemIter += 1
	EndWhile

	If(Value > ValueMax)
		Value = ValueMax as Float
	EndIf

	;;Main.Util.PrintDebug(GemStages + ", " + GemCount + ", " + ValueMax + ", " + Value)

	Return (Value / (ValueMax as Float))
EndFunction

Float Function ActorGemRemoveLargest(Actor Who)
{pull the largest gem out of the dataset.}

	Int Len = StorageUtil.FloatListCount(Who,self.KeyActorGemData)
	Float Out

	StorageUtil.FloatListSort(Who,self.KeyActorGemData)
	Out = self.ActorGemGet(Who,(Len - 1))

	;; todo return negative if unable
	;; original idea may be unneded due to ActorGemReady doing a >1 check.

	StorageUtil.FloatListRemoveAt(Who,self.KeyActorGemData,(Len - 1))

	Main.Body.ActorUpdate(Who)
	Return Out
EndFunction

Bool Function ActorGemReady(Actor Who)
{return if this actor has any gems that have progressed far enough to birth.}

	Int GemCount = self.ActorGemCount(Who)
	Int GemIter = 0

	While(GemIter < GemCount)
		If(self.ActorGemGet(Who,GemIter) >= 1.0)
			Return TRUE
		EndIf
		GemIter += 1
	EndWhile

	Return FALSE
EndFunction

Bool Function ActorGemUpdateData(Actor Who, Float TimeSince)
{update the actors gem data given the time progression. returns false if this
actor is physically not capable of producing this item.}

	Float PerDay = Main.Config.GetFloat("GemsPerDay")
	Float Inc = ((TimeSince * PerDay) / 24.0)
	Int GemCount = self.ActorGemCount(Who)
	Int GemStages = self.GemStageCount(Who)
	Int GemCurMax = GemCount * GemStages
	Int GemCurTotal = 0
	Int GemIter = 0
	Int GemOld
	Int GemNew
	Bool Growth = FALSE

	;;;;;;;;

	If(!Who.IsInFaction(Main.FactionProduceGems))
		Return FALSE
	EndIf

	If(GemCount == 0)
		Main.Util.PrintDebug(Who.GetDisplayName() + " is not incubating gems.")
		Return TRUE
	EndIf

	;;;;;;;;

	While(GemIter < GemCount)
		GemOld = Math.Floor(self.ActorGemGet(Who,GemIter))
		GemNew = Math.Floor(self.ActorGemInc(Who,GemIter,Inc))
		GemCurTotal += GemNew

		If(GemOld != GemNew && GemNew <= GemStages)
			Main.Util.PrintDebug("Gem Inc " + GemOld + " => " + GemNew)
			Main.Stats.IncInt(Who,Main.Stats.KeyGemsIncubated,(GemNew-GemOld),TRUE)
			Growth = TRUE
		EndIf

		GemIter += 1
	EndWhile

	;;;;;;;;

	If(Growth)
		If(Who == Main.Player)
			Main.Util.PrintLookupRandom("FlavourPlayerGemGrowth")
		EndIf
	ElseIf(GemCurTotal >= GemCurMax)
		If(Who == Main.Player)
			Main.Util.PrintLookupRandom("FlavourPlayerGemFull")
		EndIf
	EndIf

	Main.Util.PrintDebug(Who.GetDisplayName() + " " + GemCount + " gems have progressed " + Inc)
	Return TRUE
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function ActorMilkSet(Actor Who, Float Value)
{set how much milk the actor should have.}

	StorageUtil.SetFloatValue(Who,self.KeyActorMilkData,Value)
	self.ActorTrackingAdd(Who)
	Main.Body.ActorUpdate(Who)

	Return
EndFunction

Function ActorMilkInc(Actor Who, Float Value)
{add/sub how much milk this actor has.}

	Float Milk = StorageUtil.AdjustFloatValue(Who,self.KeyActorMilkData,Value)
	Main.Util.PrintDebug(Who.GetDisplayName() + " now has " + Milk + " milk.")

	self.ActorTrackingAdd(Who)
	Main.Body.ActorUpdate(Who)

	Return
EndFunction

Function ActorMilkLimit(Actor Who)
{if this actor is over the limit on maximum milk, limit it.}

	Float Amount = self.ActorMilkAmount(Who,FALSE)
	Int Max = self.ActorMilkMax(Who)

	If(Amount > Max)
		self.ActorMilkSet(Who,Max as Float)
	EndIf

	Return
EndFunction

Float Function ActorMilkAmount(Actor Who, Bool Limit=TRUE)
{return how much milk an actor has.}

	Int MilkMax = self.ActorMilkMax(Who)
	Float MilkVal = StorageUtil.GetFloatValue(Who,self.KeyActorMilkData)

	If(Limit && MilkVal > MilkMax)
		MilkVal = MilkMax as Float
	EndIf

	Return MilkVal
EndFunction

Function ActorMilkClear(Actor Who)
{drop milk data for this actor.}

	StorageUtil.SetFloatValue(Who,self.KeyActorMilkData,0.0)
	Main.Body.ActorUpdate(Who)

	Return
EndFunction

Int Function ActorMilkMax(Actor Who)
{return how much milk an actor can have at once.}

	Int Base = Main.Config.GetInt("ActorMilkMax")
	Float Val = self.ActorModGetFinal(Who,"MilkMax",Base)

	Return Main.Util.RoundToInt(Val)
EndFunction

Float Function ActorMilkTotalPercent(Actor Who)
{get the current state of fullness of milk.}

	Float MilkAmount = self.ActorMilkAmount(Who)
	Int ValueMax = self.ActorMilkMax(Who)

	Return (MilkAmount / (ValueMax as Float))
EndFunction

Bool Function ActorMilkUpdateData(Actor Who, Float TimeSince)
{update the actors gem data given the time progression. returns false if this
actor is physically not capable of producing this item.}

	Float PregPercent = self.ActorGemTotalPercent(Who)
	Float PregNeeded = Main.Config.GetFloat("MilksPregPercent") / 100.0
	Float PerDay = Main.Config.GetFloat("MilksPerDay")
	Float Inc = ((TimeSince * PerDay) / 24.0)
	Int MilkMax = self.ActorMilkMax(Who)
	Int MilkOld
	Int MilkNew

	If(!Who.IsInFaction(Main.FactionProduceMilk))
		Return FALSE
	EndIf

	If(PregPercent < PregNeeded)
		Main.Util.PrintDebug(Who.GetDisplayName() + " is not producing milk yet.")
		Return TRUE
	EndIf

	Inc *= PregPercent
	MilkOld = Math.Floor(self.ActorMilkAmount(Who))
	self.ActorMilkInc(Who,Inc)
	MilkNew = Math.Floor(self.ActorMilkAmount(Who))

	If(MilkOld != MilkNew)
		Main.Stats.IncInt(Who,Main.Stats.KeyMilksProduced,(MilkNew-MilkOld),TRUE)

		If(Who == Main.Player)
			If(MilkNew == MilkMax)
				Main.Util.PrintLookupRandom("FlavourPlayerMilkFull")
			Else
				Main.Util.PrintLookupRandom("FlavourPlayerMilkProduced")
			EndIf
		EndIf
	EndIf

	Main.Util.PrintDebug(Who.GetDisplayName() + " milk has progressed " + Inc)
	Return TRUE
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Float Function ActorSemenAmount(Actor Who, Bool Limit=TRUE)
{return how much semen an actor has.}

	Int SemenMax = self.ActorSemenMax(Who)
	Float SemenVal = StorageUtil.GetFloatValue(Who,self.KeyActorSemenData,-1.0)

	If(SemenVal < 0)
		;; if no data assume they never been wanked before.
		StorageUtil.SetFloatValue(Who,self.KeyActorSemenData,SemenMax)
		SemenVal = SemenMax
	EndIf

	If(Limit && SemenVal > SemenMax)
		SemenVal = SemenMax as Float
	EndIf

	Return SemenVal
EndFunction

Function ActorSemenClear(Actor Who)
{add/sub how much semen this actor has.}

	StorageUtil.SetFloatValue(Who,self.KeyActorSemenData,0.0)
	Main.Body.ActorUpdate(Who)

	Return
EndFunction

Function ActorSemenSet(Actor Who, Float Value)
{add/sub how much semen this actor has.}

	StorageUtil.SetFloatValue(Who,self.KeyActorSemenData,Value)
	self.ActorTrackingAdd(Who)

	Return
EndFunction

Function ActorSemenInc(Actor Who, Float Value)
{add/sub how much semen this actor has.}

	StorageUtil.AdjustFloatValue(Who,self.KeyActorSemenData,Value)
	self.ActorTrackingAdd(Who)
	
	Return
EndFunction

Function ActorSemenLimit(Actor Who)
{if this actor is over the limit on maximum semen, limit it.}

	Float Amount = self.ActorSemenAmount(Who,FALSE)
	Int Max = self.ActorSemenMax(Who)

	If(Amount > Max)
		self.ActorSemenSet(Who,Max as Float)
	EndIf

	Return
EndFunction

Int Function ActorSemenMax(Actor Who)
{return how many bottles of semen an actor can have at once.}

	Int Base = Main.Config.GetInt("ActorSemenMax")
	Float Val = self.ActorModGetFinal(Who,"SemenMax",Base)

	Return Main.Util.RoundToInt(Val)
EndFunction

Float Function ActorSemenTotalPercent(Actor Who)
{get the current state of fullness of milk.}

	Float SemenAmount = self.ActorSemenAmount(Who)
	Int ValueMax = self.ActorSemenMax(Who)

	Return (SemenAmount / (ValueMax as Float))
EndFunction

Bool Function ActorSemenUpdateData(Actor Who, Float TimeSince)
{update the actors gem data given the time progression. returns false if this
actor is physically not capable of producing this item.}

	Float PerDay = Main.Config.GetFloat("SemensPerDay")
	Float Inc = ((TimeSince * PerDay) / 24.0)

	If(!Who.IsInFaction(Main.FactionProduceSemen))
		Return FALSE
	EndIf

	self.ActorSemenInc(Who,Inc)

	Main.Util.PrintDebug(Who.GetDisplayName() + " semen has progressed " + Inc)
	Return TRUE
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Float Function ActorFertilityValue(Actor Who)
{get the current fertility value.}

	Float Value = StorageUtil.GetFloatValue(Who,self.KeyActorFertilityData,-1.0)

	If(Value == -1.0)
		Value = Utility.RandomFloat(0.0,Main.Config.GetInt("FertilityDays"))
		StorageUtil.SetFloatValue(Who,self.KeyActorFertilityData,Value)
	EndIf

	Return Value
EndFunction

Float Function ActorFertilityFactor(Actor Who, float Vmod=0.0)
{fetch the current multiplier for the fertility value using science and shit.}

	Int FertilityDays = Main.Config.GetInt("FertilityDays")
	Float FertilityWindow = Main.Config.GetFloat("FertilityWindow")
	Float Fval
	Float Poff
	Int Plen

	If(FertilityDays == 0.0)
		Return 1.0
	EndIf

	;; the x value of the wave.

	Fval = self.ActorFertilityValue(Who)
	Fval += Vmod


	;; the period offset is used to crank the amplitude and vertical offset of
	;; the wave.
	
	Poff = (FertilityWindow - 1) / 2

	;; the period length.
	
	Plen = FertilityDays

	;;  /     /          \      \
	;; |     | 2[pi]      |      |
	;; | sin | ----- fval | poff | + poff
	;; |     | plen       |      |
	;;  \     \          /      /
	;;           period    amp    y-offset

	;; SINEWAVESMOTHERFUCKER.

	Return ((Math.Sin(Math.RadiansToDegrees(((2*3.14159) / Plen) * Fval)) * Poff) + Poff) + 1
EndFunction

Bool Function ActorFertilityUpdateData(Actor Who, Float TimeSince)
{this function will keep a running loop of time from 0 to 28. returns false if
the actor is not biologically able to produce gems.}

	;; 1 2 3... 27 28 0 1 2 3...

	Int FertilityDays = Main.Config.GetInt("FertilityDays")
	Bool FertilitySync = Main.Config.GetBool("FertilitySync")
	Float FertilityWindow = Main.Config.GetFloat("FertilityWindow")
	Float SyncDist

	If(!Who.IsInFaction(Main.FactionProduceGems))
		Return FALSE
	EndIf

	If(FertilityDays == 0)
		;; no need to process if disabled.
		Return TRUE
	EndIf

	If(TimeSince < 1.0)
		;; no need to process if too soon.
		Return TRUE
	EndIf

	;; get our current values. if this actor has not yet ever been calculated
	;; then we set them at a random point in the cycle to try and avoid having
	;; all the females in skyrim synced up.

	Float Fval = self.ActorFertilityValue(Who)
	Float Nval = Fval + (TimeSince / 24.0)

	;; attempt to sync up cycles with any followers currently following lololol.
	;; for starters we will try just making followers run hotter until they
	;; are synced up.

	If(FertilitySync && Who != Main.Player)
		;; todo follower faction check not distance check.
		If(Main.Player.GetDistance(Who) <= 750)
			SyncDist = self.ActorFertilityFactor(Who) - self.ActorFertilityFactor(Main.Player)
			Main.Util.PrintDebug(Who.GetDisplayName() + " fertility out of sync by " + SyncDist)

			;; trying to bring followers to be in sync within 1.5 days of eachother.
			;; i think if someone was almost sycned, and then you fast wait multiple
			;; days, it might be possible they overshoot and then have to compinsate
			;; again. i am leaning towards that actually intentionally being a game
			;; mecahnic as punishment for cheating. while actually playing they will
			;; eventually sync.

			If( Math.Abs(SyncDist) > (FertilityWindow * (1.5 / FertilityDays)) )
				If(SyncDist > 0.0)
					Nval += ((TimeSince / 24.0) * 3.0)
				Else
					Nval -= ((TimeSince / 24.0) * 4.0)
				EndIf
			EndIf

		EndIf
	EndIf

	Nval = PapyrusUtil.WrapFloat(Nval,FertilityDays,1.0)

	;; update our fertile value.

	StorageUtil.SetFloatValue(Who,self.KeyActorFertilityData,Nval)
	Main.Util.PrintDebug(Who.GetDisplayName() + " fertility data " + Nval + " " + self.ActorFertilityFactor(Who))

	;; todo: immersive messages comparing fval and nval.

	Return TRUE
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Function RaceLoadFiles()
{index all the race files available to scan.}

	Int Iter

	self.RaceFiles = JsonUtil.JsonInFolder(self.RaceDirectory)
	PapyrusUtil.SortStringArray(self.RaceFiles)

	;; flesh out the full file path.

	Iter = 0
	While(Iter < self.RaceFiles.Length)
		self.RaceFiles[Iter] = self.RaceDirectory + "/" + self.RaceFiles[Iter]
		Iter += 1
	EndWhile

	;; cache the race count. runs through all the files.

	self.RaceCount = self.RaceCount()
	Main.Util.PrintDebug("Found " + self.RaceFiles.Length + " race files with " + self.RaceCount + " total races.")

	Return
EndFunction

Int Function RaceCount()
{count how many total races have been configured via json files. this is
automatically done and cached on game load.}

	Int Total = 0
	Int Iter = 0

	While(Iter < self.RaceFiles.Length)
		Main.Util.PrintDebug(self.RaceFiles[Iter])
		Total += JsonUtil.PathCount(self.RaceFiles[Iter],"Races")
		Iter += 1
	EndWhile

	Return Total
EndFunction

Int[] Function RaceFind(Race What)
{returns an array len of 2, first number is which race file we found the race
in and the second number is which array item was the race.}

	Int[] Offset = new Int[2]
	Int FileRaceCount
	Race Current
	String Path

	Offset[0] = 0
	Offset[1] = 0

	While(Offset[0] < self.RaceFiles.Length)
		Offset[1] = 0
		FileRaceCount = JsonUtil.PathCount(self.RaceFiles[Offset[0]],"Races")

		While(Offset[1] < FileRaceCount)
			Path = "Races[" + Offset[1] + "].Race"
			Current = JsonUtil.GetPathFormValue(self.RaceFiles[Offset[0]],Path) as Race

			If(Current == What)
				Return Offset
			EndIf

			Offset[1] = Offset[1] + 1
		EndWhile

		Offset[0] = Offset[0] + 1
	EndWhile

	Offset[0] = 0
	Offset[1] = 1	
	Return Offset
EndFunction

Form Function RaceGetMilk(Int FileIndex, Int RaceIndex)
{get the milk for the specified race.}

	String Path = "Races[" + RaceIndex + "].Milk"

	Return JsonUtil.GetPathFormValue(self.RaceFiles[FileIndex],Path)
EndFunction

Form Function RaceGetSemen(Int Index)
{get the semen for the specified race.}

	String Path = "Races[" + Index + "].Semen"

	Return JsonUtil.GetPathFormValue(self.FileRaces,Path)
EndFunction

Form Function RaceGetSemen2(Int FileIndex, Int RaceIndex)
{get the semen for the specified race.}

	String Path = "Races[" + RaceIndex + "].Semen"

	Return JsonUtil.GetPathFormValue(self.RaceFiles[FileIndex],Path)
EndFunction