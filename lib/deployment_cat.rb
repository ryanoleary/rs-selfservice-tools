
def server_array_to_cat( sa, rname )

    puts "  ServerArray: " + sa.name
    str = ""

    # Some of the basic resource information
    str += "resource '"+rname+"', type: 'server_array' do\n"
    str += "  name '"+sa.name.gsub(/\'/,"\\\\'")+"'\n"
    if !sa.description.nil? 
      str += "  description '"+sa.description.gsub(/\'/,"\\\\'")+"'\n"
    end

    # Get the instance information and the ServerTemplate details
    ni = sa.show.next_instance.show(:view=>"full")

    str += instance_details_to_cat(ni)

    if sa.raw["optimized"]
      str += "  optimized '"+sa.optimized+"'\n"
    end
    
    if sa.raw["state"]
      str += "  state '"+sa.state+"'\n"
    end

    if sa.raw["array_type"]
      str += "  array_type '"+sa.array_type+"'\n"
    end
    
    str += "  elasticity_params do {\n"
    str += "    'bounds' => {\n"
    str += "      'min_count'            => "+sa.elasticity_params["bounds"]["min_count"]+",\n"
    str += "      'max_count'            => "+sa.elasticity_params["bounds"]["max_count"]+"\n"
    str += "    },\n"
    str += "    'pacing' => {\n"
    str += "      'resize_calm_time'     => "+sa.elasticity_params["pacing"]["resize_calm_time"]+",\n"
    str += "      'resize_down_by'       => "+sa.elasticity_params["pacing"]["resize_down_by"]+",\n"
    str += "      'resize_up_by'         => "+sa.elasticity_params["pacing"]["resize_up_by"]+"\n"
    str += "    },\n"
    str += "    'alert_specific_params' => {\n"
    str += "      'decision_threshold'   => "+sa.elasticity_params["alert_specific_params"]["decision_threshold"]+",\n"
    str += "      'voters_tag_predicate' => '"+sa.elasticity_params["alert_specific_params"]["voters_tag_predicate"]+"'\n"
    str += "    }\n"
    str += "  } end\n"

    str += "end\n"
    str
end

def server_to_cat( s, rname )

    puts "  Server: " + s.name

    str = ""
    # Some of the basic resource information
    str += "resource '"+rname+"', type: 'server' do\n"
    str += "  name '"+s.name.gsub(/\'/,"\\\\'")+"'\n"
    if !s.description.nil? 
      str += "  description '"+s.description.gsub(/\'/,"\\\\'")+"'\n"
    end

    # Get the instance information and the ServerTemplate details
    ni = s.show.next_instance.show(:view=>"full")

    str += instance_details_to_cat(ni)

    if s.raw["optimized"]
      str += "  optimized '"+s.optimized+"'\n"
    end
    
    str += "end\n"
    str
end


def instance_details_to_cat( ni )

    st = ni.server_template.show(:view=>"inputs_2_0")

    str = ""
    str += "  # cloud '"+ni.cloud.show.name.gsub(/\'/,"\\\\'")+"'\n"
    str += "  cloud_href '"+ni.cloud.show.href+"'\n"
    
    # Check to see if there is a datacenter link to export
    if !ni.raw["links"].detect{ |l| l["rel"] == "datacenter" && l["inherited_source"] == nil}.nil?
      str += "  # datacenter '"+ni.datacenter.show.name.gsub(/\'/,"\\\\'")+"'\n"
      str += "  datacenter_href '"+ni.datacenter.show.href+"'\n"
    end

    # Check to see if there is a image link to export
    if !ni.raw["links"].detect{ |l| l["rel"] == "image" && l["inherited_source"] == nil}.nil?
      str += "  # image '"+ni.image.show.name.gsub(/\'/,"\\\\'")+"'\n"
      str += "  image_href '"+ni.image.show.href+"'\n"
    end

    # Check to see if there is an instance type link to export
    if !ni.raw["links"].detect{ |l| l["rel"] == "instance_type" && l["inherited_source"] == nil}.nil?
      str += "  # instance_type '"+ni.instance_type.show.name.gsub(/\'/,"\\\\'")+"'\n"
      str += "  instance_type_href '"+ni.instance_type.show.href+"'\n"
    end 

    # Check to see if there is an kernel type link to export
    if !ni.raw["links"].detect{ |l| l["rel"] == "kernel_image" && l["inherited_source"] == nil}.nil?
      str += "  # kernel_image '"+ni.kernel_image.show.name.gsub(/\'/,"\\\\'")+"'\n"
      str += "  kernel_image_href '"+ni.kernel_image.show.href+"'\n"
    end 

    # Check to see if there is an multi cloud image link to export
    if !ni.raw["links"].detect{ |l| l["rel"] == "multi_cloud_image" && l["inherited_source"] == nil}.nil?
      str += "  # multi_cloud_image '"+ni.multi_cloud_image.show.name.gsub(/\'/,"\\\\'")+"'\n"
      str += "  multi_cloud_image_href '"+ni.multi_cloud_image.show.href+"'\n"
    end 

    # Check to see if there is an multi cloud image link to export
    if !ni.raw["links"].detect{ |l| l["rel"] == "ramdisk_image" && l["inherited_source"] == nil}.nil?
      str += "  # ramdisk_image '"+ni.ramdisk_image.show.name.gsub(/\'/,"\\\\'")+"'\n"
      str += "  ramdisk_image_href '"+ni.ramdisk_image.show.href+"'\n"
    end 

    if !ni.user_data.nil? && ni.user_data != ''
      str += "  user_data '"+ni.user_data.gsub(/\'/,"\\\\'")+"'\n"
    end

    # Subnets and security groups aren't proper links in right_api_client, so instead
    #  just use the href values for these
    if !ni.raw["subnets"].nil? && ni.raw["subnets"].size > 0
      str += "  subnet_hrefs "
      ni.raw["subnets"].each_with_index do |sn, i|
        str += "'" + sn["href"] + "'"
        str += ", " if i != ni.raw["subnets"].size - 1
      end
      str += "\n"
    end

    # Subnets and security groups aren't proper links in right_api_client, so instead
    #  just use the href values for these
    if !ni.raw["security_groups"].nil?
      str += "  security_group_hrefs "
      ni.raw["security_groups"].each_with_index do |sn, i|
        str += "'" + sn["href"] + "'"
        str += ", " if i != ni.raw["security_groups"].size - 1
    end
      str += "\n"
    end

    # Output the server template information
    str += "  # server_template find('"+st.name.gsub(/\'/,"\\\\'")+"', revision: "+st.revision.to_s()+")\n"
    str += "  server_template_href '"+st.href+"'\n"

    # For each input, check to see if this input is in the ServerTemplate with the same value
    #  If so, skip it, since it appears to be inherited anyway
    inputs = ni.inputs.index(:view=>"inputs_2_0")
    str += "  inputs do {\n"
    inputs.each do |i|
      if st.raw["inputs"].find{ |sti| sti["name"] == i.name && sti["value"] == i.value }.nil?  
        str += "    '"+i.name+"' => '"+i.value.gsub(/\'/,"\\\\'")+"',\n" if i.value != "blank"
      end
    end 
    str += "  } end\n"

    str
end

def deployment_to_cat_file( client, deployment_id )

# Get and show the deployment name
dep = client.deployments(:id=>deployment_id).show
puts "Exporting Deployment: " + dep.name

# Output to a file named after the deployment (cleaned up for Linux filenames)
File.open(dep.name.gsub(/[^\w\s_-]+/, '')+'.cat.rb','w') do |f|

  # Output the metadata of this CloudApp
  f.puts "name '"+dep.name.gsub(/\'/,"\\\\'")+"'"
  f.puts "rs_ca_ver 20131202"
  f.puts "short_description '"+dep.description.gsub(/\'/,"\\\\'")+"'"

  # For each Server in the deployment (regardless of its status)
  servers = dep.servers.index
  scount = 0
  servers.each do |s|

    rname = "server_"+(scount+=1).to_s
    f.puts(server_to_cat(s, rname))
    f.flush
  end

  serverarrays = dep.server_arrays.index
  scount = 0
  serverarrays.each do |sa|

    rname = "server_array_"+(scount+=1).to_s
    f.puts(server_array_to_cat(sa, rname))
    f.flush
  end
end

end
