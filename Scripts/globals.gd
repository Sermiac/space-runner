extends Node

enum GameState {
	MAIN_MENU,
	LOADING,
	PLAYING
}

var state : GameState = GameState.MAIN_MENU

var music = true
