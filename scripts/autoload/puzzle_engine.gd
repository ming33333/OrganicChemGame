extends Node
## Generic graph puzzle engine. Chemistry is data — molecules are nodes, reactions are edges.

signal state_changed(state: Dictionary)
signal move_applied(result: Dictionary)
signal puzzle_solved(stars: Dictionary)
signal puzzle_failed(reason: String)

var current_level: Dictionary = {}
var state: Dictionary = {}
var undo_stack: Array = []


func load_level(level_id: String) -> bool:
	var level := ContentDB.get_level(level_id)
	if level.is_empty():
		push_error("[PuzzleEngine] Unknown level: %s" % level_id)
		return false
	current_level = level
	state = _snapshot_from_level(level)
	undo_stack.clear()
	state_changed.emit(state.duplicate(true))
	return true


func get_legal_moves() -> Array:
	var allowed: Array = _allowed_reactions()
	var moves: Array = []
	for reaction_id in allowed:
		var reaction: Dictionary = ContentDB.get_reaction(reaction_id)
		if reaction.is_empty():
			continue
		var from_id: String = state.current_molecule
		for edge in reaction.get("edges", []):
			if edge.get("from", "") == from_id:
				moves.append({
					"reaction_id": reaction_id,
					"from": from_id,
					"to": edge.get("to", ""),
					"fantasy_name": reaction.get("fantasy_name", reaction_id),
					"icon": reaction.get("icon", ""),
					"cost": int(reaction.get("cost", 0)),
					"yield": float(reaction.get("yield", 1.0)),
					"toxicity": float(reaction.get("toxicity", 0.0)),
				})
	return moves


func apply_move(reaction_id: String) -> Dictionary:
	var moves := get_legal_moves()
	var chosen: Dictionary = {}
	for move in moves:
		if move.reaction_id == reaction_id:
			chosen = move
			break
	if chosen.is_empty():
		return {"ok": false, "error": "Illegal move"}

	undo_stack.append(state.duplicate(true))
	state.move_count += 1
	state.total_cost += int(chosen.cost)
	state.total_toxicity += float(chosen.toxicity)
	state.yield_product *= float(chosen.yield)
	state.current_molecule = chosen.to
	state.history.append({
		"reaction_id": reaction_id,
		"from": chosen.from,
		"to": chosen.to,
	})

	var result := {
		"ok": true,
		"move": chosen,
		"solved": _check_goal(),
		"failed": _check_failed(),
	}
	move_applied.emit(result)
	state_changed.emit(state.duplicate(true))

	if result.solved:
		puzzle_solved.emit(score_puzzle())
	elif result.failed:
		puzzle_failed.emit("Out of moves")
	return result


func undo() -> bool:
	if undo_stack.is_empty():
		return false
	state = undo_stack.pop_back()
	state_changed.emit(state.duplicate(true))
	return true


func hint_shortest_path() -> Array:
	var start: String = state.current_molecule
	var goal: String = str(current_level.get("goal_molecule", ""))
	var allowed: Array = _allowed_reactions()
	return _bfs_path(start, goal, allowed)


func score_puzzle() -> Dictionary:
	var scoring: Dictionary = current_level.get("scoring", {})
	var par_moves: int = int(scoring.get("par_moves", 99))
	var par_cost: int = int(scoring.get("par_cost", 999))
	var par_toxicity: float = float(scoring.get("par_toxicity", 99.0))

	var stars := 0
	if state.move_count <= par_moves:
		stars += 1
	if state.total_cost <= par_cost:
		stars += 1
	if state.total_toxicity <= par_toxicity:
		stars += 1
	if undo_stack.is_empty() or state.history.size() <= par_moves:
		pass

	return {
		"stars": clampi(stars, 0, 3),
		"moves": state.move_count,
		"cost": state.total_cost,
		"toxicity": state.total_toxicity,
		"yield": state.yield_product,
		"par_moves": par_moves,
		"par_cost": par_cost,
		"par_toxicity": par_toxicity,
	}


func _snapshot_from_level(level: Dictionary) -> Dictionary:
	return {
		"level_id": level.id,
		"current_molecule": level.get("start_molecule", ""),
		"move_count": 0,
		"total_cost": 0,
		"total_toxicity": 0.0,
		"yield_product": 1.0,
		"history": [],
	}


func _allowed_reactions() -> Array:
	var allowed: Variant = current_level.get("allowed_reactions", [])
	if allowed is String and allowed == "all_unlocked":
		return ContentDB.reactions.keys()
	return allowed


func _check_goal() -> bool:
	return state.current_molecule == current_level.get("goal_molecule", "")


func _check_failed() -> bool:
	var max_moves: Variant = current_level.get("max_moves", null)
	if max_moves == null:
		return false
	return state.move_count >= int(max_moves) and not _check_goal()


func _bfs_path(start: String, goal: String, allowed: Array) -> Array:
	if start == goal:
		return []
	var queue: Array = [[start, []]]
	var visited: Dictionary = {start: true}
	while not queue.is_empty():
		var item: Array = queue.pop_front()
		var node: String = item[0]
		var path: Array = item[1]
		for reaction_id in allowed:
			var reaction: Dictionary = ContentDB.reactions.get(reaction_id, {})
			for edge in reaction.get("edges", []):
				if edge.get("from", "") != node:
					continue
				var next: String = edge.get("to", "")
				if visited.has(next):
					continue
				var new_path: Array = path.duplicate()
				new_path.append(reaction_id)
				if next == goal:
					return new_path
				visited[next] = true
				queue.append([next, new_path])
	return []
