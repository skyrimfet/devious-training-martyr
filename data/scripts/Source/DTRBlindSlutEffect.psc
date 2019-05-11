Scriptname DTRBlindSlutEffect extends ActiveMagicEffect  

DTRActor   Property DTActor   Auto
DTRConfig  Property DTConfig  Auto
DTRStorage Property DTStorage Auto
DTRTools   Property DTTools   Auto
DTRSound   Property DTSound   Auto
Actor Property acActor Auto
Int Property Slot Auto
Bool Property EffectIsRunning Auto

Actor[] Property foundActors Auto

Event OnEffectStart(Actor akTarget, Actor akCaster)

	Slot = DTActor.isRegistered(akTarget)

	if Slot == -1 || DTActor.npcs_blindSlut[Slot] > 1; || DTActor.achievementBlindSlut[slot] == false
		self.Dispel()
		return
	endIf
	
	DTActor.npcs_blindSlut[Slot] = 2
	acActor = akTarget
	EffectIsRunning = true

	;Prepare Actors!
	foundActors = new Actor[8]

	;Get init list of actors

	Actor[] actors
	actors = DTTools.getActors(acActor,500)

	debug.trace("founded actors:" + actors)

	;fuzzy sort by distance
	int limit = 0

	while limit  <  10000
		limit = limit + 500
		int i = actors.length
		int actorlistIndex = 0
		while i > 0	
			i -= 1
			
			;first quick tests
			if  actors[i]!=None && actors[i].IsHostileToActor(DTActor.npcs_ref[Slot])

				;first big condition - actor must be in valid distanece
				if DTActor.npcs_ref[Slot].GetDistance(actors[i]) <= limit
				
					;add to list
					if foundActors.find(actors[i]) == -1 && actors[i].GetActorBase().getName() !=""
						foundActors[actorlistIndex] = actors[i]
						actorlistIndex = actorlistIndex + 1
						debug.trace("found actors for distance " + limit+ " " + DTActor.npcs_ref[Slot].GetDistance(foundActors[actorlistIndex]) + ": "+foundActors)
						debug.notification("I'm sure that im hear:"+actors[i].GetActorBase().getName())
					endif

				endIf

			endif
		endWhile
		actors = DTTools.getActors(acActor,10000)
	endWhile
	debug.notification("I need to focus now!")

	RegisterForSingleUpdate(1.0)

;	if DTExpert.okBlindfold(Slot) == false
;	
;		libs.equipdevice(acActor, blindfoldInventory[DTConfig.achievement_ponygirl_colorset], blindfoldScript[DTConfig.achievement_ponygirl_colorset],DTConfig.ddKeywords[16])
;		activeEffect = true
;		selectedBlindfold = blindfoldScript[DTConfig.achievement_ponygirl_colorset] as Armor
;		DTTools.log("DT2TransformToPonyME::Equip Armbinder Selected:"+selectedBlindfold,0)
;	else
;		;DTTools.log("DT2TransformToPonyME::Equip Armbinder Skipped:"+acActor.GetWornForm(DTConfig.slotMask[46]) as Armor,0)
;	endIf

EndEvent

Event OnEffectFinish(Actor acActor, Actor akCaster)

	DTActor.npcs_blindSlut[Slot] = 1
	EffectIsRunning = false
;	if acActor.GetWornForm(DTConfig.slotMask[55]) as Armor == selectedBlindfold as Armor
;		DTTools.log("DT2TransformToPonyME::Remove Armbinder (Try)")	
;		libs.RemoveDevice(acActor, blindfoldInventory[DTConfig.achievement_ponygirl_colorset], blindfoldScript[DTConfig.achievement_ponygirl_colorset], DTConfig.ddKeywords[16])
;		acActor.RemoveItem(blindfoldInventory[DTConfig.achievement_ponygirl_colorset], 1)
;		acActor.RemoveItem(blindfoldScript[DTConfig.achievement_ponygirl_colorset], 1)
;	else
;		DTTools.log("DT2TransformToPonyME::Remove Armbinder (Fail)")	
	;DTTools.log("DT2TransformToPonyME::Compared Items: "+acActor.GetWornForm(DTConfig.slotMask[46]) as Armor+" and "+selectedArmbinder as Armor)		
;	endif
	
EndEvent

Event OnUpdate()

	int actorlistIndex = foundActors.length

	while actorlistIndex > 0
		actorlistIndex -= 1
		
		if foundActors[actorlistIndex] == None 
			Actor[] actors	
			actors = DTTools.getActors(acActor,10000)
			int i = actors.length
			while i > 0
				i -= 1
				if actors[i]!=None && actors[i].IsHostileToActor(DTActor.npcs_ref[Slot]); && actors[i].GetActorBase().getName() !=""
					if foundActors.find(actors[i]) == -1
						foundActors[actorlistIndex] = actors[i]
						debug.trace("found actors for update"  + foundActors[actorlistIndex] +" "+ DTActor.npcs_ref[Slot].GetDistance(foundActors[actorlistIndex]) + ": "+foundActors)
						debug.notification("Im sure that im hear:"+actors[i].GetActorBase().getName())
						i = -1	;papyrus break xD lol
					endif
				endif
			endWhile
		else
			float distance = DTActor.npcs_ref[Slot].GetDistance(foundActors[actorlistIndex])
			if distance <= 10000
				;debug.notification(foundActors[actorlistIndex].GetActorBase().getName()+" "+distance)
				debug.trace(foundActors[actorlistIndex]+" "+foundActors[actorlistIndex].GetActorBase().getName()+" "+distance)				
				int reductor = 10000
				if foundActors[actorlistIndex].HasLOS(DTActor.npcs_ref[Slot])
					reductor = 50000
				endif
				if DTActor.npcs_ref[Slot].HasLOS(foundActors[actorlistIndex])
					reductor = 100000
				endif
				
				if foundActors[actorlistIndex].GetFactionRank (DTStorage.SkeletonFaction)> - 1
					DTSound.playSound(Slot, DTStorage.DTRHeartBeatZombieMarker, (1.0 - (distance/reductor) as float))
				elseIf foundActors[actorlistIndex].GetFactionRank (DTStorage.DraugrFaction)> - 1
					DTSound.playSound(Slot, DTStorage.DTRHeartBeatZombieMarker, (1.0 - (distance/reductor) as float))
				elseIf foundActors[actorlistIndex].GetFactionRank (DTStorage.DwarvenAutomatonFaction)> - 1
					DTSound.playSound(Slot, DTStorage.DTRHeartBeatAutomatMarker, (1.0 - (distance/reductor) as float))
				elseIf foundActors[actorlistIndex].GetFactionRank (DTStorage.CreatureFaction)> - 1
					DTSound.playSound(Slot, DTStorage.DTRHeartBeatCreatureMarker, (1.0 - (distance/reductor) as float))
				else
					DTSound.playSound(Slot, DTStorage.DTRHeartBeatHumanMarker, (1.0 - (distance/reductor) as float))
				endif
				
				
			else
				foundActors[actorlistIndex] = None
			endif
		endif
	endWhile
	

	
	if EffectIsRunning == true
		RegisterForSingleUpdate(2)
	endIf
EndEvent