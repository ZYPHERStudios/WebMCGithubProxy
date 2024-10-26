if ! which docker > /dev/null 2>&1; then
    echo Docker is not found, installing it! Please enter your password if prompted
    sudo apt update -y > /dev/null 2>&1
    sudo apt install docker.io containerd -y > /dev/null 2>&1
fi

PORT=80

mkdir tmp > /dev/null 2>&1

touch tmp/nginx > /dev/null 2>&1

$(echo 'server {
    location / {
        proxy_pass http://dns.tortillagames.org;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_read_timeout 86400;
    }
}' > tmp/nginx) > /dev/null 2>&1

containername=nginx

docker run --name $containername -v "$(pwd)/tmp/nginx:/etc/nginx/conf.d/default.conf:ro" -p $PORT:80 -d nginx > /dev/null 2>&1

echo "Started Tortilla Proxy! Press CTRL+C to quit."

running=true

stop() {
    echo "Exiting!"
    docker stop $containername > /dev/null 2>&1
    docker rm $containername --force > /dev/null 2>&1
    rm -rf tmp > /dev/null 2>&1
    running=false
}

trap stop SIGINT

while $running; do
    sleep 1
done
