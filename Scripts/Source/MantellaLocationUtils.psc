Scriptname MantellaLocationUtils extends Quest

Actor Property PlayerRef Auto
GlobalVariable Property TimeScale Auto

ObjectReference Function GetCurrentLocationRef()
    ObjectReference fromRef = None
    if PlayerRef.IsInInterior()
        ; If player is indoors, try to use the general location
        string playerLocation = (PlayerRef.GetCurrentLocation() as Form).GetName()
        if playerLocation != ""
            int fromMarkerID = MapMarkerLocationToID(playerLocation)
            if fromMarkerID != 0x00000000
                ObjectReference fromMarkerRef = Game.GetFormFromFile(fromMarkerID, "Skyrim.esm") as ObjectReference
                if fromMarkerRef != None
                    fromRef = fromMarkerRef
                endIf
            endIf
        endIf
    else
        ; Player is outside, use their position directly
        fromRef = PlayerRef as ObjectReference
    endIf

    return fromRef
EndFunction


float Function CalculateTravelDays(ObjectReference markerRef)
    float travelDays

    ObjectReference fromRef = GetCurrentLocationRef()
    if fromRef
        float distance = fromRef.GetDistance(markerRef)

        ; https://en.m.uesp.net/wiki/Skyrim%3ATransport
        ; Walk speed = 80 units/sec (real time)
        ; 86,400 (seconds in a day) * 80 (walk speed) = 6,912,000 game units traveled in a real world day
        ; Skyrim time passes faster than real time (20x by default)
        travelDays = (distance * TimeScale.GetValue()) / 6912000.0
    else
        travelDays = 1.0 ; Default to 1 day if current location unknown
    endIf
    
    return travelDays
EndFunction


ObjectReference Function MapMarkerLocationToRef(string locationName)
    ObjectReference markerRef
    int markerID = MapMarkerLocationToID(locationName)

    if markerID != 0x00000000
        markerRef = Game.GetFormFromFile(markerID, "Skyrim.esm") as ObjectReference
    endIf
    
    return markerRef
EndFunction


int Function MapMarkerLocationToID(string locationName)
    if locationName == "Abandoned Prison"
        return 0x000ECF49
    elseif locationName == "Abandoned Shack"
        return 0x0005254D
    elseif locationName == "Alchemist's Shack"
        return 0x000D3931
    elseif locationName == "Alftand"
        return 0x00015D4A
    elseif locationName == "Alftand Dwemer Ruin"
        return 0x00015D4A
    elseif locationName == "Ancient's Ascent"
        return 0x00016231
    elseif locationName == "Anga's Mill"
        return 0x000162D6
    elseif locationName == "Angarvunde"
        return 0x00015D51
    elseif locationName == "Angarvunde Nordic Ruins"
        return 0x00015D51
    elseif locationName == "Angi's Camp"
        return 0x000CF27D
    elseif locationName == "Anise's Cabin"
        return 0x000D9531
    elseif locationName == "Ansilvund"
        return 0x00015D56
    elseif locationName == "Arcwind Point"
        return 0x000F5FEF
    elseif locationName == "Autumnshade Clearing"
        return 0x0001620C
    elseif locationName == "Autumnwatch Tower"
        return 0x00016233
    elseif locationName == "Avanchnzel"
        return 0x0001620D
    elseif locationName == "Bannermist Tower"
        return 0x0004781E
    elseif locationName == "Bard's Leap Summit"
        return 0x0001620E
    elseif locationName == "Battle-Born Farm"
        return 0x00016332
    elseif locationName == "Bilegulch Mine"
        return 0x00016275
    elseif locationName == "Black Creek"
        return 0x000F5FF4
    elseif locationName == "Black-Briar Lodge"
        return 0x000A7CE5
    elseif locationName == "Blackrock Den"
        return 0x000F5FE4
    elseif locationName == "Blackscar Camp"
        return 0x000F5FF1
    elseif locationName == "Blackwater Channel"
        return 0x000F5FE2
    elseif locationName == "Blackwind Spire"
        return 0x000F5FD9
    elseif locationName == "Bladeridge Den"
        return 0x000F5FE5
    elseif locationName == "Bleak Falls Barrow"
        return 0x00016232
    elseif locationName == "Bleakcoast Cave"
        return 0x0001620F
    elseif locationName == "Bleakwind Basin"
        return 0x00016211
    elseif locationName == "Bleakwind Bluff"
        return 0x000BB47C
    elseif locationName == "Blind Cliff Cave"
        return 0x00016213
    elseif locationName == "Blizzard Rest"
        return 0x00016214
    elseif locationName == "Bloated Man's Grotto"
        return 0x00016215
    elseif locationName == "Bloodlet Throne"
        return 0x00016EB2
    elseif locationName == "Blue Palace"
        return 0x000C44AB
    elseif locationName == "Bonechill Passage"
        return 0x000FDA48
    elseif locationName == "Bonestrewn Crest"
        return 0x000162B6
    elseif locationName == "Boulderfall Cave"
        return 0x000F52D8
    elseif locationName == "Brandy-Mug Farm"
        return 0x00016339
    elseif locationName == "Brigand's Bluff"
        return 0x000F5FF2
    elseif locationName == "Brinewater Grotto"
        return 0x0002C652
    elseif locationName == "Broadstream Camp"
        return 0x000F5FF3
    elseif locationName == "Broken Fang Cave"
        return 0x00016218
    elseif locationName == "Broken Helm Hollow"
        return 0x00016219
    elseif locationName == "Broken Limb Camp"
        return 0x000ECF86
    elseif locationName == "Broken Oar Grotto"
        return 0x000B77C3
    elseif locationName == "Broken Tower Redoubt"
        return 0x0001621A
    elseif locationName == "Bronze Water Cave"
        return 0x00046BAB
    elseif locationName == "Brood Cavern"
        return 0x0001621B
    elseif locationName == "Bruca's Leap Redoubt"
        return 0x0001621C
    elseif locationName == "Bthardamz"
        return 0x0001621D
    elseif locationName == "Chillfurrow Farm"
        return 0x0001633C
    elseif locationName == "Chillpine Grove"
        return 0x000F5FEE
    elseif locationName == "Chillwind Depths"
        return 0x00016220
    elseif locationName == "Clearpine Pond"
        return 0x00016222
    elseif locationName == "Clearspring Tarn"
        return 0x00016223
    elseif locationName == "Cliffside Retreat"
        return 0x000B238B
    elseif locationName == "Cloudreach Cavern"
        return 0x000F5FE6
    elseif locationName == "College of Winterhold"
        return 0x00046BDF
    elseif locationName == "Crabber's Shanty"
        return 0x000E66A7
    elseif locationName == "Cracked Tusk Keep"
        return 0x0001625B
    elseif locationName == "Cradle Stone Tower"
        return 0x000B23A1
    elseif locationName == "Cradlecrush Rock"
        return 0x00016225
    elseif locationName == "Cragslane Cavern"
        return 0x00016226
    elseif locationName == "Cragwallow Slope"
        return 0x00016227
    elseif locationName == "Cronvangr Cave"
        return 0x00016228
    elseif locationName == "Crystaldrift Cave"
        return 0x00016229
    elseif locationName == "Dainty Sload"
        return 0x0007BC2D
    elseif locationName == "Dark Brotherhood Sanctuary"
        return 0x0001C3B0
    elseif locationName == "Darklight Tower"
        return 0x0001622A
    elseif locationName == "Darkshade"
        return 0x000B6046
    elseif locationName == "Darkstone Tower"
        return 0x000F5FDC
    elseif locationName == "Darkthorn Grove"
        return 0x000F5FED
    elseif locationName == "Darkwater Crossing"
        return 0x00017732
    elseif locationName == "Darkwater Pass"
        return 0x0001622C
    elseif locationName == "Dawnsgard"
        return 0x000F5FEC
    elseif locationName == "Dawnstar"
        return 0x0001773A
    elseif locationName == "Dawnstar Sanctuary"
        return 0x0005E0A6
    elseif locationName == "Dead Crone Rock"
        return 0x0001622D
    elseif locationName == "Dead Men's Respite"
        return 0x0001622E
    elseif locationName == "Deep Folk Crossing"
        return 0x000B238F
    elseif locationName == "Deepwood Redoubt"
        return 0x0001622F
    elseif locationName == "Dragon Bridge"
        return 0x00017753
    elseif locationName == "Dragon Bridge Overlook"
        return 0x000B2393
    elseif locationName == "Dragonsreach"
        return 0x000C44AD
    elseif locationName == "Dragontooth Crater"
        return 0x00016230
    elseif locationName == "Drelas' Cottage"
        return 0x000E66AD
    elseif locationName == "Driftshade Refuge"
        return 0x0001623B
    elseif locationName == "Druadach Redoubt"
        return 0x0001623C
    elseif locationName == "Dushnikh Yal"
        return 0x0001623E
    elseif locationName == "Duskglow Crevice"
        return 0x0001623F
    elseif locationName == "Dustman's Cairn"
        return 0x000F5B8D
    elseif locationName == "East Empire Company Warehouse"
        return 0x0004FEF2
    elseif locationName == "Eastmarch Imperial Camp"
        return 0x00095A08
    elseif locationName == "Eboncrest"
        return 0x000F5FD5
    elseif locationName == "Ebongaze Tower"
        return 0x000F5FD6
    elseif locationName == "Eldergleam Sanctuary"
        return 0x000162B7
    elseif locationName == "Eldersblood Peak"
        return 0x00016238
    elseif locationName == "Embershard Mine"
        return 0x000B6CDF
    elseif locationName == "Evergreen Grove"
        return 0x00016241
    elseif locationName == "Eye of Markarth"
        return 0x000F5FE0
    elseif locationName == "Faldar's Tooth"
        return 0x00016242
    elseif locationName == "Falkreath"
        return 0x00017760
    elseif locationName == "Falkreath Imperial Camp"
        return 0x00016283
    elseif locationName == "Falkreath Stormcloak Camp"
        return 0x00016282
    elseif locationName == "Falkreath Watchtower"
        return 0x0004788C
    elseif locationName == "Fallowstone Cave"
        return 0x00016243
    elseif locationName == "Fellglow Keep"
        return 0x00016244
    elseif locationName == "Folgunthur"
        return 0x00016246
    elseif locationName == "Forelhost"
        return 0x00016247
    elseif locationName == "Forsaken Cave"
        return 0x00016248
    elseif locationName == "Forsaken Spire"
        return 0x000F5FD4
    elseif locationName == "Fort Amol"
        return 0x00016249
    elseif locationName == "Fort Dunstad"
        return 0x0001624B
    elseif locationName == "Fort Fellhammer"
        return 0x0001624C
    elseif locationName == "Fort Greenwall"
        return 0x0001624D
    elseif locationName == "Fort Greymoor"
        return 0x0001624A
    elseif locationName == "Fort Hraggstad"
        return 0x0003F510
    elseif locationName == "Fort Kastav"
        return 0x0001624F
    elseif locationName == "Fort Neugrad"
        return 0x00016250
    elseif locationName == "Fort Snowhawk"
        return 0x00016251
    elseif locationName == "Fort Sungard"
        return 0x00016252
    elseif locationName == "Four Skull Lookout"
        return 0x000B23A7
    elseif locationName == "Froki's Shack"
        return 0x000D392D
    elseif locationName == "Frostflow Lighthouse"
        return 0x00016253
    elseif locationName == "Frostmere Crypt"
        return 0x000162C2
    elseif locationName == "Gallows Rock"
        return 0x00016254
    elseif locationName == "Geirmund's Hall"
        return 0x00016255
    elseif locationName == "Giant's Grove"
        return 0x000D28B7
    elseif locationName == "Gjukar's Monument"
        return 0x000DED8E
    elseif locationName == "Glenmoril Coven"
        return 0x00016257
    elseif locationName == "Glimmerweb Depths"
        return 0x000F5FE1
    elseif locationName == "Gloombound Mine"
        return 0x00016349
    elseif locationName == "Gloomreach"
        return 0x00016258
    elseif locationName == "Goldenglow Estate"
        return 0x0001A710
    elseif locationName == "Graywinter Watch"
        return 0x00016259
    elseif locationName == "Great Lift at Alftand"
        return 0x000F81DB
    elseif locationName == "Great Lift at Mzinchaleft"
        return 0x000F81DA
    elseif locationName == "Great Lift at Raldbthar"
        return 0x000F81D9
    elseif locationName == "Greenspring Hollow"
        return 0x00016269
    elseif locationName == "Greywater Grotto"
        return 0x0001625A
    elseif locationName == "Guldun Rock"
        return 0x0001625C
    elseif locationName == "Haafingar Stormcloak Camp"
        return 0x00094F96
    elseif locationName == "Haemar's Shame"
        return 0x0001625D
    elseif locationName == "Hag Rock Redoubt"
        return 0x0001625E
    elseif locationName == "Hag's End"
        return 0x0001625F
    elseif locationName == "Half-Moon Mill"
        return 0x00016370
    elseif locationName == "Hall of the Vigilant"
        return 0x000C342A
    elseif locationName == "Halldir's Cairn"
        return 0x00016260
    elseif locationName == "Halted Stream Camp"
        return 0x00016261
    elseif locationName == "Hamvir's Rest"
        return 0x000EE79C
    elseif locationName == "Harmugstahl"
        return 0x00016262
    elseif locationName == "Heartwood Mill"
        return 0x0001634F
    elseif locationName == "Hela's Folly"
        return 0x000162AC
    elseif locationName == "Helgen"
        return 0x00017780
    elseif locationName == "High Gate Ruins"
        return 0x00016263
    elseif locationName == "High Hrothgar"
        return 0x00016352
    elseif locationName == "Hillgrund's Tomb"
        return 0x000162CB
    elseif locationName == "Hjaalmarch Imperial Camp"
        return 0x00016279
    elseif locationName == "Hjaalmarch Stormcloak Camp"
        return 0x0001627A
    elseif locationName == "Hlaalu Farm"
        return 0x00016355
    elseif locationName == "Hob's Fall Cave"
        return 0x00016266
    elseif locationName == "Hollyfrost Farm"
        return 0x00016358
    elseif locationName == "Honeystrand Cave"
        return 0x00016267
    elseif locationName == "Honningbrew Meadery"
        return 0x00038593
    elseif locationName == "Hunter's Rest"
        return 0x000F52B2
    elseif locationName == "Ilinalta's Deep"
        return 0x0001626A
    elseif locationName == "Irkngthand"
        return 0x0001626B
    elseif locationName == "Ironback Hideout"
        return 0x000EF543
    elseif locationName == "Ironbind Barrow"
        return 0x0003F076
    elseif locationName == "Ivarstead"
        return 0x00017791
    elseif locationName == "Japhet's Folly"
        return 0x00016245
    elseif locationName == "Journeyman's Nook"
        return 0x000EF549
    elseif locationName == "Kagrenzel"
        return 0x00080E56
    elseif locationName == "Karthspire"
        return 0x0001626C
    elseif locationName == "Karthspire Camp"
        return 0x000F6698
    elseif locationName == "Karthwasten"
        return 0x0001779A
    elseif locationName == "Katla's Farm"
        return 0x0001635E
    elseif locationName == "Kjenstag Ruins"
        return 0x000C2EEF
    elseif locationName == "Knifepoint Ridge"
        return 0x0008E03C
    elseif locationName == "Kolskeggr Mine"
        return 0x0002051D
    elseif locationName == "Korvanjund"
        return 0x00016224
    elseif locationName == "Kynesgrove"
        return 0x000177A1
    elseif locationName == "Kyneswatch"
        return 0x000F5FD7
    elseif locationName == "Labyrinthian"
        return 0x0001626E
    elseif locationName == "Largashbur"
        return 0x0001626F
    elseif locationName == "Left Hand Mine"
        return 0x00016364
    elseif locationName == "Liar's Retreat"
        return 0x00016270
    elseif locationName == "Loreius Farm"
        return 0x00016367
    elseif locationName == "Lost Echo Cave"
        return 0x000AF89B
    elseif locationName == "Lost Knife Hideout"
        return 0x00016273
    elseif locationName == "Lost Prospect Mine"
        return 0x000D3938
    elseif locationName == "Lost Summit Overlook"
        return 0x000F5FDB
    elseif locationName == "Lost Tongue Overlook"
        return 0x00016235
    elseif locationName == "Lost Valkygg"
        return 0x000EAA63
    elseif locationName == "Lost Valley Redoubt"
        return 0x00016274
    elseif locationName == "Lower Steepfall Burrow"
        return 0x000F4FE7
    elseif locationName == "Lund's Hut"
        return 0x000E66A3
    elseif locationName == "Mara's Eye Pond"
        return 0x000ECF51
    elseif locationName == "Markarth"
        return 0x0001C38A
    elseif locationName == "Markarth Military Camp"
        return 0x00094C29
    elseif locationName == "Markarth Stables"
        return 0x000E962F
    elseif locationName == "Meeko's Shack"
        return 0x000F6F11
    elseif locationName == "Merryfair Farm"
        return 0x000268FF
    elseif locationName == "Mistveil Keep"
        return 0x000C44B1
    elseif locationName == "Mistwatch"
        return 0x00016286
    elseif locationName == "Mixwater Mill"
        return 0x0001636D
    elseif locationName == "Mor Khazgur"
        return 0x00016287
    elseif locationName == "Morthal"
        return 0x000177B0
    elseif locationName == "Morvunskar"
        return 0x00016288
    elseif locationName == "Moss Mother Cavern"
        return 0x00016289
    elseif locationName == "Mount Anthor"
        return 0x0001628A
    elseif locationName == "Movarth's Lair"
        return 0x00016256
    elseif locationName == "Mzinchaleft"
        return 0x0001628B
    elseif locationName == "Mzulft"
        return 0x0001628C
    elseif locationName == "Narzulbur"
        return 0x0001628D
    elseif locationName == "Nightcaller Temple"
        return 0x00017082
    elseif locationName == "Nightgate Inn"
        return 0x00017785
    elseif locationName == "Nightingale Hall"
        return 0x00047D25
    elseif locationName == "Nilheim"
        return 0x0001628F
    elseif locationName == "North Brittleshin Pass"
        return 0x00016265
    elseif locationName == "North Cold Rock Pass"
        return 0x000F5EB1
    elseif locationName == "North Shriekwind Bastion"
        return 0x000A0E46
    elseif locationName == "North Skybound Watch"
        return 0x0004B6EB
    elseif locationName == "Northstar Tower"
        return 0x000F5FE9
    elseif locationName == "Northwatch Keep"
        return 0x00016290
    elseif locationName == "Northwind Mine"
        return 0x000FDBDE
    elseif locationName == "Northwind Summit"
        return 0x00016234
    elseif locationName == "Old Hroldan"
        return 0x000177C3
    elseif locationName == "Orotheim"
        return 0x00016291
    elseif locationName == "Orphan Rock"
        return 0x00016292
    elseif locationName == "Orphan's Tear"
        return 0x000162B0
    elseif locationName == "Palace of the Kings"
        return 0x000C44B3
    elseif locationName == "Pale Imperial Camp"
        return 0x0001627B
    elseif locationName == "Pale Stormcloak Camp"
        return 0x0001627C
    elseif locationName == "Peak's Shade Tower"
        return 0x00047880
    elseif locationName == "Pelagia Farm"
        return 0x00016373
    elseif locationName == "Pilgrim's Trench"
        return 0x000162AD
    elseif locationName == "Pinefrost Tower"
        return 0x000EF0BA
    elseif locationName == "Pinemoon Cave"
        return 0x00016293
    elseif locationName == "Pinepeak Cavern"
        return 0x00016294
    elseif locationName == "Pinewatch"
        return 0x00016295
    elseif locationName == "Purewater Run"
        return 0x00032875
    elseif locationName == "Ragnvald"
        return 0x0001629A
    elseif locationName == "Raldbthar"
        return 0x00090595
    elseif locationName == "Rannveig's Fast"
        return 0x0001629B
    elseif locationName == "Ravenscar Hollow"
        return 0x0001629C
    elseif locationName == "Reach Imperial Camp"
        return 0x00016277
    elseif locationName == "Reach Stormcloak Camp"
        return 0x00016276
    elseif locationName == "Reachcliff Cave"
        return 0x0001629D
    elseif locationName == "Reachward Watch"
        return 0x000F5FDD
    elseif locationName == "Reachwater Rock"
        return 0x0001629E
    elseif locationName == "Reachwind Eyrie"
        return 0x000B23A3
    elseif locationName == "Rebel's Cairn"
        return 0x000B629F
    elseif locationName == "Rebel's Respite"
        return 0x000F5FF0
    elseif locationName == "Red Eagle Redoubt"
        return 0x0001623D
    elseif locationName == "Red Road Pass"
        return 0x000162A0
    elseif locationName == "Redoran's Retreat"
        return 0x0001629F
    elseif locationName == "Refugees' Rest"
        return 0x000EF570
    elseif locationName == "Rift Imperial Camp"
        return 0x00016281
    elseif locationName == "Rift Stormcloak Camp"
        return 0x00016280
    elseif locationName == "Rift Watchtower"
        return 0x000D3930
    elseif locationName == "Riften"
        return 0x0001C390
    elseif locationName == "Riften Military Camp"
        return 0x000A8844
    elseif locationName == "Riften Stables"
        return 0x00096A46
    elseif locationName == "Rimerock Burrow"
        return 0x000162A1
    elseif locationName == "Rimewind Keep"
        return 0x000F5FE8
    elseif locationName == "Riverside Shack"
        return 0x000ECF4F
    elseif locationName == "Riverwatch"
        return 0x000F5FD2
    elseif locationName == "Riverwood"
        return 0x000162A4
    elseif locationName == "Roadside Ruins"
        return 0x00047875
    elseif locationName == "Robber's Gorge"
        return 0x000162A7
    elseif locationName == "Rorikstead"
        return 0x000177CC
    elseif locationName == "Ruins of Bthalft"
        return 0x000D393C
    elseif locationName == "Ruins of Rkund"
        return 0x000D3939
    elseif locationName == "Saarthal"
        return 0x000162A5
    elseif locationName == "Sacellum of Boethiah"
        return 0x0004D8DA
    elseif locationName == "Salvius Farm"
        return 0x00016376
    elseif locationName == "Sarethi Farm"
        return 0x00016379
    elseif locationName == "Scarred Earth Cavern"
        return 0x000F5FE7
    elseif locationName == "Secunda's Kiss"
        return 0x000162A6
    elseif locationName == "Septimus Signus' Outpost"
        return 0x0002D511
    elseif locationName == "Serpent's Bluff Redoubt"
        return 0x000162CC
    elseif locationName == "Shaderest Tower"
        return 0x000F5FEA
    elseif locationName == "Shadowgreen Cavern"
        return 0x000162A8
    elseif locationName == "Shearpoint"
        return 0x00016237
    elseif locationName == "Shimmermist Cave"
        return 0x000162A9
    elseif locationName == "Shor's Stone"
        return 0x000177D7
    elseif locationName == "Shor's Watchtower"
        return 0x000D3934
    elseif locationName == "Shrine of Azura"
        return 0x00092496
    elseif locationName == "Shrine of Mehrunes Dagon"
        return 0x000246A5
    elseif locationName == "Shrine to Peryite"
        return 0x000AD066
    elseif locationName == "Shroud Hearth Barrow"
        return 0x0006CCC8
    elseif locationName == "Shrouded Grove"
        return 0x000162B1
    elseif locationName == "Sightless Pit"
        return 0x000162B3
    elseif locationName == "Silent Moons Camp"
        return 0x000162B4
    elseif locationName == "Silverdrift Lair"
        return 0x000162B5
    elseif locationName == "Sky Haven Temple"
        return 0x0001637C
    elseif locationName == "Skyborn Altar"
        return 0x00016239
    elseif locationName == "Skytemple Ruins"
        return 0x000EF0AE
    elseif locationName == "Sleeping Tree Camp"
        return 0x000162B8
    elseif locationName == "Snapleg Cave"
        return 0x00068094
    elseif locationName == "Snow Veil Sanctum"
        return 0x0002DDD1
    elseif locationName == "Snow-Shod Farm"
        return 0x0001634C
    elseif locationName == "Snowmelt Cove"
        return 0x000F5FE3
    elseif locationName == "Snowpoint Beacon"
        return 0x000C2EF6
    elseif locationName == "Softfire Camp"
        return 0x000F5FD3
    elseif locationName == "Solitude"
        return 0x0004D0F4
    elseif locationName == "Solitude Lighthouse"
        return 0x000C016D
    elseif locationName == "Solitude Military Camp"
        return 0x00034896
    elseif locationName == "Solitude Sawmill"
        return 0x00016382
    elseif locationName == "Soljund's Sinkhole"
        return 0x000162BB
    elseif locationName == "South Brittleshin Pass"
        return 0x00082213
    elseif locationName == "South Cold Rock Pass"
        return 0x000F5EAF
    elseif locationName == "South Shriekwind Bastion"
        return 0x000B83C8
    elseif locationName == "South Skybound Watch"
        return 0x000479BB
    elseif locationName == "Southfringe Sanctum"
        return 0x00016217
    elseif locationName == "Statue to Meridia"
        return 0x0001626D
    elseif locationName == "Steamcrag Camp"
        return 0x0001623A
    elseif locationName == "Steepfall Burrow"
        return 0x000162BF
    elseif locationName == "Stendarr's Beacon"
        return 0x00108A58
    elseif locationName == "Stillborn Cave"
        return 0x000162C0
    elseif locationName == "Stonehill Bluff"
        return 0x000162C1
    elseif locationName == "Stonehills"
        return 0x000177E4
    elseif locationName == "Stoneshaper Summit"
        return 0x000F5FDF
    elseif locationName == "Stony Creek Cave"
        return 0x00080F13
    elseif locationName == "Stormcrest Tower"
        return 0x000F5FD8
    elseif locationName == "Sundered Towers"
        return 0x000B6295
    elseif locationName == "Sunderstone Gorge"
        return 0x000F5EA8
    elseif locationName == "Swindler's Den"
        return 0x00015D4D
    elseif locationName == "Talking Stone Camp"
        return 0x000162C3
    elseif locationName == "Thalmor Embassy"
        return 0x00033E45
    elseif locationName == "The Apprentice Stone"
        return 0x0001BAB9
    elseif locationName == "The Atronach Stone"
        return 0x000E0F4C
    elseif locationName == "The Guardian Stones"
        return 0x0001BABD
    elseif locationName == "The Katariah"
        return 0x000C4D20
    elseif locationName == "The Lady Stone"
        return 0x000DED90
    elseif locationName == "The Lord Stone"
        return 0x000E0F47
    elseif locationName == "The Lover Stone"
        return 0x0001BABB
    elseif locationName == "The Ritual Stone"
        return 0x000DD9D5
    elseif locationName == "The Serpent Stone"
        return 0x000E0F69
    elseif locationName == "The Shadow Stone"
        return 0x000D3935
    elseif locationName == "The Steed Stone"
        return 0x0001BAC0
    elseif locationName == "The Tower Stone"
        return 0x000E0ED5
    elseif locationName == "Thieves Guild"
        return 0x00105F3A
    elseif locationName == "Throat of the World"
        return 0x000162C4
    elseif locationName == "Tolvald's Cave"
        return 0x000162C5
    elseif locationName == "Tower of Mzark"
        return 0x000D30DA
    elseif locationName == "Traitor's Post"
        return 0x000C2EE9
    elseif locationName == "Treva's Watch"
        return 0x000162C6
    elseif locationName == "Tumble Arch Pass"
        return 0x000162C7
    elseif locationName == "Twilight Sepulcher"
        return 0x00016216
    elseif locationName == "Twisted Root Cave"
        return 0x000F5FF5
    elseif locationName == "Understone Keep"
        return 0x000C44AF
    elseif locationName == "Ustengrav"
        return 0x0001621F
    elseif locationName == "Uttering Hills Cave"
        return 0x000162C8
    elseif locationName == "Valtheim Towers"
        return 0x000162C9
    elseif locationName == "Valthume"
        return 0x0008D5D6
    elseif locationName == "Volskygge"
        return 0x000162CA
    elseif locationName == "Volunruud"
        return 0x00016264
    elseif locationName == "Wayward Pass"
        return 0x000C2EFA
    elseif locationName == "Western Watchtower"
        return 0x000DB889
    elseif locationName == "Weynon Stones"
        return 0x000BC0AA
    elseif locationName == "Whistling Mine"
        return 0x00016385
    elseif locationName == "White River Watch"
        return 0x000162CD
    elseif locationName == "Whiterun"
        return 0x000162CE
    elseif locationName == "Whiterun Imperial Camp"
        return 0x00016284
    elseif locationName == "Whiterun Military Camp"
        return 0x00094A1F
    elseif locationName == "Whiterun Stables"
        return 0x00072879
    elseif locationName == "Whiterun Stormcloak Camp"
        return 0x00095885
    elseif locationName == "Whitewatch Tower"
        return 0x000DD99A
    elseif locationName == "Widow's Watch Ruins"
        return 0x000EF0A7
    elseif locationName == "Windhelm"
        return 0x00038436
    elseif locationName == "Windhelm Military Camp"
        return 0x0009003B
    elseif locationName == "Windhelm Stables"
        return 0x0009846F
    elseif locationName == "Windshear Post"
        return 0x000F5FEB
    elseif locationName == "Windward Ruins"
        return 0x000C2EEC
    elseif locationName == "Windward Spire"
        return 0x000F5FDA
    elseif locationName == "Winterhold"
        return 0x000177EF
    elseif locationName == "Winterhold Imperial Camp"
        return 0x0001627D
    elseif locationName == "Winterhold Stormcloak Camp"
        return 0x0001627E
    elseif locationName == "Witchmist Grove"
        return 0x000E1B80
    elseif locationName == "Wolfskull Cave"
        return 0x000162D1
    elseif locationName == "Wreck Of The Brinehammer"
        return 0x000162AB
    elseif locationName == "Wreck of the Icerunner"
        return 0x000162AA
    elseif locationName == "Wreck of The Pride of Tel Vos"
        return 0x000162AE
    elseif locationName == "Wreck of the Winter War"
        return 0x000162AF
    elseif locationName == "Yngol Barrow"
        return 0x00016271
    elseif locationName == "Yngvild"
        return 0x000162D3
    elseif locationName == "Yorgrim Overlook"
        return 0x000C33FF
    elseif locationName == "Ysgramor's Tomb"
        return 0x000162D2
    
    ;;;; Interior Locations - Mapped to Equal Exterior Locations (eg Riverwood Trader -> Riverwood) ;;;;
    ; Riverwood Locations
    elseif locationName == "Sleeping Giant Inn"
        return 0x000162A4
    elseif locationName == "Riverwood Trader"
        return 0x000162A4
    elseif locationName == "Lucan's Dry Goods"
        return 0x000162A4
    elseif locationName == "Alvor and Sigrid's House"
        return 0x000162A4
    elseif locationName == "Faendal's House"
        return 0x000162A4
    elseif locationName == "Hod and Gerdur's House"
        return 0x000162A4
    elseif locationName == "Sven and Hilde's House"
        return 0x000162A4
    ; Dragon Bridge Locations
    elseif locationName == "Lylvieve Family's House"
        return 0x00017753
    elseif locationName == "Four Shields Tavern"
        return 0x00017753
    elseif locationName == "Horgeir's House"
        return 0x00017753
    elseif locationName == "Penitus Oculatus Outpost"
        return 0x00017753
    ; Ivarstead Locations
    elseif locationName == "Vilemyr Inn"
        return 0x00017791
    elseif locationName == "Fellstar Farm"
        return 0x00017791
    elseif locationName == "Klimmek's House"
        return 0x00017791
    elseif locationName == "Narfi's Ruined House"
        return 0x00017791
    elseif locationName == "Temba Wide-Arm's Mill"
        return 0x00017791
    elseif locationName == "Shroud Hearth Barrow"
        return 0x00017791
    ; Karthwasten Locations
    elseif locationName == "Enmon's House"
        return 0x0001779A
    elseif locationName == "Karthwasten Hall"
        return 0x0001779A
    elseif locationName == "Miner's Barracks"
        return 0x0001779A
    elseif locationName == "Sanuarach Mine"
        return 0x0001779A
    ; Rorikstead Locations
    elseif locationName == "Lemkil's Farmhouse"
        return 0x000177CC
    elseif locationName == "Frostfruit Inn"
        return 0x000177CC
    elseif locationName == "Cowflop Farm"
        return 0x000177CC
    elseif locationName == "Rorik's Manor"
        return 0x000177CC
    ; Shor's Stone Locations
    elseif locationName == "Filnjar's House"
        return 0x000177D7
    elseif locationName == "Odfel's House"
        return 0x000177D7
    elseif locationName == "Redbelly Mine"
        return 0x000177D7
    elseif locationName == "Sylgja's House"
        return 0x000177D7
    ; Whiterun Locations
    elseif locationName == "The Bannered Mare"
        return 0x000162CE
    elseif locationName == "Arcadia's Cauldron"
        return 0x000162CE
    elseif locationName == "Belethor's General Goods"
        return 0x000162CE
    elseif locationName == "Skyforge"
        return 0x000162CE
    elseif locationName == "The Drunken Huntsman"
        return 0x000162CE
    elseif locationName == "Warmaiden's"
        return 0x000162CE
    elseif locationName == "Whiterun Marketplace"
        return 0x000162CE
    elseif locationName == "Amren's House"
        return 0x000162CE
    elseif locationName == "Breezehome"
        return 0x000162CE
    elseif locationName == "Carlotta Valentia's House"
        return 0x000162CE
    elseif locationName == "Heimskr's House"
        return 0x000162CE
    elseif locationName == "House Gray-Mane"
        return 0x000162CE
    elseif locationName == "House of Clan Battle-Born"
        return 0x000162CE
    elseif locationName == "Olava the Feeble's House"
        return 0x000162CE
    elseif locationName == "Severio Pelagia's House"
        return 0x000162CE
    elseif locationName == "Uthgerd's House"
        return 0x000162CE
    elseif locationName == "Ysolda's House"
        return 0x000162CE
    elseif locationName == "Guard Barracks"
        return 0x000162CE
    elseif locationName == "Gildergreen"
        return 0x000162CE
    elseif locationName == "Jorrvaskr"
        return 0x000162CE
    elseif locationName == "Temple of Kynareth"
        return 0x000162CE
    ; Riften Locations
    elseif locationName == "The Bee and Barb"
        return 0x0001C390
    elseif locationName == "The Ragged Flagon"
        return 0x0001C390
    elseif locationName == "Black-Briar Meadery"
        return 0x0001C390
    elseif locationName == "Elgrim's Elixirs"
        return 0x0001C390
    elseif locationName == "The Pawned Prawn"
        return 0x0001C390
    elseif locationName == "Riften Marketplace"
        return 0x0001C390
    elseif locationName == "The Scorched Hammer"
        return 0x0001C390
    elseif locationName == "Aerin's House"
        return 0x0001C390
    elseif locationName == "Beggar's Row"
        return 0x0001C390
    elseif locationName == "Black-Briar Manor"
        return 0x0001C390
    elseif locationName == "Bolli's House"
        return 0x0001C390
    elseif locationName == "Haelga's Bunkhouse"
        return 0x0001C390
    elseif locationName == "Honeyside"
        return 0x0001C390
    elseif locationName == "Marise Aravel's House"
        return 0x0001C390
    elseif locationName == "Riftweald Manor"
        return 0x0001C390
    elseif locationName == "Romlyn Dreth's House"
        return 0x0001C390
    elseif locationName == "Snow-Shod Manor"
        return 0x0001C390
    elseif locationName == "Valindor's House"
        return 0x0001C390
    elseif locationName == "Honorhall Orphanage"
        return 0x0001C390
    elseif locationName == "Temple of Mara"
        return 0x0001C390
    elseif locationName == "The Ratway"
        return 0x0001C390
    elseif locationName == "Riften Jail"
        return 0x0001C390
    elseif locationName == "Riften Fishery"
        return 0x0001C390
    ; Windhelm Locations
    elseif locationName == "Candlehearth Hall"
        return 0x00038436
    elseif locationName == "New Gnisis Cornerclub"
        return 0x00038436
    elseif locationName == "Blacksmith Quarters"
        return 0x00038436
    elseif locationName == "The White Phial"
        return 0x00038436
    elseif locationName == "Sadri's Used Wares"
        return 0x00038436
    elseif locationName == "Windhelm Marketplace"
        return 0x00038436
    elseif locationName == "Aretino Residence"
        return 0x00038436
    elseif locationName == "Atheron Residence"
        return 0x00038436
    elseif locationName == "Belyn Hlaalu's House"
        return 0x00038436
    elseif locationName == "Brunwulf Free-Winter's House"
        return 0x00038436
    elseif locationName == "Hjerim"
        return 0x00038436
    elseif locationName == "House of Clan Cruel-Sea"
        return 0x00038436
    elseif locationName == "House of Clan Shatter-Shield"
        return 0x00038436
    elseif locationName == "Niranye's House"
        return 0x00038436
    elseif locationName == "Viola Giordano's House"
        return 0x00038436
    elseif locationName == "Calixto's House of Curiosities"
        return 0x00038436
    elseif locationName == "Argonian Assemblage"
        return 0x00038436
    elseif locationName == "Brandy-Mug Farm"
        return 0x00038436
    elseif locationName == "Clan Shatter-Shield Office"
        return 0x00038436
    elseif locationName == "East Empire Company Office"
        return 0x00038436
    elseif locationName == "Hlaalu Farm"
        return 0x00038436
    elseif locationName == "Hollyfrost Farm"
        return 0x00038436
    elseif locationName == "Warehouse"
        return 0x00038436
    ; Solitude Locations
    elseif locationName == "The Winking Skeever"
        return 0x0004D0F4
    elseif locationName == "Radiant Raiment"
        return 0x0004D0F4
    elseif locationName == "Angeline's Aromatics"
        return 0x0004D0F4
    elseif locationName == "Bits and Pieces"
        return 0x0004D0F4
    elseif locationName == "Fletcher"
        return 0x0004D0F4
    elseif locationName == "Solitude Blacksmith"
        return 0x0004D0F4
    elseif locationName == "Addvar's House"
        return 0x0004D0F4
    elseif locationName == "Bryling's House"
        return 0x0004D0F4
    elseif locationName == "Erikur's House"
        return 0x0004D0F4
    elseif locationName == "Evette San's House"
        return 0x0004D0F4
    elseif locationName == "Jala's House"
        return 0x0004D0F4
    elseif locationName == "Proudspire Manor"
        return 0x0004D0F4
    elseif locationName == "Vittoria Vici's House"
        return 0x0004D0F4
    elseif locationName == "Bards College"
        return 0x0004D0F4
    elseif locationName == "Castle Dour"
        return 0x0004D0F4
    elseif locationName == "Solitude Stables"
        return 0x0004D0F4
    elseif locationName == "Temple of the Divines"
        return 0x0004D0F4
    elseif locationName == "Thalmor Headquarters"
        return 0x0004D0F4
    ; Markarth Locations
    elseif locationName == "Silver-Blood Inn"
        return 0x0001C38A
    elseif locationName == "Arnleif and Sons Trading Company"
        return 0x0001C38A
    elseif locationName == "The Hag's Cure"
        return 0x0001C38A
    elseif locationName == "Ghorza gra-Bagol"
        return 0x0001C38A
    elseif locationName == "Moth gro-Bagol"
        return 0x0001C38A
    elseif locationName == "Hogni Red-Arm"
        return 0x0001C38A
    elseif locationName == "Kerah"
        return 0x0001C38A
    elseif locationName == "Calcelmo"
        return 0x0001C38A
    elseif locationName == "Endon's House"
        return 0x0001C38A
    elseif locationName == "Nepos's House"
        return 0x0001C38A
    elseif locationName == "Ogmund's House"
        return 0x0001C38A
    elseif locationName == "Smelter Overseer's House"
        return 0x0001C38A
    elseif locationName == "Vlindrel Hall"
        return 0x0001C38A
    elseif locationName == "Abandoned House"
        return 0x0001C38A
    elseif locationName == "Cidhna Mine"
        return 0x0001C38A
    elseif locationName == "Markarth Lumber Mill and Forge"
        return 0x0001C38A
    elseif locationName == "Markarth Guard Tower"
        return 0x0001C38A
    elseif locationName == "Shrine of Talos"
        return 0x0001C38A
    elseif locationName == "Temple of Dibella"
        return 0x0001C38A
    elseif locationName == "The Treasury House"
        return 0x0001C38A
    elseif locationName == "The Warrens"
        return 0x0001C38A
    ; Morthal Locations
    elseif locationName == "Moorside Inn"
        return 0x000177B0
    elseif locationName == "Thaumaturgist's Hut"
        return 0x000177B0
    elseif locationName == "Alva's House"
        return 0x000177B0
    elseif locationName == "Falion's House"
        return 0x000177B0
    elseif locationName == "Hroggar's House"
        return 0x000177B0
    elseif locationName == "Jorgen and Lami's House"
        return 0x000177B0
    elseif locationName == "Thonnir's House"
        return 0x000177B0
    elseif locationName == "Highmoon Hall"
        return 0x000177B0
    elseif locationName == "Morthal Cemetery"
        return 0x000177B0
    elseif locationName == "Guardhouse"
        return 0x000177B0
    ; Dawnstar Locations
    elseif locationName == "Windpeak Inn"
        return 0x0001773A
    elseif locationName == "Rustleif's House"
        return 0x0001773A
    elseif locationName == "The Mortar and Pestle"
        return 0x0001773A
    elseif locationName == "Beitild's House"
        return 0x0001773A
    elseif locationName == "Brina's House"
        return 0x0001773A
    elseif locationName == "Fruki's House"
        return 0x0001773A
    elseif locationName == "Irgnir's House"
        return 0x0001773A
    elseif locationName == "Leigelf's House"
        return 0x0001773A
    elseif locationName == "Silus Vesuius's House"
        return 0x0001773A
    elseif locationName == "The White Hall"
        return 0x0001773A
    elseif locationName == "Iron-Breaker Mine"
        return 0x0001773A
    elseif locationName == "Quicksilver Mine"
        return 0x0001773A
    elseif locationName == "Dawnstar Barracks"
        return 0x0001773A
    elseif locationName == "The Sea Squall"
        return 0x0001773A
    ; Falkreath Locations
    elseif locationName == "Dead Man's Drink"
        return 0x00017760
    elseif locationName == "Grave Concoctions"
        return 0x00017760
    elseif locationName == "Gray Pine Goods"
        return 0x00017760
    elseif locationName == "Lod's House"
        return 0x00017760
    elseif locationName == "Corpselight Farm"
        return 0x00017760
    elseif locationName == "Dengeir's House"
        return 0x00017760
    elseif locationName == "Jarl's Longhouse"
        return 0x00017760
    elseif locationName == "Deadwood Lumber Mill"
        return 0x00017760
    elseif locationName == "Falkreath Barracks"
        return 0x00017760
    elseif locationName == "Falkreath Jail"
        return 0x00017760
    elseif locationName == "Falkreath Graveyard"
        return 0x00017760
    
    else
        Debug.Notification("Location not found: " + locationName)
        return 0x00000000
    endif
EndFunction