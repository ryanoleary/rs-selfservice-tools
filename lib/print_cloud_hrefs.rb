def print_cloud_details( c )

  c.clouds.index.each do |cloud|
    
    puts "=== CLOUD: " + cloud.name
    puts cloud.name + " - " + cloud.href

    if !cloud.raw["links"].detect{ |l| l["rel"] == "datacenters"}.nil?

      puts "  == DATACENTERS"
      cloud.show.datacenters.index.each do |d|
        puts "    " + d.name + " - " + d.href
      end
    end

    if !cloud.raw["links"].detect{ |l| l["rel"] == "subnets"}.nil?

      puts "  == SUBNETS"
      cloud.show.subnets.index.each do |d|
        # Sometimes subnets names are nil, shouw the resource_uid instead
        if d.name.nil?
          sname = d.resource_uid
        else
          sname = d.name
        end
        puts "    " + sname + " - " + d.href
      end
    end

    if !cloud.raw["links"].detect{ |l| l["rel"] == "instance_types"}.nil?

      puts "  == INSTANCE_TYPES"
      cloud.show.instance_types.index.each do |d|
        puts "    " + d.name + " - " + d.href
      end
    end

    if !cloud.raw["links"].detect{ |l| l["rel"] == "ssh_keys"}.nil?

      puts "  == SSH_KEYS"
      cloud.show.ssh_keys.index.each do |d|
        puts "    " + d.resource_uid + " - " + d.href
      end
    end

    if !cloud.raw["links"].detect{ |l| l["rel"] == "security_groups"}.nil?

      puts "  == SECURITY_GROUPS"
      cloud.show.security_groups.index.each do |d|
        puts "    " + d.name + " - " + d.href
      end
    end

    # if !cloud.raw["links"].detect{ |l| l["rel"] == "images"}.nil?

    #   puts "== IMAGES"
    #   cloud.show.images.index.each do |d|
    #     puts d.name + " - " + d.href
    #   end
    # end

    puts ""

  end
end

