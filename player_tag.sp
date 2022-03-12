
#include <sourcemod>

public Plugin myinfo = 
{
	name = "Player Tag",
	author = "Zeisen",
	description = "",
	version = "1.0",
	url = "http://steamcommunity.com/profiles/76561198002384750"
};

#define TAGNAME_LENGTH 64

ArrayList g_tagList[MAXPLAYERS + 1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	RegPluginLibrary("player_tag");
	CreateNative("PlayerTag_Add", Native_Add);
	CreateNative("PlayerTag_Has", Native_Has);
	CreateNative("PlayerTag_Remove", Native_Remove);
	CreateNative("PlayerTag_RemoveAll", Native_RemoveAll);
	
	return APLRes_Success;
}

public void OnClientDisconnect(int client)
{
	delete g_tagList[client];
}

public int Native_Add(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	char tagName[TAGNAME_LENGTH];
	GetNativeString(2, tagName, sizeof(tagName));
	
	Client_AddTag(client, tagName);
}

public int Native_Has(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	char tagName[TAGNAME_LENGTH];
	GetNativeString(2, tagName, sizeof(tagName));
	
	return view_as<int>(Client_HasTag(client, tagName));
}

public int Native_Remove(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	char tagName[TAGNAME_LENGTH];
	GetNativeString(2, tagName, sizeof(tagName));
	
	Client_RemoveTag(client, tagName);
}

public int Native_RemoveAll(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	
	delete g_tagList[client];
}

void Client_AddTag(int client, const char[] tagName)
{
	if (g_tagList[client] == null)
		g_tagList[client] = CreateTagList();
	
	if (g_tagList[client].FindString(tagName) != -1)
		return;
	
	g_tagList[client].PushString(tagName);
}

void Client_RemoveTag(int client, const char[] tagName)
{
	if (g_tagList[client] == null)
		return;
	
	int idx = g_tagList[client].FindString(tagName);
	if (idx == -1)
		return;
	
	g_tagList[client].Erase(idx);
}

bool Client_HasTag(int client, const char[] tagName)
{
	if (g_tagList[client] == null)
		return false;
	
	return g_tagList[client].FindString(tagName) != -1;
}

ArrayList CreateTagList()
{
	return new ArrayList(TAGNAME_LENGTH);
}
