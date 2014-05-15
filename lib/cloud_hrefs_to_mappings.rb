def cloud_hrefs_to_mappings( c )

  # Instance Types
  puts 'mapping "cloud_hrefs" do {'

  c.clouds.index.each do |cloud|
    puts '  "' + cloud.name + '" => {'
    puts '    "href" => "' + cloud.href + '",'
    puts "  },"
  end

  puts '}'
  puts 'end'

  # Instance Types
  puts 'mapping "cloud_instance_types" do {'

  c.clouds.index.each do |cloud|
    puts '  "' + cloud.href + '" => {'

    if !cloud.raw["links"].detect{ |l| l["rel"] == "instance_types"}.nil?

      cloud.show.instance_types.index.each do |d|
        puts '    "' + d.name + '" => "' + d.href + '",'
      end
    end

    puts "  },"
  end

  puts '}'
  puts 'end'


end

