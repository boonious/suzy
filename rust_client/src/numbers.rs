use serde::Deserialize;

#[derive(Debug, Deserialize)]
pub struct Numbers {
    numbers: Vec<Number>
}

impl Numbers {
    pub fn list(numbers: Numbers, mut writer: impl std::io::Write) {
        for num in numbers.numbers { Number::print(num, &mut writer) }
    }
}

#[derive(Debug, Deserialize)]
struct Number {
    value: u64,
    attrs: Vec<String>,
    cached: bool
}

impl Number {
    fn print(num: Number, mut writer: impl std::io::Write) {
        let _result = writeln!(writer, "{}{}{}", num.value, print(num.attrs), print_cached(num.cached));
    }
}

fn print_cached(cached: bool) -> &'static str {
    match cached {
        true => " cached",
        false => ""
    }
}

fn print(attrs: Vec<String>) -> &'static str {
    let attrs: Vec<&str> = attrs.iter().map(AsRef::as_ref).collect();

    match attrs[..] {
        ["mod_3"] => " Fizz",
        ["mod_5"] => " Buzz",
        ["mod_5", "mod_3"]  => " FizzBuzz",
        [] => "",
        _ => "<to do>"
    }
}

#[test]
fn list_numbers() {
    let nums = Numbers{
        numbers: vec![
            Number{value: 1, attrs: vec![], cached: false},
            Number{value: 3, attrs: vec![String::from("mod_3")], cached: false},
            Number{value: 5, attrs: vec![String::from("mod_5")], cached: true},
            Number{value: 15, attrs: vec![String::from("mod_5"), String::from("mod_3")], cached: false}
        ]
    };

    let mut result = Vec::new();
    Numbers::list(nums, &mut result);
    assert_eq!(result, b"1\n3 Fizz\n5 Buzz cached\n15 FizzBuzz\n");
}
