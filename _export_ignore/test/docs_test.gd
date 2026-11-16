@tool
extends EditorScript

## Tests for the doc folder lookup: packaged `.doc` beats the source folder, and the source folder
## follows ExportIgnore's spelling preference.
##
##     load("res://addons/_lib/gdpackage/spec/_export_ignore/test/docs_test.gd").run_tests()

const Docs = preload("uid://01wqb0kamr3o") #! resolve GDPackageSpec.Docs

const DIR = "user://gdpackage_spec_docs_tests"

static var _failures:Array[String] = []
static var _passed:int = 0


static func run_tests() -> Dictionary:
	_failures = []
	_passed = 0
	var root = ProjectSettings.globalize_path(DIR)
	_remove_dir(root)

	_test_lookup(root)

	_remove_dir(root)
	var output:Array[String] = []
	output.append("docs: %d passed, %d failed" % [_passed, _failures.size()])
	for failure in _failures:
		output.append("  FAIL  " + failure)
	return {"result": _failures.size(), "output": output}


func _run() -> void: # EditorScript entry, for running this from the editor
	print("\n".join(run_tests().output))


static func _test_lookup(root:String) -> void:
	var pkg = root.path_join("pkg")
	DirAccess.make_dir_recursive_absolute(pkg)
	_check("none: empty", Docs.dir_in(pkg), "")
	_check("none: no source", Docs.source_dir_in(pkg), "")

	DirAccess.make_dir_recursive_absolute(pkg.path_join("export_ignore/doc"))
	_check("old spelling found", Docs.dir_in(pkg), pkg.path_join("export_ignore/doc"))

	DirAccess.make_dir_recursive_absolute(pkg.path_join("_export_ignore/doc"))
	_check("new spelling wins", Docs.source_dir_in(pkg), pkg.path_join("_export_ignore/doc"))

	DirAccess.make_dir_recursive_absolute(pkg.path_join(".doc"))
	_check("packaged wins", Docs.dir_in(pkg), pkg.path_join(".doc"))
	_check("source ignores packaged", Docs.source_dir_in(pkg), pkg.path_join("_export_ignore/doc"))


static func _check(label:String, got, expected) -> void:
	if got == expected:
		_passed += 1
		return
	_failures.append("%s (expected %s, got %s)" % [label, expected, got])


static func _remove_dir(path:String) -> void:
	var dir = DirAccess.open(path)
	if dir == null:
		return
	dir.include_hidden = true
	for f in dir.get_files():
		DirAccess.remove_absolute(path.path_join(f))
	for d in dir.get_directories():
		_remove_dir(path.path_join(d))
	DirAccess.remove_absolute(path)
