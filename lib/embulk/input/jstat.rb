# -*- coding:utf-8 -*-

module Embulk
  class InputJstat < InputPlugin
    require 'json'

    Plugin.register_input('jstat', self)

    # output columns of jstat (JDK8)
    JSTAT_COLUMNS = {
      class: {
        Loaded: 'int',
        Bytes: 'double',
        Unloader: 'int',
        Bytes: 'double',
        Time: 'double'
      },
      compiler: {
        Compiled: 'int',
        Failed: 'int',
        Invalid: 'int',
        Time: 'double',
        FailedType: 'int',
        FailedMethod: 'string'
      },
      gc: {
        S0C: 'double',
        S1C: 'double',
        S0U: 'double',
        S1U: 'double',
        EC: 'double',
        EU: 'double',
        OC: 'double',
        MC: 'double',
        MU: 'double',
        CCSC: 'double',
        CCSU: 'double',
        YGC: 'int',
        YGCT: 'double',
        FGC: 'int',
        FGCT: 'double',
        GCT: 'double'
      },
      gccause: {
        S0: 'double',
        S1: 'double',
        E: 'double',
        O: 'double',
        M: 'double',
        CCS: 'double',
        YGC: 'int',
        YGCT: 'double',
        FGC: 'int',
        FGCT: 'double',
        GCT: 'double',
        LGCC: 'string',
        GCC: 'string'
      },
      gcnew: {
        S0C: 'double',
        S1C: 'double',
        S0U: 'double',
        S1U: 'double',
        TT: 'int',
        MTT: 'double',
        DSS: 'double',
        EC: 'double',
        EU: 'double',
        YGC: 'int',
        YGCT: 'double'
      },
      gcnewcapacity: {
        NGCMN: 'double',
        NGCMX: 'double',
        NGC: 'double',
        S0CMX: 'double',
        S0C: 'double',
        S1CMX: 'double',
        S1C: 'double',
        ECMX: 'double',
        EC: 'double',
        YGC: 'int',
        FGC: 'int'
      },
      gcold: {
        MC: 'double',
        MU: 'double',
        CCSC: 'double',
        CCSU: 'double',
        OC: 'double',
        OU: 'double',
        YGC: 'int',
        FGC: 'int',
        FGCT: 'double',
        GCT: 'double'
      },
      gcoldcapacity: {
        OGCMN: 'double',
        OGCMX: 'double',
        OGC: 'double',
        OC: 'double',
        YGC: 'int',
        FGC: 'int',
        FGCT: 'double',
        GCT: 'double'
      },
      gcmetacapacity: {
        MCMN: 'double',
        MCMX: 'double',
        MC: 'double',
        CCSMN: 'double',
        CCSMX: 'double',
        CCSC: 'double',
        YGC: 'int',
        FGC: 'int',
        FGCT: 'double',
        GCT: 'double'
      },
      gcutil: {
        S0: 'double',
        S1: 'double',
        E: 'double',
        O: 'double',
        M: 'double',
        CCS: 'double',
        YGC: 'int',
        YGCT: 'double',
        FGC: 'int',
        FGCT: 'double',
        GCT: 'double'
      },
      printcompilation: {
        Compiled: 'int',
        Size: 'int',
        Type: 'int',
        Method: 'string'
      }
    }

    def self.transaction(config, &control)
      # find jstat files and push to "task".
      paths = config.param('paths', :array, default: ['/tmp']).map do |path|
        next [] unless Dir.exists?(path)
        Dir.entries(path).sort.select do |f|
          f =~ /^.+\.log$/
        end.map do |file|
          File.expand_path(File.join(path, file))
        end
      end.flatten
      # remove checked jstat files by other threads.
      paths -= config.param('done', :array, default: [])
      task = {'paths' => paths}

      # generate schema by parsing a given options of jstat.
      option = config.param('option', :string, default: 'gcutil')
      option[0] = '' if option =~ /^\-/
      unless JSTAT_COLUMNS.has_key?(option.to_sym)
        raise "Wrong configuration: \"option: #{option}\". Specify a stat option of jstat correctly."
      end

      timestamp = config.param('timestamp', :bool, default: false)

      i = timestamp ? 1 : 0
      columns = JSTAT_COLUMNS[option.to_sym].each.with_index(i).map do |column, index|
        stat, type = column
        case type
        when 'string'
          Column.new(index, stat.to_s, :string)
        when 'int', 'long'
          Column.new(index, stat.to_s, :long)
        when 'double', 'float'
          Column.new(index, stat.to_s, :double)
        end
      end

      if timestamp
        columns.unshift(Column.new(0, 'Timestamp', :double))
      end

      #TODO: Now, force to set threads as amount of found files. Need a better idea.
      report = yield(task, columns, paths.length)

      config.merge( report['done'].flatten.compact )

      return {}
    end

    def initialize(task, schema, index, page_builder)
      super
    end

    def run
      # if no path, returns empty.
      unless path = @task['paths'][@index]
        return { 'done' => [] }
      end

      File.read(path).each_line.with_index(0) do |line, i|
        stats = line.strip.split(/\s+/)

        # maybe not jstat file if a number of column is not match.
        if stats.size != @schema.size
          # if not header, maybe injected other log, e.g. console.
          i == 0 ? break : next
        end

        # ignore column heading line
        next if i == 0 && stats[0] == @schema[0]['name']

        page = []
        @schema.each_with_index do |s, i|
          case s['type']
          when :string
            page << stats[i]
          # TODO: If not numeric, raise error.
          when :long
            page << stats[i].to_i
          when :double
            page << stats[i].to_f
          else
            raise "unknown type: #{s['type']}"
          end
        end
        @page_builder.add(page)
      end
      @page_builder.finish

      {  # commit report
        'done' => path
      }
    end
  end
end
