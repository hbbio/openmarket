GOERLI_RPC="https://goerli.infura.io/v3/9aa3d95b3bc440fa88ea12eaa4456161"
POLYGON_RPC="https://polygon.llamarpc.com"
CONTRACT=OpenMarket

.PHONY: deploy json install test deploynft

null:
    @:

# update forge and git subs
update:
	cargo install --git https://github.com/foundry-rs/foundry --profile local --locked foundry-cli
	forge update

test:
	forge test


deploygoerli: test
	forge create \
		--json \
		--rpc-url "$(GOERLI_RPC)" \
		--private-key "$(DEPLOY_KEY)" \
		src/$(CONTRACT).sol:$(CONTRACT) > gen/outnft.json

deploy: test
	forge create \
		--json \
		--rpc-url "$(POLYGON_RPC)" \
		--private-key "$(DEPLOY_KEY_POLY)" \
		src/$(CONTRACT).sol:$(CONTRACT) > gen/outnft_poly.json


jsonnft:
	@mkdir -p gen
	jq \
		--arg ADDR `cat gen/outnft.json | jq -r .deployedTo` \
		--arg QUOTE `cat out/$(CONTRACT).sol/$(CONTRACT).json | jq -c '.abi'` \
		'.contracts[0].addr.addr=$$ADDR | .contracts[0].abi.abi=$$QUOTE' \
		gen/$(CONTRACT).json | sponge gen/$(CONTRACT).json

