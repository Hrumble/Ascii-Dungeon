# TO-DO
*This is a simple to-do list because I keep forgetting what I have to do when I come back to it*

- [x] Find a way to implement doorways into rooms, so that the player can move around
- [x] Player move around!
- [x] Minimap
- [x] Have enemies and entities spawn in the dungeon
- [x] Room Interactions
- [x] Unique entities with unique logic
- [x] Fix whatever logic you have about moving around in the dungeon, need a way to create a coherent map to join rooms together
- [x] Inventory UI
- [x] Fighting system...
- [x] Find a way for permanent changes to happen in visited rooms, if the player killed a spider, it should still be dead when he comes back
- [x] Loot tables (merchants, entities, and so on...)
- [x] Chests
- [ ] Rewrite the log system (see ##Log system and rooms in [#Issues])
- [ ] Conversations with NPCs
- [ ] Merchant, buying stuff, selling stuff and spawning
- [ ] Entire equipment system
- [ ] Crafting mechanic
- [ ] Story progression system
- [ ] Status effects and consumables
- [ ] Artefacts!!!

## Backlog
- [ ] Add a queuing system for logs which can't print immediately 
- [ ] More in depth combat system, for now it just sucks.

## Optional but thinking about it

- [ ] Separate the different crafting with different NPCs, blacksmith, forgers and so on...
- [ ] Adding textures to items
- [ ] Type weaknesses of enemies and so on?
- [ ] Be able to throw fists with anyone
- [ ] Completely revamp command system, and instead use a more immersive tokenizing system
- [ ] Rethink the whole "guidance spirit" thing and switch to a full fledged narrator
- [ ] Quest system? 
- [ ] Unique items with unique logic
- [ ] Attribute system like minecraft

# Issues

## Log system and rooms
As of now, the game suffers a great flaw, entities and else are set to spawn on very specific constraints from the room. However, those room informations, 
appart from creating constraints serve absolutely no purpose. Not to mention that reading the same description for smell and size every time gets boring and annoying fast.

My solution is, ditch the "description" system, and rather use a room status system, where a room has multiple statuses like now, but each of those actually change an element of gameplay rather than just, there's a slime here or not.

This begs the question, do we really need this big log screen in the center? the entities in the room have been moved away from it, so have the available path. This log screen is now solely used for room descriptions - which will eventually be ditched - and conversations. What to do with it?

## Combat
as of now, the combat system is fundamentally flawed in that, it fucking sucks. Its just boring and its ugly. Adding more combat moves and sequences all building on one another could
add interesting mechanics. But as of now there is no real strategy appart from spamming the attack move. Also its very ugly.

## Others
[ ] Font is barely readable
[ ] THE UI IS UGLY!!
