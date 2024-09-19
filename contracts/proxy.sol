// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @dev This abstract contract provides a fallback function that delegates all calls to another contract using the EVM
 * instruction `delegatecall`. The second contract is the _implementation_ contract (RoamCoin).
 *
 * Delegation to the implementation can be triggered manually via {_fallback} or {_delegate}.
 * The success and return data of the delegated call will be returned back to the external caller of the proxy.
 */
abstract contract Proxy {
    /**
     * @dev Delegates the current call to `implementation`.
     * This function does not return to its internal call site, it will return directly to the external caller.
     */
    function _delegate(address implementation) internal virtual {
        assembly {
            // Copy msg.data (call data)
            calldatacopy(0, 0, calldatasize())

            // Delegatecall to the implementation contract
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy returndata from the implementation contract
            returndatacopy(0, 0, returndatasize())

            // Check the result of the delegatecall
            switch result
            case 0 { revert(0, returndatasize()) }  // If failed, revert
            default { return(0, returndatasize()) } // If successful, return data
        }
    }

    /**
     * @dev This is a virtual function that should be overridden to return the address of the logic contract.
     */
    function _implementation() internal view virtual returns (address);

    /**
     * @dev Delegates the current call to the implementation returned by `_implementation()`.
     */
    function _fallback() internal virtual {
        _delegate(_implementation());
    }

    /**
     * @dev Fallback function that delegates all calls to the implementation contract.
     */
    fallback() external payable virtual {
        _fallback();
    }

    /**
     * @dev Receive function that delegates calls to the implementation contract.
     * It runs when Ether is sent to the contract without call data.
     */
    receive() external payable virtual {
        _fallback();
    }
}

contract RoamProxy is Proxy {
    // Storage slot for the address of the current implementation (RoamCoin contract)
    bytes32 private constant IMPLEMENTATION_SLOT = keccak256("org.roamcoin.proxy.implementation.address");

    // Storage slot for the address of the proxy owner
    bytes32 private constant PROXY_OWNER_SLOT = keccak256("org.roamcoin.proxy.owner.address");

    // Events
    event Upgraded(address indexed newImplementation);
    event ProxyOwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Modifier to restrict functions to the proxy owner.
     */
    modifier onlyProxyOwner() {
        require(msg.sender == proxyOwner(), "RoamProxy: caller is not the proxy owner");
        _;
    }

    /**
     * @dev Constructor that sets the initial logic contract and proxy owner.
     * @param initialImplementation Address of the initial logic contract (RoamCoin contract).
     */
    constructor(address initialImplementation) {
        _setImplementation(initialImplementation);  // Set the initial logic contract (RoamCoin)
        _setProxyOwner(msg.sender);  // Set the deployer as the proxy owner
    }

    /**
     * @dev Allows the proxy owner to upgrade the implementation contract (RoamCoin).
     * @param newImplementation The address of the new implementation contract.
     */
    function upgradeTo(address newImplementation) external onlyProxyOwner {
        require(newImplementation != address(0), "RoamProxy: new implementation is the zero address");
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    /**
     * @dev Allows the proxy owner to transfer ownership to a new owner.
     * @param newOwner The address of the new proxy owner.
     */
    function transferProxyOwnership(address newOwner) external onlyProxyOwner {
        require(newOwner != address(0), "RoamProxy: new owner is the zero address");
        emit ProxyOwnershipTransferred(proxyOwner(), newOwner);
        _setProxyOwner(newOwner);
    }

    /**
     * @dev Internal function to return the current implementation address.
     */
    function _implementation() internal view override returns (address impl) {
        bytes32 position = IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(position)
        }
    }

    /**
     * @dev Returns the current proxy owner address.
     */
    function proxyOwner() public view returns (address owner) {
        bytes32 position = PROXY_OWNER_SLOT;
        assembly {
            owner := sload(position)
        }
    }

    /**
     * @dev Internal function to set the implementation address in storage.
     */
    function _setImplementation(address newImplementation) private {
        bytes32 position = IMPLEMENTATION_SLOT;
        assembly {
            sstore(position, newImplementation)
        }
    }

    /**
     * @dev Internal function to set the proxy owner address in storage.
     */
    function _setProxyOwner(address newOwner) private {
        bytes32 position = PROXY_OWNER_SLOT;
        assembly {
            sstore(position, newOwner)
        }
    }
}
