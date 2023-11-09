"""
simple logger for godot 4
license: 0BSD
https://github.com/nshebang/simple-gd-logger
"""
class_name Logger

enum LEVELS { DEBUG, INFO, WARNING, ERROR, FATAL }
const _LEVELS_STR = ["debug", "info", "warning", "error", "fatal"]

const STRAT_MUTE = 0
const STRAT_FILE = 1
const STRAT_PRINT = 2
#const STRAT_BUFFER = 4 not implemented yet
const STRAT_FILE_AND_PRINT = STRAT_FILE | STRAT_PRINT

static var _log_format = "[{yyyy}-{mm}-{dd} {hh}:{ii}:{ss}] [{lvl}] [{cat}] {msg}"

static var _categories = {
	"default": {
		"level": LEVELS.DEBUG,
		"strat": STRAT_FILE_AND_PRINT,
		"logpath": "user://default.log",
	}
}
static var _current_category = "default"

#static var _buffers = {} not implemented yet


static func add_category(
	name,
	level = LEVELS.DEBUG,
	strat = STRAT_FILE_AND_PRINT,
	logpath = ""
):
	#if strat & STRAT_BUFFER:
	#	_buffers[name] = PackedStringArray()

	if logpath.dedent().is_empty():
		logpath = "user://%s.log" % [name]

	var new_category = {
		"level": level,
		"strat": strat,
		"logpath": logpath
	}

	_categories[name] = new_category


static func select_category(name):
	_current_category = name if _categories.has(name) else "default"


static func set_category_level(category, level):
	_categories[category]["level"] = level if \
		(level < LEVELS.FATAL) else LEVELS.DEBUG


static func set_category_strat(category, strat):
	# if strat & STRAT_BUFFER:
	#	_buffers[category] = PackedStringArray()

	_categories["default"]["strat"] = strat


static func set_category_logpath(category, logpath):
	_categories["default"]["logpath"] = logpath


static func set_default_level(level):
	set_category_level("default", level)


static func set_default_strat(strat):
	set_category_strat("default", strat)


static func set_default_logpath(logpath):
	set_category_logpath("default", logpath)


# Default is "[{yyyy}-{mm}-{dd} {hh}:{ii}:{ss}] [{lvl}] [{cat}] {msg}"
static func set_log_format(str: String):
	_log_format = str


static func debug(msg):
	_puts(LEVELS.DEBUG, msg)


static func info(msg):
	_puts(LEVELS.INFO, msg)


static func warn(msg):
	_puts(LEVELS.WARNING, msg)


static func error(msg):
	_puts(LEVELS.ERROR, msg)


static func fatal(msg):
	_puts(LEVELS.FATAL, msg)


static func _puts(level, msg):
	var strat = _categories[_current_category]["strat"]
	var cat_level = _categories[_current_category]["level"]

	if (strat == STRAT_MUTE or cat_level > level):
		return

	var output = _fmt_msg(level, msg)

	if strat & STRAT_PRINT:
		print(output)

	if strat & STRAT_FILE:
		var err = _append_to_file(output)
		if err != OK:
			var err_msg = "[error] [logger] Couldn't write to log file '%s'. Error code was %d"
			print(err_msg % [_categories[_current_category]["logpath"], err])


static func _get_open_mode(logpath) -> int:
	var fa = FileAccess
	return fa.READ_WRITE if fa.file_exists(logpath) else fa.WRITE


static func _validate_path(logpath) -> int:
	if not logpath.is_absolute_path() and not logpath.is_relative_path():
		return ERR_INVALID_PARAMETER
	var base_dir = logpath.get_base_dir()
	var dir = DirAccess.open(base_dir)
	if not dir:
		var err = dir.make_dir_recursive(base_dir)
		if err != OK:
			return err
	return OK


static func _append_to_file(msg) -> int:
	var logpath = _categories[_current_category]["logpath"]
	var open_mode = _get_open_mode(logpath)
	var err = OK

	err = _validate_path(logpath)
	if err != OK:
		return err

	var file = FileAccess.open(logpath, open_mode)
	err = file.get_open_error()
	if err != OK:
		return err

	file.seek_end()
	file.store_line(msg)
	file.close()

	return err


static func _fmt_msg(level, msg) -> String:
	var now = Time.get_unix_time_from_system()
	var datetime = Time.get_datetime_dict_from_unix_time(now)
	return _log_format.format({
		"yyyy": datetime.year,
		"mm": "%02d" % [datetime.month],
		"dd": "%02d" % [datetime.day],
		"hh": "%02d" % [datetime.hour],
		"ii": "%02d" % [datetime.minute],
		"ss": "%02d" % [datetime.second],
		"lvl": _LEVELS_STR[level],
		"cat": _current_category,
		"msg": msg
	})
