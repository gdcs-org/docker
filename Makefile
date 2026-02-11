# Find all Dockerfile-<component> files and extract component names
COMPONENTS := $(patsubst Dockerfile-%,%,$(wildcard Dockerfile-*))

# Declare all targets as phony
.PHONY: $(COMPONENTS) $(addsuffix -up,$(COMPONENTS)) $(addsuffix -down,$(COMPONENTS)) $(addsuffix -restart,$(COMPONENTS)) auth_keys

# auth_keys target
auth_keys:
	@mkdir -p configs
	@cat ~/.ssh/*.pub > configs/authorized_keys
	@cat ~/.gitconfig > configs/.gitconfig
	@cat ~/.git-credentials > configs/.git-credentials

# Build target for each component
$(COMPONENTS): % : auth_keys
	docker build --network=host -f Dockerfile-$* -t $* .
	docker tag $* ghcr.io/stepherg/$*

# Up target for each component
$(addsuffix -up,$(COMPONENTS)): %-up :
	docker-compose -f compose-$*.yaml up -d

# Down target for each component
$(addsuffix -down,$(COMPONENTS)): %-down :
	docker-compose -f compose-$*.yaml down

# Down target for each component
$(addsuffix -stop,$(COMPONENTS)): %-stop :
	docker-compose -f compose-$*.yaml stop

# Restart target for each component
$(addsuffix -restart,$(COMPONENTS)): %-restart :
	docker-compose -f compose-$*.yaml restart