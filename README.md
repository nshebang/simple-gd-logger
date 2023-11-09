# simple logger for godot 4
Another logger singleton for Godot 4, but simple to use, modify and
understand. I know there are some logging singletons out there, but they
are too bloated for my needs so I made this one that's simpler and
lightweight yet featureful.

## How to use
Just put the `logger.gd` file somewhere in your Godot project and it'll be
basically ready to be used (the Logger class is static and can be access
from any GDScript file)

### Usage

```
Logger.debug("debug msg")
Logger.info("some info")
Logger.warn("some warning")
Logger.error("an error occurred!")
Logger.fatal("FATAL error!")
```

### "Advanced" usage 
The logger uses _categories_ to handle different types of logs. Each
category has a logging level, a logging strategy ("strat") and
a log file path.

The level tells the Logger which logs are relevant and which are not.
The default hierarchy order is DEBUG < INFO < WARN < ERROR < FATAL

The strategy tells the Logger how it should handle new logs. By default
they are both printed to the stdout and stored in a file.

And the log file path is a valid path to which you want to dump the logs,
in case `STRAT_FILE` is enabled.

In simple cases, you may just need one category to log everything. And by 
default, there is already one category added and ready to be used (named
"default"). The default settings for this category are:

```
level: Logger.LEVELS.DEBUG
strat: Logger.STRAT_FILE_AND_PRINT
logpath: "user://default.log"
```

### How to change category settings

The following functions are used to change category settings:

* `set_category_level`
* `set_category_strat`
* `set_category_logpath`
* `set_default_level`, which is a shortcut for
`set_category_level("default", level)`
* `set_default_strat`, which is a shortcut for
`set_default_level("default", strat)`
* `set_default_logpath`, which is a shortcut for
`set_category_logpath("default", logpath)`

#### Valid levels:
```
Logger.LEVEL.*
```

#### Valid strats:

Strats are defined as a bitmask.

```
Logger.STRAT_MUTE - logs nothing
Logger.STRAT_PRINT - prints logs to the stdout
Logger.STRAT_FILE - prints logs to a log file
Logger.STRAT_FILE_AND_PRINT - same as Logger.STRAT_FILE | Logger.STRAT_PRINT
```

### How to select a different category
You need to call `Logger.select_category()` to select another existing
category. For example:

```
Logger.add_category("my_custom_category", Logger.LEVELS.ERROR, Logger.STRAT_PRINT)
Logger.select_category("my_custom_category")
Logger.info("this won't be logged")
Logger.error("this will be logged to the new custom category!")
```

## To Dos

I want to implement `STRAT_BUFFER` at some point in the future.

## Will I make this a plugin?

No, it's just a simple singleton. I don't think it's necessary to make a whole
new plugin just for logging stuff.

## License
BSD 0 clause license or public domain.

