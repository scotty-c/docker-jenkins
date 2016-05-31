#!/bin/bash

echo "Authenticating with the UCP cluster"

AUTHTOKEN=$(curl -sk -d '{"username":"admin","password":"orca"}' https://172.17.10.101/auth/login | jq -r .auth_token) && \
curl -k -H "Authorization: Bearer $AUTHTOKEN" https://172.17.10.101/api/clientbundle -o bundle.zip && \
unzip bundle.zip && rm -rf bundle.zip

echo "Creating JSON payload"

IP=$(hostname -i)

cat << EOF > ./docker.json
{
	"Hostname": "consul",
	"Image": "scottyc/consul:latest",
	"AttachStdin": false,
	"AttachStdout": true,
	"AttachStderr": true,
	"Tty": false,
	"OpenStdin": false,
	"StdinOnce": false,
	"Cmd": ["-bootstrap-expect", "1",
		    "--advertise", "$IP", 
            "-server",
		    "-dc", "gotham",
		    "-bind", "0.0.0.0"
	],

	"HostConfig": {
		"PortBindings": {
			"8500/tcp": [{
				"HostPort": "8500"
			}]
		}
	}
}  
EOF

echo "Creating container"

CONTAINER=$(curl -sk --cacert ca.pem --cert cert.pem --key key.pem -H "Content-Type: application/json" -X POST --data "@docker.json" https://172.17.10.101/v1.22/containers/create?name=consul | jq -r '.Id')

echo $CONTAINER


echo "Staring conatiner $CONTAINER" 
curl -sk --cacert ca.pem --cert cert.pem --key key.pem  -X POST https://172.17.10.101/v1.22/containers/$CONTAINER/start



echo "Cleaning workspace"

rm -rf ./docker.json
rm -rf *.pem
rm -rf *.pub
rm -rf env.sh
rm -rf *.ps1
rm -rf *.cmd

