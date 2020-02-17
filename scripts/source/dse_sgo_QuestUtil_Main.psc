ScriptName dse_sgo_QuestUtil_Main extends Quest

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dse_sgo_QuestController_Main Property Main Auto

String Property FileStrings = "../../../configs/dse-soulgem-oven/translations/English.json" AutoReadOnly Hidden

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; mostly debugging

Function Print(String Msg)

	Debug.Notification("[SGO] " + Msg)
	Return
EndFunction

Function PrintDebug(String Msg)

	If(Main.Config.DebugMode)
		MiscUtil.PrintConsole("[SGO] " + Msg)
		Debug.Trace("[SGO] " + Msg)
	EndIf

	Return
EndFunction

Function PopupError(String Msg)
{display an error message that the user must address.}

	String Output = ""

	Output += "Soulgem Oven Error:\n"
	Output += Msg

	Debug.MessageBox(Output)
	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; mostly game data related.

Form Function GetForm(Int FormID)
{get a specific form from the soulgem oven esp.}

	Return Game.GetFormFromFile(FormID,Main.KeyESP)
EndFunction

Form Function GetFormFrom(String ModName, Int FormID)
{gets a form from a specific mod.}

	If(!Game.IsPluginInstalled(ModName))
		Return NONE
	EndIf

	Return Game.GetFormFromFile(FormID,ModName)
EndFunction


Function SortByDisplayName(Actor[] ItemList)
{sort a list of actors by their name.}

	Actor TmpForm
	Int Iter
	Bool Changed = TRUE

	While(Changed)
		Iter = 0
		Changed = FALSE

		While(Iter < (ItemList.Length - 1))

			If(ItemList[Iter].GetDisplayName() > ItemList[(Iter+1)].GetDisplayName())
				TmpForm = ItemList[Iter]
				ItemList[Iter] = ItemList[(Iter+1)]
				ItemList[(Iter+1)] = TmpForm
				Changed = TRUE
			EndIf

			Iter += 1
		EndWhile
	EndWhile

	Return
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; maths

Int Function RoundToInt(Float Val)
{round a float to an integer.}

	Return Math.Floor(Val + 0.5)
EndFunction

Float Function RoundTo(Float Val, Int Dec=0)
{round a float to a specified number of decimal places.}

	Float Bump = Math.Pow(10,Dec) As Float

	Return (Math.Floor((Val * Bump) + 0.5) As Float) / Bump
EndFunction

Float Function FloorTo(Float Val, Int Dec=0)
{floor a float to a specified number of decimal places.}

	Float Bump = Math.Pow(10,Dec) As Float

	Return (Math.Floor(Val * Bump) As Float) / Bump
EndFunction

String Function FloatToString(Float Val, Int Dec=0)
{"convert" a float into a string - e.g. get a printable float
that cuts off all the ending zeroes the game adds when casting
a float into a string directly.}

	Int Last = Math.Floor(Val)
	String Output = Last As String

	If(Dec > 0 && Val != Last)
		Output += "."

		While(Dec > 0)
			Val = (Val - Last) * 10
			Last = Math.Floor(Val)
			Output += Last As String

			Dec -= 1
		EndWhile
	EndIf

	Return Output
EndFunction

String[] Function FloatsToStrings(Float[] Vals, Int Dec=0)
{convert a list of floats into strings using FloatToString.}

	String[] Output = Utility.CreateStringArray(Vals.Length)
	Int Iter = Vals.Length

	While(Iter > 0)
		Iter -= 1
		Output[Iter] = self.FloatToString(Vals[Iter],Dec)
	EndWhile

	Return Output
EndFunction

String Function DecToHex(Int Number)

	String Output = ""
	String[] HexChar = new String[16]
	Int HexKey = 0

	If(Number == 0)
		Output = "0"
	Else
		HexChar[0] = "0"
		HexChar[1] = "1"
		HexChar[2] = "2"
		HexChar[3] = "3"
		HexChar[4] = "4"
		HexChar[5] = "5"
		HexChar[6] = "6"
		HexChar[7] = "7"
		HexChar[8] = "8"
		HexChar[9] = "9"
		HexChar[10] = "A"
		HexChar[11] = "B"
		HexChar[12] = "C"
		HexChar[13] = "D"
		HexChar[14] = "E"
		HexChar[15] = "F"

		While(Number != 0)
			HexKey = Math.LogicalAnd(Number,0xF)
			Number = Math.RightShift(Number,4)
			Output = HexChar[HexKey] + Output
		EndWhile
	EndIf

	Return Output
EndFunction

Float Function GetLeveledValue(Float Level, Float Value, Float Factor = 1.0)
{modify a value based on a level 100 system. this means at level 100 the input
value will be doubled.}
	
	;; input 1 at level 0
	;; ((0 / 100) * 1) + 1 = 1

	;; input 1 at level 1
	;; ((1 / 100) * 1) + 1 = 1.01

	;; input 1 at level 50
	;; ((50 / 100) * 1) + 1 = 1.5

	;; input 1 at level 100
	;; ((100 / 100) * 1) + 1 = 2.0

	Float Base = Main.Config.GetFloat(".LevelValueBase")

	Return (((Level / Base) * (Value * Factor)) + Value) as Float
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; strings

String Function StringInsert(String Format, String InputList="")
{a cheeky af implementation of like an sprintf type thing but not.}

	Int Iter = 0
	Int Pos = -1
	String ToFind
	String[] Inputs

	;; short short circuit if we can.

	If(StringUtil.GetLength(InputList) == 0)
		Return Format
	EndIf

	;; rebuild a full string.

	Inputs = PapyrusUtil.StringSplit(InputList,"|")

	While(Iter < Inputs.Length)
		ToFind = "%" + (Iter+1)
		Pos = StringUtil.Find(Format,ToFind)

		;; substring with a length of 0 means full string so we had to test
		;; the position in case the token was the first thing in the string.

		If(Pos > -1)
			If(Pos > 0)
				Format = StringUtil.Substring(Format,0,Pos) + Inputs[Iter] + StringUtil.Substring(Format,(Pos+2))
			Else
				Format = Inputs[Iter] + StringUtil.Substring(Format,(Pos+2))
			EndIf			
		EndIf

		Iter += 1
	EndWhile

	Return Format
EndFunction

String Function StringLookup(String Path, String InputList="")
{get a string from the translation file and run it through StringInsert.}

	String Format = JsonUtil.GetPathStringValue(self.FileStrings,Path,("MISSING STRING LOL: " + Path))

	Return self.StringInsert(Format,InputList)
EndFunction

String Function StringLookupRandom(String Path, String InputList="")
{get a random string from the translation file and run it through StringInsert.}

	Int Count = JsonUtil.PathCount(self.FileStrings,Path)
	Int Selected = Utility.RandomInt(0,(Count - 1))
	String Format = JsonUtil.GetPathStringValue(self.FileStrings,(Path + "[" + Selected + "]"))

	Return self.StringInsert(Format,InputList)
EndFunction

Function PrintLookup(String KeyName, String InputList="")
{print a notification string from the translation file.}

	self.Print(self.StringLookup(KeyName,InputList))
EndFunction

Function PrintLookupRandom(String KeyName, String InputList="")
{print a random string from the translation file.}

	self.Print(self.StringLookupRandom(KeyName,InputList))
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; game utility

Function ActorArmourRemove(Actor Who)
{remove an actor's chestpiece.}

	Form[] Items

	If(Main.Config.GetBool(".SexLabStrip"))
		Items = Main.SexLab.StripActor(Who,None,FALSE,FALSE) as Form[]
		Main.Util.PrintDebug("Stripping " + Who.GetDisplayName() + " via SexLab (" + Items.Length + ")")
	Else
		Main.Util.PrintDebug("Stripping " + Who.GetDisplayName() + " manually.")
		If(Who.GetWornForm(0x00000004) != None)
			Items = new Form[1]
			Items[0] = Who.GetWornForm(0x00000004)
			Who.UnequipItemSlot(32)
			Who.QueueNiNodeUpdate()
		EndIf
	EndIf

	If(Items.Length > 0)
		StorageUtil.FormListCopy(Who,"SGO4.Actor.Armor",Items)
	EndIf

	Return
EndFunction

Function ActorArmourReplace(Actor Who)
{replace an actor's chestpiece.}

	Form[] Items

	If(StorageUtil.FormListCount(Who,"SGO4.Actor.Armor") > 0)
		Items = StorageUtil.FormListToArray(Who,"SGO4.Actor.Armor") as Form[]
	EndIf

	;;If(Main.Config.GetBool(".SexLabStrip"))
	If(Items.Length > 0)
		Main.SexLab.UnstripActor(Who,Items,FALSE)
	EndIf
	;;Else
	;;	If(StorageUtil.GetFormValue(Who,"SGO.Actor.Armor.Chest"))
	;;		Who.EquipItem(Storageutil.GetFormValue(Who,"SGO.Actor.Armor.Chest"),FALSE,TRUE)
	;;		StorageUtil.SetFormValue(who,"SGO.Actor.Armor.Chest",None)
	;;	EndIf
	;;EndIf

	StorageUtil.FormListClear(Who,"SGO4.Actor.Armor")
	Return
EndFunction

Function ActorLevelAlchemy(Actor Who, Float ItemValue=1.0)
{progress the alchemy skill for the specified actor. for most things we will
leave ItemValue at the default of 1.0.}

	Float Factor
	Float Level
	Float Value
	Float MilksPerDay

	If(Who != Main.Player)
		;; not possible to level npcs at this time.
		Return
	EndIf

	Factor = Main.Config.GetFloat(".LevelAlchFactor")
	MilksPerday = Main.Config.GetFloat(".MilksPerDay")

	If(Factor == 0.0)
		;; do not process when disabled.
		Return
	EndIf

	;; http://www.uesp.net/wiki/Skyrim:Leveling#Skill_XP

	;; xp/btl gained at x btl/day at level 0.
	;; double this at level 100 with 1.0 progress factor.
	;; 1 = 100xp
	;; 2 = 50xp
	;; 3 = 33xp (default)

	Level = Who.GetLevel()
	Value = (100 / MilksPerDay) * ItemValue

	;; if its progressing retarded fast, manipulate the 24 to be smaller.
	;; if too slow manipulate the 24 larger.
	;; once this calc feels good to me at default, users can tweak it via the factor.

	Game.AdvanceSkill("Alchemy",self.GetLeveledValue(Level,Value,Factor))
	Return
EndFunction

Function ActorLevelEnchanting(Actor Who, Float ItemValue=-1.0)
{progress the enchanting skill for the specified actor. item value will default
to an item value equal to the gem stages as we are using this for gem birthing
mostly.}

	Float Factor
	Float Level
	Float Value
	Float Base

	If(Who != Main.Player)
		;; not possible to level npcs at this time.
		Return
	EndIf

	Factor = Main.Config.GetFloat(".LevelEnchFactor")

	If(Factor == 0.0)
		;; do not process when disabled.
		Return
	EndIf

	;; http://www.uesp.net/wiki/Skyrim:Leveling#Skill_XP
	;; normal enchanting works as 1xp per item enchanted and it seems enchanting levels fast
	;; so we will use small numbers here.

	Base = Main.Data.GemStageCount(Who)
	Level = Who.GetLevel()

	If(ItemValue == -1.0)
		ItemValue = Base
	EndIf

	Value = ((ItemValue / Base) / 2.0)

	;; if enchanting levels too slow manipulate the /2.0 smaller.
	;; if too fast, manipulate the /2.0 larger.
	;; once this calc feels good to me at default, users can tweak it via the factor.

	Game.AdvanceSkill("Enchanting",self.GetLeveledValue(Level,Value,Factor))
	Return
EndFunction

Int Function ActorGetGender(Actor Who)
{return 0 for male, 1 for female, 2 for ftm, 3 for mtf. if you mod the value
of this by 2 it will narrow the results to 0 or 1, which you can typically
trust as "this actor flat out wishes to be treated as" male or female if you
just need a snap judgement.}

	Int GameSays = Who.GetLeveledActorBase().GetSex()
	Int SexLabSays = Main.SexLab.GetGender(Who) % 2

	;; if sexlab and the game agree then we will just take what it says
	;; at face value.

	If(GameSays == SexLabSays)
		Return SexLabSays
	EndIf

	;; else the code asking the question will need to make some decisions
	;; about what to do next.

	If(GameSays == 1 && SexLabSays == 0)
		Return 2 ;; ftm
	EndIf

	If(GameSays == 0 && SexLabSays == 1)
		Return 3 ;; mtf
	EndIf

	Return 0
EndFunction

Bool Function ActorHasPackageOverrides(Actor Who)
{return if there are any package overrides on this actor and the current
package is not one of ours. designed for detecting if other mods like
display model are currently forcing the actor to do more important thigngs.}

	Package Pkg = StorageUtil.GetFormValue(Who,"SGO4.Actor.Lockdown") as Package

	If(ActorUtil.CountPackageOverride(Who) > 0)
		If(Pkg != None)
			Return (Who.GetCurrentPackage() != Pkg)
		Else
			Return (Who.GetCurrentPackage() != Main.PackageDoNothing)
		EndIf
	EndIf

	Return FALSE
EndFunction

Function ActorToggleFaction(Actor Who, Faction What)
{add the actor to a faction if not in it, remove them from it if they are.}

	If(Who.IsInFaction(What))
		Who.RemoveFromFaction(What)
	Else
		Who.AddToFaction(What)
	EndIf

	Main.Data.ActorTrackingAdd(Who)
	Return
EndFunction

Bool Function ActorIsValid(Actor Who)
{check if the actor is valid for use.}

	Int SexLabSays

	If(Main.OptValidateActor)
		SexLabSays = Main.SexLab.ValidateActor(Who)

		If(SexLabSays < 0)
			self.PrintDebug(Who.GetDisplayName() + " did not pass sexlab's test: " + SexLabSays)
			Return FALSE
		EndIf
	EndIf

	Return TRUE
EndFunction

String Function GetBirthingAnimationName(Int Offset)
{0 = random, 1 and higher specific animation.}

	String[] AniList = new String[1]
	AniList[0] = Main.Body.AniBirth01
	Offset = PapyrusUtil.ClampInt(Offset,0,AniList.Length) - 1

	If(Offset == -1)
		Offset = Utility.RandomInt(0,(AniList.Length - 1))
	EndIf

	Return AniList[Offset]
EndFunction

String Function GetInsertingAnimationName(Int Offset)
{0 = random, 1 and higher specific animation.}

	String[] AniList = new String[2]
	AniList[0] = Main.Body.AniInsert01
	AniList[1] = Main.Body.AniInsert02
	Offset = PapyrusUtil.ClampInt(Offset,0,AniList.Length) - 1

	If(Offset == -1)
		Offset = Utility.RandomInt(0,(AniList.Length - 1))
	EndIf

	Return AniList[Offset]
EndFunction

String Function GetMilkingAnimationName(Int Offset)
{0 = random, 1 and higher specific animation.}

	String[] AniList = new String[1]
	AniList[0] = Main.Body.AniMilking01
	Offset = PapyrusUtil.ClampInt(Offset,0,AniList.Length) - 1

	If(Offset == -1)
		Offset = Utility.RandomInt(0,(AniList.Length - 1))
	EndIf

	Return AniList[Offset]
EndFunction

String Function GetWankingAnimationName(Int Offset)
{0 = random, 1 and higher specific animation.}

	String[] AniList = new String[1]
	AniList[0] = Main.Body.AniWanking01
	Offset = PapyrusUtil.ClampInt(Offset,0,AniList.Length) - 1

	If(Offset == -1)
		Offset = Utility.RandomInt(0,(AniList.Length - 1))
	EndIf

	Return AniList[Offset]
EndFunction