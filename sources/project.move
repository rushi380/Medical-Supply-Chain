module MyModule::MedicalSupplyChain1 {
    use aptos_framework::signer;
    use std::string::String;
    use aptos_framework::timestamp;
    
    /// Struct representing a medical supply item in the chain.
    struct MedicalSupply has store, key {
        item_id: u64,           // Unique identifier for the medical item
        item_name: String,      // Name of the medical supply (e.g., "Insulin", "Masks")
        manufacturer: address,  // Address of the manufacturer
        current_owner: address, // Current owner in the supply chain
        is_verified: bool,      // Whether the item has been verified as authentic
        created_at: u64,        // Timestamp when item was added to chain
        last_updated: u64,      // Last update timestamp
    }
    
    /// Function to register a new medical supply item in the chain.
    /// Only manufacturers can create new items.
    public fun register_medical_supply(
        manufacturer: &signer, 
        item_id: u64, 
        item_name: String
    ) {
        let manufacturer_addr = signer::address_of(manufacturer);
        let current_time = timestamp::now_seconds();
        
        let supply = MedicalSupply {
            item_id,
            item_name,
            manufacturer: manufacturer_addr,
            current_owner: manufacturer_addr,
            is_verified: true,  // Manufacturer items are verified by default
            created_at: current_time,
            last_updated: current_time,
        };
        
        move_to(manufacturer, supply);
    }
    
    /// Function to transfer ownership of medical supply to next party in chain.
    /// Updates ownership and verification status.
    public fun transfer_ownership(
        current_owner: &signer,
        supply_owner: address,
        new_owner: address,
        verify_item: bool
    ) acquires MedicalSupply {
        let supply = borrow_global_mut<MedicalSupply>(supply_owner);
        let current_owner_addr = signer::address_of(current_owner);
        
        // Ensure only current owner can transfer
        assert!(supply.current_owner == current_owner_addr, 1);
        
        // Update ownership and verification status
        supply.current_owner = new_owner;
        supply.is_verified = verify_item;
        supply.last_updated = timestamp::now_seconds();
    }
}