TAG=`cat octez_version`


build:
	docker build -t bakingbad/sandboxed-node:$(TAG) --build-arg TAG=$(TAG) --progress=plain .

run:
	docker run --rm -p 127.0.0.1:8732:8732 --name sandbox bakingbad/sandboxed-node:$(TAG)

release:
	git tag $(TAG) -f && git push origin $(TAG) --force
