#!/bin/bash
#script to pull the ip addresses of well known sinkholes
#from the maltrail site to keep up to date with sinkhole IP

#sample crontab
# maltrail sinkhole domain downloads
# 22 3 * * * /root/rsa-maltrail-sinkhole-script/script-rsa-wellknown-sinkhole.sh

#location for tmp file processing
sink_tmp="/tmp"
#name of the file in the feed file (feed.name)
feed_name="sinkhole_ip"
#combined sinkhole indicator filename
sink_output_file=$feed_name".csv"

#webroot for SA feeds directory
rsa_feed_webroot="/var/netwitness/srv/www/"
# rsa_feed_webroot="/var/www/html/"

# sinkhole root webdirectory github
sinkhole_git_root="https://raw.githubusercontent.com/stamparm/maltrail/master/trails/static/malware/"

# sinkhole txt files to grab from maltrail site and processing
sinkhole_urls=("sinkhole_abuse.txt"
"sinkhole_anubis.txt"
"sinkhole_arbor.txt"
"sinkhole_bitdefender.txt"
"sinkhole_blacklab.txt"
"sinkhole_botnethunter.txt"
"sinkhole_certgovau.txt"
"sinkhole_certpl.txt"
"sinkhole_checkpoint.txt"
"sinkhole_cirtdk.txt"
"sinkhole_conficker.txt"
"sinkhole_cryptolocker.txt"
"sinkhole_drweb.txt"
"sinkhole_dynadot.txt"
"sinkhole_dyre.txt"
"sinkhole_farsight.txt"
"sinkhole_fbizeus.txt"
"sinkhole_fitsec.txt"
"sinkhole_fnord.txt"
"sinkhole_gameoverzeus.txt"
"sinkhole_georgiatech.txt"
"sinkhole_gladtech.txt"
"sinkhole_honeybot.txt"
"sinkhole_kaspersky.txt"
"sinkhole_microsoft.txt"
"sinkhole_rsa.txt"
"sinkhole_secureworks.txt"
"sinkhole_shadowserver.txt"
"sinkhole_sidnlabs.txt"
"sinkhole_sinkdns.txt"
"sinkhole_sugarbucket.txt"
"sinkhole_supportintel.txt"
"sinkhole_tech.txt"
"sinkhole_tsway.txt"
"sinkhole_unknown.txt"
"sinkhole_virustracker.txt"
"sinkhole_wapacklabs.txt"
"sinkhole_zinkhole.txt")

#sinkhole indicator download
for sink_link in "${sinkhole_urls[@]}"
do
        cd $sink_tmp && curl -O $sinkhole_git_root$sink_link 2> /dev/null
        echo $sinkhole_git_root$sink_link
done

echo "SINKHOLE - downloaded sinkhole raw files from github "

#create the header line that will be added to the indicator file on line 1
csv_header="#ip,#ioc,#feed.name"
#write the initial file and first line
echo $csv_header > $sink_output_file

#check all the files and extract the filename as a column of data for the files to append to create a feed of IP
for sink_file in $sink_tmp/sinkhole_*.txt
do
        echo $sink_file

                #get me the filename for adding to csv
                filename=$(basename "$sink_file")
                fname="${filename%.*}"
                echo $fname

                #create the names to use later
                filtered_name=$sink_tmp/"filtered_"$fname".txt"

                #create the columns that will be used in the combined output file
                csv_columns=","$fname","$feed_name

                # get me just the ip address lines
                cat $sink_file | grep -Eo "^([0-9]{1,3}[\.]){3}[0-9]{1,3}" > $filtered_name

                #iterate over the filtered file and concat the fields we need to add to the sinkhole csv
                while IFS= read -r var
                do
                        # write this to the combined sinkhole file with the added columns
                        #echo linebyline "$var""$csv_columns"
                        echo $var"$csv_columns" >> $sink_output_file

                done < "$filtered_name"
done

#copy the output file to the RSA web directory for recurring feed to read from
cp $sink_output_file $rsa_feed_webroot
echo "SINKHOLE - copied to web root "$rsa_feed_webroot$sink_output_file 
