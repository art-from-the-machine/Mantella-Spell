Scriptname MantellaConstants extends Quest hidden

int property HTTP_PORT = 5000 auto
string property HTTP_ROUTE_MAIN = "mantella" auto
string property HTTP_ROUTE_STT = "stt" auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; JSON keys for communication ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

string property PREFIX = "mantella_" auto
string property KEY_REQUESTTYPE = "request_type" auto
string property KEY_REPLYTYPE = "reply_type" auto

;Conversation
string property KEY_REQUESTTYPE_STARTCONVERSATION = "start_conversation" auto
string property KEY_REQUESTTYPE_CONTINUECONVERSATION = "continue_conversation" auto
string property KEY_REQUESTTYPE_PLAYERINPUT = "player_input" auto
string property KEY_REQUESTTYPE_ENDCONVERSATION = "end_conversation" auto

;Actors
string property KEY_ACTORS = "actors" auto
string property KEY_ACTOR_NAME = "actor_name" auto
string property KEY_ACTOR_GENDER = "actor_gender" auto
string property KEY_ACTOR_RACE = "actor_race" auto
string property KEY_ACTOR_ISPLAYER = "actor_is_player" auto
string property KEY_ACTOR_RELATIONSHIPRANK = "actor_relationshiprank" auto
string property KEY_ACTOR_VOICETYPE = "actor_voicetype" auto
string property KEY_ACTOR_ISENEMY = "actor_is_enemy" auto

string property KEY_ACTOR_SPEAKER = "actor_speaker" auto
string property KEY_ACTOR_LINETOSPEAK = "actor_line_to_speak" auto

;context
string property KEY_CONTEXT = "context" auto
string property KEY_CONTEXT_LOCATION = "location" auto
string property KEY_CONTEXT_TIME = "time" auto
string property KEY_CONTEXT_INGAMEEVENTS = "ingame_events" auto

;player input
string property KEY_REQUESTTYPE_TTS = "tts" auto
string property KEY_INPUT_NAMESINCONVERSATION = "names_in_conversation" auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;       Possible actions      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

string property ACTION_NPCTALK = "npc_talk" auto
string property ACTION_PLAYERTALK = "player_talk" auto
string property ACTION_ENDCONVERSATION = "end_conversation" auto
