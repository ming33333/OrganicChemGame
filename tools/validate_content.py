#!/usr/bin/env python3
"""Validate level solvability and content integrity."""

import json
from collections import deque
from pathlib import Path

ROOT = Path(__file__).parent.parent
DATA = ROOT / "data"


def load_json(path: Path):
    return json.loads(path.read_text())


def build_graph(reactions):
    edges = {}
    for r in reactions:
        for e in r.get("edges", []):
            edges.setdefault(e["from"], []).append((e["to"], r["id"]))
    return edges


def bfs(start, goal, allowed, graph):
    if start == goal:
        return True, 0
    q = deque([(start, 0)])
    seen = {start}
    while q:
        node, depth = q.popleft()
        for nxt, rxn in graph.get(node, []):
            if rxn not in allowed:
                continue
            if nxt in seen:
                continue
            if nxt == goal:
                return True, depth + 1
            seen.add(nxt)
            q.append((nxt, depth + 1))
    return False, -1


def main():
    molecules = {m["id"]: m for m in load_json(DATA / "molecules.json")}
    reactions = {r["id"]: r for r in load_json(DATA / "reactions.json")}
    graph = build_graph(load_json(DATA / "reactions.json"))

    errors = []
    for chapter in load_json(DATA / "chapters.json"):
        levels = load_json(Path(chapter["levels_file"].replace("res://", "")))
        for level in levels:
            lid = level["id"]
            start = level["start_molecule"]
            goal = level["goal_molecule"]
            allowed = level["allowed_reactions"]

            if start not in molecules:
                errors.append(f"{lid}: unknown start molecule '{start}'")
            if goal not in molecules:
                errors.append(f"{lid}: unknown goal molecule '{goal}'")
            for rxn in allowed:
                if rxn not in reactions:
                    errors.append(f"{lid}: unknown reaction '{rxn}'")

            ok, depth = bfs(start, goal, allowed, graph)
            if not ok:
                errors.append(f"{lid}: NO PATH from {start} to {goal}")
            else:
                par = level.get("scoring", {}).get("par_moves", 99)
                if depth > par:
                    errors.append(
                        f"{lid}: par_moves={par} but shortest path={depth}"
                    )
                print(f"  OK {lid}: {start} -> {goal} in {depth} move(s)")

    if errors:
        print("\nERRORS:")
        for e in errors:
            print(f"  - {e}")
        raise SystemExit(1)
    print("\nAll levels valid!")


if __name__ == "__main__":
    print("Validating content...")
    main()
