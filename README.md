# Alchemist's Path

A fantasy puzzle game where every spell is a real organic chemistry reaction. Transform magical materials into your target compound — learn retrosynthesis by playing, not memorizing.

Built with **Godot 4.3** and a fully **data-driven** puzzle engine.

## Quick Start

1. Install [Godot 4.3+](https://godotengine.org/download)
2. Open this folder in Godot (`project.godot`)
3. Press **F5** to run

## How to Play

- Compare **START → CURRENT → TARGET** molecules on the workbench
- Cast **spell scrolls** (reactions) to transform your material
- Earn up to **3 stars** for efficient moves, low cost, and green chemistry
- Complete Chapter 1 trials to earn guild gold

## Project Structure

```
data/                  JSON content (molecules, reactions, levels)
scripts/autoload/      Puzzle engine, save system, content DB
scripts/ui/            Screen controllers
scenes/                Godot scenes
assets/sprites/        Pixel art (generated via tools/generate_pixel_art.py)
tools/                 Content validator + art generator
```

## Architecture

| Layer | Responsibility |
|-------|----------------|
| `ContentDB` | Loads JSON molecule/reaction/level data |
| `PuzzleEngine` | Generic graph puzzle — legal moves, apply, undo, hints (BFS) |
| `GameState` | Progression, stars, currency |
| `SaveManager` | Local save to `user://alchemist_save.json` |

Chemistry is **not hardcoded in UI**. Reactions are edges in JSON; levels define start/goal/allowed spells.

## Regenerate Pixel Art

```bash
python3 tools/generate_pixel_art.py
```

## Validate Levels

Ensures every level is solvable and `par_moves` is achievable:

```bash
python3 tools/validate_content.py
```

## Chapter 1 Content

| Level | Transformation |
|-------|----------------|
| First Infusion | Alkene → alcohol (hydration) |
| Reverse the Flow | Alcohol → alkene (dehydration) |
| Life Bloom | Alkene → alkane (hydrogenation) |
| The Long Brew | Multi-spell routing |
| Dawnwheel Ritual | Cyclic hydration |
| Grand Apprentice Trial | Full cyclic hydrogenation |

## Roadmap

- [ ] RDKit integration for SMILES-based reactions
- [ ] Reaction preview (ghost product)
- [ ] Codex (fantasy ↔ real chemistry names)
- [ ] Chapters 2–8 (oxidation, SN2, aromatic, retrosynthesis)
- [ ] PixelLab-enhanced sprites

## License

MIT (add your license here)
