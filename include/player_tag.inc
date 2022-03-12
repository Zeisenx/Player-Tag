
#if defined _player_tag_included_
  #endinput
#endif
#define _player_tag_included_

native void PlayerTag_Add(int client, const char[] tagName);
native bool PlayerTag_Has(int client, const char[] tagName);
native void PlayerTag_Remove(int client, const char[] tagName);
native void PlayerTag_RemoveAll(int client);

forward void PlayerTag_OnAdded(int client, const char[] tagName);
forward void PlayerTag_OnRemoved(int client, const char[] tagName);

public SharedPlugin __pl_player_tag = 
{
	name = "player_tag",
	file = "player_tag.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_player_tag_SetNTVOptional()
{
	MarkNativeAsOptional("PlayerTag_Add");
	MarkNativeAsOptional("PlayerTag_Has");
	MarkNativeAsOptional("PlayerTag_Remove");
	MarkNativeAsOptional("PlayerTag_RemoveAll");
}
#endif
