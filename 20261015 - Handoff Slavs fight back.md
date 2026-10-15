# VOLYA — HANDOFF v5 (story · names · levels · visual brief)

> **What this file is.** A single self-contained brief for a session that works on **controls, visuals and scene generation**. It compiles the current (v5) story, the v6 naming rules, the level layout and the visual set pieces — so scenes can be generated without reading the HTML dashboards.
>
> **Status: not yet canon.** The canonical files `SPEC_MASTER.md` and `STORY_BIBLE.md` are still the **pre-pivot** version (hero Vladan, bosses Omor/Med, 6 levels, slave stockade). They will be rewritten to v2 **after Pavel confirms the layout**. Treat this file as the current working truth, and §12 as the list of things still open.
>
> **Sources:** `VOLYA_pribeh_v5.html` (story), `VOLYA_mena_v6.html` (names), `VOLYA_akt2_jadro_v4.html` (Act 2 core, mechanic), `VOLYA_struktura_v3.html`, plus canon `SPEC_MASTER.md` / `STORY_BIBLE.md` for anything unchanged (controls, compliance, world rules).
>
> Date: 15 Oct 2026.

---

## 1. Project facts (unchanged from canon)

| Field | Value |
|---|---|
| Title | **VOLYA** (internal name, no subtitle) |
| Genre | 2D side-scrolling run-and-gun (Metal Slug style) + roguelite score-attack |
| Platform | Android (Google Play), single-player only, offline |
| Rating | PEGI 16 |
| In-game language | **ENGLISH** (all dialogue, UI, codex). Slovak only in design docs. |
| Art | Pixel art, side-scroller, distant perspective |
| Performance | `[HARD]` 60 fps on a ~150 € phone; object pooling from the start |
| Sessions | Short runs (2–4 min), replayable score-attack core |
| Release plan | **Act I ships FREE on mobile** (first episode), then the full game |

**Tone:** over-the-top action on a dark historical backdrop. Gallows humour comes from the world and the enemies — **never from the hero**. The hero is serious; absurdity comes from exaggerated enemies and situations.

---

## 2. `[HARD]` compliance rules — these travel with EVERY scene

Non-negotiable. They override any creative or visual choice.

1. **Enemies are defined only by political / military / economic role.** Never by ethnicity, nationality or religion. In practice: a guard is a *guard*, a recruiter is a *recruiter*. No visual coding that reads as a real ethnic or religious group.
2. **No real religious symbolism anywhere.** No crosses, crescents, calligraphy, runes resembling SS. **Fictional heraldry only** (§9 below).
3. **The player can never damage a non-combatant.** Civilians, prisoners and fleeing people have **no hitbox** for the player's attacks, projectiles or AoE. Enforced in code, not by level-design caution.
4. **Enemies may harm non-combatants — that is the stake, not a target.** Never close-up, never lingering, never gore-based. Impact is implied (fall / fade) at side-scroller distance. No slow motion, no lingering on a body.
5. **No dismemberment, no decapitation.** Enemies fall intact. Blood = pixel particles fading in ~2 s, no persistent pools.
6. **No interactive torture, no sadistic loops, no self-harm content.**
7. **No real-world contemporary political reference.** The game is 15th-century fiction. No modern flags, symbols, slogans, uniforms or insignia.
8. **Forbidden terms** never appear in any text, dialogue or metadata: ethnic group names used as enemies, religious/racial slurs, "great replacement", "invasion" (as ethnic framing), "remigration".
9. **Moral diversity is required:** at least one friendly/neutral NPC from the same broad region as the antagonists exists (we have several — Bohdan, Jaga).
10. **EDSA disclaimer** at first launch (unchanged, canon §9.4) — historical-fiction framing, no promotion of hatred toward any contemporary group.

---

## 3. Setting

**Fictional feudal Central Europe, ~1420–1480.** Not a real country, not a real war. Green forest and river valleys → wooden villages and palisades → the Council's road network and guard posts → the "house of clerks" in the capital.

**Two layers, and the second one is rarer than the first:**
- **History layer:** charcoal + iron (the economy the whole conflict is about), wood levies, grain tithes, debt, clerks, laws written by people who never visited.
- **Myth layer (`[HARD]`: brief, never explained):** one stag, one portal, one sorcerer. That is the entire budget. No magic children, no fantasy world, no sorcerer armies. Magic explains *why Vlad revives* and *why he is here* — and nothing else.

---

## 4. Controls & core mechanics (canon, `[HARD]`)

These come from `SPEC_ovladanie_implementacia.md` and **win over any level or scene idea that violates them.**

- Two thumbs. **Free 2-axis movement. NO gravity. NO jump.**
- Playing field = bottom of screen + 1.5 screen-heights up, vertical camera.
- **Lethal threats only arrive from the RIGHT** (the left thumb covers the left third).
- **Rage "VOLYA"** — fills by freeing prisoners; ~8 s screen-clear burst. Visual spec in §8.
- **Rift Step** — ground glyph ("Rift Mark") → instant relocation, **no airborne state, no physics, no new button**. Unlockable; gates only optional content.
- **Branching** — mid-level physical fork, both routes head right. Harder route = more to save + harder boss tier + more gold.
- **Equipment progression, not stats.** Gold buys gear at the merchant. Armor → more hearts. Weapons → melee / ranged / thrown-AoE, each with an elemental property (fire / lightning / ice).

**Core mechanic — "ZÁCHRANA" (Rescue), one mechanic, three faces.** Enemies take or destroy something; you interrupt it; **how much you saved = the reward.** Only the *subject* changes per act:

| Act | You save | The "cage" is | Emotion |
|---|---|---|---|
| I | **People** — captives being marched south | Cage / cart / column | Saving lives |
| II | **Livelihood** — firewood, grain, tools seized by the Council | Levy post, barn, timber cart | Saving the village before winter |
| III | **Truth and the accused** — registers, lists, arrested people | Archive, files, lockup | Saving the truth and the people in it |

**Why this matters visually:** the cage asset changes per act, the **mechanic does not**. One code path, three art sets.

**Roguelite:** a run = one expedition out of the village. Death = return to the village, **what you saved is kept**. Two progression layers: **gold** (spent on gear) and **the village itself** (permanent — wood literally builds houses, grain keeps people, tools open the smithy). The village is the meta-progression, and it visibly changes.

---

## 5. Cast (v6 names — use the "in-game" column in ALL game text)

Pavel's naming rule: **Slavic names an English speaker reads correctly on the first try**, and a Slav still recognizes them as Slavic.
Five tests: **no diacritics (ASCII in-game) · max 3 syllables · no initial consonant clusters (Mst-, Vlk-, Krk-) · stress must survive being pulled to the first syllable · recognizable Slavic root.**
**Rule of the project: short ASCII name in-game, full Slavic name + meaning in the Codex.**

| In-game | Full name (Codex) | Role | What they want |
|---|---|---|---|
| **Vlad** | **Vladan**, called the Storm | Hero. Appears from nowhere in L1; doesn't know who he is. | **Does not want to lead.** Wants people to live — and doesn't know why it matters so much to him. Was sent to protect Zora (he learns this in the epilogue). |
| **Zora** | **Zorica** | First character in the game. Dragged behind the village in L1; Vlad intervenes. Later the law-reader. | **Wants to know how the whole thing works.** Resists by reading, not by force. **Has a power she doesn't know about** (§7). |
| **Dobrava** | Dobrava | Widow with children from L1. Doesn't get rescued — **she rescues herself** by shielding her children. | Her children live. Nothing else. The only character who never wants anything from Vlad. |
| **Vojtek** | Vojtěch ("joy of the warriors") | **Dobrava's son.** Sees Zora fighting in L1 and is lost. | Wants to be someone Zora notices. **That's why he enlists.** Dies in L7 refusing an order → **this is the finale trigger.** |
| **Jarek** | Jaroslav ("fierce, strong") | Village chief of Hradisko; hides in the cellar in L1; Vlad eclipses him. **Boss L4.** | **To finally be someone.** Vlad took his village, the Council gave him power. Not a villain — a neighbour eaten by envy. |
| **Radim** | Radim ("glad, joyful") | Chief who betrays the council of chiefs in L2 and brings Ordan's force. **Boss L2.** | **Fear.** Ordan promised to spare his village. He never tells his own people. *"I only wanted my village to survive."* |
| **Kamen** | (nickname, "stone") | The brute of L4. A man his own village never listened to. | **To vent.** Power gave him what his village denied him. Ties by name to the Stone Council. |
| **Prokop** | Prokop | The Council's clerk. Not a fighter — an official. | **Sincerely believes he is saving the country from chaos.** The most dangerous kind of evil. |
| **Bor** | (from *bor* = pine wood) | The Council's forester who "owns" the wood. **Boss L5.** | Planted that forest his whole life; someone renamed it property. **Broken, not evil.** |
| **Milo** | Miloš ("dear, kind") | The recruiter who walks the villages and talks neighbours into signing up. **Boss L6.** | **He organizes.** Warm, convincing, gives people work. Doesn't fight you directly. |
| **Miran** | Miran ("peace / world") | The boy Vlad pulls out of a cage in L1 — who then stays with him. **Ordan's son. Boss L7.** | **Patience.** Waited through all of Act I and II. Commands the guard, wears the Act I uniform. |
| **Ordan** | Ordan | Raid commander from the south. Retreats in Act I — not defeated. | **Wants the land.** Political, no magic. That makes him understandable — and dangerous. Returns in the epilogue. |
| **Teodor** | Teodor | Master of the clerks. Built the whole Council machine. **Boss L9, the only one with magic.** | Serves someone who wants to subjugate the land. Takes orders through an orb ("palantír", never explicit). |
| **Bohdan** | Bohumil / Bohuslav (Codex) | Merchant from L1, runs the shop in the hub. | **To get rich.** Got rich off the war and it shows. Comments on everything, cynically but not cruelly. |
| **Jaga** | Jaga | Herbalist in the hub. | To heal. First to notice Vlad heals strangely fast. Speaks in riddles, explains nothing. |
| **The Stone Council** | — | Not a character — **a machine**: clerks, judges, tax collectors, recruiters. | **Has no face and no plan that makes sense in the end.** Every one of its people has his own small reason. That's why it can't be killed. |

**Names deliberately rejected** (so nobody re-proposes them): *Miro* (collides with Miran) · *Zoran* (collides with Zora) · *Radek* (third "Rad-") · *Bohuš* (reads as "bogus") · *Vlk, Krk, Zby, Mstislav* (unpronounceable for English speakers).

**Note on Vlad:** the Codex full name **Vladan** is already the canonical hero name from the pre-pivot spec — so "Vlad" in-game / "Vladan" in the Codex fits both the naming rule and existing canon.

---

## 6. Structure — 9 levels + epilogue, 3 acts

### ACT I — THE UNKNOWN (3 levels) · ships free
**Enemy: Ordan's raiders.** Simple, clear evil — no politics, pure reason to massacre hordes.
**Arc:** Vlad appears from nowhere, sees injustice, intervenes. In three levels a nobody becomes the man the villages trust.
**The sting:** he **wins the battle and accidentally creates a power vacuum.** Nobody sits on the throne; the villages have no lord. Into that emptiness, in Act II, walks the Stone Council.

| ID | Name | Environment / mood | What happens | Boss |
|---|---|---|---|---|
| **L1** | **The Burning Village** | Night raid, fire, smoke, orange on black. Village of Hradisko. | Raiders burn the village and drag people away. Vlad appears from nothing — **the first thing he sees is a girl being dragged behind the village.** He intervenes before he can ask who he is. | Raid Captain |
| **L2** | **The Council of Chiefs** | A wooden hall, banners, then a battlefield at dusk. | The chiefs meet and agree on nothing. **Radim betrays them and brings Ordan's force.** Vlad's first **RAGE** — a short, brutal massacre. He earns respect and, with it, distance: from now on they fear him a little. | Radim |
| **L3** | **The Joined Villages** | River valley, marching column, morning. | Vlad leads the joined villages and hits Ordan's camp to get the taken people back. **Ordan withdraws south — not defeated.** The chiefs offer Vlad the seat of a chief. **He refuses.** | Ordan's Commander |

**End-of-act card:** *"Ordan pulled back south. The villages were free. Nobody noticed that an empty seat always gets filled — the only question is by whom."*

### ACT II — THE LAW (3 levels)
**Enemy: your own villagers**, enforcing the Council's law.
**Arc:** nobody came with a sword. **The clerks came.** First "just to write things down". Then rules. Then rules that apply directly to everyone. Then fees. Then a common debt you didn't incur but must guarantee. The Council has **no face** — it's a machine of clerks and neighbours. Most militia men enforce it reluctantly, eyes averted. But there is always one who enjoys it. **Vlad fights his own.**

**The slow erosion lives in the HUB, not in the levels.** Between levels you return to the village and see what the Council took while you were away. **A level is always the *consequence*; the village is the erosion itself.**

| Hub visit | What the Council does | What it triggers in people | Rescue / gold |
|---|---|---|---|
| **After L3** | Clerks arrive — "just to write things down". The first notice board appears on the gate. | Curiosity and mockery. **Nobody reads it, nobody is afraid.** Jaga: *"Writing is like fire. First it gives light."* | Nothing (soft intro). Gold only from the run. |
| **After L4** | Judges. Rules now apply **directly to every person**. An outsider decides. | A neighbour is summoned over a dispute about the mill — and a stranger rules. **The first injustice that lands on one concrete person.** People start counting who did well out of it. | Grain and tools seized during enforcement. Gold + the first permanent village upgrade (winter stores). |
| **After L5** | A wood levy. A fee for timber. **The forest belongs to the Council**, including what grew behind the village. | **Winter.** This is the break — people aren't fighting for pride any more, they're fighting for warmth. A widow's firewood is seized before winter. The first time it can't be heated. **Anger turns against the Council for the first time, not against Vlad.** | Firewood, charcoal, logs. The strongest meta-progression — **wood literally builds houses in the hub.** |
| **After L6** | A common penny and a common debt. The village guarantees other villages' debts — and the recruiting starts. | **Rifts inside the village.** Some want to pay and be left alone, others refuse to pay for someone else's debt — neighbours argue with each other. And young men enlist because it's **steady coin**. Among them Dobrava's son. | Registers and the arrested — for the first time you rescue truth, not things. Gold + new hub buildings unlock. |

| ID | Name | Environment / mood | What happens | Boss |
|---|---|---|---|---|
| **L4** | **The Notice Board** | A village square in grey daylight; a gallows; a new wooden board with unreadable script. | The law is enforced by **each village's own militia** — your neighbours. **Kamen**, a man his own village never listened to, now *can*. He hangs a man in front of the village over a debt. Vlad is there. | **Jarek** |
| **L5** | **The Forest** (NEW, perception level) | Deep forest, mist, low sun through trunks, warm greens and browns against cold grey. Charcoal kiln smoke. | The wood levy means the village can't heat itself. Vlad goes into the hills with woodsmen for timber — **and someone has set traps.** Nobody knows who. Sophisticated, military, made by someone who knows this forest better than the locals. (Ordan's people — **never shown**, only traces: a frayed rope, a foreign bootprint, a still-warm fire.) | **Bor** |
| **L6** | **The Break** | Council archive and levy post, then a village square where a crowd is being signed up. | Vlad undercuts the Council: frees the detained, burns the levy archive. The Council is short of loyal soldiers — so it **starts recruiting**. For coin. And men volunteer who are **far too eager** — strangers nobody has ever seen plough. | **Milo** |

**Six wooden traps for L5** (all timber, readable at a glance, treacherous at speed):
rolling log (from a slope — dodge up/down, uses the 2-axis movement) · falling deadfall (bound trees tip over — a zone you must not enter) · leaf pit (hidden stakes, visible only by how the leaves sag) · chain hook (a log on a rope between trees) · log sluice (timber rolling down a stream — rhythm and timing) · charcoal kiln (a burning mound — area fire, walk around; and it reminds you what the whole dispute is about).

**Mid-level magic beat:** in the silence between traps, **a stag flickers past** — and is gone. No line, no explanation, no reaction barks. Vlad stops for a second and walks on. That is all the magic in Act II.

### ACT III — THE UNVEILING (3 levels + epilogue)
**Enemy: a mixed guard** — conscripted villagers + the sworn.
**Arc:** the Council is no longer clerks, it has a **guard**. Half are conscripted villagers, doing it for coin with their eyes down. Half are **sworn**: men who volunteered, with one extra mark, who enforce the law not for coin but because they live in the enemy. **Miran commands them.**
**And Zora starts reading.** That's the whole point of Act III — not the sword, the notebook. She finds names of commanders who exist in no village. Men who are on paper but not in the country. She starts asking — and that ends everything.

| ID | Name | Environment / mood | What happens | Boss |
|---|---|---|---|---|
| **L7** | **The Guard** | A guard post / barracks yard at dawn; grey uniforms, mud, a row of posts. | Vlad goes for Vojtek — the boy from L1 is in the guard now, in a unit where the sworn command the conscripted. Vojtek **refuses an order** and **the sworn kill him in front of Vlad.** Then Miran steps up. | **MIRAN** |
| **L8** | *open — "The Return" recommended* | The L1 village again, now under the Council. Same asset set, new state: a notice board on the gate where a house used to burn. | A mirror of the game's opening. **Cheapest and most emotional option** (asset reuse). Alternatives: a Council checkpoint / the guard barracks. | — |
| **L9** | **The Master of Clerks** | Interior: archive hall, candlelight, paper, then magic. | The final boss and a **pace change**: after a mass shooter, one man with magic. Teodor isn't a councillor — he **built the machine**, and takes orders from somewhere else. Zora reveals who the Council serves — **and the portal takes her at that moment**, not Ordan. | **TEODOR** (magic) |

### EPILOGUE — playable, the village
Playable, not a cutscene. You walk the ruined village and see what happened to the people you saved. Nobody welcomes a hero.
**Then the stag comes** — and for the first time it doesn't vanish. It tells Vlad (the only line an animal has in the whole game) that **he failed in his main goal** — but he gets another chance. Vlad doesn't understand. **The player does.** The whole game re-reads in that moment: he wasn't sent to save the villages, he was sent to protect **her** — the villages were just the road he took.

---

## 7. Zora — the full arc (visual + narrative)

**Her power (proposed): she reads what someone tried to erase.** She looks at a ledger and sees the struck-through, scraped-out, overwritten names. **Her ordinary role — law-reader — IS her magic**, toned down, invisible, with no VFX.
Why it works: (1) it explains why the Council wants her — she is evidence you cannot burn; (2) it explains why Vlad was sent — to protect the one who will reveal the truth; (3) it's original, not another glowing chosen one; (4) it keeps our rule "magic brief, unexplained".

**How it plays:** in the hub you can have a document **read to you** — the game shows the crossed-out names. Cheap (text + one filter) and it's a **mechanic, not a cutscene**: the more registers you save, the more Zora reads. **Rescue in Act III directly unlocks story.**

**Her path:** L1 dragged and defiant (she bites, she kicks) → Act I she learns writing is power, from the clerks themselves → Act II she keeps her own notebook (who seized what, from whom, when — the first record not in the Council's hands; **this is where the player falls for her, because she does what the player does: assembles the picture**) → L5 she hears "someone foreign in the forest" and writes it down → **L7 she exposes Miran** → **L9 she reads the names aloud, and the portal takes her in that moment** → epilogue: the stag tells Vlad he failed — not because he was slow, but because **she was faster than him**.

**The guardrail (important, so she isn't a plot device):** the abduction must happen **because Zora did something**, not because she was standing there. She reads the names aloud, in front of the Council and the people — and the portal takes her *then*. That way she is taken as the one who said it out loud, not as a helpless prize. And Vlad didn't fail by being slow; he failed because she got there first.

**Ending split (Pavel's decision):** **Ordan wants the land** (political antagonist → DLC / part 2), **the master wants Zora** (the portal). Two threats, two directions for the continuation.

---

## 8. Visual set pieces (scene-generation reference)

### 8.1 Rage "VOLYA" — wind, white eyes, lightning
**That is the order they appear in, and the order matters for readability on a phone.**
1. **Wind** — dust, leaves, and Vlad's cloak tearing *away from him*. For the first couple of seconds this is all there is. **Sound is muffled** — wind swallows noise, so silence is usable.
2. **Eyes** — they go **white (no pupils)**. One frame. The strongest and cheapest effect in the game.
3. **Lightning** — short arcs **between him and the ground / the enemies' metal weapons**. Not from the sky — **from him.**

**Why wind beats fire:** fire is just bigger damage. **Wind can do something mechanically** — deflect projectiles, push enemies back, scatter a crowd. That's a different game for eight seconds, which is exactly what L2 needs. And fire and coal already have their place (the charcoal kiln) — don't flood the whole game with it.
**So it doesn't feel cheap:** during rage Vlad **hears no barks** — not his own, not the enemies'. Only wind. And villagers **pull back** when he returns to the hub. **The price of earning it is fear.**

**Mythology note (Pavel asked):** **Perun is the god of thunder and lightning** — his weapons are the axe and "Perun's arrow" (the bolt), his tree is the oak, his day is Thursday. **Fire belongs to Svarog, wind to Stribog.** So **bolt + storm wind = Perun**: authentically Slavic, no need to import Odin or Thor (though the feel is similar, both descend from the same Indo-European storm god).

### 8.2 The stag
Majestic, golden-antlered, **never explained, never speaks except once (epilogue)**. Appears: L1 (glimpsed at the moment Vlad rises after dying), L5 (a flicker in the forest silence), epilogue (stands still and delivers the only animal line in the game). Treat it as a **silent witness**, not a mascot — it never helps in combat.

### 8.3 Teodor's magic (L9 only)
One sorcerer, one orb. Magic reads as **displacement and force**, not fireballs: the orb on a chain, space folding, objects moved without touching. Orders arrive through the orb — a light in it, a voice never heard. **Never show the master.**

### 8.4 The portal (L9 finale)
Zora reads the names aloud — **and the air behind her opens.** Cold light, no gore, no scream-hold: the abduction is one clean beat, framed at side-scroller distance. Vlad's reach arrives a frame late. **No lingering, no slow motion.**

### 8.5 The guard marker — "sworn vs conscripted"
**Not decided, leaning to a hint rather than a uniform.** Current favourite: **a scarf** — an ordinary dark cloth scarf, **tied the same knot on the shoulder**. Readable at silhouette scale, recolourable, cheap; a way of tying rather than a symbol.
Alternatives on the table: a small bronze pin · a knotted cord on the shoulder · a plain black leather strap across the chest.
**How it reads in play (applies to any option):** **conscripted** (villagers) — sloppy kit, no mark, *hesitant animations, averted gaze, weapon drops when aiming at Vlad*. **Sworn** (Ordan's men) — same clothing **plus the mark**, confident stance, uncompromising.
**`[HARD]`:** the mark must stay **invented and political**, never ethnic or religious. (Pavel's earlier idea of "something Arabic" was dropped for this reason — it would break §2 rule 1 and weaken the theme.)

---

## 9. Heraldry (existing canon, still valid)

| Faction | Symbol |
|---|---|
| The Empire (general) | Iron collar in a circle |
| Iron Guard | Crossed swords over a collar |
| Merchant League | Scales with a coin |
| The Stockade | A barred gate |
| Rift Mark (traversal glyph) | A broken chain-link spiral (fictional, nature-geometric) |

**The Stone Council needs a mark for v2** — proposal: a **stone block with a vertical chisel line** (or a stack of three stones, one slightly crooked). Fictional, geometric, no resemblance to any real symbol.

---

## 10. Scene pack v1 — the first scenes to generate

Suggested first batch (10), chosen because they define the visual language. Each: id · level · contents · must-not-appear.

| ID | Level | Scene contents | Must NOT appear |
|---|---|---|---|
| `S01_village_burning` | L1 | Night. A wood-and-thatch village burning, orange light on black smoke, carts, captives being pulled. Foreground: a girl (Zora) dragged by two men, resisting. Vlad entering frame right. | Any religious building/symbol; gore; close-up on a captive's face |
| `S02_first_cage` | L1 | A cart-cage of prisoners, slats and rope, hands through the bars. The "cage" of Act I — the reference asset for all three act variants. | Real-world shackle designs (fictional iron collar instead); gore |
| `S03_rage_wind` | L2 | **Rage key art.** Vlad centre, cloak and dust tearing outward, eyes white, arcs of lightning between his hands and the ground. Around him, enemies being scattered. | Sky-sourced lightning; fire as the main read |
| `S04_chiefs_hall_betrayal` | L2 | Interior, wooden hall, long table, banners (fictional heraldry). Radim at the door, Ordan's soldiers behind. Warm interior light vs cold outside. | Real flags/insignia |
| `S05_notice_board` | L4 | Village square, grey daylight, gallows frame, a new wooden board with dense script nobody can read. Militia men in mismatched kit, eyes averted. | Uniforms that read as a real 20th-century force |
| `S06_forest_traps` | L5 | Forest interior, mist and low sun. In the foreground a **rolling log** mid-slope and a **leaf pit** sagging; background a **charcoal kiln** smoking. Woodsmen with hand-carts. | Modern logging equipment; ethnic coding on the unseen trappers |
| `S07_stag_flicker` | L5 | The silence beat. A stag with golden antlers between trunks, half-lit — the composition should read as "it was there and then wasn't". | Visible magic effects, glow, sparkles |
| `S08_guard_yard` | L7 | Barracks yard at dawn. Two rows of guards: conscripted villagers (sloppy, averted eyes) and the sworn (same kit + shoulder scarf), Miran at the front in the Act I uniform. | Ethnic or religious marking of any kind |
| `S09_portal_takes_zora` | L9 | Archive hall. Zora mid-sentence, holding a register; behind her the air opening in cold light. Vlad's hand reaching, a frame late. | Gore, lingering, slow motion |
| `S10_epilogue_stag` | Epilogue | Ruined village at dusk, ash and broken palisade. The stag standing still, facing Vlad. The village behind is intact in one panel and ruined in the other (the mirror). | Any explicit magical explanation |

---

## 11. What NOT to change in these scenes

- **Do not add magic** to Act II scenes other than the stag flicker. Act II's power is that it has none.
- **Do not make the Council visually exotic.** Its whole horror is that it looks like *your own village* — wooden, familiar, slightly cleaner.
- **Do not design the Council as a villain lair.** Clerks, paper, a wooden desk. That's the point.
- **Do not give the raiders (Act I) any real-world ethnic markers** — they are defined by role only (§2).
- **Keep the hero serious.** No quips, no victory poses. The world is absurd; he is not.

---

## 12. Still open (do NOT treat as final)

1. **Zora's power** — is the "reads what was erased" version confirmed?
2. **Vojtek's name** — Vojtek, or Marek / Janko?
3. **L5 boss** — Bor (recommended), or a bear / Jarek's lieutenant?
4. **L6 boss** — Milo the recruiter (recommended), or the executioner / Ordan's disguised captain?
5. **L8** — "The Return" (recommended), checkpoint, or guard barracks?
6. **Names Jarek / Radim** — working, or replace?
7. **Scope** — 9 levels + epilogue (current), or a leaner 7–8 level version?
8. **The guard marker** — scarf (leaning), pin, cord, or strap?
9. **Core game + roguelite** — Pavel is still considering the final form.
10. **Canon rewrite** — `SPEC_MASTER.md` and `STORY_BIBLE.md` are **still the pre-pivot version** and will be rewritten to v2 once the layout and Zora are confirmed. Until then, **this file is the working truth for story/levels/visuals**; controls, compliance and world rules should still be read from `SPEC_MASTER.md` (§2, §4, §7, §9).
