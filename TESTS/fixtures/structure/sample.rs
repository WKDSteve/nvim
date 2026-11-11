struct Walker;

impl Walker {
    fn walk(&self, items: &[i32]) {
        for item in items {
            match *item {
                1 => println!("one"),
                _ => {}
            }
        }
    }
}
