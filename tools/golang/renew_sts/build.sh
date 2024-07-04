GOOS=linux GOARCH=amd64 go build -o renew_sts main.go

docker build -t yakirkkyang/goto-renew-sts:latest .
docker push yakirkkyang/goto-renew-sts:latest
