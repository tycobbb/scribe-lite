use action::{ Action, Result };

// types
pub struct AddLine;

// action
impl<'a> Action<'a, ()> for AddLine {
    fn call(&self) -> Result<'a, ()> {
        Ok(())
    }
}
