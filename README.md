#**TRANSPARENT PROXY CONTRACT SYSTEM**

##**What its about**

The transparent proxy allows the admin using the contract(Proxy Admin) to perform special functions that are onlu restricted and accessible by the deployer of the contract.
It also allows any other user apart from the admin to access functions from the implementation code using the delegate calls.
This proxy differentiates the calls that can be made by the admin from that of the user.

##**Components**

###**Proxy Contract**

- It uses EIP 1967 storage slots to store the admin and implementation address in special slots to avoid storage collision.
- Uses a modifier to check if the sender or user is the admin before accessing certain functions
- There's delegate call that allows the user to interact with the implementation contract through the proxy address.

###**Proxy Admin Contract**

- It holds the functions that only the admin can process or carry out
- Restricts who can perform upgrades or change admin to the contract owner.
- Provides read functions to inspect current implementation and admin addresses.
- Enhances security by centralizing upgrade permissions.

##**How it Works**

- Deploy the Logic Contract (e.g., nameRegistry & nameRegistry2).
- Deploy the Proxy Contract.
- Set the Logic Contract as Implementation:
 -Deploy ProxyAdmin with yourself as owner.
- Use ProxyAdmin to upgrade implementations or change admin
- Calls from non-admin addresses are forwarded to the logic contract.
- Admin calls can upgrade or change admin safely.

##**Advantages of Transparent Proxy Contract**

- Clear Separation: Admin functions do not interfere with user calls, preventing function selector clashes.
- Upgradeable: Logic can be upgraded without changing proxy address or losing storage.
- Uses EIP-1967 slots to prevent storage collision.
- Secure Admin Control: Centralized management via ProxyAdmin contract.

## References

- [Medium](https://solidity-by-example.org/app/upgradeable-proxy/)
- [Youtube](https://www.youtube.com/watch?v=CLhPUrxwP7k)



