class_name PlatformerWallGrip
extends Node2D

const LoseGripDelay_Msec := 200

signal wall_gripped
signal wall_released

onready var _body := get_parent() as KinematicBody2D
onready var _controller := NodE.get_sibling(self, Controller) as Controller
onready var _velocity := NodE.get_sibling(self, Velocity) as Velocity
onready var _jump := NodE.get_sibling(self, PlatformerJump) as PlatformerJump
onready var _disabler := NodE.get_sibling(self, ComponentDisabler) as ComponentDisabler


