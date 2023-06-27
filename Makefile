build:
	forge build

test:
	forge test --offline -vv

gas-report:
	NUM=100 forge test --offline --gas-report --match-test "test_Set|test_Multiset|test_RegisterWithPermit"

fork:
	anvil --fork-url "$(ETH_RPC_URL)"

deploy:
	# ENV should include ETH_RPC_URL, ETH_PRIVATE_KEY, ETH_OWNER_ADDRESS
	forge script script/ManagedENSResolver.s.sol:Deploy --rpc-url "$(ETH_RPC_URL)" --broadcast --verify -vvvv

# Call `make fork` and grab one of the forked private keys
#   export ETH_PRIVATE_KEY="0x..."
# Note that this will produce a ./broadcast output
deploy-forked:
	forge script script/ManagedENSResolver.s.sol:Deploy --rpc-url "http://127.0.0.1:8545" --broadcast -vvvv

.PHONY: test build
