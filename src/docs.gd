#! namespace GDPackageSpec class Docs
@tool
extends RefCounted
## Where a package's docs live. Authored under the export-ignore folder, packaged by the exporter
## into a dot-folder Godot never imports. Viewers check the packaged folder first, so a released
## plugin and its dev checkout both resolve.

const ExportIgnore = preload("uid://c4pt5djyuf8c") #! resolve GDPackageSpec.ExportIgnore

const PACKAGED_DIR = ".doc"
const SOURCE_SUB_DIR = "doc" # inside an export-ignore folder


## The first doc folder that exists in package_dir, packaged before source, or "".
static func dir_in(package_dir:String) -> String:
	var packaged = package_dir.path_join(PACKAGED_DIR)
	if DirAccess.dir_exists_absolute(packaged):
		return packaged
	return source_dir_in(package_dir)


## The source doc folder in package_dir, in ExportIgnore.NAMES order, or "".
static func source_dir_in(package_dir:String) -> String:
	for path in ExportIgnore.candidates(package_dir, [SOURCE_SUB_DIR]):
		if DirAccess.dir_exists_absolute(path):
			return path
	return ""
