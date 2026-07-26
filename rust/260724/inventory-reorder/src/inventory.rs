use std::fmt;

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct InventoryItem {
    product_code: String,
    current_stock: i32,
    safety_stock: i32,
    incoming_stock: i32,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum InventoryDecision {
    Sufficient,
    WaitingForIncomingStock,
    ReorderRequired {
        recommended_quantity: i32,
    },
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub enum InventoryError {
    EmptyProductCode,
    NegativeCurrentStock(i32),
    NegativeSafetyStock(i32),
    NegativeIncomingStock(i32),
}

impl InventoryItem {
    pub fn new(
        product_code: impl Into<String>,
        current_stock: i32,
        safety_stock: i32,
        incoming_stock: i32,
    ) -> Result<Self, InventoryError> {
        let product_code = product_code.into();

        if product_code.trim().is_empty() {
            return Err(InventoryError::EmptyProductCode);
        }

        if current_stock < 0 {
            return Err(InventoryError::NegativeCurrentStock(current_stock),);
        }
        if safety_stock < 0 {
            return Err(InventoryError::NegativeSafetyStock(safety_stock),);
                }
        if incoming_stock < 0 {
            return Err(InventoryError::NegativeIncomingStock(incoming_stock),);
        }

        Ok(Self {
            product_code,
            current_stock,
            safety_stock,
            incoming_stock,
        })
    }

    pub fn product_code(&self) -> &str {
        &self.product_code
    }

    pub fn current_stock(&self) -> i32 {
        self.current_stock
    }

    pub fn safety_stock(&self) -> i32 {
        self.safety_stock
    }

    pub fn incoming_stock(&self) -> i32 {
        self.incoming_stock
    }
}

pub fn evaluate_inventory(
    item: &InventoryItem,
) -> Result<InventoryDecision, InventoryError> {
    if item.current_stock() >= item.safety_stock() {
        return Ok(InventoryDecision::Sufficient);
    }

    let available_after_incoming =
        item.current_stock() + item.incoming_stock();

    if available_after_incoming >= item.safety_stock() {
        return Ok(
            InventoryDecision::WaitingForIncomingStock,
        );
    }

    let recommended_quantity =
        item.safety_stock() - available_after_incoming;

    Ok(InventoryDecision::ReorderRequired {
        recommended_quantity,
    })
}

impl fmt::Display for InventoryError {
    fn fmt(
        &self,
        formatter: &mut fmt::Formatter<'_>,
    ) -> fmt::Result {
        match self {
            InventoryError::EmptyProductCode => {
                write!(formatter, "product code must not be empty")
            }

            InventoryError::NegativeCurrentStock(value) => {
                write!(
                    formatter,
                    "current stock must not be negative: {value}"
                )
            }

            InventoryError::NegativeSafetyStock(value) => {
                write!(
                    formatter,
                    "safety stock must not be negative: {value}"
                )
            }

            InventoryError::NegativeIncomingStock(value) => {
                write!(
                    formatter,
                    "incoming stock must not be negative: {value}"
                )
            }
        }
    }
}

impl std::error::Error for InventoryError {}
