require 'gruff'
require "time"

module BikeIn
  module MastodonBot
    module Diagram
      def print(tag,data,path,file)
        # data = [ {
        #           "type": "Number",
        #           "value": "0.00502",
        #           "modifiedAt": "2019-08-27T23:34:56.563Z"
        #         }, ...]
        data_grouping_by_hours = []
        data.each do |current_data|
          t = Time.strptime(current_data[:modifiedAt][0..18],"%Y-%m-%dT%H:%M:%S")
          data_grouping_by_hours[t.hour.to_i] ||= []
          data_grouping_by_hours[t.hour.to_i] << current_data[:value]
        end

        # pp data
        data_digested = data_grouping_by_hours.map do |hour|
          hour.map{ |c| c.to_f }.sum * 100 / hour.size
        end

        g = Gruff::Line.new
        g.labels = {
          0 => '00am',
          1 => '',
          2 => '',
          3 => '',
          4 => '',
          5 => '',
          6 => '6am',
          7 => '',
          8 => '',
          9 => '',
          10 => '',
          11 => '',
          12 => '12pm',
          13 => '',
          14 => '',
          15 => '',
          16 => '',
          17 => '',
          18 => '18pm',
          19 => '',
          20 => '',
          21 => '',
          22 => '',
          23 => '23pm'
        }
        g.data tag.to_sym, data_digested
        g.write("#{path}/#{file}")

      end
    end
  end
end
