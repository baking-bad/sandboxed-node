TAG=v8.2-2

build:
	docker build -t bakingbad/sandbox:$(TAG) --build-arg TAG=$(TAG) .

run:
	docker run --rm -p 127.0.0.1:8732:8732 --name sandbox bakingbad/sandbox:$(TAG)

release:
	git tag $(TAG) -f && git push origin $(TAG) --force