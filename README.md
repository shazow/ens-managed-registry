# ENS Managed Registry

**Status**: Pre-production. Not audited, not deployed.

---

## Getting Started

```
$ nix develop  # or install foundry some other way
$ make test    # or `forge test`
```

## Overview

### `src/ManagedRegistrar.sol`

A simple managed registrar, allowing an admin to set namehash node to address
mappings.

Note: ENS operates on recursive domain component hashes ([namehash](https://docs.ens.domains/contract-api-reference/name-processing)) rather than DNS-style domain strings. Roughly speaking, `foo.example.eth`'s namehash is:

```
sha3(
    sha3(
        sha3(
            bytes32(0x0) + sha3("eth")
        ) + sha3("example")
    ) + sha3("foo")
)
```

When a client is resolving a domain, the namehash is provided.


### `src/Resolver.sol`

A wildcard ENS resolver that uses a registrar (like `ManagedRegistrar` above) as a backend.

Note: [Wildcard resolvers](https://docs.ens.domains/ens-improvement-proposals/ensip-10-wildcard-resolution) are different from the original ENS subnode-based resolver, which relied on registering every subdomain on ENS's central subnode registry. With wildcard resolvers, the client is expected to recursively attempt to find a resolver for each level until it succeeds: First `foo.example.eth`, if no resolver is registered then check `example.eth`, if no resolver then fall back to the default `eth` resolver.

### `src/extended/ManagedENSResolver.sol`

Builds on top of the basic Resolver, except it adds a wrapper `register(...)` helper which also performs subnode registering for each subdomain.

This is mainly to demonstrate what it would take to support even naive resolvers, and to measure the gas difference.

### `src/extended/ChildResolver.sol`

Wrapper around another Resolver which proxies all of the optional fields as available default values. If we want to maintain all of the set field values on today's production resolver without reapplying them to a new resolver's state, we can use this.

### `src/extended/ManagedRegistrarWithReverse.sol`

Builds on top of a basic ManagedRegistrar, but adds reverse name lookup registration. Some DApps use this to convert addresses to ENS names for display purposes.

Setting a name mapping is an additional call, with additional gas costs.

### `src/extended/PermitRegistrarWithReverse.sol`

Builds on top of ManagedRegistrarWithReverse, except the user pays for the gas costs of registering their subdomain. A signature oracle provides a signed digest that a user can use to claim a name. A reverse name mapping is set at the same time.


## License

MIT
