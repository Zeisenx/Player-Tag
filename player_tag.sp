
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

Handle g_fwOnPlayerTagAdded;
Handle g_fwOnPlayerTagRemoved;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	RegPluginLibrary("player_tag");
	CreateNative("PlayerTag_Add", Native_Add);
	CreateNative("PlayerTag_Has", Native_Has);
	CreateNative("PlayerTag_Remove", Native_Remove);
	CreateNative("PlayerTag_RemoveAll", Native_RemoveAll);
	
	g_fwOnPlayerTagAdded		= CreateGlobalForward("PlayerTag_OnAdded", ET_Ignore, Param_Cell, Param_String);
	g_fwOnPlayerTagRemoved		= CreateGlobalForward("PlayerTag_OnRemoved", ET_Ignore, Param_Cell, Param_String);
	
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
	
	if (g_tagList[client] == null)
		return 0;
	
	ArrayList tagList = g_tagList[client].Clone();
	
	delete g_tagList[client];
	for (int i=0; i<tagList.Length; i++)
	{
		char tagName[TAGNAME_LENGTH];
		tagList.GetString(i, tagName, sizeof(tagName));
		Forward_OnRemoved(client, tagName);
	}
	
	delete tagList;
	
	return 0;
}

void Client_AddTag(int client, const char[] tagName)
{
	if (g_tagList[client] == null)
		g_tagList[client] = CreateTagList();
	
	if (g_tagList[client].FindString(tagName) != -1)
		return;
	
	g_tagList[client].PushString(tagName);
	Call_StartForward(g_fwOnPlayerTagAdded);
	Call_PushCell(client);
	Call_PushString(tagName);
	Call_Finish();
}

void Client_RemoveTag(int client, const char[] tagName)
{
	if (g_tagList[client] == null)
		return;
	
	int idx = g_tagList[client].FindString(tagName);
	if (idx == -1)
		return;
	
	g_tagList[client].Erase(idx);
	Forward_OnRemoved(client, tagName);
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

void Forward_OnRemoved(int client, const char[] tagName)
{
	Call_StartForward(g_fwOnPlayerTagRemoved);
	Call_PushCell(client);
	Call_PushString(tagName);
	Call_Finish();
}