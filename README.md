# embulk-plugin-input-jstat

[Embulk](https://github.com/embulk/embulk) input plugin for [jstat](http://docs.oracle.com/javase/8/docs/technotes/tools/unix/jstat.html).
Now, this plugin supports only JDK8.

## Installation

Run this command with your embulk binary.

```ruby
$ java -jar embulk.jar gem install embulk-plugin-input-jstat
```

## Configuration

Specify in your config.yml file

```yaml
in:
  type: jstat
  paths: [/tmp, /path/to/jstat_files, /other/path/to/jstats_files]
  option: -gcutil
  timestamp: false
```

- type: specify this plugin as `jstat`.
- paths: specify paths where jstat files(\*.log) are. (optional, default: /tmp)
- option: specify a stat option of jstat, e.g., -gcutil. (optional, default: -gcutil)
- timestamp: specify whether your jstat files include a timestamp column or not. (optional, default: false)

## TODO

- support JDK7, JDK6.

