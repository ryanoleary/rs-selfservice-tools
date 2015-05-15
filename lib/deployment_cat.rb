
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
  str += server_template_details_to_cat(ni)

  if sa.raw["optimized"]
    str += "  optimized '#{sa.optimized}'\n"
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
  str += server_template_details_to_cat(ni)

  if s.raw["optimized"]
    str += "  optimized '"+s.optimized.to_s+"'\n"
  end
  
  str += "end\n"
  str
end

def instance_to_cat( i, rname )

  puts "  Instance: " + i.name

  str = ""
  # Some of the basic resource information
  str += "resource '"+rname+"', type: 'instance' do\n"
  str += "  name '"+i.name.gsub(/\'/,"\\\\'")+"'\n"
  if !i.description.nil? 
    str += "  description '"+i.description.gsub(/\'/,"\\\\'")+"'\n"
  end

  str += instance_details_to_cat(i)

  str += "end\n"
  str
end

def server_template_details_to_cat( ni )

  st = ni.server_template.show(:view=>"inputs_2_0")

  str = ""
  # Output the server template information
  str += "  server_template find('"+st.name.gsub(/\'/,"\\\\'")+"', revision: "+st.revision.to_s()+")\n"
  # str += "  server_template_href '"+st.href+"'\n"

  # For each input, check to see if this input is in the ServerTemplate with the same value
  #  If so, skip it, since it appears to be inherited anyway
  inputs = ni.inputs.index(:view=>"inputs_2_0")
  str += "  inputs do {\n"
  inputs = inputs.sort_by {|a| a.name.downcase}
  inputs.each do |i|
    if st.raw["inputs"].find{ |sti| sti["name"] == i.name && sti["value"] == i.value }.nil? && 
       ((@deployment_inputs && @dep.raw["inputs"].find{ |sti| sti["name"] == i.name && sti["value"] == i.value }.nil?) || !@deployment_inputs)
      str += "    '"+i.name+"' => '"+i.value.gsub(/\'/,"\\\\'")+"',\n" if i.value != "blank"
    end
  end 
  str += "  } end\n"

  str

end

def instance_details_to_cat( ni )

  str = ""
  str += "  cloud '"+ni.cloud.show.name.gsub(/\'/,"\\\\'")+"'\n"
  #str += "  cloud_href '"+ni.cloud.show.href+"'\n"
  cloud_href = ni.cloud.show.href

  # Check to see if there is a datacenter link to export
  if !ni.raw["links"].detect{ |l| l["rel"] == "datacenter" && l["inherited_source"] == nil}.nil?
    begin
      str += "  datacenter '"+ni.datacenter.show.name.gsub(/\'/,"\\\\'")+"'\n"
    rescue
      str += "  # datacenter ** NOT ABLE TO EXPORT **\n"
    end
    # str += "  datacenter_href '"+ni.datacenter.show.href+"'\n"
  end

  # Check to see if there is a image link to export
  if !ni.raw["links"].detect{ |l| l["rel"] == "image" && l["inherited_source"] == nil}.nil?
    str += "  image '"+ni.image.show.name.gsub(/\'/,"\\\\'")+"'\n"
    # str += "  image_href '"+ni.image.show.href+"'\n"
  end

  # Check to see if there is an instance type link to export
  if !ni.raw["links"].detect{ |l| l["rel"] == "instance_type" && l["inherited_source"] == nil}.nil?
    str += "  instance_type '"+ni.instance_type.show.name.gsub(/\'/,"\\\\'")+"'\n"
    # str += "  instance_type_href '"+ni.instance_type.show.href+"'\n"
  end 

  # Check to see if there is an kernel type link to export
  if !ni.raw["links"].detect{ |l| l["rel"] == "kernel_image" && l["inherited_source"] == nil}.nil?
    str += "  kernel_image '"+ni.kernel_image.show.name.gsub(/\'/,"\\\\'")+"'\n"
    # str += "  kernel_image_href '"+ni.kernel_image.show.href+"'\n"
  end 

  # Check to see if there is an multi cloud image link to export
  if !ni.raw["links"].detect{ |l| l["rel"] == "multi_cloud_image" && l["inherited_source"] == nil}.nil?
    str += "  multi_cloud_image find('"+ni.multi_cloud_image.show.name.gsub(/\'/,"\\\\'")+"', revision: " + ni.multi_cloud_image.show.revision.to_s + ")\n"
    # str += "  multi_cloud_image_href '"+ni.multi_cloud_image.show.href+"'\n"
  end 

  # Check to see if there is an ramdisk image link to export
  if !ni.raw["links"].detect{ |l| l["rel"] == "ramdisk_image" && l["inherited_source"] == nil}.nil?
    str += "  ramdisk_image '"+ni.ramdisk_image.show.name.gsub(/\'/,"\\\\'")+"'\n"
    # str += "  ramdisk_image_href '"+ni.ramdisk_image.show.href+"'\n"
  end 

  # Check to see if there is an ssh key link to export
  if !ni.raw["links"].detect{ |l| l["rel"] == "ssh_key" }.nil?
    begin
      str += "  ssh_key '"+ni.ssh_key.show.resource_uid.gsub(/\'/,"\\\\'")+"'\n"
    rescue
      str += "  # ssh_key ** NOT ABLE TO EXPORT **\n"
    end
    # str += "  ssh_key_href '"+ni.ssh_key.show.href+"'\n"
  end 

  # Export the user_data if it's not blank
  if !ni.user_data.nil? && ni.user_data != ''
    str += "  user_data '"+ni.user_data.gsub(/\'/,"\\\\'")+"'\n"
  end

  # Subnets and security groups aren't proper links in right_api_client, so instead
  #  just use the href values for these
  # If we have problems getting any subnet, just ignore them all and print an error
  if !ni.raw["subnets"].nil? && ni.raw["subnets"].size > 0
    begin

      # First let's set the network_href for the resource (just use the first subnet for this - they should all be the same)
      sn = ni.raw["subnets"][0]
      snr = @client.resource(sn["href"])
      str += "  network \"#{snr.network.show.name}\"\n"

      substr = "  subnets "
      ni.raw["subnets"].each_with_index do |sn, i|
        snr = @client.resource(sn["href"])

        # If the name is nil, use the resource_uid and network href
        if !snr.name
            substr += "find(resource_uid: '" + snr.resource_uid + "')"
        else
          substr += "'" + snr.name + "'"
        end

        substr += ", " if i != ni.raw["subnets"].size - 1
      end
      str += substr + "\n"
    rescue
      str += "  # subnets ** NOT ABLE TO EXPORT **\n"
    end
  end

  # Subnets and security groups aren't proper links in right_api_client, so instead
  #  just use the href values for these
  if !ni.raw["security_groups"].nil?
    str += "  security_groups "
    ni.raw["security_groups"].each_with_index do |sn, i|
      sgr = @client.resource(sn["href"])

      str += "'" + sgr.name + "'"

      str += ", " if i != ni.raw["security_groups"].size - 1
    end
    str += "\n"
  end

  str
end

def deployment_to_cat_string(client, deployment_id, deployment_inputs, concurrent)

  # Get and show the deployment name
  @dep = client.deployments(:id=>deployment_id).show(:view=>"inputs_2_0")
  @deployment_inputs = deployment_inputs
  resources = []

  cat = ''
  cat += 
    
  # Output the metadata of this CloudApp
  cat += "name '"+@dep.name.gsub(/\'/,"\\\\'")+"'\n"
  cat += "rs_ca_ver 20131202\n"

  desc = @dep.description.gsub(/\'/,"\\\\'")
  desc = @dep.name.gsub(/\'/,"\\\\'") if desc == '' 
  cat += "short_description '"+desc+"'\n"  

  # For each Server in the deployment (regardless of its status)
  servers = @dep.servers.index
  scount = 0
  servers.each do |s|
    rname = "server_"+(scount+=1).to_s
    cat += server_to_cat(s, rname)
    resources << rname
  end

  serverarrays = @dep.server_arrays.index
  scount = 0
  serverarrays.each do |sa|
    rname = "server_array_"+(scount+=1).to_s
    cat += server_array_to_cat(sa, rname)
    resources << rname
  end

  # Iterate through all clouds to get instances in the deployment
  instances = []
  client.clouds.index.each do |c|
    inst = c.instances.index(:filter=>["deployment_href=="+@dep.href],:view=>'full')
    instances += inst
  end

  # Delete instances with a parent (parent means they're from a Server or ServerArray)
  instances.delete_if { |i| i.raw["links"].detect{ |l| l["rel"] == "parent" } }
  scount = 0
  instances.each do |i|
    rname = "instance_" + (scount+=1).to_s
    cat += instance_to_cat(i, rname)
    resources << rname
  end

  cat += launch_operation(concurrent, resources) if @deployment_inputs || concurrent

  cat
end

def launch_operation( concurrent, resources )
  str = ""

  str += "operation 'launch' do \n"
  str += "  description 'Launch the application' \n"
  str += "  definition 'generated_launch' \n"
  str += "end \n"

  rlist = ""
  resources.each_with_index do |r, i|
    rlist += "@" + r
    rlist += ", " if i != resources.size - 1
  end 

  str += "define generated_launch("
  str += rlist if concurrent
  str += ") "
  str += " return #{rlist} " if concurrent
  str += " do \n"

  str += deployment_inputs_to_cat if @deployment_inputs
  str += concurrent_resource_launch(resources) if concurrent

  str += "end \n"
  str

end

def concurrent_resource_launch(resources) 
  puts "Creating concurrent launch code"

  str = ""

  resources.each do |r|
    str += "  @@global_" + r + " = @" + r + "\n"
  end

  str += "  concurrent do \n"
  resources.each do |r|
    str += "    provision(@@global_" + r + ")\n" 
  end
  str += "  end \n"

  resources.each do |r|
    str += "  @" + r + " = @@global_" + r + "\n"
  end

  str
end

def deployment_inputs_to_cat() 
  puts "Creating deployment-level inputs"

  str = "\n\n"

  inputs = @dep.raw["inputs"].select{ |i| i["value"] != "blank"}
  if inputs.size > 0
    str += "  $inp = {\n"
    inputs.each_with_index do |input, i|
      str += "    '" + input["name"] + "':'" + input["value"] + "'"
      str += "," if i != inputs.size - 1
      str += "\n"
    end
    str += "  } \n"
    str += "  @@deployment.multi_update_inputs(inputs: $inp) \n"
  else
    str += "  # No deployment level inputs found \n"
  end
  str
end

def deployment_to_cat_file( client, deployment_id, deployment_inputs, concurrent )

  # Get and show the deployment name
  dep = client.deployments(:id=>deployment_id).show
  puts "Exporting Deployment: " + dep.name

  # Output to a file named after the deployment (cleaned up for Linux filenames)
  File.open(dep.name.gsub(/[^\w\s_-]+/, '')+'.cat.rb','w') do |f|

    f.puts deployment_to_cat_string( client, deployment_id, deployment_inputs, concurrent)

  end

end
