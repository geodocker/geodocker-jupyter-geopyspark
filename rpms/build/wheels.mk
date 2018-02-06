wheels: archives/ipykernel.zip
	docker run -it --rm \
          -v $(shell pwd)/archives:/archives:ro \
          -v $(shell pwd)/wheel:/wheel:rw \
          -v $(shell pwd)/scripts:/scripts:ro \
          $(GCC6IMAGE) /scripts/wheel.sh $(shell id -u) $(shell id -g)
