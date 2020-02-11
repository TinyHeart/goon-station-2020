var/list/animal_spell_critter_paths = list(/mob/living/critter/small_animal/mouse,
/mob/living/critter/small_animal/cat,
/mob/living/critter/small_animal/dog,
/mob/living/critter/small_animal/dog/corgi,
/mob/living/critter/small_animal/dog/shiba,
/mob/living/critter/small_animal/bird/random,
/mob/living/critter/small_animal/bird/owl,
/mob/living/critter/small_animal/bird/turkey,
/mob/living/critter/small_animal/bird/timberdoodle,
/mob/living/critter/small_animal/bird/seagull,
/mob/living/critter/small_animal/bird/crow,
/mob/living/critter/small_animal/bird/goose,
/mob/living/critter/small_animal/bird/goose/swan,
/mob/living/critter/small_animal/cockroach,
/mob/living/critter/small_animal/cockroach/robo,
/mob/living/critter/small_animal/opossum,
/mob/living/critter/small_animal/floateye,
/mob/living/critter/small_animal/pig,
/mob/living/critter/spider/clown,
/mob/living/critter/small_animal/bat,
/mob/living/critter/small_animal/bat/angry,
/mob/living/critter/spider/nice,
/mob/living/critter/spider/baby,
/mob/living/critter/spider/ice/baby,
/mob/living/critter/small_animal/wasp,
/mob/living/critter/small_animal/raccoon,
/mob/living/critter/small_animal/slug,
/mob/living/critter/small_animal/slug/snail,
/mob/living/critter/small_animal/bee,
/mob/living/critter/small_animal/butterfly)

/datum/targetable/spell/animal
	name = "Baleful Polymorph" // todo: a decent name - done?
	desc = "Turns the target into an animal of some sort."
	icon_state = "animal"
	targeted = 1
	max_range = 1
	cooldown = 1350
	requires_robes = 1
	offensive = 1
	sticky = 1

	cast(mob/target)
		if (!holder)
			return
		var/mob/living/carbon/human/H = target
		if (!istype(H))
			boutput(holder.owner, "Your target must be human!")
			return 1
		holder.owner.visible_message("<span style=\"color:red\"><b>[holder.owner] begins to cast a spell on [target]!</b></span>")
		if (do_mob(holder.owner, target, 20))
			holder.owner.say("YORAF UHRY") // AN EMAL? PAL EMORF? TURAN SPHORM?

			var/mob/living/carbon/human/O = holder.owner
			if(O && istype(O.wear_suit, /obj/item/clothing/suit/wizrobe/necro) && istype(O.head, /obj/item/clothing/head/wizard/necro))
				playsound(holder.owner.loc, "sound/voice/wizard/FurryGrim.ogg", 50, 0, -1)
			else if(holder.owner.gender == "female")
				playsound(holder.owner.loc, "sound/voice/wizard/FurryFem.ogg", 50, 0, -1)
			else
				playsound(holder.owner.loc, "sound/voice/wizard/FurryLoud.ogg", 50, 0, -1)

			var/datum/effects/system/harmless_smoke_spread/smoke = new /datum/effects/system/harmless_smoke_spread()
			smoke.set_up(5, 0, H.loc)
			smoke.attach(H)
			smoke.start()

			if (H.traitHolder.hasTrait("training_chaplain"))
				boutput(holder.owner, "<span style='color:red'>[H] has divine protection from magic.</span>")
				H.visible_message("<span style='color:red'>The spell has no effect on [H]!</span>")
				return

			if (iswizard(H))
				H.visible_message("<span style='color:red'>The spell has no effect on [H]!</span>")
				return

			if (check_target_immunity( H ))
				H.visible_message("<span style='color:red'>[H] seems to be warded from the effects!</span>")
				return 1

			if (H.mind && (H.mind.assigned_role != "Animal") || (!H.mind || !H.client))
				boutput(H, "<span style='color:red'><B>You feel your flesh painfully ripped apart and reformed into something else!</B></span>")
				if (H.mind)
					H.mind.assigned_role = "Animal"
				H.emote("scream", 0)

				H.unequip_all()
				var/mob/living/critter/C = H.make_critter(pick(animal_spell_critter_paths))
				if (istype(C, /mob/living/critter/small_animal/bee))
					var/mob/living/critter/small_animal/bee/B = C
					B.non_admin_bee_allowed = 1
				if (istype(C))
					C.change_misstep_chance(30)
					C.stuttering = 40
					SHOW_POLYMORPH_TIPS(C)
		else
			return 1