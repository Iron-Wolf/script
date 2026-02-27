# Installation
- modpack : https://www.curseforge.com/minecraft/modpacks/cobblemon-academy
  - Take the "server" modpack : **Cobblemon Academy Server Files 1.4.1.zip**
  - it come bundled with the corect fabric server jar file
- Work with Java 21 : https://adoptium.net/fr/temurin/releases
  - Take the LTS version
- just start the fabric jar with the JDK


# Links
- general infos on pokemon : https://www.cobbledex.info/fr


# Configuration
## Minecraft
- add OP player : `/op <player>`

## Lootr
- reset chest content : `/lootr clear <player>`

### chest loot config
- files : `~/cobblemon-academy-legacy-1.4.1/datapacks/Academy/data/academy/loot_table`
  - modify the "tier" config file, in thoses directories : basic, basic_gym, basic_meteor, basic_underground

## Cobblemon
### Spawn rule
One shot rule (one pokemon at a time) :
  - wiki : https://wiki.cobblemon.com/index.php/Tutorials/Creating_Custom_Spawns
  - Gitlab : https://gitlab.com/cable-mc/cobblemon/-/tree/main/common/src/main/resources/data/cobblemon/spawn_pool_world
  - files : `~/cobblemon-academy-legacy-1.4.1/datapacks/Academy/data/cobblemon/spawn_pool_world/`
<details>
  <summary>📝 test.json</summary>
  
```json  
{
  "enabled": false, <- not working !
  "neededInstalledMods": [],
  "neededUninstalledMods": [],
  "spawns": [
    {
      "id": "arceus-1",
      "pokemon": "arceus",
      "presets": [
        "natural"
      ],
      "type": "pokemon",
      "context": "grounded",
      "bucket": "common",
      "level": "50-60",
      "weight": 999.0,
      "condition": {}
    }
  ]
}
```
</details>

Globa rules (mass modification) :
  - wiki : https://wiki.cobblemon.com/index.php/Spawn_Rules
  - Gitlab : https://gitlab.com/cable-mc/cobblemon/-/tree/main/common/src/main/resources/data/cobblemon/spawn_rules
  - files : `~/cobblemon-academy-legacy-1.4.1/datapacks/Academy/data/cobblemon/spawn_rules/`
    - use the modified [MoLang](https://wiki.cobblemon.com/index.php/Molang) functions, to filter pokemon
    - Kotlin [source](https://gitlab.com/cable-mc/cobblemon/-/tree/main/common/src/main/kotlin/com/cobblemon/mod/common/api/spawning/rules/component) for the authorized fields, in each component
<details>
  <summary>📝 test.json</summary>
  
```json  
{
  "displayName": "Test",
  "enabled": "true",
  "components": [ 
    {
      "type": "weight",
      "spawnSelector": "v.spawn.pokemon.species.name == 'pidgey'",
      "contextSelector": "v.context.biome.is_in('#cobblemon:is_overworld')",
      "weight": "v.weight * 10000"
    },
    {
      "type": "weight",
      "spawnSelector": "v.spawn.pokemon.species.name == 'pikachu'", <- watch out with the bucket of the pokemon !
      "contextSelector": "v.context.biome.is_in('#cobblemon:is_overworld')",
      "weight": "v.weight * 10000"
    }
  ]
}
```
</details>

### Item drop
- wiki : https://wiki.cobblemon.com/index.php/Pok%C3%A9mon/Drops
- gitlab : https://gitlab.com/cable-mc/cobblemon/-/tree/main/common/src/main/resources/data/cobblemon/species
- files : `~/cobblemon-academy-legacy-1.4.1/datapacks/Academy/data/cobblemon/species/`

### Main conf
- wiki : https://wiki.cobblemon.com/index.php/Config
- files : `~/cobblemon-academy-legacy-1.4.1/config/cobblemon/main.json`

### NPC conf
- files : `~/cobblemon-academy-legacy-1.4.1/config/academy/npc.json`
  - configure Safari cost


