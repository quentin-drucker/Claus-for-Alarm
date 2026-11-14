class_name EconomyLedger
extends RefCounted
## Every cash change goes through here (master plan §6.5). Cash can never go negative.

var cash: int = 0
## {tick, amount, reason, source_id, balance}; newest last.
var transactions: Array[Dictionary] = []


func _init(start_cash: int) -> void:
	_record(0, start_cash, &"start_cash", 0)


## Returns false (and changes nothing) if `amount` is not affordable.
func spend(tick: int, amount: int, reason: StringName, source_id: int) -> bool:
	if amount < 0 or amount > cash:
		return false
	_record(tick, -amount, reason, source_id)
	return true


func credit(tick: int, amount: int, reason: StringName, source_id: int) -> void:
	assert(amount >= 0, "credit must be positive")
	_record(tick, amount, reason, source_id)


func _record(tick: int, amount: int, reason: StringName, source_id: int) -> void:
	cash += amount
	transactions.append({"tick": tick, "amount": amount, "reason": reason, "source_id": source_id, "balance": cash})
