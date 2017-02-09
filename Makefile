.PHONY: container build deploy build/clean documentation documentation/deploy

container: build
	docker build --tag kill-the-newsletter:latest .

build: kill-the-newsletter

kill-the-newsletter: kill-the-newsletter.go
	env GOOS=linux GOARCH=amd64 go build kill-the-newsletter.go

deploy: build
	ssh leafac.com 'cd leafac.com && docker-compose stop kill-the-newsletter && docker-compose rm --force kill-the-newsletter'
	rsync -av kill-the-newsletter leafac.com:leafac.com/kill-the-newsletter/kill-the-newsletter
	ssh leafac.com 'cd leafac.com && docker-compose build kill-the-newsletter && docker-compose up -d kill-the-newsletter'

build/clean:
	rm -f kill-the-newsletter

################################################################################

project = kill-the-newsletter

documentation: documentation/index.html

documentation/index.html: documentation/$(project).scrbl
	cd documentation && raco scribble --dest-name index -- $(project).scrbl

documentation/deploy: documentation
	rsync -av --delete documentation/ leafac.com:leafac.com/websites/software/$(project)/
