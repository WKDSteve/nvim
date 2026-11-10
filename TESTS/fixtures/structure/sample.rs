fn walk(items: &[i32]) {
    for item in items {
        if *item > 1 {
            println!("{}", item);
        }
    }
}
