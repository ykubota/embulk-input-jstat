# Embulk::Plugin::Input::Jstat

[Embulk](https://github.com/embulk/embulk) input plugin for [jstat](http://docs.oracle.com/javase/8/docs/technotes/tools/unix/jstat.html).
Now, this plugin supports only JDK8.

## Requirements

- Embulk 0.4.1 or later.
- bundler 1.7 or later.
- rake 10.0 or later.

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

## Contributing

1. Fork it ( https://github.com/ykubota/embulk-plugin-input-jstat/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

