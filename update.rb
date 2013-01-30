require 'rubygems'
require 'fog'
require 'pp'
require 'json'
require 'net/http'


dns = Fog::DNS.new({
  :provider               => 'AWS',
  :aws_access_key_id      => 'xxxxxxxxxxxxx',
  :aws_secret_access_key  => 'xxxxxxxxxxxxxxxxxxxxxxxx'
})

newSet = ''
dynRecord = '' #set the record you want to check and update here

ipUrl = 'icanhazip.com'
#ipUrl = 'ip.appspot.com'

req = Net::HTTP::Get.new('/')
res = Net::HTTP.start('icanhazip.com', 80) {|http|
  http.request(req)
}
newIp = res.body.strip

targetZone = 'xxxxxxxxxxx' #target hostedzone

myzone = dns.get_hosted_zone(targetZone)

recordSets = dns.list_resource_record_sets(targetZone)

rs = recordSets.body['ResourceRecordSets']

rs.each do |set|
	if set['Name'] == dynRecord
		newSet = set
	end
end

oldIp = newSet['ResourceRecords'][0]
oldTTL = newSet['TTL']

change_batch_options = [
  {
    :action => "DELETE",
    :name => dynRecord,
    :type => "A",
    :ttl => oldTTL,
    :resource_records => [ oldIp ]
  },
  {
    :action => "CREATE",
    :name => dynRecord,
    :type => "A",
    :ttl => oldTTL,
    :resource_records => [ newIp ]
  }
]


if oldIp != newIp
	dns.change_resource_record_sets(targetZone,change_batch_options)
	puts "#{dynRecord} IP updated from #{oldIp} to #{newIp}"
else
	puts "#{dynRecord} IP is already #{oldIp}, no update needed"
end
