extends Node

func rand_element(arr : Array):
	return arr[randi_range(0, len(arr)-1)]
