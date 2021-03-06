/obj/item/megaphone
	name = "megaphone"
	desc = "A device used to project your voice. Loudly."
	icon_state = "megaphone"
	item_state = "radio"
	w_class = WEIGHT_CLASS_SMALL
	flags_atom = CONDUCT

	var/spamcheck = 0
	var/insults = 0
	var/list/insultmsg = list("FUCK EVERYONE!", "I'M A TATER!", "ALL SECURITY TO SHOOT ME ON SIGHT!", "I HAVE A BOMB!", "CAPTAIN IS A COMDOM!", "FOR THE SYNDICATE!")

/obj/item/megaphone/attack_self(mob/living/user)
	if (user.client)
		if(user.client.prefs.muted & MUTE_IC)
			to_chat(src, "<span class='warning'>You cannot speak in IC (muted).</span>")
			return
	if(!ishuman(user))
		to_chat(user, "<span class='warning'>You don't know how to use this!</span>")
		return

	if(spamcheck)
		to_chat(user, "<span class='warning'>\The [src] needs to recharge!</span>")
		return

	var/message = copytext(sanitize(input(user, "Shout a message?", "Megaphone", null)  as text),1,MAX_MESSAGE_LEN)
	if(!message)
		return
	message = capitalize(message)
	log_game("[key_name(user)] used a megaphone to say: [message]")
	user.log_talk(message, LOG_SAY)
	if ((src.loc == user && usr.stat == 0))
		if(CHECK_BITFIELD(obj_flags, EMAGGED))
			if(insults)
				audible_message("<B>[user]</B> broadcasts, <FONT size=3>\"[pick(insultmsg)]\"</FONT>")
				insults--
			else
				to_chat(user, "<span class='warning'>*BZZZZzzzzzt*</span>")
		else
			audible_message("<B>[user]</B> broadcasts, <FONT size=3>\"[message]\"</FONT>")

		spamcheck = TRUE
		addtimer(VARSET_CALLBACK(src, spamcheck, FALSE), 2 SECONDS)

/obj/item/megaphone/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(istype(I, /obj/item/card/emag) && !CHECK_BITFIELD(obj_flags, EMAGGED))
		to_chat(user, "<span class='warning'>You overload \the [src]'s voice synthesizer.</span>")
		ENABLE_BITFIELD(obj_flags, EMAGGED)
		insults = rand(1, 3)
