#!/bin/bash

echo "Authenticating with the UCP cluster"

AUTHTOKEN=$(curl -sk -d '{"username":"admin","password":"orca"}' https://172.17.10.101/auth/login | jq -r .auth_token) && \
curl -k -H "Authorization: Bearer $AUTHTOKEN" https://172.17.10.101/api/clientbundle -o bundle.zip && \
unzip bundle.zip && rm -rf bundle.zip

echo "Creating JSON payload"

cat << EOF > ./docker.json
{
	"Hostname": "webapp",
	"Image": "scottyc/webapp:latest",
	"AttachStdin": false,
	"AttachStdout": true,
	"AttachStderr": true,
	"Tty": false,
	"OpenStdin": false,
	"StdinOnce": false,
	"Labels": {
               "interlock.hostname": "webapp",
               "interlock.domain": "ucp-demo.local"
    },
    "HostConfig": {
		"PortBindings": {
			"3000/tcp": [{
				"HostPort": ""
			}]

		}
	}
}  
EOF

echo "Creating container"

CONTAINER=$(curl -sk --cacert ca.pem --cert cert.pem --key key.pem -H "Content-Type: application/json" -X POST --data "@docker.json" https://172.17.10.101/v1.22/containers/create?name=webapp | jq -r '.Id')

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

