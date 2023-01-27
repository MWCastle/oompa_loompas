#!/usr/bin/env ruby

require 'faraday'
require 'json'
require 'rubyXL'

module Helper

  # class for common operations dealing with reading/writing/finding files
  class Fops

    # TODO: Add in some functions to help find differences between files and provide very simple metrics like size type and whatnot

    # *************************************************************************************************************** #
    #                                             JSON HELPER METHODS                                                 #
    # *************************************************************************************************************** #

    # Will return a hash when given a path to a correctly formatted json file. Otherwise throws error.
    def self.json_to_hash(path, **options)
      unless File.file?(path)
        puts 'Invalid Filepath in json_to_hash'
        return nil
      end

      jason = File.read(path)
      if jason.strip.empty?
        nil
      else
        JSON.parse(jason, options)
      end
    end

    # Will write a hash to json file with proper formatting.
    def self.hash_to_json(hash, path)
      File.open(path, 'w') do |json|
        json.write JSON.pretty_generate(hash)
      end
    end

    # *************************************************************************************************************** #
    #                                             EXCEL HELPER METHODS                                                #
    # *************************************************************************************************************** #

    # TODO: Check if this works with .xls as well or just .xlsx
    # Will return a workbook object from .xlsx files given a path
    # To get a specific sheet from a workbook, use workbook.worksheets[#] array
    # To get a specific row from a worksheet, use worksheet[#]
    # To get cell values from a row used row[#].value or row[#].raw_value
    def self.workbook_from_excel(path)
      RubyXL::Parser.parse(path)
    end

    # *************************************************************************************************************** #
    #                                             CSV HELPER METHODS                                                  #
    # *************************************************************************************************************** #

    # TODO: add in rescue to have function return false if something fails, but return true if the generation completes
    # Will write to a csv file given a path, data to write, and optionally headers.
    def self.write_csv(path, data_rows, headers = [])
      CSV.open(path, 'wb') do |csv|
        csv << headers unless headers.empty?
        data_rows.each do |row|
          csv << row
        end
      end
    end

    # TODO: Need to check how this handles having headers or not as well as splat operator
    # Returns and array of the rows from a csv file.
    def self.get_csv_rows(path, have_headers: false, add_opt: nil)
      if add_opt
        CSV.parse(path, headers: have_headers, **add_opt)
      else
        CSV.parse(path, headers: have_headers)
      end
    end

    # *************************************************************************************************************** #
    #                                       DIRECTORY/PATHS HELPER METHODS                                            #
    # *************************************************************************************************************** #

    # Will return a hash of arrays containing all non-hidden subdirectories and files given a certain directory path
    def self.get_direct_subpaths(path)
      paths = { directories: [], files: [] }

      subs = Dir.glob("#{path}/**")
      subs.each do |sub_path|
        if Dir.exist?(sub_path)
          paths[:directories].push(sub_path)
        else
          paths[:files].push(sub_path)
        end
      end
      paths
    end

    # Will recursively collect all paths reachable from a given directory and return a hash of arrays containing them
    def self.get_all_subpaths(path)
      paths = { directories: [], files: [] }
      queue = []

      subs = get_direct_subpaths(path)
      paths[:directories].push(*subs[:directories])
      paths[:files].push(*subs[:files])
      queue.push(*subs[:directories])
      while queue.size.positive?
        subs = get_direct_subpaths(queue.pop)
        paths[:directories].push(*subs[:directories])
        paths[:files].push(*subs[:files])
        queue.push(*subs[:directories])
      end
      paths
    end

  end

  # Class to help with generating commonly used graphing methods
  class Graphing

  end

  # Class to help with date handling, ordering, conversions, etc.
  class Dates

    # Handles converting any possible data type to a Date object, or returns false if not possible
    # Expects arrays to be ordered [year, month, day], hashes to use keys :year, :month, :day,
    # strings to be in YYYY-MM-DD format where you can put '.', '/', or '-' in between the numbers,
    # and Integers to represent the chronological Julian day number.
    # FYI: 1721058 would be 0000-01-01 according to Julian calendar
    def self.to_date(input)
      return input if input.instance_of?(Date)

      if input.instance_of?(Array)
        if input.size == 3
          Date.new(input[0], input[1], input[2])
        else
          false
        end
      elsif input.instance_of?(Hash)
        if input[:year] && input[:month] && input[:day]
          Date.new(input[:year], input[:month], input[:day])
        else
          false
        end
      elsif input.instance_of?(String)
        Date.parse(input)
      elsif input.instance_of?(Integer)
        Date.jd(input)
      elsif input.instance_of?(DateTime)
        # TODO: CHECK THIS SHEEEIT MANE
        # puts 'DATETIME'
        # seconds_to_midnight = input.sec + (input.min * 60) + (input.hour * 3600) + (input.offset * 24 * 3600).to_i
        # puts "SECONDS TO MIDNIGHT: #{seconds_to_midnight}"
        # if seconds_to_midnight >= 86_400
        #   input.to_date + 1
        # elsif seconds_to_midnight <= -86_400
        #   input.to_date - 1
        # else
        #   input.to_date
        # end
        datetime_to_utc(input).to_date
      else
        false
      end
    end

    # Handles converting any possible data type to a DateTime object, or returns false if not possible
    # Expects arrays to be ordered [year, month, day, hour, min, sec, offset],
    # offset must be string '+#:##' or Rational(#, 24), otherwise ignored
    # hashes to use keys :year, :month, :day, :hour, :min, :sec, and optionally :offset,
    # strings can be various formats. Need to check what is returned if passing this a string.
    def self.to_datetime(input)
      return input if input.instance_of?(DateTime)

      if input.instance_of?(Array)
        case input.size
        when 6
          DateTime.new(input[0], input[1], input[2], input[3], input[4], input[5])
        when 7
          DateTime.new(input[0], input[1], input[2], input[3], input[4], input[5], input[6])
        else
          false
        end
      elsif input.instance_of?(Hash)
        if input[:offset] && input[:year] && input[:month] && input[:day] && input[:hour] && input[:min] && input[:sec]
          DateTime.new(input[:year], input[:month], input[:day], input[:hour], input[:min], input[:sec], input[:offset])
        elsif input[:year] && input[:month] && input[:day] && input[:hour] && input[:min] && input[:sec]
          DateTime.new(input[:year], input[:month], input[:day], input[:hour], input[:min], input[:sec])
        else
          false
        end
      elsif input.instance_of?(String)
        DateTime.parse(input)
      elsif input.instance_of?(Date)
        input.to_datetime
      else
        false
      end
    end

    # Accepts two dates, possibly of different data types, normalizes them to Fate objects and returns a hash
    # containing some simple metrics commonly of interest when dealing with dates.
    def self.compare_dates(uno, dos)
      metrics = { same_day: false }
      one = to_date(uno)
      two = to_date(dos)
      return if one == false
      return if two == false

      metrics[:days_between] = (one - two).to_i.abs
      if one > two
        metrics[:begin] = two
        metrics[:end] = one
      elsif two > one
        metrics[:begin] = one
        metrics[:end] = two
      else
        metrics[:begin] = one
        metrics[:end] = one
        metrics[:same_day] = true
      end
      metrics
    end

    # Accepts two datetimes, possibly of different data types, normalizes them to DateTime objects and returns a hash
    # containing some simple metrics commonly of interest when dealing with datetimes
    def self.compare_datetimes(uno, dos)
      metrics = { same_day: false }
      one = to_datetime(uno)
      two = to_datetime(dos)
      return if one == false
      return if two == false

      one_date = to_date(one)
      puts "ONE_DATE: #{one_date}"
      two_date = to_date(two)
      puts "TWO_DATE: #{two_date}"
      metrics[:days_between] = (one_date - two_date).to_i.abs
      if one_date > two_date
        metrics[:begin] = two
        metrics[:end] = one
        metrics.merge!(get_time_difference(one, two))
      elsif one_date < two_date
        metrics[:begin] = one
        metrics[:end] = two
        metrics.merge!(get_time_difference(two, one))
      else
        metrics[:begin] = one
        metrics[:end] = one
        metrics.merge!(get_time_difference(one, two))
        metrics[:same_day] = true
      end
      metrics
    end

    # Finds offsets from time fields between two DateTime objects because this apparently isn't important to whoever
    # decided returning a fraction from DateTime arithmetic would be cool...
    def self.get_time_difference(one, two)
      diff = { hrs_dif: 0, min_dif: 0, sec_dif: 0 }
      diff[:hrs_dif] = one.hour - two.hour
      diff[:min_dif] = one.min - two.min
      diff[:sec_dif] = one.second - two.second
      diff
    end

    # Method used to normalize a datetime to UTC. Gets rid of offset if there is one and corrects date accordingly
    def self.datetime_to_utc(datetime)
      date = datetime.to_date
      sec_of_day = datetime.sec + (datetime.min * 60) + (datetime.hour * 3600)
      sec_of_offset = (datetime.offset * 24 * 3600).to_i
      seconds_to_midnight = sec_of_day + sec_of_offset
      if seconds_to_midnight >= 86_400
        date += 1
        formatted = convert_seconds(seconds_to_midnight - 86_400)
        DateTime.new(date.year, date.month, date.day, formatted[0], formatted[1], formatted[2])
      elsif seconds_to_midnight < 0
        date -= 1
        formatted = convert_seconds(86_400 - seconds_to_midnight.abs)
        DateTime.new(date.year, date.month, date.day, formatted[0], formatted[1], formatted[2])
      end
    end

    # Method used to calculate the number of hrs, mins, seconds given a total time in seconds
    def self.convert_seconds(seconds)
      hours = seconds / 3600
      mins = (seconds - (hours * 3600)) / 60
      secs = seconds - ((hours * 3600) + (mins * 60))
      puts "#{hours}:#{mins}:#{secs}"
      [hours, mins, secs]
    end

  end

  # Class containing helper functions with setting up, changing settings, making requests via Faraday, etc.
  class HTTP

    @@endpoints = { 'prod_web' => 'https://fleet.badger-technologies.com/api/web/v1',
                    'prod_insight' => 'https://fleet.badger-technologies.com/api/insight/v1',
                    'staging_web' => 'https://staging.btdev.team/api/web/v1',
                    'staging_insight' => 'https://staging.btdev.team/api/insight/v1',
                    'dev_web' => 'https://dev.btdev.team/api/web/v1',
                    'dev_insight' => 'https://dev.btdev.team/api/insight/v1',
                    'demo_web' => 'https://demo.badger-service.com/api/web/v1',
                    'demo_insight' => 'https://demo.badger-service.com/api/insight/v1' }

    # Function to create a fleet connection with endpoint set to what user specifies and return a pointer to it.
    # Defaults to not outputting errors and no authorization. error flags can be set and authentication can be provided
    # via 'creds' hash with keys :username and :password
    def self.get_fleet_connection(environment, raise_errors: false, creds: nil)
      connection = nil
      if @@endpoints[environment]
        connection = Faraday.new(@@endpoints[environment]) do |conn|
          conn.use Faraday::Response::RaiseError if raise_errors
          conn.request :authorization, :basic, creds['username'], creds['password'] if creds
          conn.request :json
          conn.response :json
          # conn.request :retry    NOT SURE IF THIS DOES WHAT I THINK SO COMMENT IT FOR NOW
        end
      else
        puts "Invalid endpoint selected. You provided: #{environment}"
        puts 'Valid Options Include:'
        puts @@endpoints.keys
      end
      connection
    end

    # TODO: See if these 'raise's will still throw if the connection is set up without flags turned on
    # Used to make http requests once the conection is established. Expects pointer to the connection, http request
    # type, the enpoint to add to the end of the base endpoint tied to connection, and any body/param or headers.
    def self.request(conn, request_type, endpoint, body_or_params = {}, headers = {})
      response = conn.run_request(request_type, endpoint, body_or_params, headers)
      response.body.nil? ? {} : response.body
    rescue Faraday::Error => e
      raise 'Connection failed!' if e.instance_of?(Faraday::ConnectionFailed)

      raise 'Response not parsable! Authorization may have failed' if e.instance_of?(Faraday::ParsingError)

      raise 'Fleet authorization failed!' if response.status == 401
    end

    # Method to find the relative path within docker container to a vpn file for the org that a given robot belongs to.
    def self.vpn_fpath_from_robot_name(env, rname, credentials: nil)
      puts "RNAME: #{rname}"
      temp_name = Marshal.load(Marshal.dump(rname)).gsub('"', '').gsub('bar', 'BAR')
      name = temp_name.include?('BAR') ? temp_name : "BAR#{temp_name}"
      temp_env = Marshal.load(Marshal.dump(env)).gsub('"', '')
      # TODO: Fill out rest of logic needed here then test that right stuff is coming back.
      conn = get_fleet_connection(temp_env, raise_errors: false, creds: credentials)
      robot_data = all_robots(conn)&.keep_if do |entry|
        entry['name'] == name
      end
      if robot_data.empty?
        puts 'Invalid bar number found in vpn_fpath_from_robot_name. Exiting...'
        exit(1)
      end
      # puts ''
      # puts robot_data
      store_data = request(conn, :get, "stores/#{robot_data[0]['store_id']}")
      # puts ''
      # puts store_data
      org_data = request(conn, :get, "organizations/#{store_data['organization_id']}")
      # puts ''
      # puts org_data['slug']
      puts 'GLOB GANG'
      system('ls -l')
      relative_path = nil
      Dir.glob("#{__dir__}/../image_files/vpn/configs/*").each do |path|
        next unless path.include?(org_data['slug'])

        relative_path = "\"/code#{path.split('/../image_files/vpn').last}\""
        puts path
      end
      puts 'Correct .ovpn file found. Returning from vpn_fpath_from_robot_name' if relative_path
      relative_path
      # map = Fops.json_to_hash("#{__dir__}/../configs/vpn_mapping.json")
      # if map.keys.include?(org_data['slug'])
      #   # Iterate through files in configs and pull path of one that includes the value mapped to the slug
      #   puts map[org_data['slug']]
      #   puts ''
      #   Dir.glob("#{__dir__}/../vpn/configs/*").each do |path|
      #     # puts "\"/code#{path.split('/../vpn').last}\"" if path.include?(map[org_data['slug']])
      #     return "\"/code#{path.split('/../vpn').last}\"" if path.include?(map[org_data['slug']])
      #   end
      # else
      #   puts 'There is no known .ovpn file for this organization found in vpn_mapping.json. Exiting...'
      #   return nil
      # end
    end

    # TODO: Add to these to where you can pass in optional args that would build queries at the end of the endpoint
    # Method to request all the org data from fleet in whatever environment the connection was made.
    def self.all_orgs(conn)
      request(conn, :get, 'organizations')
    end

    # Method to request all the store data from fleet in whatever environment the connection was made.
    def self.all_stores(conn)
      request(conn, :get, 'stores')
    end

    # Method to request all the robot data from fleet in whatever environment the connection was made.
    def self.all_robots(conn)
      request(conn, :get, 'robots')
    end

    # TODO: Look into setting up this helper and make it possible to pass a connection and path to tie logs from specific connections to specific files
    def self.toggle_logger
      # POOP
    end

    # TODO: Look into a check request and/or connection status
    # def self.check_connection_status

  end
end

# TODO: Create a method that returns just the name of the file given a full_path