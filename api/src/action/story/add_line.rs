use core::action::{ Action, Result };

// types
pub struct AddLine;

// impls
impl<'a> Action<'a, ()> for AddLine {
    fn call(&self) -> Result<'a, ()> {
        Ok(())
    }
}
