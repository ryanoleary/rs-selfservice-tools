

def get_value(input_val)
	if input_val.is_a?(Hash)
		out_val = convert_ref(input_val["Ref"]) if input_val["Ref"] != nil
		out_val = convert_fn_equals(input_val["Fn::Equals"]) if input_val["Fn::Equals"] != nil
		out_val = convert_fn_and(input_val["Fn::And"]) if input_val["Fn::And"] != nil
		out_val = convert_fn_or(input_val["Fn::Or"]) if input_val["Fn::Or"] != nil
		out_val = convert_fn_not(input_val["Fn::Not"]) if input_val["Fn::Not"] != nil
		out_val = convert_fn_if(input_val["Fn::If"]) if input_val["Fn::If"] != nil
		out_val = convert_fn_find_in_map(input_val["Fn::FindInMap"]) if input_val["Fn::FindInMap"] != nil
	else
		out_val = "\"" + input_val + "\""
	end
	out_val
end

def convert_resources(resources, source)
	resblock = []
	resources.each do |r|
		resblock << convert_resource(r, source)
	end
	resblock.join("\n\n")
end

def convert_resource(r, source)
	rblock = []
	case r[1]["Type"]
	when "AWS::EC2::SecurityGroup"
		rblock << convert_resource_security_group(r, source) 
	when "AWS::EC2::SecurityGroupIngress"
		r[1]["Properties"]["GroupId"] != nil ? grp = get_value(r[1]["Properties"]["GroupId"]) : grp = get_value(r[1]["Properties"]["GroupName"])
		rblock << convert_resource_security_group_rule(r[0], "ingress", r[1]["Properties"], grp)
	when "AWS::EC2::SecurityGroupEgress"
		rblock << convert_resource_security_group_rule(r[0], "egress", r[1]["Properties"], getValue(r[1]["Properties"]["GroupId"]))
	when "AWS::AutoScaling::AutoScalingGroup"
		rblock << convert_resource_auto_scaling_group(r)
	when "AWS::AutoScaling::LaunchConfiguration"
		rblock << convert_resource_auto_scaling_launch_configuration(r)
	when "AWS::ElasticLoadBalancing::LoadBalancer"
		rblock << convert_resource_elb(r)
	else 
		rblock << "# Type " + r[1]["Type"] + " not yet supported"
	end
	rblock.join("\n")
end

def convert_resource_elb(r)
	elb = []
	elb << "resource \"" + r[0] + "\", type:\"aws_elb\" do"
	elb << "  name \"" + r[0] + "\""
	elb << "  condition $" + r[1]["Condition"] if r[1]["Condition"] != nil
	if r[1]["Properties"]["SecurityGroups"] != nil
		sgs = "  security_groups "
		r[1]["Properties"]["SecurityGroups"].each_with_index do |sg,i|
			sgs = sgs + get_value(sg)
			sgs = sgs + "," if i != r[1]["Properties"]["SecurityGroups"].size - 1
		end
		elb << sgs
	end	
	elb << "  subnets " + get_value(r[1]["Properties"]["Subnets"]) if r[1]["Properties"]["Subnets"] != nil
	if r[1]["Properties"]["Listeners"] != nil
		ls = []
		ls << "  listeners [ "
		r[1]["Properties"]["Listeners"].each_with_index do |l,i|
			ls << "    {"
			ls << "      frontend_port     => " + l["LoadBalancerPort"] if l["LoadBalancerPort"] != nil 
			ls << "      frontend_protocol => \"" + l["Protocol"] + "\"" if l["Protocol"] != nil 
			ls << "      backend_port      => " + l["InstancePort"] if l["InstancePort"] != nil 
			ls << "      backend_protocol  => \"" + l["InstanceProtocol"] + "\"" if l["InstanceProtocol"] != nil 
			ls << "    },"
		end
		ls << "  ]"
		ls.join("\n")
		elb << ls
	end	
  
	elb << "end"
	elb.join("\n")
end

# For this we create a resource that will never launch, but whose properties will still be inheritd by others
def convert_resource_auto_scaling_launch_configuration(r)
	lc = []
	lc << "resource \"" + r[0] + "\", type: \"server_array\" do"
	lc << "  condition false"
	lc << "  instance_type " + get_value(r[1]["Properties"]["InstanceType"]) if r[1]["Properties"]["InstanceType"] != nil
	lc << "  iam_instance_profile " + get_value(r[1]["Properties"]["IamInstanceProfile"]) if r[1]["Properties"]["IamInstanceProfile"] != nil
	lc << "  ssh_key " + get_value(r[1]["Properties"]["KeyName"]) if r[1]["Properties"]["KeyName"] != nil
	lc << "  image " + get_value(r[1]["Properties"]["ImageId"]) if r[1]["Properties"]["ImageId"] != nil
	if r[1]["Properties"]["SecurityGroups"] != nil
		sgs = "  security_groups "
		r[1]["Properties"]["SecurityGroups"].each_with_index do |sg,i|
			sgs = sgs + get_value(sg)
			sgs = sgs + "," if i != r[1]["Properties"]["SecurityGroups"].size - 1
		end
		lc << sgs
	end
	lc << "  instance_type " + get_value(r[1]["Properties"]["InstanceType"]) if r[1]["Properties"]["InstanceType"] != nil
	lc << "  # Skipping userdata for now"
	lc << "end"
	lc.join("\n")
end

def convert_resource_auto_scaling_group(r)
	asg = []
	asg << "resource \"" + r[0] + "\", type: \"server_array\" do"
	asg << "  condition $" + r[1]["Condition"] if r[1]["Condition"] != nil
	if r[1]["Properties"]["AvailabilityZones"] != nil 
	end
	asg << "end"
	asg.join("\n")
end

def convert_resource_security_group(r, source)
	sg = []
	sg << "resource \"" + r[0] + "\", type: \"security_group\" do"
	sg << "  name \"" + r[0] + "\""
	sg << "  condition $" + r[1]["Condition"] if r[1]["Condition"] != nil
	sg << "  description \"" + r[1]["Properties"]["GroupDescription"] + "\"" if r[1]["Properties"]["GroupDescription"] != nil
	sg << "  network " + get_value(r[1]["Properties"]["VpcId"]) if r[1]["Properties"]["VpcId"] != nil
	sg << "  # Tags are not supported on sec groups" if r[1]["Properties"]["Tags"] != nil
	sg << "end"
	sg << convert_resource_security_group_rules(r[1]["Properties"]["SecurityGroupEgress"], "egress", r[0]) if r[1]["Properties"]["SecurityGroupEgress"] != nil 
	sg << convert_resource_security_group_rules(r[1]["Properties"]["SecurityGroupIngress"], "ingress", r[0]) if r[1]["Properties"]["SecurityGroupIngress"] != nil 
	sg.join("\n")
end

def convert_resource_security_group_rules(rules, type, name)
	sgrs = []
	rules.each_with_index do |r,i|
		sgrs << convert_resource_security_group_rule(name + " - " + (i+1).to_s, type, r, "@"+name)
	end
	sgrs.join("\n")
end

def convert_resource_security_group_rule(name, type, r, sg_name)
	sgr = []
  sgr << "resource \"" + name + "\", type: \"security_group_rule\" do"
	sgr << "  security_group " + sg_name
	sgr << "  direction \"" + type + "\""
	r["CidrIp"] != nil ? sgr << "  source_type \"cidr_ips\"" : sgr << "  source_type \"group\""
	sgr << "  cidr_ips \"" + r["CidrIp"] + "\"" if r["CidrIp"] != nil
	sgr << "  start_port \"" + r["FromPort"] + "\"" if r["FromPort"] != nil
	sgr << "  end_port \"" + r["ToPort"] + "\"" if r["ToPort"] != nil
	sgr << "  protocol \"" + r["IpProtocol"] + "\"" if r["IpProtocol"] != nil
	sgr << "  group_name " + get_value(r["SourceSecurityGroupId"]) if r["SourceSecurityGroupId"] != nil
	sgr << "  group_name " + get_value(r["SourceSecurityGroupName"]) if r["SourceSecurityGroupName"] != nil
	sgr << "  group_owner \"" + get_value(r["SourceSecurityGroupOwnerId"]) + "\"" if r["SourceSecurityGroupOwnerId"] != nil
	sgr << "end"
	sgr.join("\n")
end

def convert_conditions(conditions)
	condsblock = []
	conditions.each do |c|
		condsblock << convert_condition(c)
	end
	condsblock.join("\n\n")
end

def convert_condition(condition)
	cblock = []
	cblock << "condition \"" + condition[0] + "\" do"
	cblock << get_value(condition[1]) 
	cblock << "end"
	cblock.join("\n")
end

def convert_mappings(mappings)
	mappingsblock = []
	mappings.each do |m|
		mappingsblock << convert_mapping(m)
	end
	mappingsblock.join("\n\n")
end

def convert_mapping(mapping)
	mblock = []
	mblock << "mapping \"" + mapping[0] + "\" do {"
	mapping[1].each do |n|
		mblock << "  \"" + n[0] + "\" => {"
		n[1].each do |v|
			if v[1].is_a?(Array)
				mblock << "    \"" + v[0] + "\" => " + v[1].to_s + ","
			else
				mblock << "    \"" + v[0] + "\" => \"" + v[1].to_s + "\","
			end
		end
		mblock << "  },"
	end
	mblock << "} end"
	mblock.join("\n")
end

def convert_params(params)
	paramsblock = []
	params.each do |p|
		paramsblock << convert_param(p)
	end
	paramsblock.join("\n\n")
end

def convert_param(param)
	pblock = []
	pblock << "parameter \"" + param[0] + "\" do"

	pblock << "  label \"" + param[0] + "\""

	case param[1]["Type"]
	when "String"
		pblock << "  type \"string\""
	when "Number"
		pblock << "  type \"number\""
	when "CommaDelimitedList"
		pblock << "  type \"list\""
	end
	
	pblock << "  default \"" + param[1]["Default"] + "\"" if  param[1]["Default"] != nil
	pblock << "  no_echo \"" + param[1]["NoEcho"] + "\"" if  param[1]["NoEcho"] != nil

	if param[1]["AllowedValues"] != nil
		vv = "  allowed_values "
		param[1]["AllowedValues"].each_with_index do |av,i|
			vv = vv + "\"" + av + "\""
			vv = vv + "," if i != param[1]["AllowedValues"].size - 1
		end
		pblock << vv
	end

	pblock << "  allowed_pattern \"" + param[1]["AllowedPattern"] + "\"" if  param[1]["AllowedPattern"] != nil
	pblock << "  min_length " + param[1]["MinLength"] if  param[1]["MinLength"] != nil
	pblock << "  max_length " + param[1]["MaxLength"] if  param[1]["MaxLength"] != nil
	pblock << "  max_value " + param[1]["MaxValue"] if  param[1]["MaxValue"] != nil
	pblock << "  min_value " + param[1]["MinValue"] if  param[1]["MinValue"] != nil
	pblock << "  description \"" + param[1]["Description"] +"\"" if  param[1]["Description"] != nil
	pblock << "  constraint_description \"" + param[1]["ConstraintDescription"] + "\"" if  param[1]["ConstraintDescription"] != nil

	pblock << "end"
	pblock.join("\n")
end

def convert_ref(ref)
	# If it refers to a parameter, it needs a $, a resource needs a @
	if $obj["Resources"][ref] != nil
		txt = "@" + ref
	elsif ref.start_with?("AWS::")
		txt = "AWS:: ref types not yet supported"
	else
		txt = "$" + ref
	end
	txt
end

def convert_fn_equals(content)
	"  equals?(" + get_value(content[0]) + "," + get_value(content[1]) + ")"
end

def convert_fn_and(content)
	"  logic_and(" + get_value(content[0]) + "," + get_value(content[1]) + ")"
end

def convert_fn_or(content)
	"  logic_or(" + get_value(content[0]) + "," + get_value(content[1]) + ")"
end

def convert_fn_not(content)
	"  logic_not(" + get_value(content[0]) + ")"
end

def convert_fn_find_in_map(content)
	"  map( $" + content[0] + ", " + get_value(content[1]) + ", " + get_value(content[2]) + ")"
end

def convert_fn_if(content)
	"  # IF is not yet supported "
end

def convert_cft_to_cat(json, output_file, cat_name)
	# Need a better solution here, but need this in certain cases and don't want to pass it around
	$obj = JSON.parse(json)

	File.open(output_file, 'w') do |c|

	c.puts "name \"" + cat_name + "\""
	c.puts "rs_ca_ver 20131202"

	desctext = $obj["Description"] != nil ? $obj["Description"] : name
	# c.puts "short_description \"" + obj["Description"] + "\"\n"
	c.puts "short_description \"" + desctext + "\"\n\n"

	paramstext = convert_params($obj["Parameters"]) if $obj["Parameters"] != nil

	condstext = convert_conditions($obj["Conditions"]) if $obj["Conditions"] != nil

	mappingstext = convert_mappings($obj["Mappings"]) if $obj["Mappings"] != nil

	resourcestext = convert_resources($obj["Resources"], $obj) # Required by definition


	c.puts "\n\n#################\nPARAMETERS\n#################\n\n"
	c.puts paramstext
	c.puts "\n\n#################\nMAPPINGS\n#################\n\n"
	c.puts mappingstext
	c.puts "\n\n#################\nCONDITIONS\n#################\n\n"
	c.puts condstext
	c.puts "\n\n#################\nRESOURCES\n#################\n\n"
	c.puts resourcestext

	end

end