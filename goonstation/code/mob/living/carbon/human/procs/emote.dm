// emote



/mob/living/carbon/human/emote(var/act, var/voluntary = 0)
	var/param = null

	for (var/uid in src.pathogens)
		var/datum/pathogen/P = src.pathogens[uid]
		if (P.onemote(act))
			return

	if (!bioHolder) bioHolder = new/datum/bioHolder( src )

	if (src.bioHolder.HasEffect("revenant"))
		src.visible_message("<span style=\"color:red\">[src] makes [pick("a rude", "an eldritch", "a", "an eerie", "an otherworldly", "a netherly", "a spooky")] gesture!</span>", group = "revenant_emote")
		return

	if (findtext(act, " ", 1, null))
		var/t1 = findtext(act, " ", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	var/muzzled = istype(src.wear_mask, /obj/item/clothing/mask/muzzle)
	var/m_type = 1 //1 is visible, 2 is audible
	var/custom = 0 //Sorry, gotta make this for chat groupings.

	for (var/obj/item/implant/I in src)
		if (I.implanted)
			I.trigger(act, src)

	var/message = null
	if (src.mutantrace)
		message = src.mutantrace.emote(act)
	if (!message)
		switch (lowertext(act))
			if ("custom")
				if (src.client)
					if (IS_TWITCH_CONTROLLED(src)) return
					var/input = sanitize(html_encode(input("Choose an emote to display.")))
					var/input2 = input("Is this a visible or audible emote?") in list("Visible","Audible")
					if (input2 == "Visible") m_type = 1
					else if (input2 == "Audible") m_type = 2
					else
						alert("Unable to use this emote, must be either audible or visible.")
						return
					message = "<B>[src]</B> [input]"

			if ("customv")
				if (IS_TWITCH_CONTROLLED(src)) return
				if (!param)
					param = input("Choose an emote to display.")
					if(!param) return

				param = sanitize(html_encode(param))
				message = "<b>[src]</b> [param]"
				m_type = 1
				custom = copytext(param, 1, 10)

			if ("customh")
				if (IS_TWITCH_CONTROLLED(src)) return
				if (!param)
					param = input("Choose an emote to display.")
					if(!param) return
				param = sanitize(html_encode(param))
				message = "<b>[src]</b> [param]"
				m_type = 2
				custom = copytext(param, 1, 10)

			if ("me")
				if (IS_TWITCH_CONTROLLED(src)) return
				if (!param)
					return
				param = sanitize(html_encode(param))
				message = "<b>[src]</b> [param]"
				m_type = 1 // default to visible
				custom = copytext(param, 1, 10)

			if ("give")
				if (!src.restrained())
					if (!src.emote_check(voluntary, 50))
						return
					var/obj/item/thing = src.equipped()
					if (!thing)
						if (src.l_hand)
							thing = src.l_hand
						else if (src.r_hand)
							thing = src.r_hand

					if (thing)
						var/mob/living/carbon/human/H = null
						if (param)
							for (var/mob/living/carbon/human/M in view(1, src))
								if (ckey(param) == ckey(M.name))
									H = M
									break
						else
							var/list/possible_recipients = list()
							for (var/mob/living/carbon/human/M in view(1, src))
								if (M != src)
									possible_recipients += M
							if (possible_recipients.len > 1)
								H = input(src, "Who would you like to hand your [thing] to?", "Choice") as null|anything in possible_recipients
							else if (possible_recipients.len == 1)
								H = possible_recipients[1]

#ifdef TWITCH_BOT_ALLOWED
						if (IS_TWITCH_CONTROLLED(H))
							return
#endif
						src.give_to(H)
						return
				m_type = 1

			if ("help")
				src.show_text("To use emotes, simply enter 'me (emote)' in the input bar. Certain emotes can be targeted at other characters - to do this, enter 'me (emote) (name of character)' without the brackets.")
				src.show_text("For a list of all emotes, use 'me list'. For a list of basic emotes, use 'me listbasic'. For a list of emotes that can be targeted, use 'me listtarget'.")

			if ("listbasic")
				src.show_text("smile, grin, smirk, frown, scowl, grimace, sulk, pout, blink, drool, shrug, tremble, quiver, shiver, shudder, shake, \
				think, ponder, clap, flap, aflap, laugh, chuckle, giggle, chortle, guffaw, cough, hiccup, sigh, mumble, grumble, groan, moan, sneeze, \
				sniff, snore, whimper, yawn, choke, gasp, weep, sob, wail, whine, gurgle, gargle, blush, flinch, blink_r, eyebrow, shakehead, shakebutt, \
				pale, flipout, rage, shame, raisehand, crackknuckles, stretch, rude, cry, retch, raspberry, tantrum, gesticulate, wgesticulate, smug, \
				nosepick, flex, facepalm, panic, snap, airquote, twitch, twitch_v, faint, deathgasp, signal, wink, collapse, trip, dance, scream, \
				burp, fart, monologue, contemplate, custom")

			if ("listtarget")
				src.show_text("salute, bow, hug, wave, glare, stare, look, leer, nod, tweak, flipoff, doubleflip, shakefist, handshake, daps, slap, boggle, highfive")

			if ("suicide")
				src.show_text("Suicide is a command, not an emote.  Please type 'suicide' in the input bar at the bottom of the game window to kill yourself.", "red")

	//april fools start

			if ("inhale")
				if (!manualbreathing)
					src.show_text("You are already breathing!")
					return
				if (src.breathstate)
					src.show_text("You just breathed in, try breathing out next dummy!")
					return
				src.show_text("You breathe in.")
				src.breathtimer = 0
				src.breathstate = 1

			if ("exhale")
				if (!manualbreathing)
					src.show_text("You are already breathing!")
					return
				if (!src.breathstate)
					src.show_text("You just breathed out, try breathing in next silly!")
					return
				src.show_text("You breathe out.")
				src.breathstate = 0

			if ("closeeyes")
				if (!manualblinking)
					src.show_text("Why would you want to do that?")
					return
				if (src.blinkstate)
					src.show_text("You just closed your eyes, try opening them now dumbo!")
					return
				src.show_text("You close your eyes.")
				src.blinkstate = 1
				src.blinktimer = 0

			if ("openeyes")
				if (!manualblinking)
					src.show_text("Your eyes are already open!")
					return
				if (!src.blinkstate)
					src.show_text("Your eyes are already open, try closing them next moron!")
					return
				src.show_text("You open your eyes.")
				src.blinkstate = 0

	//april fools end

			if ("birdwell")
				if ((src.client && src.client.holder) && src.emote_check(voluntary, 50))
					message = "<B>[src]</B> birdwells."
					playsound(src.loc, 'sound/vox/birdwell.ogg', 50, 1)
				else
					src.show_text("Unusable emote '[act]'. 'Me help' for a list.", "blue")
					return

			if ("uguu")
				if (istype(src.wear_mask, /obj/item/clothing/mask/anime) && !src.stat)

					message = "<B>[src]</B> uguus!"
					m_type = 2
					if (narrator_mode)
						playsound(get_turf(src), 'sound/vox/uguu.ogg', 80, 0, 0, src.get_age_pitch())
					else
						playsound(get_turf(src), 'sound/voice/uguu.ogg', 80, 0, 0, src.get_age_pitch())
					SPAWN_DBG(10)
						src.gib()
						new /obj/item/clothing/mask/anime(src.loc)
						return
				else
					src.show_text("You just don't feel kawaii enough to uguu right now!", "red")
					return

			if ("twirl", "spin", "juggle")
				if (!src.restrained())
					if (src.emote_check(voluntary, 25))
						m_type = 1

						// clown juggling
						if ((src.mind && src.mind.assigned_role == "Clown") || src.can_juggle)
							var/obj/item/thing = src.equipped()
							if (!thing)
								if (src.l_hand)
									thing = src.l_hand
								else if (src.r_hand)
									thing = src.r_hand
							if (thing)
								if (src.juggling())
									if (prob(src.juggling.len * 5)) // might drop stuff while already juggling things
										src.drop_juggle()
									else
										src.add_juggle(thing)
								else
									src.add_juggle(thing)
							else
								message = "<B>[src]</B> wiggles \his fingers a bit.[prob(10) ? " Weird." : null]"

						// everyone else
						else
							var/obj/item/thing = src.equipped()
							if (!thing)
								if (src.l_hand)
									thing = src.l_hand
								else if (src.r_hand)
									thing = src.r_hand
							if (thing)
								if ((src.bioHolder && src.bioHolder.HasEffect("clumsy") && prob(50)) || (src.reagents && prob(src.reagents.get_reagent_amount("ethanol") / 2)) || prob(5))
									message = "<B>[src]</B> [pick("spins", "twirls")] [thing] around in [his_or_her(src)] hand, and drops it right on the ground.[prob(10) ? " What an oaf." : null]"
									src.u_equip(thing)
									thing.set_loc(src.loc)
								else
									message = "<B>[src]</B> [pick("spins", "twirls")] [thing] around in [his_or_her(src)] hand."
									thing.on_spin_emote(src)
								animate(thing, transform = turn(matrix(), 120), time = 0.7, loop = 3)
								animate(transform = turn(matrix(), 240), time = 0.7)
								animate(transform = null, time = 0.7)
							else
								message = "<B>[src]</B> wiggles [his_or_her(src)] fingers a bit.[prob(10) ? " Weird." : null]"
				else
					message = "<B>[src]</B> struggles to move."

			if ("tip")
				if (!src.restrained() && !src.stat)
					if (istype(src.head, /obj/item/clothing/head/fedora))
						var/obj/item/clothing/head/fedora/hat = src.head
						message = "<B>[src]</B> tips \his [hat] and [pick("winks", "smiles", "grins", "smirks")].<br><B>[src]</B> [pick("says", "states", "articulates", "implies", "proclaims", "proclamates", "promulgates", "exclaims", "exclamates", "extols", "predicates")], &quot;M'lady.&quot;"
						SPAWN_DBG(10)
							hat.set_loc(src.loc)
							src.head = null
							src.gib()
							src.mind.karma -= 10
					else if (istype(src.head, /obj/item/clothing/head) && !istype(src.head, /obj/item/clothing/head/fedora))
						src.show_text("This hat just isn't [pick("fancy", "suave", "manly", "sexerific", "majestic", "euphoric")] enough for that!", "red")
						return
					else
						src.show_text("You can't tip a hat you don't have!", "red")
						return

			if ("hatstomp", "stomphat")
				if (!src.restrained())
					var/obj/item/clothing/head/helmet/HoS/hat = src.find_type_in_hand(/obj/item/clothing/head/helmet/HoS)
					var/hat_or_beret = null
					var/already_stomped = null // store the picked phrase in here
					var/on_head = 0

					if (!hat) // if the find_type_in_hand() returned 0 earlier
						if (istype(src.head, /obj/item/clothing/head/helmet/HoS)) // maybe it's on our head?
							hat = src.head
							on_head = 1
						else // if not then never mind
							return
					if (hat.icon_state == "hosberet" || hat.icon_state == "hosberet-smash") // does it have one of the beret icons?
						hat_or_beret = "beret" // call it a beret
					else // otherwise?
						hat_or_beret = "hat" // call it a hat. this should cover cases where the hat somehow doesn't have either hosberet or hoscap
					if (hat.icon_state == "hosberet-smash" || hat.icon_state == "hoscap-smash") // has it been smashed already?
						already_stomped = pick(" That [hat_or_beret] has seen better days.", " That [hat_or_beret] is looking pretty shabby.", " How much more abuse can that [hat_or_beret] take?", " It looks kinda ripped up now.") // then add some extra flavor text

					// the actual messages are generated here
					if (on_head)
						message = "<B>[src]</B> yanks \his [hat_or_beret] off \his head, throws it on the floor and stomps on it![already_stomped]\
						<br><B>[src]</B> grumbles, \"<i>rasmn frasmn grmmn[prob(1) ? " dick dastardly" : null]</i>.\""
					else
						message = "<B>[src]</B> throws \his [hat_or_beret] on the floor and stomps on it![already_stomped]\
						<br><B>[src]</B> grumbles, \"<i>rasmn frasmn grmmn</i>.\""

					if (hat_or_beret == "beret")
						hat.icon_state = "hosberet-smash" // make sure it looks smushed!
					else
						hat.icon_state = "hoscap-smash"
					src.drop_from_slot(hat) // we're done here, drop that hat!
					if(src.mind && src.mind.assigned_role != "Head of Security")
						src.mind.karma += 5
				else
					message = "<B>[src]</B> tries to move \his arm and grumbles."
				m_type = 1

			if ("bubble")
				var/obj/item/clothing/mask/bubblegum/gum = src.wear_mask
				if (!istype(gum))
					return
				if (!muzzled)
					if (src.emote_check(voluntary, 25))
						message = "<B>[src]</B> blows a bubble."
						//todo: sound
						//todo: gum icon animation?
						if (gum.reagents && gum.reagents.total_volume)
							gum.reagents.reaction(get_turf(src), TOUCH, gum.chew_size)
				else
					message = "<B>[src]</B> tries to make a noise."
				m_type = 2

			if ("handpuppet")
				message = "<b>[src]</b> throws their voice, badly, as they flap their thumb and index finger like some sort of lips.[prob(50) ? "  Perhaps they're off their meds?" : null]"
				m_type = 1

			if ("smile","grin","smirk","frown","scowl","grimace","sulk","pout","blink","drool","shrug","tremble","quiver","shiver","shudder","shake","think","ponder","contemplate","grump")
				// basic visible single-word emotes
				message = "<B>[src]</B> [act]s."
				m_type = 1

			if (":)")
				message = "<B>[src]</B> smiles."
				m_type = 1

			if (":(")
				message = "<B>[src]</B> frowns."
				m_type = 1

			if (":d", ">:)") // the switch is lowertext()ed so this is what :D would be
				message = "<B>[src]</B> grins."
				m_type = 1

			if ("d:", "dx") // same as above for D: and DX
				message = "<B>[src]</B> grimaces."
				m_type = 1

			if (">:(")
				message = "<B>[src]</B> scowls."
				m_type = 1

			if (":j")
				message = "<B>[src]</B> smirks."
				m_type = 1

			if (":i")
				message = "<B>[src]</B> grumps."
				m_type = 1

			if (":|")
				message = "<B>[src]</B> stares."
				m_type = 1

			if ("xd")
				message = "<B>[src]</B> laughs."
				m_type = 1

			if (":c")
				message = "<B>[src]</B> pouts."
				m_type = 1

			if ("clap")
				// basic visible single-word emotes - unusable while restrained
				if (!src.restrained())
					message = "<B>[src]</B> [lowertext(act)]s."
				else
					message = "<B>[src]</B> struggles to move."
				m_type = 1

			if ("cough","hiccup","sigh","mumble","grumble","groan","moan","sneeze","sniff","snore","whimper","yawn","choke","gasp","weep","sob","wail","whine","gurgle","gargle")
				// basic audible single-word emotes
				if (!muzzled)
					if (lowertext(act) == "sigh" && prob(1)) act = "singh" //1% chance to change sigh to singh. a bad joke for drsingh fans.
					message = "<B>[src]</B> [act]s."
				else
					message = "<B>[src]</B> tries to make a noise."
				m_type = 2

				if (src.emote_check(voluntary,20))
					if (act == "gasp")
						if (src.health <= 0)
							var/dying_gasp_sfx = "sound/voice/gasps/[src.gender]_gasp_[pick(1,5)].ogg"
							playsound(get_turf(src), dying_gasp_sfx, 100, 0, 0, src.get_age_pitch())
						else
							playsound(get_turf(src), src.sound_gasp, 15, 0, 0, src.get_age_pitch())

			if ("laugh","chuckle","giggle","chortle","guffaw","cackle")
				if (!muzzled)
					message = "<B>[src]</B> [act]s."
					if (src.sound_list_laugh && src.sound_list_laugh.len)
						playsound(src.loc, pick(src.sound_list_laugh), 80, 0, 0, src.get_age_pitch())
				else
					message = "<B>[src]</B> tries to make a noise."
				m_type = 2


			if ("salute","bow","hug","wave", "blowkiss")
				// visible targeted emotes
				if (!src.restrained())
					var/M = null
					if (param)
						for (var/mob/A in view(null, null))
							if (ckey(param) == ckey(A.name))
								M = A
								break
					if (!M)
						param = null

					act = lowertext(act)
					if (param)
						switch(act)
							if ("bow","wave")
								message = "<B>[src]</B> [act]s to [param]."
							if ("blowkiss")
								message = "<B>[src]</B> blows a kiss to [param]."
								//var/atom/U = get_turf(param)
								//shoot_projectile_ST(src, new/datum/projectile/special/kiss(), U) //I gave this all of 5 minutes of my time I give up
							else
								message = "<B>[src]</B> [act]s [param]."
					else
						switch(act)
							if ("hug")
								message = "<B>[src]</b> [act]s \himself."
							if ("blowkiss")
								message = "<B>[src]</b> blows a kiss to...themselves?"
							else
								message = "<B>[src]</b> [act]s."
								src.mind.karma += 2

				else
					message = "<B>[src]</B> struggles to move."

				m_type = 1

			if ("nod","glare","stare","look","leer")
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (ckey(param) == ckey(A.name))
							M = A
							break
				if (!M)
					param = null

				act = lowertext(act)
				if (param)
					switch(act)
						if ("nod")
							message = "<B>[src]</B> [act]s to [param]."
						if ("glare","stare","look","leer")
							message = "<B>[src]</B> [act]s at [param]."
				else
					message = "<B>[src]</b> [act]s."

				m_type = 1

			// basic emotes that change the wording a bit

			if ("blush")
				message = "<B>[src]</B> blushes."
				m_type = 1

			if ("flinch")
				message = "<B>[src]</B> flinches."
				m_type = 1

			if ("blink_r")
				message = "<B>[src]</B> blinks rapidly."
				m_type = 1

			if ("eyebrow","raiseeyebrow")
				message = "<B>[src]</B> raises an eyebrow."
				m_type = 1

			if ("shakehead","smh")
				message = "<B>[src]</B> shakes \his head."
				m_type = 1

			if ("shakebutt","shakebooty","shakeass","twerk")
				message = "<B>[src]</B> shakes \his ass!"
				m_type = 1
				src.mind.karma -= 3

				SPAWN_DBG (5)
					var/beeMax = 15
					for (var/obj/critter/domestic_bee/responseBee in range(5, src))
						if (!responseBee.alive)
							continue

						if (beeMax-- < 0)
							break

						if (prob(75))
							responseBee.visible_message("<b>[responseBee]</b> buzzes [pick("in a confused manner", "perplexedly", "in a perplexed manner")].", group = "responseBee")
						else
							responseBee.visible_message("<b>[responseBee]</b> can't understand [src]'s accent!")

			if ("pale")
				message = "<B>[src]</B> goes pale for a second."
				m_type = 1

			if ("flipout")
				message = "<B>[src]</B> flips the fuck out!"
				m_type = 1

			if ("rage","fury","angry")
				message = "<B>[src]</B> becomes utterly furious!"
				m_type = 1

			if ("shame","hanghead")
				message = "<B>[src]</B> hangs \his head in shame."
				m_type = 1

			// basic emotes with alternates for restraints

			if ("flap")
				if (!src.restrained())
					message = "<B>[src]</B> flaps \his arms!"
					if (src.sound_list_flap && src.sound_list_flap.len)
						playsound(src.loc, pick(src.sound_list_flap), 80, 0, 0, src.get_age_pitch())
				else
					message = "<B>[src]</B> writhes!"
				m_type = 1

			if ("aflap")
				if (!src.restrained())
					message = "<B>[src]</B> flaps \his arms ANGRILY!"
					if (src.sound_list_flap && src.sound_list_flap.len)
						playsound(src.loc, pick(src.sound_list_flap), 80, 0, 0, src.get_age_pitch())
				else
					message = "<B>[src]</B> writhes angrily!"
				m_type = 1

			if ("raisehand")
				if (!src.restrained()) message = "<B>[src]</B> raises a hand."
				else message = "<B>[src]</B> tries to move \his arm."
				m_type = 1

			if ("crackknuckles","knuckles")
				if (!src.restrained()) message = "<B>[src]</B> cracks \his knuckles."
				else message = "<B>[src]</B> irritably shuffles around."
				m_type = 1

			if ("stretch")
				if (!src.restrained()) message = "<B>[src]</B> stretches."
				else message = "<B>[src]</B> writhes around slowly."
				m_type = 1

			if ("rude")
				if (!src.restrained()) message = "<B>[src]</B> makes a rude gesture."
				else message = "<B>[src]</B> tries to move \his arm."
				m_type = 1

			if ("cry")
				if (!muzzled) message = "<B>[src]</B> cries."
				else message = "<B>[src]</B> makes an odd noise. A tear runs down \his face."
				m_type = 2

			if ("retch","gag")
				if (!muzzled) message = "<B>[src]</B> retches in disgust!"
				else message = "<B>[src]</B> makes a strange choking sound."
				m_type = 2

			if ("raspberry")
				if (!muzzled) message = "<B>[src]</B> blows a raspberry."
				else message = "<B>[src]</B> slobbers all over \himself."
				m_type = 2

			if ("tantrum")
				if (!src.restrained()) message = "<B>[src]</B> throws a tantrum!"
				else message = "<B>[src]</B> starts wriggling around furiously!"
				m_type = 1

			if ("gesticulate")
				if (!src.restrained()) message = "<B>[src]</B> gesticulates."
				else message = "<B>[src]</B> wriggles around a lot."
				m_type = 1

			if ("wgesticulate")
				if (!src.restrained()) message = "<B>[src]</B> gesticulates wildly."
				else message = "<B>[src]</B> enthusiastically wriggles around a lot!"
				m_type = 1

			if ("smug")
				if (!src.restrained()) message = "<B>[src]</B> folds \his arms and smirks broadly, making a self-satisfied \"heh\"."
				else message = "<B>[src]</B> shuffles a bit and smirks broadly, emitting a rather self-satisfied noise."
				m_type = 1
				if (src.mind)
					src.mind.karma -= 2

			if ("nosepick","picknose")
				if (!src.restrained()) message = "<B>[src]</B> picks \his nose."
				else message = "<B>[src]</B> sniffs and scrunches \his face up irritably."
				m_type = 1
				if (src.mind)
					src.mind.karma -= 1

			if ("flex","flexmuscles")
				if (!src.restrained())
					var/roboarms = src.limbs && istype(src.limbs.r_arm, /obj/item/parts/robot_parts) && istype(src.limbs.l_arm, /obj/item/parts/robot_parts)
					if (roboarms) message = "<B>[src]</B> flexes \his powerful robotic muscles."
					else message = "<B>[src]</B> flexes \his muscles."
				else message = "<B>[src]</B> tries to stretch \his arms."
				m_type = 1

			if ("facepalm")
				if (!src.restrained()) message = "<B>[src]</B> places \his hand on \his face in exasperation."
				else message = "<B>[src]</B> looks rather exasperated."
				m_type = 1

			if ("panic","freakout")
				if (!src.restrained()) message = "<B>[src]</B> enters a state of hysterical panic!"
				else message = "<B>[src]</B> starts writhing around in manic terror!"
				m_type = 1

			// targeted emotes

			if ("tweak","tweaknipples","tweaknips","nippletweak")
				if (!src.restrained())
					var/M = null
					if (param)
						for (var/mob/A in view(1, src))
							if (ckey(param) == ckey(A.name))
								M = A
								break
					if (!M)
						param = null

					if (param)
						message = "<B>[src]</B> tweaks [param]'s nipples."
					else
						message = "<B>[src]</b> tweaks \his nipples."
				m_type = 1

			if ("flipoff","flipbird","middlefinger")
				m_type = 1
				if (!src.restrained())
					var/M = null
					if (param)
						for (var/mob/A in view(null, null))
							if (ckey(param) == ckey(A.name))
								M = A
								break
					if (M) message = "<B>[src]</B> flips off [M]."
					else message = "<B>[src]</B> raises \his middle finger."
				else message = "<B>[src]</B> scowls and tries to move \his arm."

			if ("doubleflip","doubledeuce","doublebird","flip2")
				m_type = 1
				if (!src.restrained())
					var/M = null
					if (param)
						for (var/mob/A in view(null, null))
							if (ckey(param) == ckey(A.name))
								M = A
								break
					if (M) message = "<B>[src]</B> gives [M] the double deuce!"
					else message = "<B>[src]</B> raises both of \his middle fingers."
				else message = "<B>[src]</B> scowls and tries to move \his arms."

			if ("boggle")
				m_type = 1
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (ckey(param) == ckey(A.name))
							M = A
							break
				if (M) message = "<B>[src]</B> boggles at [M]'s stupidity."
				else message = "<B>[src]</B> boggles at the stupidity of it all."

			if ("shakefist")
				m_type = 1
				if (!src.restrained())
					var/M = null
					if (param)
						for (var/mob/A in view(null, null))
							if (ckey(param) == ckey(A.name))
								M = A
								break
					if (M) message = "<B>[src]</B> angrily shakes \his fist at [M]!"
					else message = "<B>[src]</B> angrily shakes \his fist!"
				else message = "<B>[src]</B> tries to move \his arm angrily!"

			if ("handshake","shakehand","shakehands")
				m_type = 1
				if (!src.restrained() && !src.r_hand)
					var/mob/M = null
					if (param)
						for (var/mob/A in view(1, null))
							if (ckey(param) == ckey(A.name))
								M = A
								break
					if (M == src) M = null

					if (M)
						if (M.canmove && !M.r_hand && !M.restrained()) message = "<B>[src]</B> shakes hands with [M]."
						else message = "<B>[src]</B> holds out \his hand to [M]."

			if ("daps","dap")
				m_type = 1
				if (!src.restrained())
					var/M = null
					if (param)
						for (var/mob/A in view(1, null))
							if (ckey(param) == ckey(A.name))
								M = A
								break
					if (M) message = "<B>[src]</B> gives daps to [M]."
					else message = "<B>[src]</B> sadly can't find anybody to give daps to, and daps \himself. Shameful."
				else message = "<B>[src]</B> wriggles around a bit."

			if ("slap","bitchslap","smack")
				m_type = 1
				if (!src.restrained())
					if (src.emote_check(voluntary))
						if (src.bioHolder.HasEffect("chime_snaps"))
							src.sound_snap = 'sound/impact_sounds/Glass_Shards_Hit_1.ogg'
						var/M = null
						if (param)
							for (var/mob/A in view(1, null))
								if (ckey(param) == ckey(A.name))
									M = A
									break
						if (M) message = "<B>[src]</B> slaps [M] across the face! Ouch!"
						else
							message = "<B>[src]</B> slaps \himself!"
							src.TakeDamage("head", 0, 4, 0, DAMAGE_BURN)
						playsound(src.loc, src.sound_snap, 100, 1)
				else message = "<B>[src]</B> lurches forward strangely and aggressively!"

			if ("highfive")
				m_type = 1
				if (!src.restrained() && src.stat != 1 && !isunconscious(src) && !isdead(src))
					if (src.emote_check(voluntary))
						var/mob/M = null
						if (param)
							for (var/mob/A in view(1, null))
								if (ckey(param) == ckey(A.name))
									M = A
									break
						if (M)
#ifdef TWITCH_BOT_ALLOWED
							if (IS_TWITCH_CONTROLLED(M))
								return
#endif
							if (!M.restrained() && M.stat != 1 && !isunconscious(M) && !isdead(M))
								if (alert(M, "[src] offers you a high five! Do you accept it?", "Choice", "Yes", "No") == "Yes")
									if (M in view(1,null))
										message = "<B>[src]</B> and [M] highfive!"
										playsound(src.loc, src.sound_snap, 100, 1)
								else
									message = "<B>[src]</B> offers [M] a highfive, but [M] leaves \him hanging!"
									if (M.mind)
										M.mind.karma -= 5
							else
								message = "<B>[src]</B> highfives [M]!"
								playsound(src.loc, src.sound_snap, 100, 1)
						else
							message = "<B>[src]</B> randomly raises \his hand!"
			// emotes that do STUFF! or are complex in some way i guess

			if ("snap","snapfingers","fingersnap","click","clickfingers")
				if (!src.restrained())
					if (src.emote_check(voluntary))
						if (src.bioHolder.HasEffect("chime_snaps"))
							src.sound_fingersnap = 'sound/musical_instruments/WeirdChime_5.ogg'
							src.sound_snap = 'sound/impact_sounds/Glass_Shards_Hit_1.ogg'
						if (prob(5))
							message = "<font color=red><B>[src]</B> snaps \his fingers RIGHT OFF!</font>"
							/*
							if (src.bioHolder)
								src.bioHolder.AddEffect("[src.hand ? "left" : "right"]_arm")
							else
							*/
							random_brute_damage(src, 20)
							if (narrator_mode)
								playsound(src.loc, 'sound/vox/break.ogg', 100, 1)
							else
								playsound(src.loc, src.sound_snap, 100, 1)
						else
							message = "<B>[src]</B> snaps \his fingers."
							if (narrator_mode)
								playsound(src.loc, 'sound/vox/deeoo.ogg', 50, 1)
							else
								playsound(src.loc, src.sound_fingersnap, 50, 1)

			if ("airquote","airquotes")
				if (param)
					param = strip_html(param, 200)
					message = "<B>[src]</B> sneers, \"Ah yes, \"[param]\". We have dismissed that claim.\""
					m_type = 2
				else
					message = "<B>[src]</B> makes air quotes with \his fingers."
					m_type = 1

			if ("twitch")
				message = "<B>[src]</B> twitches."
				m_type = 1
				SPAWN_DBG(0)
					var/old_x = src.pixel_x
					var/old_y = src.pixel_y
					src.pixel_x += rand(-2,2)
					src.pixel_y += rand(-1,1)
					sleep(2)
					src.pixel_x = old_x
					src.pixel_y = old_y

			if ("twitch_v","twitch_s")
				message = "<B>[src]</B> twitches violently."
				m_type = 1
				SPAWN_DBG(0)
					var/old_x = src.pixel_x
					var/old_y = src.pixel_y
					src.pixel_x += rand(-3,3)
					src.pixel_y += rand(-1,1)
					sleep(2)
					src.pixel_x = old_x
					src.pixel_y = old_y

			if ("faint")
				message = "<B>[src]</B> faints."
				src.sleeping = 1
				m_type = 1

			if ("deathgasp")
				if (!voluntary || src.emote_check(voluntary,50))
					if (prob(15) && !src.is_changeling() && !isdead(src)) message = "<span style=\"color:black\"><B>[src]</B> seizes up and falls limp, peeking out of one eye sneakily.</span>"
					else
						message = "<span style=\"color:black\"><B>[src]</B> seizes up and falls limp, \his eyes dead and lifeless...</span>"
						playsound(get_turf(src), "sound/voice/death_[pick(1,2)].ogg", 40, 0, 0, src.get_age_pitch())
					m_type = 1

			if ("johnny")
				if (src.emote_check(voluntary,60))
					var/M
					if (param) M = adminscrub(param)
					if (!M) param = null
					else
						message = "<B>[src]</B> says, \"[M], please. He had a family.\" [src.name] takes a drag from a cigarette and blows \his name out in smoke."
						particleMaster.SpawnSystem(new /datum/particleSystem/blow_cig_smoke(src.loc, src.dir))
						m_type = 2

			if ("point")
				if (!src.restrained())
					var/mob/M = null
					if (param)
						for (var/atom/A as mob|obj|turf|area in view(null, null))
							if (ckey(param) == ckey(A.name))
								M = A
								break

					if (!M)
						message = "<B>[src]</B> points."
					else
						src.point(M)

					if (M)
						message = "<B>[src]</B> points to [M]."
					else
				m_type = 1

			if ("signal")
				if (!src.restrained())
					var/t1 = min( max( round(text2num(param)), 1), 10)
					if (isnum(t1))
						if (t1 <= 5 && (!src.r_hand || !src.l_hand))
							message = "<B>[src]</B> raises [t1] finger\s."
						else if (t1 <= 10 && (!src.r_hand && !src.l_hand))
							message = "<B>[src]</B> raises [t1] finger\s."
				m_type = 1

			if ("wink")
				for (var/obj/item/clothing/C in src.get_equipped_items())
					if ((locate(/obj/item/gun/kinetic/derringer) in C) != null)
						var/obj/item/gun/kinetic/derringer/D = (locate(/obj/item/gun/kinetic/derringer) in C)
						var/drophand = (src.hand == 0 ? slot_r_hand : slot_l_hand)
						drop_item()
						D.set_loc(src)
						equip_if_possible(D, drophand)
						src.visible_message("<span style=\"color:red\"><B>[src] pulls a derringer out of \the [C]!</B></span>")
						playsound(src.loc, "rustle", 60, 1)
						break

				message = "<B>[src]</B> winks."
				m_type = 1

			if ("collapse", "trip")
				if (!src.getStatusDuration("paralysis"))
					src.changeStatus("paralysis", 30)
				message = "<B>[src]</B> [lowertext(act)]s!"
				m_type = 2

			if ("dance", "boogie")
				if (src.emote_check(voluntary, 50))
					if (src.restrained()) // check this first for convenience
						message = "<B>[src]</B> twitches feebly in time to music only they can hear."
					else
						if (iswizard(src) && prob(10))
							message = pick("<span style=\"color:red\"><B>[src]</B> breaks out the most unreal dance move you've ever seen!</span>", "<span style=\"color:red\"><B>[src]'s</B> dance move borders on the goddamn diabolical!</span>")
							src.say("GHET DAUN!")
							animate_flash_color_fill(src,"#5C0E80", 1, 10)
							animate_levitate(src, 1, 10)
							SPAWN_DBG(0) // some movement to make it look cooler
								for (var/i = 0, i < 10, i++)
									src.dir = turn(src.dir, 90)
									sleep(2)

							var/datum/effects/system/spark_spread/s = unpool(/datum/effects/system/spark_spread)
							s.set_up(3, 1, src)
							s.start()

						else
							//glowsticks
							var/left_glowstick = istype (l_hand, /obj/item/device/glowstick)
							var/right_glowstick = istype (r_hand, /obj/item/device/glowstick)
							var/obj/item/device/glowstick/l_glowstick = null
							var/obj/item/device/glowstick/r_glowstick = null
							if (left_glowstick)
								l_glowstick = l_hand
							if (right_glowstick)
								r_glowstick = r_hand
							if ((left_glowstick && l_glowstick.on) || (right_glowstick && r_glowstick.on))
								if (left_glowstick)
									particleMaster.SpawnSystem(new /datum/particleSystem/glow_stick_dance(src.loc))
								if (right_glowstick)
									particleMaster.SpawnSystem(new /datum/particleSystem/glow_stick_dance(src.loc))
								var/dancemove = rand(1,6)
								switch(dancemove)
									if (1)
										message = "<B>[src]</B> puts on a sick-ass lightshow!"
									if (2)
										message = "<B>[src]</B> waves a glowstick around in the air!"
									if (3)
										message = "<B>[src]</B> twirls a glowstick! Cool!"
									if (4)
										message = "<B>[src]</B> spins a glowstick! Trippy!"
									if (5)
										message = "<B>[src]</B> is the life of the party!"
									else
										message = "<B>[src]</B> is raving super hard!"
								SPAWN_DBG(0)
									for (var/i = 0, i < 4, i++)
										src.dir = turn(src.dir, 90)
										sleep(2)
							//standard dancing
							else
								var/dancemove = rand(1,7)

								switch(dancemove)
									if (1)
										message = "<B>[src]</B> busts out some mad moves."
										SPAWN_DBG(0)
											for (var/i = 0, i < 4, i++)
												src.dir = turn(src.dir, 90)
												sleep(2)

									if (2)
										message = "<B>[src]</B> does the twist, like they did last summer."
										SPAWN_DBG(0)
											for (var/i = 0, i < 4, i++)
												src.dir = turn(src.dir, -90)
												sleep(2)

									if (3)
										message = "<B>[src]</B> moonwalks."
										SPAWN_DBG(0)
											for (var/i = 0, i < 4, i++)
												src.pixel_x+= 2
												sleep(2)
											for (var/i = 0, i < 4, i++)
												src.pixel_x-= 2
												sleep(2)

									if (4)
										message = "<B>[src]</B> boogies!"
										SPAWN_DBG(0)
											for (var/i = 0, i < 4, i++)
												src.pixel_x+= 2
												src.dir = turn(src.dir, 90)
												sleep(2)
											for (var/i = 0, i < 4, i++)
												src.pixel_x-= 2
												src.dir = turn(src.dir, 90)
												sleep(2)

									if (5)
										message = "<B>[src]</B> gets on down."
										SPAWN_DBG(0)
											for (var/i = 0, i < 4, i++)
												src.pixel_y-= 2
												sleep(2)
											for (var/i = 0, i < 4, i++)
												src.pixel_y+= 2
												sleep(2)

									if (6)
										message = "<B>[src]</B> dances!"
										SPAWN_DBG(0)
											for (var/i = 0, i < 4, i++)
												src.pixel_x+= 1
												src.pixel_y+= 1
												sleep(2)
											for (var/i = 0, i < 4, i++)
												src.pixel_x-= 1
												src.pixel_y-= 1
												sleep(2)

									else
										message = "<B>[src]</B> cranks out some dizzying windmills."
										SPAWN_DBG(0)
											for (var/i = 0, i < 4, i++)
												src.pixel_x+= 1
												src.pixel_y+= 1
												src.dir = turn(src.dir, -90)
												sleep(2)
											for (var/i = 0, i < 4, i++)
												src.pixel_x-= 1
												src.pixel_y-= 1
												src.dir = turn(src.dir, -90)
												sleep(2)
										// expand this too, however much

									// todo: add context-sensitive break dancing and some other goofy shit

						SPAWN_DBG(5)
							var/beeMax = 15
							for (var/obj/critter/domestic_bee/responseBee in range(7, src))
								if (!responseBee.alive)
									continue

								if (beeMax-- < 0)
									break

								responseBee.dance_response()
								src.mind.karma += 1

							var/parrotMax = 15
							for (var/obj/critter/parrot/responseParrot in range(7, src))
								if (!responseParrot.alive)
									continue
								if (parrotMax-- < 0)
									break
								responseParrot.dance_response()

						if (src.traitHolder && src.traitHolder.hasTrait("happyfeet"))
							if (prob(33))
								SPAWN_DBG(5)
									for (var/mob/living/carbon/human/responseMonkey in range(1, src)) // they don't have to be monkeys, but it's signifying monkey code
										if (responseMonkey.stat || responseMonkey.getStatusDuration("paralysis") || responseMonkey.sleeping || responseMonkey.getStatusDuration("stunned") || (responseMonkey == src))
											continue
										responseMonkey.emote("dance")

						if (src.reagents)
							if (src.reagents.has_reagent("ants") && src.reagents.has_reagent("mutagen"))
								var/ant_amt = src.reagents.get_reagent_amount("ants")
								var/mut_amt = src.reagents.get_reagent_amount("mutagen")
								src.reagents.del_reagent("ants")
								src.reagents.del_reagent("mutagen")
								src.reagents.add_reagent("spiders", ant_amt + mut_amt)
								boutput(src, "<span style=\"color:blue\">The ants arachnify.</span>")
								playsound(get_turf(src), "sound/effects/bubbles.ogg", 80, 1)

			if ("flip")
				if (src.emote_check(voluntary, 50) && !src.shrunk)

					//TODO: space flipping
					//if ((!src.restrained()) && (!src.lying) && (istype(src.loc, /turf/space)))
					//	message = "<B>[src]</B> does a flip!"
					//	if (prob(50))
					//		animate(src, transform = turn(GetPooledMatrix(), 90), time = 1, loop = -1)
					//		animate(transform = turn(GetPooledMatrix(), 180), time = 1, loop = -1)
					//		animate(transform = turn(GetPooledMatrix(), 270), time = 1, loop = -1)
					//		animate(transform = turn(GetPooledMatrix(), 360), time = 1, loop = -1)
					//	else
					//		animate(src, transform = turn(GetPooledMatrix(), -90), time = 1, loop = -1)
					//		animate(transform = turn(GetPooledMatrix(), -180), time = 1, loop = -1)
					//		animate(transform = turn(GetPooledMatrix(), -270), time = 1, loop = -1)
					//		animate(transform = turn(GetPooledMatrix(), -360), time = 1, loop = -1)
					if (istype(src.loc,/obj/))
						var/obj/container = src.loc
						container.mob_flip_inside(src)

					if (!iswrestler(src))
						if (src.stamina <= STAMINA_FLIP_COST || (src.stamina - STAMINA_FLIP_COST) <= 0)
							boutput(src, "<span style=\"color:red\">You fall over, panting and wheezing.</span>")
							message = "<span style=\"color:red\"><B>[src]</b> falls over, panting and wheezing.</span>"
							src.changeStatus("weakened", 2 SECONDS)
							src.set_stamina(min(1, src.stamina))
							src.emote_allowed = 0
							goto showmessage

					if (isvampire(src))
						var/datum/abilityHolder/vampire/V = get_ability_holder(/datum/abilityHolder/vampire)
						V.launch_bat_orbiters()

					if ((!istype(src.loc, /turf/space)) && (!src.on_chair))
						if (!src.lying)
							if ((src.restrained()) || (src.reagents && src.reagents.get_reagent_amount("ethanol") > 30) || (src.bioHolder.HasEffect("clumsy")))
								message = pick("<B>[src]</B> tries to flip, but stumbles!", "<B>[src]</B> slips!")
								src.changeStatus("weakened", 4 SECONDS)
								src.TakeDamage("head", 8, 0, 0, DAMAGE_BLUNT)
							if (src.bioHolder.HasEffect("fat"))
								message = pick("<B>[src]</B> tries to flip, but stumbles!", "<B>[src]</B> collapses under their own weight!")
								src.changeStatus("weakened", 2 SECONDS)
								src.TakeDamage("head", 4, 0, 0, DAMAGE_BLUNT)
							else
								message = "<B>[src]</B> does a flip!"
							if (!src.reagents.has_reagent("fliptonium"))
								animate_spin(src, prob(50) ? "L" : "R", 1, 0)
							//TACTICOOL FLOPOUT
							if (src.traitHolder.hasTrait("matrixflopout") && src.stance != "dodge")
								src.remove_stamina(STAMINA_FLIP_COST * 2.0)
								message = "<B>[src]</B> does a tactical flip!"
								src.stance = "dodge"
								SPAWN_DBG(2) //I'm sorry for my transgressions there's probably a way better way to do this
									if(src && src.stance == "dodge")
										src.stance = "normal"

							//FLIP OVER TABLES
							if (iswrestler(src) && !istype(usr.equipped(), /obj/item/grab))
								for (var/obj/table/T in oview(1, null))
									if ((src.dir == get_dir(src, T)))
										T.set_density(0)
										if (LinkBlockedWithAccess(src.loc, T.loc))
											T.set_density(1)
											continue
										T.set_density(1)
										var/turf/newloc = T.loc
										src.set_loc(newloc)
										message = "<B>[src]</B> flips onto [T]!"


							for (var/mob/living/M in view(1, null))
								var/obj/item/grab/G = usr.equipped()
								if (M == src)
									continue
								if (istype(usr.equipped(), /obj/item/grab))
									if (!G.affecting) //Wire note: Fix for Cannot read null.loc
										continue

									if (G.state >= 1 && isturf(src.loc) && isturf(G.affecting.loc))
										var/obj/table/tabl = locate() in src.loc.contents
										var/turf/newloc = src.loc
										G.affecting.set_loc(newloc)
										if (!G.affecting.reagents.has_reagent("fliptonium"))
											animate_spin(src, prob(50) ? "L" : "R", 1, 0)

										if (!iswrestler(src) && src.traitHolder && !src.traitHolder.hasTrait("glasscannon"))
											src.remove_stamina(STAMINA_FLIP_COST)
											src.stamina_stun()

										src.emote("scream")
										message = "<span style='color:red'><B>[src] suplexes [G.affecting][tabl ? " into [tabl]" : null]!</B></span>"
										logTheThing("combat", src, G.affecting, "suplexes %target%[tabl ? " into \an [tabl]" : null] [log_loc(src)]")
										M.lastattacker = src
										M.lastattackertime = world.time
										if (iswrestler(src))
											if (prob(50))
												M.ex_act(3) // this is hilariously overpowered, but WHATEVER!!!
											else
												G.affecting.changeStatus("stunned", 50)
												G.affecting.changeStatus("weakened", 5 SECONDS)
												G.affecting.force_laydown_standup()
												G.affecting.TakeDamage("head", 10, 0, 0, DAMAGE_BLUNT)
											playsound(src.loc, "sound/impact_sounds/Flesh_Break_1.ogg", 75, 1)
										else
											src.changeStatus("weakened", 3 SECONDS)

											if (client && client.hellbanned)
												src.changeStatus("weakened", 4 SECONDS)
											if (!G.affecting.hasStatus("weakened"))
												G.affecting.changeStatus("weakened", 5 SECONDS)


											G.affecting.force_laydown_standup()
											SPAWN_DBG(10) //let us do that combo shit people like with throwing
												src.force_laydown_standup()

											G.affecting.TakeDamage("head", 9, 0, 0, DAMAGE_BLUNT)
											playsound(src.loc, "sound/impact_sounds/Flesh_Break_1.ogg", 75, 1)
										if (tabl)
											if (istype(tabl, /obj/table/glass))
												var/obj/table/glass/g_tabl = tabl
												if (!g_tabl.glass_broken)
													if ((prob(g_tabl.reinforced ? 60 : 80)) || (src.bioHolder.HasEffect("clumsy") && (!g_tabl.reinforced || prob(90))) || ((src.bioHolder.HasEffect("fat") || G.affecting.bioHolder.HasEffect("fat")) && (!g_tabl.reinforced || prob(90))))
														SPAWN_DBG(0)
															g_tabl.smash()
															src.changeStatus("stunned", 7 SECONDS)
															src.changeStatus("weakened", 6 SECONDS)
															random_brute_damage(src, rand(20,40))
															take_bleeding_damage(src, src, rand(20,40))

															G.affecting.changeStatus("stunned", 2 SECONDS)
															G.affecting.changeStatus("weakened", 4 SECONDS)
															random_brute_damage(G.affecting, rand(20,40))
															take_bleeding_damage(G.affecting, src, rand(20,40))


															G.affecting.force_laydown_standup()
															SPAWN_DBG(10) //let us do that combo shit people like with throwing
																src.force_laydown_standup()

									if (G && G.state < 1) //ZeWaka: Fix for null.state
										var/turf/oldloc = src.loc
										var/turf/newloc = G.affecting.loc
										src.set_loc(newloc)
										G.affecting.set_loc(oldloc)
										message = "<B>[src]</B> flips over [G.affecting]!"
								else if (src.reagents && src.reagents.get_reagent_amount("ethanol") > 10)
									if (!iswrestler(src) && src.traitHolder && !src.traitHolder.hasTrait("glasscannon"))
										src.remove_stamina(STAMINA_FLIP_COST)
										src.stamina_stun()

									message = "<span style=\"color:red\"><B>[src]</B> flips into [M]!</span>"
									logTheThing("combat", src, M, "flips into %target%")
									src.changeStatus("weakened", 6 SECONDS)
									src.TakeDamage("head", 4, 0, 0, DAMAGE_BLUNT)
									M.changeStatus("weakened", 2 SECONDS)
									M.TakeDamage("head", 2, 0, 0, DAMAGE_BLUNT)
									playsound(src.loc, pick(sounds_punch), 100, 1)
									var/turf/newloc = M.loc
									src.set_loc(newloc)
								else
									message = "<B>[src]</B> flips in [M]'s general direction."
								break

					if (src.on_chair)// == 1)
						if (src.on_chair.loc != src.loc)
							src.pixel_y = 0
							src.anchored = 0
							src.on_chair = 0
							src.buckled = null
						else
							//CHAIR FLIPPING LOOP
							for (var/mob/living/M in oview(3))
								if (M == src)
									continue

								if (!istype(usr.equipped(), /obj/item/grab))
									src.pixel_y = 0
									src.buckled = null
									src.anchored = 0
									. = 1
									if (M && M.loc != src.loc) // just in case, so the user doesn't fall into nullspace if they fly at a person mid-gibbing or whatever
										var/list/flipLine = getline(src, M)
										for (var/turf/T in flipLine)
											if (!istype(src.loc, /turf) || T.density || T.loc:sanctuary || LinkBlockedWithAccess(src.loc, T))
												message = "<span style=\"color:red\"><B>[src]</b> does a flying flip...into the ground.  Like a big doofus.</span>"
												src.changeStatus("weakened", 5 SECONDS)
												. = 0
												break
											else
												src.set_loc(T)

									src.emote("scream")
									src.on_chair = 0

									if (!iswrestler(src) && src.traitHolder && !src.traitHolder.hasTrait("glasscannon"))
										src.remove_stamina(STAMINA_FLIP_COST)
										src.stamina_stun()

									if (.)
										playsound(src.loc, "sound/impact_sounds/Flesh_Break_1.ogg", 75, 1)
										message = "<span style=\"color:red\"><B>[src]</B> does a flying flip into [M]!</span>"
										logTheThing("combat", src, M, "[src] chairflips into %target%, [showCoords(M.x, M.y, M.z)].")
										M.lastattacker = src
										M.lastattackertime = world.time

										if (iswrestler(src))
											if (prob(33))
												M.ex_act(3)
											else
												random_brute_damage(M, 25)
												M.changeStatus("weakened", 7 SECONDS)
												M.changeStatus("stunned", 7 SECONDS)
										else if (M.traitHolder.hasTrait("training_security"))
											message = "<span style=\"color:red\"><B>[src]</B></span> does a flying flip into <span style=\"color:red\">[M]</span>, but <span style=\"color:red\">[M]</span> skillfully slings them away!"
											src.changeStatus("weakened", 6 SECONDS)
											src.changeStatus("stunned", 6 SECONDS)
											var/atom/target = get_edge_target_turf(M, M.dir)
											src.throw_at(target, 3, 10)
										else
											random_brute_damage(M, 10)
											if (!M.hasStatus("weakened"))
												M.changeStatus("weakened", 4 SECONDS)
												M.changeStatus("stunned", 4 SECONDS)
											src.changeStatus("weakened", 3 SECONDS)
											src.changeStatus("stunned", 3 SECONDS)

								if (!src.reagents.has_reagent("fliptonium"))
									animate_spin(src, prob(50) ? "L" : "R", 1, 0)
								break


					if (src.lying)
						message = "<B>[src]</B> flops on the floor like a fish."
					// If there is a chest item, see if its reagents can be dumped into the body
					if(src.chest_item != null)
						src.chest_item_dump_reagents_on_flip()

			if ("scream")
				if (src.emote_check(voluntary, 50))
					if (!muzzled)
						message = "<B>[src]</B> [istype(src.w_uniform, /obj/item/clothing/under/gimmick/frog) ? "croaks" : "screams"]!"
						m_type = 2
						if (narrator_mode)
							playsound(src.loc, 'sound/vox/scream.ogg', 80, 0, 0, src.get_age_pitch())
						else if (src.sound_list_scream && src.sound_list_scream.len)
							playsound(src.loc, pick(src.sound_list_scream), 80, 0, 0, src.get_age_pitch())
						else
							//if (src.gender == MALE)
								//playsound(get_turf(src), src.sound_malescream, 80, 0, 0, src.get_age_pitch())
							//else
							playsound(get_turf(src), src.sound_scream, 80, 0, 0, src.get_age_pitch())
						SPAWN_DBG(5)
							var/possumMax = 15
							for (var/obj/critter/opossum/responsePossum in range(4, src))
								if (!responsePossum.alive)
									continue
								if (possumMax-- < 0)
									break
								responsePossum.CritterDeath() // startled into playing dead!
							for (var/mob/living/critter/small_animal/opossum/P in mobs) // is this more or less intensive than a range(4)?
								if (P.z != src.z) // they're on a different world, maaaan
									continue
								if (P.playing_dead) // already out
									continue
								if (get_dist(P, src) > 4) // out of range
									continue
								P.play_dead(rand(20,40)) // shorter than the regular "death" stun
					else
						message = "<B>[src]</B> makes a very loud noise."
						m_type = 2
					if (src.traitHolder && src.traitHolder.hasTrait("scaredshitless"))
						src.emote("fart") //We can still fart if we're muzzled.

			if ("burp")
				if (src.emote_check(voluntary))
					if ((src.charges >= 1) && (!muzzled))
						for (var/mob/O in viewers(src, null))
							O.show_message("<B>[src]</B> burps.")
						for (var/mob/M in oview(1))
							var/datum/effects/system/spark_spread/s = unpool(/datum/effects/system/spark_spread)
							s.set_up(3, 1, src)
							s.start()
							boutput(M, "<span style=\"color:blue\">BZZZZZZZZZZZT!</span>")
							M.TakeDamage("chest", 0, 20, 0, DAMAGE_BURN)
							src.charges -= 1
							if (narrator_mode)
								playsound(src.loc, 'sound/vox/bloop.ogg', 100, 0, 0, src.get_age_pitch())
							else
								playsound(get_turf(src), src.sound_burp, 100, 0, 0, src.get_age_pitch())
							return
					else if ((src.charges >= 1) && (muzzled))
						for (var/mob/O in viewers(src, null))
							O.show_message("<B>[src]</B> vomits in \his own mouth a bit.")
						src.TakeDamage("head", 0, 50, 0, DAMAGE_BURN)
						src.charges -=1
						return
					else if ((src.charges < 1) && (!muzzled))
						message = "<B>[src]</B> burps."
						m_type = 2
						if (narrator_mode)
							playsound(src.loc, 'sound/vox/bloop.ogg', 100, 0, 0, src.get_age_pitch())
						else
							if (src.getStatusDuration("food_deep_burp"))
								playsound(get_turf(src), src.sound_burp, 100, 0, 0, src.get_age_pitch() * 0.5)
							else
								playsound(get_turf(src), src.sound_burp, 100, 0, 0, src.get_age_pitch())

						var/datum/statusEffect/fire_burp/FB = src.hasStatus("food_fireburp")
						if (!FB)
							FB = src.hasStatus("food_fireburp_big")
						if (FB)
							SPAWN_DBG(0)
								FB.cast()
					else
						message = "<B>[src]</B> vomits in \his own mouth a bit."
						m_type = 2

			if ("fart")
				if (src.emote_check(voluntary) && farting_allowed && (!src.reagents || !src.reagents.has_reagent("anti_fart")))
					if (!src.get_organ("butt"))
						m_type = 1
						if (prob(10))
							switch(rand(1, 5))
								if (1) message = "<B>[src]</B> purses \his lips and makes a wet sound. It's not very convincing."
								if (2) message = "<B>[src]</B> quietly peels some eggs. <B>Ugh!</B> what a <i>smell!</i>"
								if (3) message = "<B>[src]</B> does some armpit singing. Rude."
								if (4) message = "<B>[src]</B> manages to blow one out- but it goes <i>right back in!</i>"
								if (5)
									message = "<span style=\"color:red\"><B>[src]</B> grunts so hard \he tears a ligament!</span>"
									src.emote("scream")
									random_brute_damage(src, 20)
						else
							message = "<B>[src]</B> grunts for a moment. Nothing happens."
					else
						m_type = 2
						var/fart_on_other = 0
						for (var/mob/living/M in src.loc) //TODO : FARTABLE FLAG?
							if (M == src || !M.lying)
								continue
							message = "<span style='color:red'><B>[src]</B> farts in [M]'s face!</span>"
							if (sims)
								sims.affectMotive("fun", 4)
							if (src.mind)
								if (M.mind && M.mind.assigned_role == "Geneticist")
									src.mind.karma += 10
							fart_on_other = 1
							break
						for (var/obj/item/storage/bible/B in src.loc)
							B.farty_heresy(src)
							fart_on_other = 1
							break
						for (var/obj/item/book_kinginyellow/K in src.loc)
							K.farty_doom(src)
							fart_on_other = 1
							break
						for (var/obj/item/photo/voodoo/V in src.loc) //kubius: voodoo photo farty party
							var/mob/M = V.cursed_dude
							if (!M || !M.lying)
								continue
							playsound(get_turf(M), src.sound_fart, 20, 0, 0, src.get_age_pitch())
							switch(rand(1, 7))
								if (1) M.visible_message("<b>[M]</b> suddenly radiates an unwelcoming odor.</span>")
								if (2) M.visible_message("<b>[M]</b> is visited by ethereal incontinence.</span>")
								if (3) M.visible_message("<b>[M]</b> experiences paranormal gastrointestinal phenomena.</span>")
								if (4) M.visible_message("<b>[M]</b> involuntarily telecommutes to the farty party.</span>")
								if (5) M.visible_message("<b>[M]</b> is swept over by a mysterious draft.</span>")
								if (6) M.visible_message("<b>[M]</b> abruptly emits an odor of cheese.</span>")
								if (7) M.visible_message("<b>[M]</b> is set upon by extradimensional flatulence.</span>")
							if (sims)
								sims.affectMotive("fun", 4)
							//break deliberately omitted
						if (!fart_on_other)
							switch(rand(1, 42))
								if (1) message = "<B>[src]</B> lets out a girly little 'toot' from \his butt."
								if (2) message = "<B>[src]</B> farts loudly!"
								if (3) message = "<B>[src]</B> lets one rip!"
								if (4) message = "<B>[src]</B> farts! It sounds wet and smells like rotten eggs."
								if (5) message = "<B>[src]</B> farts robustly!"
								if (6) message = "<B>[src]</B> farted! It smells like something died."
								if (7) message = "<B>[src]</B> farts like a muppet!"
								if (8) message = "<B>[src]</B> defiles the station's air supply."
								if (9) message = "<B>[src]</B> farts a ten second long fart."
								if (10) message = "<B>[src]</B> groans and moans, farting like the world depended on it."
								if (11) message = "<B>[src]</B> breaks wind!"
								if (12) message = "<B>[src]</B> expels intestinal gas through the anus."
								if (13) message = "<B>[src]</B> release an audible discharge of intestinal gas."
								if (14) message = "<B>[src]</B> is a farting motherfucker!!!"
								if (15) message = "<B>[src]</B> suffers from flatulence!"
								if (16) message = "<B>[src]</B> releases flatus."
								if (17) message = "<B>[src]</B> releases methane."
								if (18) message = "<B>[src]</B> farts up a storm."
								if (19) message = "<B>[src]</B> farts. It smells like Soylent Surprise!"
								if (20) message = "<B>[src]</B> farts. It smells like pizza!"
								if (21) message = "<B>[src]</B> farts. It smells like George Melons' perfume!"
								if (22) message = "<B>[src]</B> farts. It smells like the kitchen!"
								if (23) message = "<B>[src]</B> farts. It smells like medbay in here now!"
								if (24) message = "<B>[src]</B> farts. It smells like the bridge in here now!"
								if (25) message = "<B>[src]</B> farts like a pubby!"
								if (26) message = "<B>[src]</B> farts like a goone!"
								if (27) message = "<B>[src]</B> sharts! That's just nasty."
								if (28) message = "<B>[src]</B> farts delicately."
								if (29) message = "<B>[src]</B> farts timidly."
								if (30) message = "<B>[src]</B> farts very, very quietly. The stench is OVERPOWERING."
								if (31) message = "<B>[src]</B> farts egregiously."
								if (32) message = "<B>[src]</B> farts voraciously."
								if (33) message = "<B>[src]</B> farts cantankerously."
								if (34) message = "<B>[src]</B> fart in \he own mouth. A shameful [src]."
								if (35) message = "<B>[src]</B> farts out pure plasma! <span style='color:red'><B>FUCK!</B></span>"
								if (36) message = "<B>[src]</B> farts out pure oxygen. What the fuck did \he eat?"
								if (37) message = "<B>[src]</B> breaks wind noisily!"
								if (38) message = "<B>[src]</B> releases gas with the power of the gods! The very station trembles!!"
								if (39) message = "<B>[src] <span style='color:red'>f</span><span style='color:blue'>a</span>r<span style='color:red'>t</span><span style='color:blue'>s</span>!</B>"
								if (40) message = "<B>[src]</B> laughs! \His breath smells like a fart."
								if (41) message = "<B>[src]</B> farts, and as such, blob cannot evoulate."
								if (42) message = "<b>[src]</B> farts. It might have been the Citizen Kane of farts."
						if (src.bioHolder && src.bioHolder.HasEffect("toxic_farts"))
							message = "<span style='color:red'><B>[src] [pick("unleashes","rips","blasts")] \a [pick("truly","utterly","devastatingly","shockingly")] [pick("hideous","horrendous","horrific","heinous","horrible")] fart!</B></span>"
							var/turf/fart_turf = get_turf(src)
							fart_turf.fluid_react_single("toxic_fart",2,airborne = 1)
						// If there is a chest item, see if it can be activated on fart (attack_self)
						if (src && src.chest_item != null) //Gotta do that pre-emptive runtime protection!
							src.chest_item_attack_self_on_fart()
						if (src.bioHolder && src.bioHolder.HasEffect("linkedfart"))
							message = "<span style=\"color:red\"><B>[src] [pick("unleashes","rips","blasts")] \a [pick("truly","utterly","devastatingly","shockingly")] [pick("hideous","horrendous","horrific","heinous","horrible")] fart!</B></span>"
							var/turf/fart_turf = get_turf(src)
							fart_turf.fluid_react_single("toxic_fart",2,airborne = 1)

							for(var/mob/living/H in mobs)
								if (H.bioHolder && H.bioHolder.HasEffect("linkedfart")) continue
								if(locate(/obj/item/storage/bible) in get_turf(H))
									src.visible_message("<span style=\"color:red\"><b>A mysterious force smites [src.name] for inciting blasphemy!</b></span>")
									src.gib()
								else
									H.emote("fart")
						if (istype(src.loc, /turf/space))
							// mbc : no actually fuck this it throws off the whole balance of space movement
							if (src.getStatusDuration("food_space_farts"))
								src.inertia_dir = src.dir
								step(src, inertia_dir)
								SPAWN_DBG(1)
									src.inertia_dir = src.dir
									step(src, inertia_dir)

						if (iscluwne(src))
							playsound(get_turf(src), "sound/voice/farts/poo.ogg", 50, 1)
						else if (src.organ_istype("butt", /obj/item/clothing/head/butt/cyberbutt))
							playsound(get_turf(src), "sound/voice/farts/poo2_robot.ogg", 100, 1, 0, src.get_age_pitch())
						else if (src.reagents && src.reagents.has_reagent("honk_fart"))
							playsound(src.loc, 'sound/musical_instruments/Bikehorn_1.ogg', 50, 1, -1)
						else
							if (narrator_mode)
								playsound(get_turf(src), 'sound/vox/fart.ogg', 100, 0, 0, src.get_age_pitch())
							else
								if (src.getStatusDuration("food_deep_fart"))
									playsound(get_turf(src), src.sound_fart, 100, 0, 0, src.get_age_pitch() - 0.3)
								else
									playsound(get_turf(src), src.sound_fart, 100, 0, 0, src.get_age_pitch())

						if(src.loc && istype(src.loc, /turf/simulated/floor/specialroom/freezer) && prob(10)) //ZeWaka: Fix for null.loc
							message = "<b>[src]</B> farts. The fart freezes in MID-AIR!!!"
							new/obj/item/material_piece/fart(src.loc)
							var/obj/item/material_piece/fart/F = unpool(/obj/item/material_piece/fart)
							F.set_loc(src.loc)

						src.remove_stamina(STAMINA_DEFAULT_FART_COST)

						src.stamina_stun()
		#ifdef DATALOGGER
						game_stats.Increment("farts")
		#endif

			if ("pee", "piss", "urinate")
				if (src.emote_check(voluntary))
					if (sims)
						var/bladder = sims.getValue("bladder")
						var/obj/item/storage/toilet/toilet = locate() in src.loc
						var/obj/item/reagent_containers/glass/beaker = locate() in src.loc
						if (bladder > 75)
							boutput(src, "<span style=\"color:blue\">You don't need to go right now.</span>")
							return
						else if (bladder > 50)
							if(toilet)
								if (wear_suit || w_uniform)
									message = "<B>[src]</B> unzips their pants and pees in the toilet."
								else
									message = "<B>[src]</B> pees in the toilet."
								toilet.clogged += 0.10
								sims.affectMotive("bladder", 100)
								sims.affectMotive("hygiene", -5)
							else if(beaker)
								boutput(src, "<span style=\"color:red\">You don't feel desperate enough to piss in the beaker.</span>")
							else if(wear_suit || w_uniform)
								boutput(src, "<span style=\"color:red\">You don't feel desperate enough to piss into your [w_uniform ? "uniform" : "suit"].</span>")
							else
								boutput(src, "<span style=\"color:red\">You don't feel desperate enough to piss on the floor.</span>")
							return
						else if (bladder > 25)
							if(toilet)
								if (wear_suit || w_uniform)
									message = "<B>[src]</B> unzips their pants and pees in the toilet."
								else
									message = "<B>[src]</B> pees in the toilet."
								toilet.clogged += 0.10
								sims.affectMotive("bladder", 100)
								sims.affectMotive("hygiene", -5)
							else if(beaker)
								if(wear_suit || w_uniform)
									message = "<B>[src]</B> unzips their pants, takes aim, and pees in the beaker."
								else
									message = "<B>[src]</B> takes aim and pees in the beaker."
								beaker.reagents.add_reagent("urine", 5)
								sims.affectMotive("bladder", 100)
								sims.affectMotive("hygiene", -25)
							else
								if(wear_suit || w_uniform)
									boutput(src, "<span style=\"color:red\">You don't feel desperate enough to piss into your [w_uniform ? "uniform" : "suit"].</span>")
									return
								else
									src.urinate()
									sims.affectMotive("bladder", 100)
									sims.affectMotive("hygiene", -50)
						else
							if (toilet)
								if (wear_suit || w_uniform)
									message = "<B>[src]</B> unzips their pants and pees in the toilet."
								else
									message = "<B>[src]</B> pees in the toilet."
								toilet.clogged += 0.10
								sims.affectMotive("bladder", 100)
								sims.affectMotive("hygiene", -5)
							else if(beaker)
								if(wear_suit || w_uniform)
									message = "<B>[src]</B> unzips their pants, takes aim, and fills the beaker with pee."
								else
									message = "<B>[src]</B> takes aim and fills the beaker with pee."
								sims.affectMotive("bladder", 100)
								sims.affectMotive("hygiene", -25)
								beaker.reagents.add_reagent("urine", 10)
							else
								if (wear_suit || w_uniform)
									message = "<B>[src]</B> pisses all over themselves!"
									sims.affectMotive("bladder", 100)
									sims.affectMotive("hygiene", -100)
									if (w_uniform)
										w_uniform.name = "piss-soaked [initial(w_uniform.name)]"
									else
										wear_suit.name = "piss-soaked [initial(wear_suit.name)]"
								else
									src.urinate()
									sims.affectMotive("bladder", 100)
									sims.affectMotive("hygiene", -50)

					else
						var/obj/item/storage/toilet/toilet = locate() in src.loc
						var/obj/item/reagent_containers/glass/beaker = locate() in src.loc

						if (src.urine < 1)
							message = "<B>[src]</B> pees themselves a little bit."
						else if (toilet && (src.buckled != null) && (src.urine >= 2))
							for (var/obj/item/storage/toilet/T in src.loc)
								message = pick("<B>[src]</B> unzips their pants and pees in the toilet.", "<B>[src]</B> empties their bladder.", "<span style=\"color:blue\">Ahhh, sweet relief.</span>")
								src.urine = 0
								T.clogged += 0.10
								break
						else if (beaker && (src.urine >= 1))
							message = pick("<B>[src]</B> unzips their pants, takes aim, and pees in the beaker.", "<B>[src]</B> takes aim and pees in the beaker!", "<B>[src]</B> fills the beaker with pee!")
							beaker.reagents.add_reagent("urine", src.urine * 4)
							src.urine = 0
						else
							src.urine--
							src.urinate()

			if ("poo", "poop", "shit", "crap")
				if (src.emote_check(voluntary))
					message = "<B>[src]</B> grunts for a moment. [prob(1) ? "Something" : "Nothing"] happens."

			if ("monologue")
				m_type = 2
				if (src.mind && src.mind.assigned_role == "Detective")
					if (istype(src.l_hand, /obj/item/grab))
						var/obj/item/grab/G = src.l_hand
						if (ishuman(G.affecting))
							message = "<span style=\"color:black\"><B>[src]</B> says, \"I'll stare the bastard in the face as he screams to God, and I'll laugh harder when he whimpers like a baby. And when [src.l_hand:affecting]'s eyes go dead, the hell I send him to will seem like heaven after what I've done to him.\"</span>"
					else if (istype(src.r_hand, /obj/item/grab))
						var/obj/item/grab/G = src.r_hand
						if (ishuman(G.affecting))
							message = "<span style=\"color:black\"><B>[src]</B> says, \"I'll stare the bastard in the face as he screams to God, and I'll laugh harder when he whimpers like a baby. And when [src.r_hand:affecting]'s eyes go dead, the hell I send him to will seem like heaven after what I've done to him.\"</span>"
					else if (istype(src.loc.loc, /area/station/security/detectives_office))
						message = "<span style=\"color:black\"><B>[src]</B> says, \"As I looked out the door of my office, I realised it was a night when you didn't know your friends but strangers looked familiar. A night like this, the smartest thing to do is nothing: stay home. It was like the wind carried people along with it. But I had to get out there.\"</span>"
					else if (istype(src.loc.loc, /area/station/maintenance))
						message = "<span style=\"color:black\"><B>[src]</B> says, \"The dark maintenance corridoors of this place were always the same, home to the most shady characters you could ever imagine. Walk down the right back alley in [station_name(1)], and you can find anything.\"</span>"
					else if (istype(src.loc.loc, /area/station/hydroponics))
						message = "<span style=\"color:black\"><B>[src]</b> says, \"A gang of space farmers growing psilocybin mushrooms, cannabis, and of course those goddamned george melons. A shady bunch, whose wiles had earned them the trust of many. The Chef. The Barman. But not me. No, their charms don't work on a man of values and principles.\"</span>"
					else if (istype(src.loc.loc, /area/station/mailroom))
						message = "<span style=\"color:black\"><B>[src]</b> says, \"The post office, an unused room habited by a brainless monkey, a cynical postman, and now, me. I've never trusted postal workers, with their crisp blue suits and their peaked caps. There's never any mail sent, excepting the ticking packages I gotta defuse up in the bridge.\"</span>"
					else if (istype(src.loc.loc, /area/centcom))
						message = "<span style=\"color:black\"><B>[src]</B> says, \"Central Command. I was tired as hell but I could afford to be tired now... I needed it to be morning. I wanted to hear doors opening, cars start, and human voices talking about the Space Olympics. I wanted to make sure there were still folks out there facing life with nothing up their sleeves but their arms. They didn't know it yet, but they had a better shot at happiness and a fair shake than they did yesterday.\"</span>"
					else if (istype(src.loc.loc, /area/station/chapel))
						message = "<span style=\"color:black\"><B>[src]</B> says, \"The self-pontificating bastard who calls himself our chaplain conducts worship here. If you can call the summoning of an angry god who pelts us with toolboxes, bolts of lightning, and occasionally rips our bodies in twain 'worship'.\"</span>"
					else if (istype(src.loc.loc, /area/station/bridge))
						message = "<span style=\"color:black\"><B>[src]</B> says, \"The bridge. The home of the Captain and Head of Personnel. I tried to tell myself I was the sturdy leg in our little triangle. I was worried it was true.\"</span>"
					else if (istype(src.loc.loc, /area/station/security/main))
						message = "<span style=\"color:black\"><B>[src]</B> says, \"I had dreams of being security before I got into the detective game. I wanted to meet stimulating and interesting people of an ancient space culture, and kill them. I wanted to be the first kid on my ship to get a confirmed kill.\"</span>"
					else if (istype(src.loc.loc, /area/station/crew_quarters/bar))
						message = "<span style=\"color:black\"><B>[src]</B> says, \"The station bar, full of the best examples of lowlifes and drunks I'll ever find. I need a drink though, and there are no better places to find a beer than here.\"</span>"
					else if (istype(src.loc.loc, /area/station/medical))
						message = "<span style=\"color:black\"><B>[src]</B> says, \"Medical. In truth it's full of the biggest bunch of cut throats on the station, most would rather cut you up than sow you up, but if I've got a slug in my ass, I don't have much choice.\"</span>"
					else if (istype(src.loc.loc, /area/station/hallway/primary/))
						message = "<span style=\"color:black\"><B>[src]</B> says, \"The halls of the station assault my nostrils like a week old meal left festering in the sink. A thug around every corner, and reason enough themselves to keep my gun in my hand.\"</span>"
					else if (istype(src.loc.loc, /area/station/hallway/secondary/exit))
						message = "<span style=\"color:black\"><B>[src]</B> says, \"The only way off this hellhole and it's the one place I don't want to be, but sometimes you have to show your friends that you're worth a damn. Sometimes that means dying, sometimes it means killing a whole lot of people to escape alive.\"</span>"
					else if (istype(src.loc.loc, /area/station/hallway/secondary/entry))
						message = "<span style=\"color:black\"><B>[src]</B> says, \"The entrance to [station_name(1)]. You will never find a more wretched hive of scum and villainy. I must be cautious.\"</span>"
					else if (istype(src.loc.loc, /area/station/engine/))
						message = "<span style=\"color:black\"><B>[src]</B> says, \"The churning, hellish heart of the station that just can't help missing the beat. Full of the dregs of society, and not the right place to be caught unwanted. I better watch my back.\"</span>"
					else if (istype(src.loc.loc, /area/station/maintenance/disposal))
						message = "<span style=\"color:black\"><B>[src]</B> says, \"Disposal. Usually bloodied, full of grey-suited corpses and broken windows. Down here, you can hear the quiet moaning of the station itself. It's like it's mourning. Mourning better days long gone, like assistants through these pipes.\"</span>"
					else if (istype(src.loc.loc, /area/station/crew_quarters/cafeteria))
						message = "<span style=\"color:black\"><B>[src]</B> says, \"A place to eat, but not an appealing one. I've heard rumours about this place, and if there's one thing I know, it's that it's not normal to eat people.\"</span>"
					else if (istype(src.wear_mask, /obj/item/clothing/mask/cigarette))
						message = "<B>[src]</B> takes a drag on \his cigarette, surveying the scene around them carefullly."
					else
						message = "<B>[src]</B> looks uneasy, like [src.gender == MALE ? "" : "s"]he's missing a vital part of h[src.gender == MALE ? "im" : "er"]self. [src.gender == MALE ? "H" : "Sh"]e needs a smoke badly."

				else
					message = "<B>[src]</B> tries to say something clever, but just can't pull it off looking like that."

			if ("miranda")
				if (src.emote_check(voluntary, 50))
					if (src.mind && (src.mind.assigned_role in list("Captain", "Head of Personnel", "Head of Security", "Security Officer", "Detective", "Vice Officer", "Regional Director", "Inspector")))
						src.recite_miranda()

			if ("dab") //I'm honestly not sure how I'm ever going to code anything lower than this - Readster 23/04/19
				if (src.emote_check(voluntary))
					var/mob/living/carbon/human/H = null
					if(ishuman(src))
						H = src
					if(H && (!H.limbs.l_arm || !H.limbs.r_arm))
						usr.show_text("You can't do that without arms!")
					else if ((src.mind && src.mind.assigned_role in list("Clown", "Staff Assistant")) || src.reagents && src.reagents.has_reagent("THC")) //only clowns and the useless know the true art of dabbing
						src.mind.karma -= 10
						if(prob(92))
							if (src.mind && src.mind.assigned_role == "Clown")
								message = "<B>[src]</B> [pick("performs a sick dab", "dabs on the haters", "shows everybody their dope dab skills", "performs a wicked dab", "dabs like nobody has dabbed before", "shows everyone how they dab in the circus")]!!!"
							else
								message = "<B>[src]</B> [pick("performs a sick dab", "dabs on the haters", "shows everybody their dope dab skills", "performs a wicked dab", "dabs like nobody has dabbed before")]!!!"
						// Act 2: Starring Firebarrage
						else
							message = "<span style=\"color:red\"><B>[src]</B> dabs their arms <B>RIGHT OFF</B>!!!!</span>"
							playsound(src.loc,"sound/misc/deepfrieddabs.ogg",50,0)
							shake_camera(src, 40, 0.5)
							if(H)
								if(H.limbs.l_arm)
									src.limbs.l_arm.sever()
								if(H.limbs.r_arm)
									src.limbs.r_arm.sever()
								H.emote("scream")
						src.take_brain_damage(10)
						if(src.get_brain_damage() > 60)
							usr.show_text(__red("Your head hurts!"))
					else
						usr.show_text("You don't know how to do that but you feel deeply ashamed for trying", "red")

			else
				src.show_text("Unusable emote '[act]'. 'Me help' for a list.", "blue")
				return

	showmessage
	if (message)
		logTheThing("say", src, null, "EMOTE: [message]")
		act = lowertext(act)
		if (m_type & 1)
			for (var/mob/O in viewers(src, null))
				O.show_message("<span style='color:#605b59'>[message]</span>", m_type, group = "[src]_[act]_[custom]")
		else if (m_type & 2)
			for (var/mob/O in hearers(src, null))
				O.show_message("<span style='color:#605b59'>[message]</span>", m_type, group = "[src]_[act]_[custom]")
		else if (!isturf(src.loc))
			var/atom/A = src.loc
			for (var/mob/O in A.contents)
				O.show_message("<span style='color:#605b59'>[message]</span>", m_type, group = "[src]_[act]_[custom]")