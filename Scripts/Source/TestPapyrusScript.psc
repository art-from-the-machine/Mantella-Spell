scriptName TestPapyrusScript extends Quest
{!BIND}
Import SKSE_HTTP

int H_KEY = 35

event OnHttpReplyReceived(int typedDictionaryHandle)    
    string replyType = SKSE_HTTP.getString(typedDictionaryHandle, "replytype", "Error: No reply type received")
    string text = replyType + "\n"
    if(replyType == "conversationResponse")
        int[] npcHandles = SKSE_HTTP.getNestedDictionariesArray(typedDictionaryHandle, "npcs")        
        iElement = npcHandles.Length
        iIndex = 0
        text += "NPC handles: "
        While iIndex < iElement
            text += npcHandles[iIndex] + ", "
            iIndex += 1
        EndWhile

        text += "NPCs:" + "\n"
        Int iElement = npcHandles.Length
        Int iIndex = 0
        While iIndex < iElement
            string npcText = GetNPC(npcHandles[iIndex])
            text += npcText + "\n"
            iIndex += 1
        EndWhile

        float testFloat = SKSE_HTTP.getFloat(typedDictionaryHandle, "testfloat", 1)
        text += "testFloat: " + testFloat + "\n"

        string[] testStringArray = SKSE_HTTP.getStringArray(typedDictionaryHandle, "teststringarray")
        iElement = testStringArray.Length
        iIndex = 0
        While iIndex < iElement
            text += testStringArray[iIndex] + ", "
            iIndex += 1
        EndWhile

        int[] testIntArray = SKSE_HTTP.getIntArray(typedDictionaryHandle, "testintarray")
        iElement = testIntArray.Length
        iIndex = 0
        While iIndex < iElement
            text += testIntArray[iIndex] + ", "
            iIndex += 1
        EndWhile

        float[] testFloatArray = SKSE_HTTP.getFloatArray(typedDictionaryHandle, "testfloatarray")
        iElement = testFloatArray.Length
        iIndex = 0
        While iIndex < iElement
            text += testFloatArray[iIndex] + ", "
            iIndex += 1
        EndWhile

        bool[] testBoolArray = SKSE_HTTP.getBoolArray(typedDictionaryHandle, "testboolarray")
        iElement = testBoolArray.Length
        iIndex = 0
        While iIndex < iElement
            text += testBoolArray[iIndex] + ", "
            iIndex += 1
        EndWhile


        int contextHandle = SKSE_HTTP.getNestedDictionary(typedDictionaryHandle, "context", 0)
        string current_location = SKSE_HTTP.getString(contextHandle, "location", "Only the gods know where")
        text += "location: " + current_location + "\n"
        int time = SKSE_HTTP.getInt(contextHandle, "time", 0)
        text += "time: " + time + "\n"     
        
    endIf
    
    Debug.MessageBox(text)
endEvent

string function GetNPC(int handle)    
    string result = SKSE_HTTP.getString(handle, "name", "Error: Could not get name of NPC") + "\n"
    result += SKSE_HTTP.getString(handle, "gender", "Error: Could not get gender of NPC") + "\n"
    result += SKSE_HTTP.getBool(handle, "npcLikesPlayer", "Error: Could not get npcLikesPlayer of NPC") + "\n"
    return result
endFunction

event OnInit()
    Debug.MessageBox("OnInit for TestPapyrusScript triggered")
    RegisterForModEvent("SKSE_HTTP_OnHttpReplyReceived","OnHttpReplyReceived")
    RegisterForKey(H_KEY)
endEvent

event OnKeyDown(int keyCode)
    if keyCode == H_KEY
        Debug.Notification("OnKeyDown for TestPapyrusScript triggered")
        DoSomething()
    endIf
endEvent

function DoSomething()
    int handle = SKSE_HTTP.createDictionary()
    SKSE_HTTP.setString(handle, "requestType", "startConversation")
    ;Debug.MessageBox(SKSE_HTTP.getString(handle,"requestType", "Did not work"))
    int[] npcs = new int[2]
    npcs[0] = SetNPC("Lydia", "female", false)
    npcs[1] = SetNPC("Bandit", "male", true)
    SKSE_HTTP.setNestedDictionariesArray(handle, "npcs", npcs)

    SKSE_HTTP.setFloat(handle, "testFloat", 0.123)
    string[] testStringArray = new string[2]
    testStringArray[0] = "trala"
    testStringArray[1] = "lala"
    ;Debug.MessageBox(testStringArray[0] + "\n" + testStringArray[1])
    SKSE_HTTP.setStringArray(handle, "testStringArray", testStringArray)
    int[] testIntArray = new int[2]
    testIntArray[0] = 22
    testIntArray[1] = 23
    SKSE_HTTP.setIntArray(handle, "testIntArray", testIntArray)
    float[] testFloatArray = new float[2]
    testFloatArray[0] = 0.123
    testFloatArray[1] = 0.456
    SKSE_HTTP.setFloatArray(handle, "testFloatArray", testFloatArray)
    bool[] testBoolArray = new bool[2]
    testBoolArray[0] = false
    testBoolArray[1] = true
    SKSE_HTTP.setBoolArray(handle, "testBoolArray", testBoolArray)

    int handleForContext = SKSE_HTTP.createDictionary()
    SKSE_HTTP.setString(handleForContext, "location", "Dragonsreach")
    SKSE_HTTP.setInt(handleForContext, "time", 1328)
    SKSE_HTTP.setNestedDictionary(handle,"context",handleForContext)

    SKSE_HTTP.sendLocalhostHttpRequest(handle,5000,"mantella")    
endFunction

int function SetNPC(string name, string gender, bool isInCombatWithPlayer)
    int npcHandle = SKSE_HTTP.createDictionary()
    SKSE_HTTP.setString(npcHandle, "name", name)
    SKSE_HTTP.setString(npcHandle,"gender", gender)
    SKSE_HTTP.setBool(npcHandle, "isInCombatWithPlayer", isInCombatWithPlayer)
    return npcHandle
endFunction
