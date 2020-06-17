# Overview
Source for Sonic SatAM RPG, requires LÖVE v0.10.2

# Architecture
Custom framework built on Love2D's lua game engine, uses Tiled for level editing.

Primary concepts include:
- EventHandler:
  Base class for all things, allows you to add/remove dynamic event handling functions

- Scene:
  Manages logic on the scale of a game level/map
  
- SceneNode:
  An object within the scene that will be created/updated within the scope of that scene
  
- Action:
  A multi-frame behavior that can be composed together to declaratively describe behavior beyond the current moment
  
# Metadata Format
All game metadata (including playable characters, item definitions, map data, and saved games), are stored as lua scripts, which allow us to automatically inflate/deflate data and use lua script concepts like "idempotent file require" which allows us to efficiently dedupe data references by requiring lua data files in other lua data files.
