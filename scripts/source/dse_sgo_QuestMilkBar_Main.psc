Scriptname dse_sgo_QuestMilkBar_Main extends dse_sgo_QuestGemBar_Main

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnWidgetReset()
{override: when a widget is turned on.}

	self.ColourRight = 0x858585
	self.ColourLeft = 0xF2F2F2
	self.ColourFlash = -1

	self.WidgetBaseReset()

	self.SetAlpha(0.0)
	self.SetAnchor(self.PosH,self.PosV,FALSE)
	self.SetScale(self.Scale)
	self.SetPosition(self.PosX,self.PosY)
	self.SetColour(self.ColourLeft,self.ColourRight,self.ColourFlash)
	self.SetDirection(self.Direction)
	self.SetTitle(self.Title)
	self.SetText(self.Text)

	self.WidgetReady("SGO4.MilkBar.Ready")
	Return
EndEvent

String function GetWidgetType()
{override: specify the class of the ui element.}

	return "SGO4MilkBar"
EndFunction
